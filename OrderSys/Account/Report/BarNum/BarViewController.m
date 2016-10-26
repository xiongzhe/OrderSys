//
//  BarViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/5.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "BarViewController.h"
#import "ListHeadView.h"
#import "TimeView.h"
#import "CommonCell.h"
#import "CommonInfo.h"
#import "CommonUtil.h"
#import "ButtonView.h"
#import "UIViewController+HUD.h"
#import "WHInterfaceUtil.h"

/**
 * 台号分析
 **/
@interface BarViewController ()<UITableViewDataSource,UITableViewDelegate,TimeViewDelegate>

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) UITableView *myTableView;

@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,retain) ButtonView *dayButton;//全天
@property(nonatomic,retain) ButtonView *lunchButton;//中餐
@property(nonatomic,retain) ButtonView *dinnerButton;//晚餐
@property(nonatomic,retain) NSArray *percents;//比例

@property(nonatomic,assign) NSInteger timesType;//时段类型 0 全天 1 中餐 2 晚餐
@property (nonatomic, retain) NSMutableArray *allDayList;
@property (nonatomic, retain) NSMutableArray *lunchList;
@property (nonatomic, retain) NSMutableArray *dinnerList;

@end

@implementation BarViewController

- (instancetype)initWithStime:(NSString *) stime withEtime:(NSString *) etime {
    self = [super init];
    if (self) {
        
        _timesType = 0;
        _dataList = [NSMutableArray arrayWithCapacity:0];
        _allDayList = [NSMutableArray arrayWithCapacity:0];
        _lunchList = [NSMutableArray arrayWithCapacity:0];
        _dinnerList = [NSMutableArray arrayWithCapacity:0];
        
        self.title = @"台号分析";
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

        
        //列表头标识
        NSArray *names = [[NSArray alloc] initWithObjects:@"台号", @"销量",@"金额",@"翻台",nil];
        self.percents = [[NSArray alloc] initWithObjects: [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)3/9], nil];
        ListHeadView *headView = [[ListHeadView alloc] initWithFrame:CGRectMake(0, timesView.frame.origin.y + timesView.frame.size.height, SCREEN_WIDTH, ROW_HEIGHT - 15) withNamesArray:names withPercentArray:self.percents];
        headView.layer.borderWidth = 0.5;
        headView.layer.borderColor = RGBColorWithoutAlpha(226, 229, 228).CGColor;
        headView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:headView];
        
        
        //列表
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headView.frame.origin.y + headView.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - headView.frame.origin.y - headView.frame.size.height) style:UITableViewStylePlain];
        // 设置tableView的数据源
        tableView.dataSource = self;
        // 设置tableView的委托
        tableView.delegate = self;
        // 设置tableView的背景图
        tableView.backgroundColor = [UIColor whiteColor];
        // 设置tableview分割线不显示
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.myTableView = tableView;
        [self.view addSubview:tableView];

        
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
            break;
        case 1:
            NSLog(@"中餐");
            _timesType = 1;
            [_dayButton setChooseType:0];
            [_lunchButton setChooseType:1];
            [_dinnerButton setChooseType:0];
            break;
        case 2:
            NSLog(@"晚餐");
            _timesType = 2;
            [_dayButton setChooseType:0];
            [_lunchButton setChooseType:0];
            [_dinnerButton setChooseType:1];
            break;
        default:
            break;
    }
    [_myTableView reloadData];
}


# pragma mark TableView
//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"Cell";
    CommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    NSUInteger row = [indexPath row];
    if (cell == nil) {
        cell = [[CommonCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:44 withPercentArray:self.percents];
    }
    CommonInfo *info = [self.dataList objectAtIndex:row];
    cell.oneLabel.text = info.one;
    cell.twoLabel.text = info.two;
    cell.threeLabel.textColor = [UIColor redColor];
    cell.fourLabel.text = info.four;
    if (_timesType == 0) { //全天
        cell.threeLabel.text = [_allDayList objectAtIndex:row];
    } else if (_timesType == 1) { //中餐
        cell.threeLabel.text = [_lunchList objectAtIndex:row];
    } else { //晚餐
        cell.threeLabel.text = [_dinnerList objectAtIndex:row];
    }
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
    //让点击背景色消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//获取数据
-(void) getData {
    [_dataList removeAllObjects];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@,%@",
                           [WHInterfaceUtil intToJsonString:@"timeQuantum" withValue:_timesType],
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getTableStat" withParams:param];
        if (dics!=nil) {
            NSDictionary *Items = [dics objectForKey:@"Items"];
            CommonInfo *info;
            if ((NSNull *)Items != [NSNull null]) {
                for (NSDictionary *key in Items) {
                    info = [[CommonInfo alloc] init];
                    info.one = [NSString stringWithFormat:@"%d", [[key objectForKey:@"Table"] integerValue]];
                    info.two = [NSString stringWithFormat:@"%d", [[key objectForKey:@"SalesVolume"] integerValue]];
                    info.four = [NSString stringWithFormat:@"%d", [[key objectForKey:@"Rockover"] integerValue]];
                    [_dataList addObject:info];
                    NSString *allDay = [NSString stringWithFormat:@"%d", [[key objectForKey:@"Money"] integerValue]];
                    [_allDayList addObject:allDay];
                    NSString *lunchDay = [NSString stringWithFormat:@"%d", [[key objectForKey:@"MoneyLunch"] integerValue]];
                    [_lunchList addObject:lunchDay];
                    NSString *dinnerDay = [NSString stringWithFormat:@"%d", [[key objectForKey:@"MoneyDinner"] integerValue]];
                    [_dinnerList addObject:dinnerDay];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideHud];
                        [self.myTableView reloadData];
                        
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                    [CommonUtil showAlert:@"无该时段记录"];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"无该时段记录"];
            });
        }
    });
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
