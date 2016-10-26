//
//  VipViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/5.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "VipViewController.h"
#import "TimeView.h"
#import "ListHeadView.h"
#import "CommonCell.h"
#import "CommonInfo.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "ButtonView.h"
#import "UUChart.h"

#define CHART_HEIGHT 150

/**
 * VIP顾客分析
 **/
@interface VipViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,TimeViewDelegate,UUChartDataSource>
{
    NSIndexPath *path;
    UUChart *chartLineView;
}

@property (nonatomic, retain) NSMutableArray *falDatas;
@property (nonatomic, retain) UITableView *favTableView;
@property (nonatomic, retain) ListHeadView *favHeadView;

@property (nonatomic, retain) NSMutableArray *consumeDatas;
@property (nonatomic, retain) UITableView *consumeTableView;
@property (nonatomic, retain) ListHeadView *consumeHeadView;
@property (nonatomic, retain) NSArray *percents;//比例


@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,retain) UIView *favView; //最受欢迎菜品视图
@property(nonatomic,retain) UIView *consumeView;//消费结构视图
@property(nonatomic,retain) UIView *timesView;//用餐时长视图
@property(nonatomic,retain) ButtonView *favButton;//最受欢迎菜品
@property(nonatomic,retain) ButtonView *consumeButton;//消费结构
@property(nonatomic,retain) ButtonView *timesButton;//用餐时长
@property(nonatomic,retain) UIScrollView *scrollView;

@property(nonatomic,retain) UIView *lineChartView;
@property(nonatomic,retain) NSMutableArray *xTitles;//横坐标
@property(nonatomic,retain) NSMutableArray *yTitles;//纵坐标
@property(nonatomic,assign) CGFloat yMax;//纵坐标最大值

@end

@implementation VipViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        
        _falDatas = [NSMutableArray arrayWithCapacity:0];
        _consumeDatas = [NSMutableArray arrayWithCapacity:0];
        
        self.title = @"VIP顾客分析";
        //设置导航栏
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        //条件按钮视图
        UIView *chooseView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT, SCREEN_WIDTH, ROW_HEIGHT)];
        chooseView.backgroundColor = [UIColor whiteColor];
        
        CGFloat buttonWidth = 100;
        CGFloat inset = (SCREEN_WIDTH - buttonWidth * 3)/4;//按钮间隔
        //按天
        _favButton = [[ButtonView alloc] initWithFrame:CGRectMake(inset, 8, buttonWidth, chooseView.frame.size.height - 16) withType:1 withTag:0 withTitle:@"最受欢迎菜品"];
        [_favButton addTarget:self action:@selector(clickChooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:_favButton];
        //按月
        _consumeButton = [[ButtonView alloc] initWithFrame:CGRectMake(_favButton.frame.origin.x + _favButton.frame.size.width + inset, 8, buttonWidth, chooseView.frame.size.height - 16) withType:0 withTag:1 withTitle:@"消费结构"];
        [_consumeButton addTarget:self action:@selector(clickChooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:_consumeButton];
        //按年
        _timesButton = [[ButtonView alloc] initWithFrame:CGRectMake(_consumeButton.frame.origin.x + _consumeButton.frame.size.width + inset, 8, buttonWidth, chooseView.frame.size.height - 16) withType:0 withTag:2 withTitle:@"用餐时长"];
        [_timesButton addTarget:self action:@selector(clickChooseType:) forControlEvents:UIControlEventTouchUpInside];
        [chooseView addSubview:_timesButton];
        
        [self.view addSubview:chooseView];

        
        //时间选择视图
        self.timeView = [[TimeView alloc] initWithHeight:chooseView.frame.origin.y + chooseView.frame.size.height + 5 withViewController:self];
        _timeView.delegate = self;
        [self.view addSubview:self.timeView];
        
        //滚动视图
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.timeView.bottomY, SCREEN_WIDTH, SCREEN_HEIGHT - self.timeView.bottomY)];
        
        
        /*******最受欢迎菜品*****/
        _favView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAV_HEIGHT - 10)];
        _favView.backgroundColor = [UIColor clearColor];
        [_favView setHidden:NO];
        //最受欢迎菜品标识
        UILabel *favDishesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, _favView.frame.size.height)];
        favDishesLabel.text = @"    最受欢迎菜品";
        favDishesLabel.textColor = [UIColor redColor];
        favDishesLabel.font = [UIFont systemFontOfSize:15.0];
        favDishesLabel.backgroundColor = [UIColor clearColor];
        [_favView addSubview:favDishesLabel];
        
        //列表头标识
        NSArray *favNames = [[NSArray alloc] initWithObjects:@"排名", @"菜名",@"销量",@"金额",nil];
        self.percents = [[NSArray alloc] initWithObjects: [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)3/9], nil];
        self.favHeadView = [[ListHeadView alloc] initWithFrame:CGRectMake(0, favDishesLabel.frame.origin.y + favDishesLabel.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT - 15) withNamesArray:favNames withPercentArray:self.percents];
        self.favHeadView.layer.borderWidth = 0.5;
        self.favHeadView.layer.borderColor = RGBColorWithoutAlpha(200, 200, 200).CGColor;
        self.favHeadView.backgroundColor = [UIColor clearColor];
        [_favView addSubview:self.favHeadView];
     
        //列表
        self.favTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _favHeadView.frame.origin.y + _favHeadView.frame.size.height, _favView.frame.size.width, _scrollView.frame.size.height - _favHeadView.frame.origin.y - _favHeadView.frame.size.height)];
        // 设置tableView的数据源
        self.favTableView.dataSource = self;
        // 设置tableView的委托
        self.favTableView.delegate = self;
        // 设置tableView的背景图
        self.favTableView.backgroundColor = [UIColor whiteColor];
        // 设置tableview分割线不显示
        self.favTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.favTableView.userInteractionEnabled = NO;
        [_favView addSubview:_favTableView];
        
        [_scrollView addSubview:_favView];
        
        
        /******消费结构*****/
        self.consumeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAV_HEIGHT - 10)];
        [_consumeView setHidden:YES];
        self.consumeView.backgroundColor = [UIColor clearColor];
        //最受欢迎菜品标识
        UILabel *consumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, _consumeView.frame.size.height)];
        consumeLabel.text = @"    消费结构";
        consumeLabel.textColor = [UIColor redColor];
        consumeLabel.font = [UIFont systemFontOfSize:15.0];
        consumeLabel.backgroundColor = [UIColor clearColor];
        [_consumeView addSubview:consumeLabel];
       
        [_scrollView addSubview:self.consumeView];
        
        //列表头标识
        NSArray *consumeNames = [[NSArray alloc] initWithObjects:@"类型",@"销量",@"金额", @"占比",nil];
        self.consumeHeadView = [[ListHeadView alloc] initWithFrame:CGRectMake(0, _consumeView.frame.origin.y + _consumeView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT - 15) withNamesArray:consumeNames withPercentArray:self.percents];
        self.consumeHeadView.layer.borderWidth = 0.5;
        self.consumeHeadView.layer.borderColor = RGBColorWithoutAlpha(200, 200, 200).CGColor;
        self.consumeHeadView.backgroundColor = [UIColor clearColor];
        [_consumeView addSubview:self.consumeHeadView];
        
        //列表
        self.consumeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _favHeadView.frame.origin.y + _favHeadView.frame.size.height, _favView.frame.size.width, _scrollView.frame.size.height - _favHeadView.frame.origin.y - _favHeadView.frame.size.height)];
        self.consumeTableView.dataSource = self;
        self.consumeTableView.delegate = self;
        self.consumeTableView.backgroundColor = [UIColor whiteColor];
        self.consumeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.consumeTableView.userInteractionEnabled = NO;
        [_consumeView addSubview:self.consumeTableView];
        
        [_scrollView addSubview:_consumeView];
        
        /******用餐时长*****/
        self.timesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAV_HEIGHT - 10)];
        self.timesView.backgroundColor = [UIColor clearColor];
        [_timesView setHidden:YES];
        
        UIView *showView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, _timesView.frame.size.width, _timesView.frame.size.height - 10)];
        showView.backgroundColor = [UIColor clearColor];
        //收入曲线标识
        UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, showView.frame.size.height)];
        showLabel.text = @"    用餐时长分析";
        showLabel.textColor = [UIColor redColor];
        showLabel.font = [UIFont systemFontOfSize:15.0];
        showLabel.backgroundColor = [UIColor clearColor];
        [showView addSubview:showLabel];
        [_timesView addSubview:showView];
        
        //折线图表
        _xTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _yTitles = [[NSMutableArray alloc] initWithCapacity:0];
        _lineChartView = [[UIView alloc] initWithFrame:CGRectMake(0, showView.frame.origin.y + showView.frame.size.height, SCREEN_WIDTH, CHART_HEIGHT + 10)];
        _lineChartView.backgroundColor = [UIColor whiteColor];
        chartLineView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 0, _lineChartView.frame.size.width - 20, CHART_HEIGHT)  withSource:self withStyle:UUChartLineStyle];
        [chartLineView showInView:_lineChartView];
        [_timesView addSubview:_lineChartView];
        [_scrollView addSubview:_timesView];
        
        [self.view addSubview:_scrollView];
        //时间控件
        [self.timeView setTimePickerView];
        
        [self setupPage:nil];
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


//改变滚动视图的方法实现
- (void)setupPage:(id)sender {
    //设置委托
    self.scrollView.delegate = self;
    //设置背景颜色
    self.scrollView.backgroundColor = [UIColor clearColor];
    //设置取消触摸
    self.scrollView.canCancelContentTouches = NO;
    //设置滚动条类型
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    //是否自动裁切超出部分
    self.scrollView.clipsToBounds = YES;
    //设置是否可以缩放
    self.scrollView.scrollEnabled = YES;
    //设置是否可以进行画面切换
    self.scrollView.pagingEnabled = NO;
    //设置在拖拽的时候是否锁定其在水平或者垂直的方向
    self.scrollView.directionalLockEnabled = YES;
    //隐藏滚动条设置（水平、跟垂直方向）
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
}


//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.favTableView) { //最受欢迎菜品
        static NSString *CellWithIdentifier = @"Cell";
        CommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        NSUInteger row = [indexPath row];
        if (cell == nil) {
            cell = [[CommonCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:44 withPercentArray:self.percents];
        }
        CommonInfo *info = [self.falDatas objectAtIndex:row];
        cell.oneLabel.text = info.one;
        cell.twoLabel.text = info.two;
        cell.threeLabel.text = info.three;
        cell.fourLabel.text = info.four;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else { //消费结构
        static NSString *CellWithIdentifier = @"Cell2";
        CommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        NSUInteger row = [indexPath row];
        if (cell == nil) {
            cell = [[CommonCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:44 withPercentArray:self.percents];
        }
        CommonInfo *info = [self.consumeDatas objectAtIndex:row];
        cell.oneLabel.text = info.one;
        cell.twoLabel.text = info.two;
        cell.threeLabel.text = info.three;
        cell.threeLabel.textColor = [UIColor redColor];
        cell.fourLabel.text = info.four;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
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
    if (tableView == self.favTableView) {
        return [_falDatas count];
    } else {
        return [_consumeDatas count];
    }
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}


//选择类型事件
-(IBAction)clickChooseType:(id)sender{
    UIButton *button = (UIButton *) sender;
    NSInteger tag = button.tag;
    switch (tag) {
        case 0:
            [_favButton setChooseType:1];
            [_consumeButton setChooseType:0];
            [_timesButton setChooseType:0];
            [_favView setHidden:NO];
            [_consumeView setHidden:YES];
            [_timesView setHidden:YES];
            break;
        case 1:
            [_favButton setChooseType:0];
            [_consumeButton setChooseType:1];
            [_timesButton setChooseType:0];
            [_favView setHidden:YES];
            [_consumeView setHidden:NO];
            [_timesView setHidden:YES];
            break;
        case 2:
            [_favButton setChooseType:0];
            [_consumeButton setChooseType:0];
            [_timesButton setChooseType:1];
            [_favView setHidden:YES];
            [_consumeView setHidden:YES];
            [_timesView setHidden:NO];
            break;
        default:
            break;
    }
}


//获取列表数据
-(void) getData {
    [_falDatas removeAllObjects];
    [_consumeDatas removeAllObjects];
    [_xTitles removeAllObjects];
    [_yTitles removeAllObjects];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@,%@",
                           [WHInterfaceUtil intToJsonString:@"type" withValue:1],
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getCustomerStat" withParams:param];
        if (dics!=nil) {
            //最受欢迎菜品
            NSDictionary *PopularDishes = [dics objectForKey:@"PopularDishes"];
            CommonInfo *dishesInfo;
            int i=0;
            if ((NSNull *) PopularDishes != [NSNull null] ) {
                for (NSDictionary *key in PopularDishes) {
                    dishesInfo = [[CommonInfo alloc] init];
                    dishesInfo.one = [NSString stringWithFormat:@"%d", ++i];
                    dishesInfo.two = [key objectForKey:@"Name"];
                    dishesInfo.three = [NSString stringWithFormat:@"%d", [[key objectForKey:@"SalesVolume"] integerValue]];
                    dishesInfo.four = [NSString stringWithFormat:@"%d", [[key objectForKey:@"Money"] integerValue]];
                    [_falDatas addObject:dishesInfo];
                }
            }
            
            //消费结构
            NSDictionary *SaleStruct = [dics objectForKey:@"SaleStruct"];
            CommonInfo *consumeInfo;
            if ((NSNull *) SaleStruct != [NSNull null] ) {
                for (NSDictionary *key in SaleStruct) {
                    consumeInfo = [[CommonInfo alloc] init];
                    consumeInfo.one = [key objectForKey:@"Name"];
                    consumeInfo.two = [NSString stringWithFormat:@"%d", [[key objectForKey:@"SalesVolume"] integerValue]];
                    consumeInfo.three = [NSString stringWithFormat:@"%d", [[key objectForKey:@"Money"] integerValue]];
                    consumeInfo.four = [NSString stringWithFormat:@"%f", [[key objectForKey:@"Ratio"] doubleValue]];
                    [_consumeDatas addObject:consumeInfo];
                }
            }
            
            //用餐时长分析曲线
            NSDictionary *Ratio = [dics objectForKey:@"Ratio"];
            if ((NSNull *) Ratio != [NSNull null]) {
                _yMax = 0;
                for (NSDictionary *key in Ratio) {
                    NSNumber *moneyRet = [key objectForKey:@"Money"];
                    float money;
                    long moneyLong = [moneyRet longValue];
                    if (moneyLong < 0) { //判断是否是负数
                        money = [moneyRet longValue]/-10000.0f;
                    } else {
                        money = [moneyRet longValue]/10000.0f;
                    }
                    NSString *time = [key objectForKey:@"Time"];
                    [_xTitles addObject:[NSString stringWithFormat:@"%@小时", time]];
                    [_yTitles addObject:[NSString stringWithFormat:@"%0.2f", money]];
                    if (money > _yMax) { //获取最大值
                        _yMax = money;
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [self.favTableView reloadData];
                [self.consumeTableView reloadData];
                
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
                [CommonUtil showAlert:@"无该类菜品类型记录"];
            });
        }
    });
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
    return CGRangeMake(_yMax * 6/5, 0);
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
