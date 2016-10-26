//
//  ProfitInfoViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/3.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "ProfitInfoViewController.h"
#import "TimeView.h"
#import "UUChart.h"
#import "ButtonView.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "IncomeInfo.h"

#define ROW IS_IPHONE && SCREEN_MAX_LENGTH >= 568.0 ? 44 : 35

/**
 * 收入/支出/毛利分析
 **/
@interface ProfitInfoViewController ()<UUChartDataSource, TimeViewDelegate>
{
    NSIndexPath *path;
    UUChart *chartView;
}

@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,retain) UILabel *profitText;//收益总计
@property(nonatomic,retain) UILabel *topMonthLabel;//最高月份
@property(nonatomic,retain) UILabel *topText;//最高
@property(nonatomic,retain) UILabel *bottomMonthLabel;//最低月份
@property(nonatomic,retain) UILabel *bottomText;//最低
@property(nonatomic,retain) ButtonView *dayButton;//按天
@property(nonatomic,retain) ButtonView *monthButton;//按月
@property(nonatomic,retain) ButtonView *yearButton;//按年
@property(nonatomic,retain) UILabel *bottomTime;
@property(nonatomic,retain) UILabel *topTime;

@property(nonatomic,assign) NSInteger chooseType;//选择类型 0 按天 1 按月 2 按年
@property(nonatomic,retain) NSMutableArray *xTitles;//横坐标
@property(nonatomic,retain) NSMutableArray *yTitles;//纵坐标
@property(nonatomic,assign) CGFloat yMax;//纵坐标最大值
@property(nonatomic,retain) NSString *MaxTime;//最大值时间
@property(nonatomic,assign) NSInteger yMaxIndex;//纵坐标最大值所在index
@property(nonatomic,assign) CGFloat yMin;//纵坐标最小值
@property(nonatomic,retain) NSString *MinTime;//最小值时间
@property(nonatomic,assign) NSInteger yMinIndex;//纵坐标最小值所在index
@property(nonatomic,retain) UIView *chartsView;
@property(nonatomic,retain) NSString *unit;//单位名称
@property(nonatomic,assign) NSInteger unitLength; //截取单位长度

@end

@implementation ProfitInfoViewController

- (instancetype)initWithType:(int)type withStime:(NSString *) stime withEtime:(NSString *) etime
{
    self = [super init];
    if (self) {
        
        _MaxTime = @"20010101";
        _MinTime = @"20010101";
        _unitLength = 2;
        _unit = @"日";
        _type = type;
        _chooseType = 0;
        
        //设置导航栏
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        
        //条件按钮视图
        UIView *chooseView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT + 5, SCREEN_WIDTH, ROW)];
        chooseView.backgroundColor = [UIColor clearColor];
        
        CGFloat inset = (SCREEN_WIDTH - 60 * 3)/4;//按钮间隔
        //按天
        _dayButton = [[ButtonView alloc] initWithFrame:CGRectMake(inset, 5, 60, chooseView.frame.size.height - 10) withType:1 withTag:0 withTitle:@"按天"];
        [_dayButton addTarget:self action:@selector(clickChooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:_dayButton];
        //按月
        _monthButton = [[ButtonView alloc] initWithFrame:CGRectMake(_dayButton.frame.origin.x + _dayButton.frame.size.width + inset, 5, 60, chooseView.frame.size.height - 10) withType:0 withTag:1 withTitle:@"按月"];
        [_monthButton addTarget:self action:@selector(clickChooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:_monthButton];
        //按年
        _yearButton = [[ButtonView alloc] initWithFrame:CGRectMake(_monthButton.frame.origin.x + _monthButton.frame.size.width + inset, 5, 60, chooseView.frame.size.height - 10) withType:0 withTag:2 withTitle:@"按年"];
        [_yearButton addTarget:self action:@selector(clickChooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:_yearButton];
        
        [self.view addSubview:chooseView];
        
        //时间选择视图
        self.timeView = [[TimeView alloc] initWithHeight:chooseView.frame.origin.y + chooseView.frame.size.height + 5 withViewController:self];
        _timeView.delegate = self;
        [self.view addSubview:self.timeView];
        
        //收入总计
        UIView *profitView = [[UIView alloc] initWithFrame:CGRectMake(0, self.timeView.bottomY + 5, SCREEN_WIDTH, ROW)];
        profitView.backgroundColor = [UIColor whiteColor];
        
        UILabel *profitLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 80, profitView.frame.size.height)];
        profitLabel.backgroundColor = [UIColor clearColor];
        profitLabel.textAlignment = NSTextAlignmentLeft;
        profitLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _profitText = [[UILabel alloc] initWithFrame:CGRectMake(profitLabel.frame.origin.x + profitLabel.frame.size.width + 20, 5, profitView.frame.size.width - profitLabel.frame.origin.x - profitLabel.frame.size.width - 10 - 75, profitLabel.frame.size.height - 10)];
        _profitText.backgroundColor = [UIColor whiteColor];
        
        UILabel *yuan = [[UILabel alloc] initWithFrame:CGRectMake(_profitText.frame.origin.x + _profitText.frame.size.width + 5, 0, 20, profitView.frame.size.height)];
        yuan.text = @"元";
        yuan.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [profitView addSubview:profitLabel];
        [profitView addSubview:_profitText];
        [profitView addSubview:yuan];
        [self.view addSubview:profitView];

        
        _xTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _yTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _chartsView = [[UIView alloc] initWithFrame:CGRectMake(0, profitView.frame.origin.y + profitView.frame.size.height + 5, SCREEN_WIDTH, 160)];
        _chartsView.backgroundColor = [UIColor whiteColor];
        //柱状图表
        chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, _chartsView.frame.size.height - 10)  withSource:self withStyle:UUChartBarStyle];
        chartView.backgroundColor = [UIColor whiteColor];
        [chartView showInView:_chartsView];
        [self.view addSubview:_chartsView];
        
        //最高
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, _chartsView.frame.origin.y + _chartsView.frame.size.height + 5, SCREEN_WIDTH, ROW)];
        topView.backgroundColor = [UIColor whiteColor];
        
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 40, topView.frame.size.height)];
        topLabel.backgroundColor = [UIColor clearColor];
        topLabel.textAlignment = NSTextAlignmentLeft;
        topLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        topLabel.text = @"最高:";
        
        _topText = [[UILabel alloc] initWithFrame:CGRectMake(topLabel.frame.origin.x + topLabel.frame.size.width + 20, 5, topView.frame.size.width - topLabel.frame.origin.x - topLabel.frame.size.width - 10 - 155, topLabel.frame.size.height - 10)];
        _topText.backgroundColor = [UIColor whiteColor];
        _topText.text = [NSString stringWithFormat:@"+ 2000"];
        
        UILabel *topYuan = [[UILabel alloc] initWithFrame:CGRectMake(_topText.frame.origin.x + _topText.frame.size.width + 5, 0, 20, profitView.frame.size.height)];
        topYuan.text = @"元";
        topYuan.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        
        _topTime = [[UILabel alloc] initWithFrame:CGRectMake(topView.frame.size.width - 80 - 20, 0, 80, topView.frame.size.height)];
        _topTime.text = @"2015-01-01";
        _topTime.textAlignment = NSTextAlignmentRight;
        _topTime.font = [UIFont systemFontOfSize:14.0];
        _topTime.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [topView addSubview:topLabel];
        [topView addSubview:_topText];
        [topView addSubview:topYuan];
        [topView addSubview:_topTime];
        
        [self.view addSubview:topView];
        
        //最低
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.frame.origin.y + topView.frame.size.height, SCREEN_WIDTH, ROW)];
        bottomView.backgroundColor = [UIColor whiteColor];
        bottomView.layer.borderWidth = 0.5;
        bottomView.layer.borderColor = RGBColorWithoutAlpha(200, 200, 200).CGColor;
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, bottomView.frame.size.height)];
        bottomLabel.backgroundColor = [UIColor clearColor];
        bottomLabel.textAlignment = NSTextAlignmentLeft;
        bottomLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        bottomLabel.text = @"最低:";
        
        _bottomText = [[UILabel alloc] initWithFrame:CGRectMake(topLabel.frame.origin.x + topLabel.frame.size.width + 20, 5, topView.frame.size.width - topLabel.frame.origin.x - topLabel.frame.size.width - 10 - 155, topLabel.frame.size.height - 10)];
        _bottomText.backgroundColor = [UIColor whiteColor];
        _bottomText.text = [NSString stringWithFormat:@"+ 2000"];
        
        UILabel *bottomYuan = [[UILabel alloc] initWithFrame:CGRectMake(_bottomText.frame.origin.x + _bottomText.frame.size.width + 5, 0, 20, profitView.frame.size.height)];
        bottomYuan.text = @"元";
        bottomYuan.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        _bottomTime = [[UILabel alloc] initWithFrame:CGRectMake(bottomView.frame.size.width - 80 - 20, 0, 80, bottomView.frame.size.height)];
        _bottomTime.textAlignment = NSTextAlignmentRight;
        _bottomTime.font = [UIFont systemFontOfSize:14.0];
        _bottomTime.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [bottomView addSubview:bottomLabel];
        [bottomView addSubview:_bottomText];
        [bottomView addSubview:bottomYuan];
        [bottomView addSubview:_bottomTime];
        [self.view addSubview:bottomView];
        
        
        //时间控件
        [self.timeView setTimePickerView];
        _timeView.stimeText.text = stime;
        _timeView.etimeText.text = etime;
        _timeView.stime = stime;
        _timeView.etime = etime;
        
        if (type == 0) {
            self.title = @"收入分析";
            profitLabel.text = @"收入总计:";
            _profitText.textColor = [UIColor redColor];
            _topText.textColor = [UIColor redColor];
            _bottomText.textColor = [UIColor redColor];
        } else if (type == 1) {
            self.title = @"支出分析";
            profitLabel.text = @"支出总计:";
            _profitText.textColor = [UIColor greenColor];
            _topText.textColor = [UIColor greenColor];
            _bottomText.textColor = [UIColor greenColor];
        } else {
            self.title = @"毛利分析";
            profitLabel.text = @"毛利总计:";
            _profitText.textColor = [UIColor redColor];
            _topText.textColor = [UIColor redColor];
            _bottomText.textColor = [UIColor redColor];
        }
        
        [self getTotalData];
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
-(void)getData{
    [_xTitles removeAllObjects];
    [_yTitles removeAllObjects];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@,%@,%@",
                           [WHInterfaceUtil intToJsonString:@"group" withValue:_chooseType],
                           [WHInterfaceUtil intToJsonString:@"type" withValue:_type],
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getIncomeListStat" withParams:param];
        if (dics!=nil) {
            _yMax = 0;
            _yMin = 1000000000;
            
            int i=-1;
            for (NSDictionary *key in dics) {
                NSNumber *moneyRet = [key objectForKey:@"Money"];
                float money;
                long moneyLong = [moneyRet longValue];
                if (moneyLong < 0) { //判断是否是负数
                    money = [moneyRet longValue]/-10000.0f;
                } else {
                    money = [moneyRet longValue]/10000.0f;
                }
                NSString *time = [key objectForKey:@"Time"];
                NSString *day = [time substringFromIndex:[time length] - _unitLength];
                [_xTitles addObject:[NSString stringWithFormat:@"%@%@", day, _unit]];
                [_yTitles addObject:[NSString stringWithFormat:@"%0.2f", money]];
                i ++;
                if (money > _yMax) { //获取最大值
                    _yMax = money;
                    _yMaxIndex = i;
                    _MaxTime = time;
                }
                if (money < _yMin) { //获取最小值
                    _yMin = money;
                    _yMinIndex = i;
                    _MinTime = time;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                
                //最高最低数据
                _topTime.text = _MaxTime;
                _bottomTime.text = _MinTime;
                _topText.text = [_yTitles objectAtIndex:_yMaxIndex];
                _bottomText.text = [_yTitles objectAtIndex:_yMaxIndex];
                
                //数据重载，暂且，之后在做优化
                chartView = nil;
                chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, _chartsView.frame.size.height - 10)  withSource:self withStyle:UUChartBarStyle];
                chartView.backgroundColor = [UIColor whiteColor];
                [chartView showInView:_chartsView];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"获取数据失败"];
            });
        }
    });
}

//获取收入/支出/毛利总计数据
-(void)getTotalData{
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@",
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getIncomeStat" withParams:param];
        if (dics!=nil) {
            int TotalExpend = [[dics objectForKey:@"TotalExpend"] integerValue];
            int TotalIncome = [[dics objectForKey:@"TotalIncome"] integerValue];
            int TotalProfit = [[dics objectForKey:@"TotalProfit"] integerValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                if (_type == 0) {
                    if (TotalIncome != 0) {
                        _profitText.text = [NSString stringWithFormat:@"+%d", TotalIncome];
                    } else {
                        _profitText.text = [NSString stringWithFormat:@"%d", TotalIncome];
                    }
                } else if(_type == 1) {
                    _profitText.text = [NSString stringWithFormat:@"%d", TotalExpend];
                } else {
                    _profitText.text = [NSString stringWithFormat:@"%d", TotalProfit];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[CommonUtil showAlert:@"获取数据失败"];
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
            _unit = @"日";
            _unitLength = 2;
            _chooseType = 0;
            [_dayButton setChooseType:1];
            [_monthButton setChooseType:0];
            [_yearButton setChooseType:0];
            break;
        case 1:
            NSLog(@"按月");
            _unit = @"月";
            _unitLength = 2;
            _chooseType = 2;
            [_dayButton setChooseType:0];
            [_monthButton setChooseType:1];
            [_yearButton setChooseType:0];
            break;
        case 2:
            NSLog(@"按年");
            _unit = @"年";
            _unitLength = 4;
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
    return CGRangeMake(_yMax * 6/5, 0);
}

#pragma mark TimeViewDelegate 
-(void) clickConfirm {
    [self getTotalData];
    [self getData];
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
