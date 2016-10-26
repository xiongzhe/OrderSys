//
//  DishDetailViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/20.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishDetailViewController.h"
#import "TimeView.h"
#import "CommonInfo.h"
#import "ButtonView.h"
#import "UUChart.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"

/**
 * 菜品详细分析
 **/
@interface DishDetailViewController ()<UUChartDataSource, TimeViewDelegate>
{
    NSIndexPath *path;
    UUChart *chartView;
}

@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,retain) ButtonView *dayButton;//全天
@property(nonatomic,retain) ButtonView *lunchButton;//中餐
@property(nonatomic,retain) ButtonView *dinnerButton;//晚餐
@property(nonatomic,retain) UILabel *salesLabel;//销售量
@property(nonatomic,retain) UILabel *moneysLabel;//销售额
@property(nonatomic,retain) UIView *chartsView;

@property(nonatomic,retain) CommonInfo *commonInfo;//当前菜品信息
@property(nonatomic,assign) NSInteger timesType;//时段类型 0 全天 1 中餐 2 晚餐
@property(nonatomic,retain) NSMutableArray *ary;
@property(nonatomic,retain) NSMutableArray *xTitles;//横坐标
@property(nonatomic,retain) NSMutableArray *yAllDayTitles;//全天纵坐标
@property(nonatomic,retain) NSMutableArray *yLunchTitles;//中餐纵坐标
@property(nonatomic,retain) NSMutableArray *yDinnerTitles;//晚餐纵坐标

@end

@implementation DishDetailViewController


- (instancetype)initWithStime:(NSString *) stime withEtime:(NSString *) etime withDishesInfo:(CommonInfo *) commonInfo 
{
    self = [super init];
    if (self) {
        
        _commonInfo = commonInfo;
        _ary = [[NSMutableArray alloc] initWithCapacity:0];
        
        self.title = @"菜品详细分析";
        //设置导航栏
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        //时间选择视图
        self.timeView = [[TimeView alloc] initWithHeight:STATU_BAR_HEIGHT + NAV_HEIGHT + 5 withViewController:self];
        _timeView.delegate = self;
        [self.view addSubview:self.timeView];
        
        //时段视图
        UIView *timesView = [[UIView alloc] initWithFrame:CGRectMake(0, self.timeView.bottomY + 5, SCREEN_WIDTH, ROW_HEIGHT - 10)];
        timesView.backgroundColor = [UIColor clearColor];
        
        UILabel *timesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 60, timesView.frame.size.height)];
        timesLabel.text = @"时段:";
        timesLabel.font = [UIFont systemFontOfSize:15.0];
        timesLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        timesLabel.backgroundColor = [UIColor clearColor];
        [timesView addSubview:timesLabel];
        
        //全天
        _dayButton = [[ButtonView alloc] initWithFrame:CGRectMake(timesLabel.frame.origin.x + timesLabel.frame.size.width, 5, 50, timesView.frame.size.height - 10) withType:1 withTag:0 withTitle:@"全天"];
        [_dayButton addTarget:self action:@selector(clickTimesType:) forControlEvents:UIControlEventTouchUpInside];
        [timesView addSubview:_dayButton];
        
        //中餐
        _lunchButton = [[ButtonView alloc] initWithFrame:CGRectMake(_dayButton.frame.origin.x + _dayButton.frame.size.width + 20, 5, 50, timesView.frame.size.height - 10) withType:0 withTag:1 withTitle:@"中餐"];
        [_lunchButton addTarget:self action:@selector(clickTimesType:) forControlEvents:UIControlEventTouchUpInside];
        [timesView addSubview:_lunchButton];
        
        //晚餐
        _dinnerButton = [[ButtonView alloc] initWithFrame:CGRectMake(_lunchButton.frame.origin.x + _lunchButton.frame.size.width + 20, 5, 50, timesView.frame.size.height - 10) withType:0 withTag:2 withTitle:@"晚餐"];
        [_dinnerButton addTarget:self action:@selector(clickTimesType:) forControlEvents:UIControlEventTouchUpInside];
        [timesView addSubview:_dinnerButton];
        [self.view addSubview:timesView];
        
        //销售量
        UIView *salesView = [[UIView alloc] initWithFrame:CGRectMake(0, timesView.frame.origin.y + timesView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        salesView.backgroundColor = [UIColor whiteColor];
        
        UILabel *saleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 80, ROW_HEIGHT)];
        saleLabel.backgroundColor = [UIColor clearColor];
        saleLabel.textAlignment = NSTextAlignmentCenter;
        saleLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        saleLabel.text = @"销售量:";
        
        _salesLabel = [[UILabel alloc] initWithFrame:CGRectMake(saleLabel.frame.origin.x + saleLabel.frame.size.width + 20, 5, salesView.frame.size.width - saleLabel.frame.origin.x - saleLabel.frame.size.width - 10 - 75, saleLabel.frame.size.height - 10)];
        _salesLabel.backgroundColor = [UIColor whiteColor];
        _salesLabel.text = [NSString stringWithFormat:@"200"];
        _salesLabel.textColor = [UIColor redColor];
        
        UILabel *pan = [[UILabel alloc] initWithFrame:CGRectMake(_salesLabel.frame.origin.x + _salesLabel.frame.size.width + 5, 0, 20, salesView.frame.size.height)];
        pan.text = @"盘";
        pan.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [salesView addSubview:saleLabel];
        [salesView addSubview:_salesLabel];
        [salesView addSubview:pan];
        [self.view addSubview:salesView];

        //销售额
        UIView *moneyView = [[UIView alloc] initWithFrame:CGRectMake(0, salesView.frame.origin.y + salesView.frame.size.height + 0.5, SCREEN_WIDTH, ROW_HEIGHT)];
        moneyView.backgroundColor = [UIColor whiteColor];
        
        UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 80, ROW_HEIGHT)];
        moneyLabel.backgroundColor = [UIColor clearColor];
        moneyLabel.textAlignment = NSTextAlignmentCenter;
        moneyLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        moneyLabel.text = @"销售额:";
        
        _moneysLabel = [[UILabel alloc] initWithFrame:CGRectMake(moneyLabel.frame.origin.x + moneyLabel.frame.size.width + 20, 5, moneyView.frame.size.width - moneyLabel.frame.origin.x - moneyLabel.frame.size.width - 10 - 75, moneyLabel.frame.size.height - 10)];
        _moneysLabel.backgroundColor = [UIColor whiteColor];
        _moneysLabel.text = [NSString stringWithFormat:@"2000"];
        _moneysLabel.textColor = [UIColor redColor];
        
        UILabel *yuan = [[UILabel alloc] initWithFrame:CGRectMake(_moneysLabel.frame.origin.x + _moneysLabel.frame.size.width + 5, 0, 20, moneyView.frame.size.height)];
        yuan.text = @"元";
        yuan.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [moneyView addSubview:moneyLabel];
        [moneyView addSubview:_moneysLabel];
        [moneyView addSubview:yuan];
        [self.view addSubview:moneyView];
        
        
        _xTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _yAllDayTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _yLunchTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _yDinnerTitles = [[NSMutableArray alloc] initWithCapacity:0];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, moneyView.frame.origin.y + moneyView.frame.size.height + 10, SCREEN_WIDTH, 180)];
        view.backgroundColor = [UIColor clearColor];
        //柱状图表
        _chartsView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 160)];
        view.backgroundColor = [UIColor whiteColor];
        chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _chartsView.frame.size.width - 20, 150)  withSource:self withStyle:UUChartBarStyle];
        [chartView showInView:_chartsView];
        [view addSubview:_chartsView];
        [self.view addSubview:view];
        
        //时间控件
        [self.timeView setTimePickerView];
        _timeView.stimeText.text = stime;
        _timeView.etimeText.text = etime;
        _timeView.stime = stime;
        _timeView.etime = etime;

        [self getData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置导航栏返回按钮为白色
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //设置背景颜色
    self.view.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
}

//获取数据
-(void) getData {
    [_xTitles removeAllObjects];
    [_yAllDayTitles removeAllObjects];
    [_yDinnerTitles removeAllObjects];
    [_yLunchTitles removeAllObjects];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",
                           [WHInterfaceUtil intToJsonString:@"dishId" withValue:_commonInfo.typeId],
                           [WHInterfaceUtil intToJsonString:@"timeQuantum" withValue:_timesType],
                           [WHInterfaceUtil intToJsonString:@"group" withValue:0],
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getDishStat" withParams:param];
        if (dics!=nil) {
            int pan = [[dics objectForKey:@"SalesVolume"] integerValue];
            int money = [[dics objectForKey:@"Money"] integerValue];
            NSDictionary *Item = [dics objectForKey:@"Item"];
            for (NSDictionary *key in Item) {
                NSString *time = [key objectForKey:@"Time"];
                NSString *month = [time substringFromIndex:[time length] - 2];
                [_xTitles addObject:[NSString stringWithFormat:@"%@日", month]];
                //全天
                NSNumber *allDayRet = [key objectForKey:@"Money"];
                float allDayMoney = [allDayRet longValue]/10000.0f;
                [_yAllDayTitles addObject:[NSString stringWithFormat:@"%0.2f", allDayMoney]];
                //中餐
                NSNumber *lunchRet = [key objectForKey:@"MoneyLunch"];
                float lunchMoney = [lunchRet longValue]/10000.0f;
                [_yLunchTitles addObject:[NSString stringWithFormat:@"%0.2f", lunchMoney]];
                //晚餐
                NSNumber *dinnerRet = [key objectForKey:@"MoneyDinner"];
                float dinnerMoney = [dinnerRet longValue]/10000.0f;
                [_yDinnerTitles addObject:[NSString stringWithFormat:@"%0.2f", dinnerMoney]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                
                _salesLabel.text = [NSString stringWithFormat:@"%d", pan];
                _moneysLabel.text = [NSString stringWithFormat:@"%d", money];
                
                //数据重载，暂且，之后在做优化
                if (_timesType == 0) {
                    _ary = _yAllDayTitles;
                } else if (_timesType == 1) {
                    _ary = _yLunchTitles;
                } else {
                    _ary = _yDinnerTitles;
                }
                chartView = nil;
                chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _chartsView.frame.size.width - 20, 150)  withSource:self withStyle:UUChartBarStyle];
                chartView.backgroundColor = [UIColor whiteColor];
                [chartView showInView:_chartsView];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"无该菜品记录"];
            });
        }
    });
}


//选择时段类型事件
-(IBAction)clickTimesType:(id)sender{
    UIButton *button = (UIButton *) sender;
    NSInteger tag = button.tag;
    switch (tag) {
        case 0:
            NSLog(@"全天");
            _timesType = 0;
            [_dayButton setChooseType:1];
            [_lunchButton setChooseType:0];
            [_dinnerButton setChooseType:0];
            _ary = _yAllDayTitles;
            [chartView showInView:_chartsView];
            break;
        case 1:
            NSLog(@"中餐");
            _timesType = 1;
            [_dayButton setChooseType:0];
            [_lunchButton setChooseType:1];
            [_dinnerButton setChooseType:0];
            _ary = _yLunchTitles;
            [chartView showInView:_chartsView];
            break;
        case 2:
            NSLog(@"晚餐");
            _timesType = 2;
            [_dayButton setChooseType:0];
            [_lunchButton setChooseType:0];
            [_dinnerButton setChooseType:1];
            _ary = _yDinnerTitles;
            [chartView showInView:_chartsView];
            break;
        default:
            break;
    }
}

//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return _xTitles;
}

//纵坐标数据数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    return @[_ary];
}

//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UURed,UUGreen,UUBrown];
}

//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(50, 0);
}



#pragma mark TimeViewDelegate
-(void)clickConfirm {
    [self getData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
