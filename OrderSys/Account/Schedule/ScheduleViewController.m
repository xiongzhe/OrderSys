//
//  ScheduleViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/10.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ScheduleAddViewController.h"
#import "ScheduleCell.h"
#import "ScheduleInfo.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"

/**
 * 日程管理首页
 **/
@interface ScheduleViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) UITableView *myTableView;

@property(nonatomic,retain) NSMutableDictionary *planDic;
@property(nonatomic,retain) NSMutableArray *sortedArray;

@property(nonatomic,retain) NSIndexPath *deleteIndexPath; //删除的日程
@property(nonatomic,retain) NSMutableArray *deleteArray;//删除日程所在section nsarray

@end

@implementation ScheduleViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置导航栏
        self.title = @"日程管理";
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        //导航栏右侧添加按钮
        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, NAV_HEIGHT)];
        [addButton setTitle:@"添加" forState:UIControlStateNormal];
        addButton.titleLabel.textColor = [UIColor whiteColor];
        addButton.backgroundColor = [UIColor clearColor];
        addButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [addButton addTarget:self action:@selector(clickAdd:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        
        //列表
        _dataList = [NSMutableArray arrayWithCapacity:0];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
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
        
        //[self getData];

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

- (void) viewWillAppear:(BOOL)animated {
    [self getData];
}


//添加事件
-(IBAction)clickAdd:(id)sender {
    NSLog(@"添加日程");
    ScheduleAddViewController *scheduleAdd = [[ScheduleAddViewController alloc] initWithScheduleInfo:nil];
    [self.navigationController pushViewController:scheduleAdd animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_sortedArray objectAtIndex:section];
}

//内容分段
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sortedArray count];
}

// 设置section的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return ROW_HEIGHT - 15;
}


//section头
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ROW_HEIGHT - 15)];
    [v setBackgroundColor:RGBColorWithoutAlpha(200, 200, 200)];
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, v.frame.size.width, v.frame.size.height)];
    [labelTitle setBackgroundColor:[UIColor clearColor]];
    labelTitle.textAlignment = NSTextAlignmentLeft;
    labelTitle.text = [self tableView:tableView titleForHeaderInSection:section];
    labelTitle.font = [UIFont systemFontOfSize:14.0];
    labelTitle.textColor = [UIColor redColor];
    [v addSubview:labelTitle];
    return v;
}

//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"Cell";
    ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    NSUInteger row = [indexPath row];
    if (cell == nil) {
        cell = [[ScheduleCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:44];
    }
    ScheduleInfo *info = [self.dataList objectAtIndex:row];
    NSInteger hour = [[info.AlertTime substringWithRange:NSMakeRange(11, 2)] integerValue];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@",hour>=12?@"PM":@"AM",[[info AlertTime] substringWithRange:NSMakeRange(11, 5)]];
    cell.contentLabel.text = info.AlterMessage;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

//每个cell中显示多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *dataArray = [self getDataArrayBySection:section];
    return [dataArray count];
}

//列表点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [self getDataArrayBySection:indexPath.section];
    ScheduleInfo *info = [array objectAtIndex:indexPath.row];
    ScheduleAddViewController *scheduleAdd = [[ScheduleAddViewController alloc] initWithScheduleInfo:info];
    [self.navigationController pushViewController:scheduleAdd animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _deleteIndexPath = indexPath;
        [self deleteSchedule];
    }
}


//获取每个section中的列表
-(NSMutableArray*)getDataArrayBySection:(NSInteger)section{
    NSString *key = [_sortedArray objectAtIndex:section];
    NSMutableArray *dataArray = [_planDic objectForKey:key];
    return dataArray;
}

//array转化成dictionary
-(NSMutableDictionary*)executeData:(NSMutableArray*)array{
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (int i = 0; i<[array count]; i++) {
        ScheduleInfo *info = [array objectAtIndex:i];
        if ([info.AlertTime length]>10) {
            NSString *date = [info.AlertTime  substringToIndex:10];
            if ([[temp allKeys] containsObject:date]) {
                NSMutableArray *dataArray = [temp objectForKey:date];
                [dataArray addObject:info];
            }else{
                NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:1];
                [dataArray addObject:info];
                [temp setObject:dataArray forKey:date];
            }
        }
    }
    return temp;
}

//获取列表数据
-(void) getData {
    [_dataList removeAllObjects];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutSchedule.asmx" urlValue:@"http://service.xingchen.com/getSchedule" withParams:nil];
        if (dics!=nil) {
            ScheduleInfo *info;
            for (NSDictionary *key in dics) {
                info = [[ScheduleInfo alloc] init];
                info.AlertTime = [key objectForKey:@"AlertTime"];
                info.AlterMessage = [key objectForKey:@"AlterMessage"];
                info.ScheduleId = [[key objectForKey:@"ScheduleId"] integerValue];
                [_dataList addObject:info];
            }
            [self setData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.myTableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CommonUtil showAlert:@"无日程记录"];
            });
        }
    });
}

//根据下发的数据重置数据列表
- (void) setData {
    _planDic = [self executeData:_dataList];
    NSComparator cmptr = ^(NSString* obj1, NSString* obj2){
        return [obj1 compare:obj2];
    };
    NSArray *array = [[_planDic allKeys] sortedArrayUsingComparator:cmptr];
    _sortedArray = [array mutableCopy];
}

//删除日程
-(void) deleteSchedule {
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        _deleteArray = [self getDataArrayBySection:_deleteIndexPath.section];
        ScheduleInfo *info = [_deleteArray objectAtIndex:_deleteIndexPath.row];
        NSString *param = [WHInterfaceUtil intToJsonString:@"scheduleId" withValue:info.ScheduleId];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutSchedule.asmx" urlValue:@"http://service.xingchen.com/deleteSchedule" withParams:param];
        if (dics!=nil) {
            int IsSuccess = [[dics objectForKey:@"IsSuccess"] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (IsSuccess == 1) {
                    [_deleteArray removeObjectAtIndex:_deleteIndexPath.row];
                    if ([_deleteArray count] == 0) {
                        [_sortedArray removeObjectAtIndex:_deleteIndexPath.section];
                    }
                    [_myTableView reloadData];
                    [CommonUtil showAlert:@"删除成功"];
                } else {
                    [CommonUtil showAlert:@"删除成功"];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CommonUtil showAlert:@"无日程记录"];
            });
        }
    });
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
