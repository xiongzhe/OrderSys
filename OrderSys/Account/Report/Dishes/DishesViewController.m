//
//  DishesViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/4.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishesViewController.h"
#import "TimeView.h"
#import "CommonCell.h"
#import "CommonInfo.h"
#import "DishViewController.h"
#import "ListHeadView.h"
#import "ButtonView.h"
#import "PopListView.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"

/**
 * 菜品分析
 **/
@interface DishesViewController ()<UITableViewDataSource,UITableViewDelegate,TimeViewDelegate,PopClickDelegate>

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) UITableView *myTableView;

@property(nonatomic,retain) UIButton *sortButton;
@property(nonatomic,retain) UIButton *timesButton;
@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,retain) NSArray *percents;//比例
@property(nonatomic,retain) NSArray *sortArray;//排序类别
@property(nonatomic,retain) NSArray *timesArray;//时段类别
@property(nonatomic,retain) PopListView *sortPopView;//排序类别弹出窗
@property(nonatomic,retain) PopListView *timesPopView;//时段类别弹出窗

@property(nonatomic,assign) NSInteger curClickType;//当前点击类型 0 排序 1 时段
@property(nonatomic,assign) NSInteger sortType;//排序类型 0 销量 1 金额
@property(nonatomic,assign) NSInteger timesType;//时段类型 0 全天 1 中餐 2 晚餐

@end

@implementation DishesViewController

- (instancetype)initWithStime:(NSString *) stime withEtime:(NSString *) etime {
    self = [super init];
    if (self) {
        
        _sortArray = [[NSArray alloc] initWithObjects:@"销量",@"金额", nil];
        _timesArray = [[NSArray alloc] initWithObjects:@"全天",@"中餐",@"晚餐", nil];
        
        _curClickType = 0;
        self.sortType = 0;
        self.timesType = 0;
        
        self.title = @"菜品分析";
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
        
        
        //排序视图
        UIView *sortView = [[UIView alloc] initWithFrame:CGRectMake(0, self.timeView.bottomY + 5, SCREEN_WIDTH, ROW_HEIGHT - 5)];
        sortView.backgroundColor = [UIColor whiteColor];
        
        _sortButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sortView.frame.size.width/4, sortView.frame.size.height)];
        [_sortButton setImage:[UIImage imageNamed:@"red_array"] forState:UIControlStateNormal];
        _sortButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_sortButton setTitle:@"排序" forState:UIControlStateNormal];
        [_sortButton addTarget:self action:@selector(clickSortType:) forControlEvents:UIControlEventTouchUpInside];
        [_sortButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _sortButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, - sortView.frame.size.width/8, 0.0, 0.0);
        _sortButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, sortView.frame.size.width/8 - 2, 0.0, 0.0);
        [sortView addSubview:_sortButton];
        
        _timesButton = [[UIButton alloc] initWithFrame:CGRectMake(_sortButton.frame.origin.x + _sortButton.frame.size.width, 0, sortView.frame.size.width/4, sortView.frame.size.height)];
        [_timesButton setImage:[UIImage imageNamed:@"red_array"] forState:UIControlStateNormal];
        _timesButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_timesButton setTitle:@"时段" forState:UIControlStateNormal];
        [_timesButton addTarget:self action:@selector(clickTimesType:) forControlEvents:UIControlEventTouchUpInside];
        [_timesButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100)  forState:UIControlStateNormal];
        _timesButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, - sortView.frame.size.width/8, 0.0, 0.0);
        _timesButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, sortView.frame.size.width/8 - 2, 0.0, 0.0);
        [sortView addSubview:_timesButton];
        
        [self.view addSubview:sortView];
        
        
        //列表头标识
        NSArray *names = [[NSArray alloc] initWithObjects:@"排名", @"类型",@"销量",@"金额",nil];
        self.percents = [[NSArray alloc] initWithObjects: [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)3/9], nil];
        
        ListHeadView *headView = [[ListHeadView alloc] initWithFrame:CGRectMake(0, sortView.frame.origin.y + sortView.frame.size.height + 5, SCREEN_WIDTH, ROW_HEIGHT - 15) withNamesArray:names withPercentArray:self.percents];
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
        
        //排序类型选择布局
        _sortPopView = [[PopListView alloc] initWithFrame:CGRectMake(_sortButton.frame.origin.x + 5, sortView.frame.origin.y + sortView.frame.size.height + 5, _sortButton.frame.size.width, 0.5+(ROW_HEIGHT + 0.5) * [_sortArray count]) withShowView:nil withArray:_sortArray withBackgroundColor:RGBColor(60, 60, 60, 0.8)];
        _sortPopView.delegate = self;
        [_sortPopView setHidden:YES];
        [self.view addSubview:_sortPopView];
        
        //时段类型选择布局
        _timesPopView = [[PopListView alloc] initWithFrame:CGRectMake(_timesButton.frame.origin.x + 5, sortView.frame.origin.y + sortView.frame.size.height + 5, _sortButton.frame.size.width, 0.5+(ROW_HEIGHT + 0.5) * [_timesArray count]) withShowView:nil withArray:_timesArray withBackgroundColor:RGBColor(60, 60, 60, 0.8)];
        _timesPopView.delegate = self;
        [_timesPopView setHidden:YES];
        [self.view addSubview:_timesPopView];
      
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

//选择排序类型事件
-(IBAction)clickSortType:(id)sender{
    _curClickType = 0;
    if (_sortPopView.isHidden) {
        [_sortPopView setHidden:NO];
    } else{
        [_sortPopView setHidden:YES];
    }
    [_timesPopView setHidden:YES];
    [_sortButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_timesButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
    NSLog(@"%d", (int)_sortPopView.type);
}


//选择时段类型事件
-(IBAction)clickTimesType:(id)sender{
    _curClickType = 1;
    if (_timesPopView.isHidden) {
        [_timesPopView setHidden:NO];
    } else{
        [_timesPopView setHidden:YES];
    }
    [_sortPopView setHidden:YES];
    [_sortButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
    [_timesButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    NSLog(@"%d", (int)_timesPopView.type);
}



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
    cell.threeLabel.text = info.three;
    cell.fourLabel.text = info.four;
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
    NSInteger row = indexPath.row;
    CommonInfo *commonInfo = [_dataList objectAtIndex:row];
    DishViewController *dish = [[DishViewController alloc] initWithStime:_timeView.stime withEtime:_timeView.etime withDishesInfo:commonInfo];
    [self.navigationController pushViewController:dish animated:YES];
    
    //让点击背景色消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//获取列表数据
-(void) getData {
    _dataList = [NSMutableArray arrayWithCapacity:0];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@,%@,%@",
                           [WHInterfaceUtil intToJsonString:@"timeQuantum" withValue:_timesType],
                           [WHInterfaceUtil intToJsonString:@"order" withValue:_sortType],
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getDishesTypeListStat" withParams:param];
        if (dics!=nil) {
            CommonInfo *info;
            int i=0;
            for (NSDictionary *key in dics) {
                info = [[CommonInfo alloc] init];
                info.typeId = [[key objectForKey:@"Id"] integerValue];
                info.one = [NSString stringWithFormat:@"%d", ++i];
                info.two = [key objectForKey:@"Name"];
                info.three = [NSString stringWithFormat:@"%d",[[key objectForKey:@"SalesVolume"] integerValue]];
                info.four = [NSString stringWithFormat:@"%ld",[[key objectForKey:@"Money"] longValue]];
                [_dataList addObject:info];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                
                [self.myTableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"无该类菜品类型记录"];
            });
        }
    });
}

#pragma mark TimeViewDelegate
-(void)clickConfirm {
    [self getData];
}

#pragma mark PopListViewDelegate
-(void)clickItem:(NSInteger)index{
    if (_curClickType == 0) {
        _sortType = index;
    } else {
        _timesType = index;
    }
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
