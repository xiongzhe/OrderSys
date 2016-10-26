//
//  FavViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/5.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "FavViewController.h"
#import "TimeView.h"
#import "UUChart.h"
#import "ListHeadView.h"
#import "CommonCell.h"
#import "CommonInfo.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"

/**
 * 偏好分析
 **/
@interface FavViewController ()<UUChartDataSource, UITableViewDataSource,UITableViewDelegate,TimeViewDelegate>
{
    NSIndexPath *path;
    UUChart *chartView;
}

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSArray *percents;//比例
@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,retain) UIView *chartsView;

@property(nonatomic,retain) NSMutableArray *xTitles;//横坐标
@property(nonatomic,retain) NSMutableArray *yTitles;//纵坐标
@property(nonatomic,assign) CGFloat yMax;//纵坐标最大值

@end

@implementation FavViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.title = @"顾客偏好分析";
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
        
        
        _xTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _yTitles = [[NSMutableArray alloc] initWithCapacity:0];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, _timeView.bottomY + 5, SCREEN_WIDTH, SCREEN_HEIGHT - _timeView.bottomY - 5)];
        view.backgroundColor = [UIColor clearColor];
        //柱状图表
        _chartsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
        view.backgroundColor = [UIColor whiteColor];
        chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _chartsView.frame.size.width - 20, 150)  withSource:self withStyle:UUChartBarStyle];
        [chartView setHidden:YES];
        [chartView showInView:_chartsView];
        [view addSubview:_chartsView];
        
        //销量冠军标识
        UIButton *chaButton = [[UIButton alloc] initWithFrame:CGRectMake(10, chartView.frame.origin.y + chartView.frame.size.height + 5, 100, NAV_HEIGHT - 15)];
        chaButton.userInteractionEnabled = NO;
        [chaButton setImage:[UIImage imageNamed:@"crown"] forState:UIControlStateNormal];
        chaButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [chaButton setTitle:@"销量冠军" forState:UIControlStateNormal];
        [chaButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        chaButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0);
        [view addSubview:chaButton];
        
        //列表头标识
        NSArray *names = [[NSArray alloc] initWithObjects:@"时段", @"菜名",@"销量",@"金额",nil];
        self.percents = [[NSArray alloc] initWithObjects: [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)3/9], nil];
        ListHeadView *headView = [[ListHeadView alloc] initWithFrame:CGRectMake(0, chaButton.frame.origin.y + chaButton.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT - 15) withNamesArray:names withPercentArray:self.percents];
        headView.layer.borderWidth = 0.5;
        headView.layer.borderColor = RGBColorWithoutAlpha(226, 229, 228).CGColor;
        headView.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
        [view addSubview:headView];
        
        //列表
        self.dataList = [[NSMutableArray alloc] initWithCapacity:0];
        self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headView.frame.origin.y + headView.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - headView.frame.origin.y - headView.frame.size.height) style:UITableViewStylePlain];
        self.myTableView.dataSource = self;
        self.myTableView.delegate = self;
        self.myTableView.backgroundColor = [UIColor whiteColor];
        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.myTableView.userInteractionEnabled = NO;
        [view addSubview:self.myTableView];

        
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



//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"Cell2";
    CommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    NSUInteger row = [indexPath row];
    if (cell == nil) {
        cell = [[CommonCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:44 withPercentArray:self.percents];
    }
    CommonInfo *info = [self.dataList objectAtIndex:row];
    cell.oneLabel.text = info.one;
    cell.twoLabel.text = info.two;
    cell.threeLabel.text = info.three;
    cell.fourLabel.text = info.four;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//内容分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return [_dataList count];
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


//获取列表数据
-(void) getData {
    [_dataList removeAllObjects];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@",
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getPreferenceStat" withParams:param];
        if (dics!=nil) {
            //中餐销量冠军
            NSDictionary *LunchMost = [dics objectForKey:@"LunchMost"];
            CommonInfo *lunchInfo = [[CommonInfo alloc] init];
            lunchInfo.one = @"中餐";
            lunchInfo.two = [LunchMost objectForKey:@"Name"];
            lunchInfo.three = [NSString stringWithFormat:@"%d", [[LunchMost objectForKey:@"SalesVolume"] integerValue]];
            lunchInfo.four = [NSString stringWithFormat:@"%d", [[LunchMost objectForKey:@"Money"] integerValue]];
            [_dataList addObject:lunchInfo];
            //晚餐销量冠军
            NSDictionary *DinnerMost = [dics objectForKey:@"DinnerMost"];
            CommonInfo *dinnerInfo = [[CommonInfo alloc] init];
            dinnerInfo.one = @"晚餐";
            dinnerInfo.two = [DinnerMost objectForKey:@"Name"];
            dinnerInfo.three = [NSString stringWithFormat:@"%d", [[DinnerMost objectForKey:@"SalesVolume"] integerValue]];
            dinnerInfo.four = [NSString stringWithFormat:@"%d", [[DinnerMost objectForKey:@"Money"] integerValue]];
            [_dataList addObject:dinnerInfo];
            //偏好分析图表
            NSDictionary *IncomeStat = [dics objectForKey:@"DishTypeStat"];
            if ((NSNull *) IncomeStat != [NSNull null]) {
                _yMax = 0;
                for (NSDictionary *key in IncomeStat) {
                    NSNumber *moneyRet = [key objectForKey:@"Money"];
                    float money;
                    long moneyLong = [moneyRet longValue];
                    if (moneyLong < 0) { //判断是否是负数
                        money = [moneyRet longValue]/-10000.0f;
                    } else {
                        money = [moneyRet longValue]/10000.0f;
                    }
                    NSString *name = [key objectForKey:@"Name"];
                    [_xTitles addObject:[NSString stringWithFormat:@"%@", name]];
                    [_yTitles addObject:[NSString stringWithFormat:@"%0.2f", money]];
                    if (money > _yMax) { //获取最大值
                        _yMax = money;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [self.myTableView reloadData];
                    
                    //数据重载，暂且，之后在做优化
                    [chartView setHidden:YES];
                    chartView = nil;
                    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _chartsView.frame.size.width - 20, 150)  withSource:self withStyle:UUChartBarStyle];
                    chartView.backgroundColor = [UIColor whiteColor];
                    [chartView showInView:_chartsView];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [CommonUtil showAlert:@"无该段时期记录"];
                });
            }
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"无该段时期记录"];
            });
        }
    });
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
