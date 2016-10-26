//
//  DishViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/4.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishViewController.h"
#import "TimeView.h"
#import "CommonCell.h"
#import "DishTypeInfo.h"
#import "CommonInfo.h"
#import "ListHeadView.h"
#import "ButtonView.h"
#import "PopListView.h"
#import "PopTableCell.h"
#import "DishDetailViewController.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "DishesListTypeInfo.h"

/**
 * 菜品分类分析
 **/
@interface DishViewController ()<UITableViewDataSource,UITableViewDelegate,TimeViewDelegate,PopClickDelegate>

@property (nonatomic, retain) NSMutableArray *typesList; //菜品类型列表数据
@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) UITableView *typesTableView;
@property (nonatomic, assign) CGFloat typesCellWidth; //typesTableView宽度

@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,retain) UIButton *sortButton;
@property(nonatomic,retain) UIButton *timesButton;
@property(nonatomic,retain) UIButton *typeButton;
@property(nonatomic,retain) NSArray *percents;//比例
@property(nonatomic,retain) NSArray *sortArray;//排序类别
@property(nonatomic,retain) NSArray *timesArray;//时段类别
@property(nonatomic,retain) PopListView *sortPopView;//排序类别弹出窗
@property(nonatomic,retain) PopListView *timesPopView;//时段类别弹出窗

@property(nonatomic,assign) NSInteger sortType;//排序类型 0 销量 1 金额
@property(nonatomic,assign) NSInteger timesType;//时段类型 0 全天 1 中餐 2 晚餐
@property(nonatomic,assign) NSInteger dishType;//菜品类型
@property(nonatomic,retain) CommonInfo *commonInfo;//当前菜品信息

@property(nonatomic,assign) NSInteger curClickType;//当前点击类型 0 排序 1 时段

@end

@implementation DishViewController

- (instancetype)initWithStime:(NSString *) stime withEtime:(NSString *) etime withDishesInfo:(CommonInfo *) commonInfo {
    self = [super init];
    if (self) {
        
        _sortArray = [[NSArray alloc] initWithObjects:@"销量",@"金额", nil];
        _timesArray = [[NSArray alloc] initWithObjects:@"全天",@"中餐",@"晚餐", nil];
        
        _dishType = commonInfo.typeId;
        _curClickType = 0;
        self.sortType = 0;
        self.timesType = 0;
        self.commonInfo = commonInfo;
        
        self.title = @"菜品分类分析";
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
        
        //排序
        _sortButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sortView.frame.size.width/4, sortView.frame.size.height)];
        [_sortButton setImage:[UIImage imageNamed:@"red_array"] forState:UIControlStateNormal];
        _sortButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_sortButton setTitle:@"排序" forState:UIControlStateNormal];
        [_sortButton addTarget:self action:@selector(clickSortType:) forControlEvents:UIControlEventTouchUpInside];
        [_sortButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _sortButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, - sortView.frame.size.width/8, 0.0, 0.0);
        _sortButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, sortView.frame.size.width/8 - 2, 0.0, 0.0);
        [sortView addSubview:_sortButton];
        
        //时段
        _timesButton = [[UIButton alloc] initWithFrame:CGRectMake(_sortButton.frame.origin.x + _sortButton.frame.size.width, 0, sortView.frame.size.width/4, sortView.frame.size.height)];
        [_timesButton setImage:[UIImage imageNamed:@"red_array"] forState:UIControlStateNormal];
        _timesButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_timesButton setTitle:@"时段" forState:UIControlStateNormal];
        [_timesButton addTarget:self action:@selector(clickTimesType:) forControlEvents:UIControlEventTouchUpInside];
        [_timesButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
        _timesButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, - sortView.frame.size.width/8, 0.0, 0.0);
        _timesButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, sortView.frame.size.width/8 - 2, 0.0, 0.0);
        [sortView addSubview:_timesButton];
        
        //类型
        _typeButton = [[UIButton alloc] initWithFrame:CGRectMake(_timesButton.frame.origin.x + _timesButton.frame.size.width, 0, sortView.frame.size.width/4, sortView.frame.size.height)];
        [_typeButton setImage:[UIImage imageNamed:@"red_array"] forState:UIControlStateNormal];
        _typeButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_typeButton setTitle:@"类型" forState:UIControlStateNormal];
        [_typeButton addTarget:self action:@selector(clickTypes:) forControlEvents:UIControlEventTouchUpInside];
        [_typeButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
        _typeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, - sortView.frame.size.width/8, 0.0, 0.0);
        _typeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, sortView.frame.size.width/8 - 2, 0.0, 0.0);
        [sortView addSubview:_typeButton];
        
        [self.view addSubview:sortView];
        
        
        //列表头标识
        NSArray *names = [[NSArray alloc] initWithObjects:@"排名", @"菜名",@"销量",@"金额",nil];
        self.percents = [[NSArray alloc] initWithObjects: [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)2/9], [NSString stringWithFormat:@"%f", (CGFloat)3/9], nil];
        
        ListHeadView *headView = [[ListHeadView alloc] initWithFrame:CGRectMake(0, sortView.frame.origin.y + sortView.frame.size.height + 5, SCREEN_WIDTH, ROW_HEIGHT - 15) withNamesArray:names withPercentArray:self.percents];
        headView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:headView];
        
        
        //列表
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headView.frame.origin.y + headView.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - headView.frame.origin.y - headView.frame.size.height) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = [UIColor whiteColor];
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
        
        //列表
        _typesCellWidth = sortView.frame.size.width/3;
        _typesTableView = [[UITableView alloc] initWithFrame:CGRectMake(_typeButton.frame.origin.x + 5, sortView.frame.origin.y + sortView.frame.size.height, sortView.frame.size.width/3, ROW_HEIGHT * 5) style:UITableViewStylePlain];
        _typesTableView.dataSource = self;
        _typesTableView.delegate = self;
        _typesTableView.layer.cornerRadius = 5;
        [_typesTableView setHidden:YES];
        _typesTableView.backgroundColor = [UIColor clearColor];
        _typesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_typesTableView];
        
        
        //时间控件
        [self.timeView setTimePickerView];
        _timeView.stimeText.text = stime;
        _timeView.etimeText.text = etime;
        _timeView.stime = stime;
        _timeView.etime = etime;
        
        [self getTypesData];
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
    [_typesTableView setHidden:YES];
    [_sortButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_timesButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
    [_typeButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
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
    [_typesTableView setHidden:YES];
    [_sortButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
    [_timesButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_typeButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
    NSLog(@"%d", (int)_timesPopView.type);
}


//点击类型事件
-(IBAction)clickTypes:(id)sender{
    if (_typesTableView.isHidden) {
        [_typesTableView setHidden:NO];
    } else{
        [_typesTableView setHidden:YES];
    }
    [_sortPopView setHidden:YES];
    [_timesPopView setHidden:YES];
    [_sortButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
    [_timesButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
    [_typeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}


//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _myTableView) {
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
    } else { //分类选择列表
        static NSString *CellWithIdentifier = @"TypeCell";
        PopTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
        NSUInteger row = [indexPath row];
        if (cell == nil) {
            cell = [[PopTableCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellWidth:_typesCellWidth withCellHeight:44];
        }
        DishTypeInfo *info = [self.typesList objectAtIndex:row];
        cell.nameLabel.text = info.name;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
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
    if (tableView == _myTableView) {
        return [_dataList count];
    } else {//分类选择列表
        return [_typesList count];
    }
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    if (tableView == _myTableView) {
        CommonInfo *commonInfo = [_dataList objectAtIndex:(int)row];
        DishDetailViewController *dishDetail = [[DishDetailViewController alloc]  initWithStime:_timeView.stime withEtime:_timeView.etime withDishesInfo:commonInfo];
        [self.navigationController pushViewController:dishDetail animated:YES];
        
        //让点击背景色消失
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {//分类选择列表
        DishesListTypeInfo *typeInfo = [_typesList objectAtIndex:row];
        _dishType = typeInfo.typeId;
        [_typesTableView setHidden:YES];
        [self getData];
    }
}

//获取列表数据
-(void) getData {
    _dataList = [NSMutableArray arrayWithCapacity:0];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",
                           [WHInterfaceUtil intToJsonString:@"typeId" withValue:_dishType],
                           [WHInterfaceUtil intToJsonString:@"timeQuantum" withValue:_timesType],
                           [WHInterfaceUtil intToJsonString:@"order" withValue:_sortType],
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getDishesListStat" withParams:param];
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
                [CommonUtil showAlert:@"无该类菜品记录"];
            });
        }
    });
}

//获取菜单类型列表
-(void)getTypesData {
    _typesList = [NSMutableArray arrayWithCapacity:0];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutDishs.asmx" urlValue:@"http://service.xingchen.com/getDishTypeList" withParams:nil];
        if (dics!=nil) {
            for (NSDictionary *key in dics) {
                //类型列表
                DishesListTypeInfo *typeInfo = [[DishesListTypeInfo alloc] init];
                typeInfo.typeId = [[key objectForKey:@"TypeId"] integerValue];
                typeInfo.name = [key objectForKey:@"TypeName"];
                typeInfo.num = 0;
                typeInfo.isSelect = 0;
                [_typesList addObject:typeInfo];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_typesTableView reloadData];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"获取数据失败");
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
