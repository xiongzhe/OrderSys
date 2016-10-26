//
//  PerViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/20.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "PerViewController.h"
#import "TimeView.h"
#import "ButtonView.h"
#import "UUChart.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"

#define ROW IS_IPHONE && SCREEN_MAX_LENGTH >= 568.0 ? 44 : 44
#define CHART_HEIGHT IS_IPHONE && SCREEN_MAX_LENGTH >= 568.0 ? 160 : 150

/**
 * 
 **/
@interface PerViewController ()<UUChartDataSource,TimeViewDelegate>
{
    NSIndexPath *path;
    UUChart *chartLineView;
}

@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,retain) ButtonView *dayButton;//按天
@property(nonatomic,retain) ButtonView *monthButton;//按月
@property(nonatomic,retain) ButtonView *yearButton;//按年
@property(nonatomic,assign) NSInteger chooseType;//选择类型 0 按天 1 按月 2 按年

@property(nonatomic,retain) UIView *lineChartView;
@property(nonatomic,retain) ButtonView *alldayButton;//全天
@property(nonatomic,retain) ButtonView *lunchButton;//中餐
@property(nonatomic,retain) ButtonView *dinnerButton;//晚餐
@property(nonatomic,assign) NSInteger timesType;//时段类型 0 全天 1 中餐 2 晚餐

@property(nonatomic,retain) NSMutableArray *xTitles;//横坐标
@property(nonatomic,retain) NSMutableArray *yTitles;//纵坐标
@property(nonatomic,assign) CGFloat yMax;//纵坐标最大值

@end

@implementation PerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _chooseType = 0;
        _timesType = 0;
        
        self.title = @"人均消费分析";
        //设置导航栏
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        //条件按钮视图
        UIView *chooseView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT, SCREEN_WIDTH, ROW)];
        chooseView.backgroundColor = [UIColor whiteColor];
        
        CGFloat inset = (SCREEN_WIDTH - 70 * 3)/4;//按钮间隔
        //按天
        _dayButton = [[ButtonView alloc] initWithFrame:CGRectMake(inset, 8, 70, chooseView.frame.size.height - 16) withType:1 withTag:0 withTitle:@"按天"];
        [_dayButton addTarget:self action:@selector(clickChooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:_dayButton];
        //按月
        _monthButton = [[ButtonView alloc] initWithFrame:CGRectMake(_dayButton.frame.origin.x + _dayButton.frame.size.width + inset, 8, 70, chooseView.frame.size.height - 16) withType:0 withTag:1 withTitle:@"按月"];
        [_monthButton addTarget:self action:@selector(clickChooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:_monthButton];
        //按年
        _yearButton = [[ButtonView alloc] initWithFrame:CGRectMake(_monthButton.frame.origin.x + _monthButton.frame.size.width + inset, 8, 70, chooseView.frame.size.height - 16) withType:0 withTag:2 withTitle:@"按年"];
        [_yearButton addTarget:self action:@selector(clickChooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:_yearButton];
        
        [self.view addSubview:chooseView];
        
        //时间选择视图
        self.timeView = [[TimeView alloc] initWithHeight:chooseView.frame.origin.y + chooseView.frame.size.height withViewController:self];
        _timeView.delegate = self;
        [self.view addSubview:self.timeView];

        //时段条件按钮视图
        UIView *timesView = [[UIView alloc] initWithFrame:CGRectMake(0, _timeView.bottomY, SCREEN_WIDTH, ROW)];
        timesView.backgroundColor = [UIColor whiteColor];

        //全天
        _alldayButton = [[ButtonView alloc] initWithFrame:CGRectMake(inset, 8, 70, chooseView.frame.size.height - 16) withType:1 withTag:0 withTitle:@"全天"];
        [_alldayButton addTarget:self action:@selector(clickTimesType:) forControlEvents:UIControlEventTouchUpInside];
        [timesView addSubview:_alldayButton];
        //中餐
        _lunchButton = [[ButtonView alloc] initWithFrame:CGRectMake(_alldayButton.frame.origin.x + _alldayButton.frame.size.width + inset, 8, 70, timesView.frame.size.height - 16) withType:0 withTag:1 withTitle:@"中餐"];
        [_lunchButton addTarget:self action:@selector(clickTimesType:) forControlEvents:UIControlEventTouchUpInside];
        [timesView addSubview:_lunchButton];
        //晚餐
        _dinnerButton = [[ButtonView alloc] initWithFrame:CGRectMake(_lunchButton.frame.origin.x + _lunchButton.frame.size.width + inset, 8, 70, timesView.frame.size.height - 16) withType:0 withTag:2 withTitle:@"晚餐"];
        [_dinnerButton addTarget:self action:@selector(clickTimesType:) forControlEvents:UIControlEventTouchUpInside];
        [timesView addSubview:_dinnerButton];
        
        [self.view addSubview:timesView];

        UIView *showView = [[UIView alloc] initWithFrame:CGRectMake(0, timesView.frame.origin.y + timesView.frame.size.height + 5, SCREEN_WIDTH, NAV_HEIGHT - 10)];
        showView.backgroundColor = [UIColor clearColor];
        //收入曲线标识
        UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, showView.frame.size.height)];
        showLabel.text = @"    人均消费分析";
        showLabel.textColor = [UIColor redColor];
        showLabel.font = [UIFont systemFontOfSize:15.0];
        showLabel.backgroundColor = [UIColor clearColor];
        [showView addSubview:showLabel];
        [self.view addSubview:showView];
        
        //折线图表
        _xTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _yTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _lineChartView = [[UIView alloc] initWithFrame:CGRectMake(0, showView.frame.origin.y + showView.frame.size.height, SCREEN_WIDTH, CHART_HEIGHT + 10)];
        _lineChartView.backgroundColor = [UIColor whiteColor];
        chartLineView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _lineChartView.frame.size.width - 20, CHART_HEIGHT)  withSource:self withStyle:UUChartLineStyle];
        [chartLineView showInView:_lineChartView];
        [self.view addSubview:_lineChartView];

        //时间控件
        [self.timeView setTimePickerView];
        
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


//获取列表数据
-(void) getData {
    [_xTitles removeAllObjects];
    [_yTitles removeAllObjects];
    [chartLineView removeFromSuperview];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@,%@,%@",
                           [WHInterfaceUtil intToJsonString:@"group" withValue:(int)_chooseType],
                           [WHInterfaceUtil intToJsonString:@"timeQuantum" withValue:(int)_timesType],
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getConsumePerPerson" withParams:param];
        if (dics!=nil) {
            //人均消费分析曲线
            NSDictionary *Items = [dics objectForKey:@"Items"];
            if ((NSNull *) Items != [NSNull null]) {
                _yMax = 0;
                for (NSDictionary *key in Items) {
                    NSNumber *moneyRet = [key objectForKey:@"Money"];
                    float money;
                    long moneyLong = [moneyRet longValue];
                    if (moneyLong < 0) { //判断是否是负数
                        money = [moneyRet longValue]/-10000.0f;
                    } else {
                        money = [moneyRet longValue]/10000.0f;
                    }
                    NSString *time = [key objectForKey:@"Time"];
                    [_xTitles addObject:[NSString stringWithFormat:@"%@", time]];
                    [_yTitles addObject:[NSString stringWithFormat:@"%0.2f", money]];
                    if (money > _yMax) { //获取最大值
                        _yMax = money;
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                
                //数据重载，暂且，之后在做优化
                [chartLineView setHidden:NO];
                chartLineView = nil;
                chartLineView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _lineChartView.frame.size.width - 20, CHART_HEIGHT)  withSource:self withStyle:UUChartLineStyle];
                chartLineView.backgroundColor = [UIColor whiteColor];
                [chartLineView showInView:_lineChartView];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"无该时段记录"];
            });
        }
    });
}


//选择类型事件
-(IBAction)clickChooseType:(id)sender{
    UIButton *button = (UIButton *) sender;
    NSInteger tag = button.tag;
    switch (tag) {
        case 0:
            NSLog(@"按天");
            _chooseType = 0;
            [_dayButton setChooseType:1];
            [_monthButton setChooseType:0];
            [_yearButton setChooseType:0];
            break;
        case 1:
            NSLog(@"按月");
            _chooseType = 2;
            [_dayButton setChooseType:0];
            [_monthButton setChooseType:1];
            [_yearButton setChooseType:0];
            break;
        case 2:
            NSLog(@"按年");
            _chooseType = 3;
            [_dayButton setChooseType:0];
            [_monthButton setChooseType:0];
            [_yearButton setChooseType:1];
            break;
        default:
            break;
    }
    [self getData];
}

//选择时段类型事件
-(IBAction)clickTimesType:(id)sender{
    UIButton *button = (UIButton *) sender;
    NSInteger tag = button.tag;
    switch (tag) {
        case 0:
            NSLog(@"全天");
            _timesType = 0;
            [_alldayButton setChooseType:1];
            [_lunchButton setChooseType:0];
            [_dinnerButton setChooseType:0];
            break;
        case 1:
            NSLog(@"中餐");
            _timesType = 1;
            [_alldayButton setChooseType:0];
            [_lunchButton setChooseType:1];
            [_dinnerButton setChooseType:0];
            break;
        case 2:
            NSLog(@"晚餐");
            _timesType = 2;
            [_alldayButton setChooseType:0];
            [_lunchButton setChooseType:0];
            [_dinnerButton setChooseType:1];
            break;
        default:
            break;
    }
    [self getData];
}

#pragma mark  UUChartDataSource
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    return _xTitles;
}

//纵坐标数据数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    return @[_yTitles];
}

//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UURed,UUGreen,UUBrown];
}

//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(_yMax, 0);
}

#pragma mark 折线图专享功能

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return NO;
}


#pragma mark TimeViewDelegate
-(void) clickConfirm {
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
