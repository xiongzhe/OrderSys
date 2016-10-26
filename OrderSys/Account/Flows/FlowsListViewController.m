//
//  FlowsListViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/1.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "FlowsListViewController.h"
#import "CommonCell.h"
#import "CommonInfo.h"
#import "TimeView.h"
#import "ListHeadView.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"
#import "FlowsTypeListObj.h"

/**
 * 我的收入/支出列表
 **/
@interface FlowsListViewController ()<UITableViewDataSource,UITableViewDelegate,TimeViewDelegate>

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSArray *percents;//比例

@property(nonatomic,retain) NSArray *flowsTypes; //收入/支出类型列表
@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,retain) NSDateFormatter *dateFormatter;

@end


@implementation FlowsListViewController

- (instancetype)initWithType:(int) type{
    self = [super init];
    if (self) {
        
        self.type = type;
        _flowsTypes = [FlowsTypeListObj getTypeList];
        
        //设置导航栏
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        if (type == 0) {
            self.title = @"我的收入列表";
        } else{
            self.title = @"我的支出列表";
        }
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat: @"yyyy-MM-dd"];
        //时间选择视图
        self.timeView = [[TimeView alloc] initWithHeight:STATU_BAR_HEIGHT + NAV_HEIGHT + 5 withViewController:self];
        _timeView.delegate = self;
        [self.view addSubview:self.timeView];
        
        
        //列表头标识
        NSArray *names = [[NSArray alloc] initWithObjects:@"日期", @"时间",@"类型",@"金额",nil];
        self.percents = [[NSArray alloc] initWithObjects: [NSString stringWithFormat:@"%f", (CGFloat)3/10], [NSString stringWithFormat:@"%f", (CGFloat)2/10], [NSString stringWithFormat:@"%f", (CGFloat)3/10], [NSString stringWithFormat:@"%f", (CGFloat)2/10], nil];
        
        ListHeadView *headView = [[ListHeadView alloc] initWithFrame:CGRectMake(0, self.timeView.bottomY + 5, SCREEN_WIDTH, ROW_HEIGHT - 10) withNamesArray:names withPercentArray:self.percents];
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


//创建并设置每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"Cell";
    CommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    NSUInteger row = [indexPath row];
    if (cell == nil) {
        cell = [[CommonCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier withCellHeight:44 withPercentArray:self.percents];
    }
    CommonInfo *info = [_dataList objectAtIndex:row];
    cell.oneLabel.text = info.one;
    cell.oneLabel.font = [UIFont systemFontOfSize:14.0];
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
    _dataList = [[NSMutableArray alloc] initWithCapacity:0];
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",
                           [WHInterfaceUtil intToJsonString:@"type" withValue:_type],
                           [WHInterfaceUtil intToJsonString:@"PageIndex" withValue:-1],
                           [WHInterfaceUtil intToJsonString:@"PageRecordCount" withValue:100],
                           [WHInterfaceUtil stringToJsonString:@"beginTime" withValue:_timeView.stime],
                           [WHInterfaceUtil stringToJsonString:@"endTime" withValue:_timeView.etime]];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getAccountListStat" withParams:param];
        if (dics!=nil) {
            
            //int TotalRecordCount = [[dics objectForKey:@"TotalRecordCount"] integerValue];
            NSDictionary *Items = [dics objectForKey:@"Items"];
            CommonInfo *info;
            for (NSDictionary *key in Items) {
                info = [[CommonInfo alloc] init];
                NSString *dateTime = [key objectForKey:@"Date"];
                NSArray *array = [dateTime componentsSeparatedByString:@" "];
                info.one = [array objectAtIndex:0];
                info.two = [array objectAtIndex:1];
                info.three = [_flowsTypes objectAtIndex:[self getIndex:[key objectForKey:@"AccountType"]]];
                info.four = [NSString stringWithFormat:@"%d",[[key objectForKey:@"Money"] integerValue]];
                [_dataList addObject:info];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [self.myTableView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"获取数据失败"];
            });
        }
    });
}

// 返回列表row
- (NSInteger) getIndex:(NSString *) retType{
    NSArray *retTypes = [FlowsTypeListObj getTypeRetList];
    for (int i=0; i<[retTypes count]; i++) {
        if ([retType isEqualToString:[retTypes objectAtIndex:i]]) {
            return i;
        }
    }
    return 0;
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
