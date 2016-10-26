//
//  EatTimesViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/5.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "EatTimesViewController.h"
#import "TimeView.h"
#import "UUChart.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"

#define CHART_HEIGHT IS_IPHONE && SCREEN_MAX_LENGTH >= 568.0 ? 160 : 120

@interface EatTimesViewController ()<UUChartDataSource,TimeViewDelegate>
{
    NSIndexPath *path;
    UUChart *chartLineView;
    UUChart *chartBarView;
}

@property(nonatomic,retain) TimeView *timeView;//时间选择视图

@property(nonatomic,retain) UIView *lineChartView;
@property(nonatomic,assign) CGFloat incomeYMax;//收入分析纵坐标最大值
@property(nonatomic,retain) NSMutableArray *incomeXTitles;//收入分析横坐标
@property(nonatomic,retain) NSMutableArray *incomeYTitles;//收入分析纵坐标

@property(nonatomic,retain) UIView *barChartView;
@property(nonatomic,assign) CGFloat timesYMax;//用餐分析纵坐标最大值
@property(nonatomic,retain) NSMutableArray *timesXTitles;//用餐分析横坐标
@property(nonatomic,retain) NSMutableArray *timesYTitles;//用餐分析纵坐标

@end

@implementation EatTimesViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.title = @"就餐时段分析";
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
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, _timeView.bottomY + 5, SCREEN_WIDTH, SCREEN_HEIGHT - _timeView.bottomY - 5)];
        view.backgroundColor = [UIColor clearColor];
        
        UIView *showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAV_HEIGHT - 10)];
        showView.backgroundColor = [UIColor clearColor];
        //收入曲线标识
        UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, showView.frame.size.height)];
        showLabel.text = @"    收入分析";
        showLabel.textColor = [UIColor redColor];
        showLabel.font = [UIFont systemFontOfSize:15.0];
        showLabel.backgroundColor = [UIColor clearColor];
        [showView addSubview:showLabel];
        [view addSubview:showView];
       
        //折线图表
        _incomeXTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _incomeYTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _lineChartView = [[UIView alloc] initWithFrame:CGRectMake(0, showView.frame.origin.y + showView.frame.size.height, SCREEN_WIDTH, CHART_HEIGHT + 10)];
        _lineChartView.backgroundColor = [UIColor whiteColor];
        chartLineView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _lineChartView.frame.size.width - 20, CHART_HEIGHT)  withSource:self withStyle:UUChartLineStyle];
        [chartLineView setHidden:YES];
        [chartLineView showInView:_lineChartView];
        [view addSubview:_lineChartView];
        
        
        UIView *tshowView = [[UIView alloc] initWithFrame:CGRectMake(0, _lineChartView.frame.origin.y + _lineChartView.frame.size.height + 5, SCREEN_WIDTH, NAV_HEIGHT - 10)];
        tshowView.backgroundColor = [UIColor clearColor];
        //收入曲线标识
        UILabel *tshowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, showView.frame.size.height)];
        tshowLabel.text = @"    用餐时长分析";
        tshowLabel.textColor = [UIColor redColor];
        tshowLabel.font = [UIFont systemFontOfSize:15.0];
        tshowLabel.backgroundColor = [UIColor clearColor];
        [tshowView addSubview:tshowLabel];
        [view addSubview:tshowView];
        
        //圆柱图表
        _timesXTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _timesYTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _barChartView = [[UIView alloc] initWithFrame:CGRectMake(0, tshowView.frame.origin.y + tshowView.frame.size.height, SCREEN_WIDTH, CHART_HEIGHT + 10)];
        _barChartView.backgroundColor = [UIColor whiteColor];
        chartBarView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _barChartView.frame.size.width - 20, CHART_HEIGHT)  withSource:self withStyle:UUChartBarStyle];
        [chartBarView setHidden:YES];
        [chartBarView showInView:_barChartView];
        [view addSubview:_barChartView];
        
        [self.view addSubview:view];
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
    [_incomeXTitles removeAllObjects];
    [_incomeYTitles removeAllObjects];
    [_timesXTitles removeAllObjects];
    [_timesYTitles removeAllObjects];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@",
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getCustomerTimeStat" withParams:param];
        if (dics!=nil) {
            //收入分析曲线
            NSDictionary *IncomeStat = [dics objectForKey:@"IncomeStat"];
            if ((NSNull *) IncomeStat != [NSNull null]) {
                _incomeYMax = 0;
                for (NSDictionary *key in IncomeStat) {
                    NSNumber *moneyRet = [key objectForKey:@"Money"];
                    float money;
                    long moneyLong = [moneyRet longValue];
                    if (moneyLong < 0) { //判断是否是负数
                        money = [moneyRet longValue]/-10000.0f;
                    } else {
                        money = [moneyRet longValue]/10000.0f;
                    }
                    NSString *time = [key objectForKey:@"Time"];
                    NSString *day = [time substringFromIndex:[time length] - 2];
                    [_incomeXTitles addObject:[NSString stringWithFormat:@"%@日", day]];
                    [_incomeYTitles addObject:[NSString stringWithFormat:@"%0.2f", money]];
                    if (money > _incomeYMax) { //获取最大值
                        _incomeYMax = money;
                    }
                }
            }
            
            //用餐时长分析曲线
            NSDictionary *TimeStat = [dics objectForKey:@"TimeStat"];
            if ((NSNull *) TimeStat != [NSNull null]) {
                _timesYMax = 0;
                for (NSDictionary *key in TimeStat) {
                    NSNumber *moneyRet = [key objectForKey:@"Money"];
                    float money;
                    long moneyLong = [moneyRet longValue];
                    if (moneyLong < 0) { //判断是否是负数
                        money = [moneyRet longValue]/-10000.0f;
                    } else {
                        money = [moneyRet longValue]/10000.0f;
                    }
                    NSString *time = [key objectForKey:@"Name"];
                    [_timesXTitles addObject:[NSString stringWithFormat:@"%@小时", time]];
                    [_timesYTitles addObject:[NSString stringWithFormat:@"%0.2f", money]];
                    if (money > _timesYMax) { //获取最大值
                        _timesYMax = money;
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
                
                //数据重载，暂且，之后在做优化
                [chartBarView setHidden:NO];
                chartBarView = nil;
                chartBarView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _barChartView.frame.size.width - 20, CHART_HEIGHT)  withSource:self withStyle:UUChartBarStyle];
                chartBarView.backgroundColor = [UIColor whiteColor];
                [chartBarView showInView:_barChartView];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"无该时段记录"];
            });
        }
    });
}


//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    if (chart == chartLineView) {
        return _incomeXTitles;
    } else {
        return _timesXTitles;
    }
}

//纵坐标数据数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    if (chart == chartLineView) {
        return @[_incomeYTitles];
    } else {
        
        return @[_timesYTitles];
    }
}

//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UURed,UUGreen,UUBrown];
}

//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    if (chart == chartLineView) {
        return CGRangeMake(_incomeYMax * 6/5, 0);
    } else {
        return CGRangeMake(_timesYMax * 6/5, 0);
    }
    
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
- (void) clickConfirm {
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
