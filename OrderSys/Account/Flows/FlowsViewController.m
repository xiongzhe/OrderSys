//
//  FlowsViewController.m
//  OrderSys
//
//  Created by Macx on 15/7/31.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "FlowsViewController.h"
#import "AddRecordViewController.h"
#import "FlowsListViewController.h"
#import "UIViewController+HUD.h"
#import "CommonUtil.h"
#import "WHInterfaceUtil.h"

/**
 * 我的收入、支出首页
 **/
@interface FlowsViewController ()

@property (nonatomic, retain) UILabel *todayText;
@property (nonatomic, retain) UILabel *monthText;
@property (nonatomic, retain) UILabel *yearText;

@end

@implementation FlowsViewController

- (instancetype)initWithType:(int) type
{
    self = [super init];
    if (self) {
        
        self.type = type;
        
        //设置导航栏
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance].titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        //导航栏右侧刷新按钮
        UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, NAV_HEIGHT)];
        [refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
        refreshButton.titleLabel.textColor = [UIColor whiteColor];
        refreshButton.backgroundColor = [UIColor clearColor];
        refreshButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [refreshButton addTarget:self action:@selector(clickRefresh:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        //今日累计收入/支出
        UIView *todayView = [[UIView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        todayView.backgroundColor = [UIColor whiteColor];
        
        UILabel *todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 110, ROW_HEIGHT)];
        todayLabel.backgroundColor = [UIColor clearColor];
        todayLabel.textAlignment = NSTextAlignmentLeft;
        todayLabel.textColor = [UIColor blackColor];
        
        _todayText = [[UILabel alloc] initWithFrame:CGRectMake(todayLabel.frame.origin.x + todayLabel.frame.size.width + 20, 5, todayView.frame.size.width - todayLabel.frame.origin.x - todayLabel.frame.size.width - 70, todayLabel.frame.size.height - 10)];
        _todayText.backgroundColor = [UIColor whiteColor];
        
        UILabel *yuan1 = [[UILabel alloc] initWithFrame:CGRectMake(_todayText.frame.origin.x + _todayText.frame.size.width + 5, 0, 20, todayView.frame.size.height)];
        yuan1.text = @"元";
        yuan1.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [todayView addSubview:todayLabel];
        [todayView addSubview:_todayText];
        [todayView addSubview:yuan1];
        [self.view addSubview:todayView];
        
        
        //本月累计收入/支出
        UIView *monthView = [[UIView alloc] initWithFrame:CGRectMake(0, todayView.frame.origin.y + todayView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        monthView.backgroundColor = [UIColor whiteColor];
        
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 110, ROW_HEIGHT)];
        monthLabel.backgroundColor = [UIColor clearColor];
        monthLabel.textAlignment = NSTextAlignmentLeft;
        monthLabel.textColor = [UIColor blackColor];
        
        _monthText = [[UILabel alloc] initWithFrame:CGRectMake(monthLabel.frame.origin.x + monthLabel.frame.size.width + 20, 5, monthView.frame.size.width - monthLabel.frame.origin.x - monthLabel.frame.size.width - 70, monthLabel.frame.size.height - 10)];
        _monthText.backgroundColor = [UIColor whiteColor];
        
        UILabel *yuan2 = [[UILabel alloc] initWithFrame:CGRectMake(_monthText.frame.origin.x + _monthText.frame.size.width + 5, 0, 20, monthView.frame.size.height)];
        yuan2.text = @"元";
        yuan2.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [monthView addSubview:monthLabel];
        [monthView addSubview:_monthText];
        [monthView addSubview:yuan2];
        [self.view addSubview:monthView];
        
        
        //今年累计收入/支出
        UIView *yearView = [[UIView alloc] initWithFrame:CGRectMake(0, monthView.frame.origin.y + monthView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT)];
        yearView.backgroundColor = [UIColor whiteColor];
        
        UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 110, ROW_HEIGHT)];
        yearLabel.backgroundColor = [UIColor clearColor];
        yearLabel.textAlignment = NSTextAlignmentLeft;
        yearLabel.textColor = [UIColor blackColor];
        
        _yearText = [[UILabel alloc] initWithFrame:CGRectMake(yearLabel.frame.origin.x + yearLabel.frame.size.width + 20, 5, yearView.frame.size.width - yearLabel.frame.origin.x - yearLabel.frame.size.width - 70, yearLabel.frame.size.height - 10)];
        _yearText.backgroundColor = [UIColor whiteColor];
        
        UILabel *yuan3 = [[UILabel alloc] initWithFrame:CGRectMake(_yearText.frame.origin.x + _yearText.frame.size.width + 5, 0, 20, yearView.frame.size.height)];
        yuan3.text = @"元";
        yuan3.textColor = RGBColorWithoutAlpha(100, 100, 100);
        
        [yearView addSubview:yearLabel];
        [yearView addSubview:_yearText];
        [yearView addSubview:yuan3];
        [self.view addSubview:yearView];
        
        //判断是否是我的收入和我的支出
        NSString *listStr = @"";
        if (type == 0) {
            self.title = @"我的收入";
            todayLabel.text = @"今日累计收入:";
            monthLabel.text = @"本月累计收入:";
            yearLabel.text = @"今年累计收入:";
            listStr = @"查看我的收入列表";
        } else {
            self.title = @"我的支出";
            todayLabel.text = @"今日累计支出:";
            monthLabel.text = @"本月累计支出:";
            yearLabel.text = @"今年累计支出:";
            listStr = @"查看我的支出列表";
        }
        
        
        //查看我的收入/支出列表
        UIButton *listButton = [[UIButton alloc] initWithFrame:CGRectMake(40, yearView.frame.origin.y + yearView.frame.size.height + ROW_HEIGHT + 5, SCREEN_WIDTH - 80, ROW_HEIGHT - 10)];
        [listButton setTitle:listStr forState:UIControlStateNormal];
        listButton.titleLabel.textColor = [UIColor whiteColor];
        listButton.backgroundColor = [UIColor redColor];
        listButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        listButton.layer.cornerRadius = 5;
        listButton.tag = 0;
        [listButton addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:listButton];
        
        
        //添加记录
        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, listButton.frame.origin.y + listButton.frame.size.height + 25, SCREEN_WIDTH, ROW_HEIGHT)];
        [addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [addButton setTitle:@"添加记录" forState:UIControlStateNormal];
        [addButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        addButton.backgroundColor = [UIColor whiteColor];
        addButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        addButton.layer.cornerRadius = 5;
        addButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0);
        addButton.tag = 1;
        [addButton addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addButton];
        
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
    [self showHudInView:self.view hint:@"正在加载"];
    dispatch_async(dispatch_queue_create("getclass", DISPATCH_QUEUE_CONCURRENT), ^(){
        NSString *param = [WHInterfaceUtil intToJsonString:@"type" withValue:_type];
        NSDictionary *dics = [WHInterfaceUtil noLoginWithUrl:@"AboutReport.asmx" urlValue:@"http://service.xingchen.com/getAccountStat" withParams:param];
        if (dics!=nil) {
            int today = [[dics objectForKey:@"TotalToday"] integerValue];
            int month = [[dics objectForKey:@"TotalMonth"] integerValue];
            int year = [[dics objectForKey:@"TotalYear"] integerValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                _todayText.text = [NSString stringWithFormat:@"%d", today];
                _monthText.text = [NSString stringWithFormat:@"%d", month];
                _yearText.text = [NSString stringWithFormat:@"%d", year];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHud];
                [CommonUtil showAlert:@"获取数据失败"];
            });
        }
    });
}


//点击按钮事件
-(IBAction)clickButtons:(id)sender {
    UIButton *button = (UIButton *) sender;
    NSInteger tag = button.tag;
    AddRecordViewController *addRecord;
    FlowsListViewController *flowsList;
    switch (tag) {
        case 0:
            //点击查看我的收入/支出列表
            NSLog(@"列表");
            flowsList = [[FlowsListViewController alloc] initWithType:_type];
            [self.navigationController pushViewController:flowsList animated:YES];
            break;
        case 1:
            //点击添加
            NSLog(@"添加记录");
            addRecord = [[AddRecordViewController alloc] initWithType:self.type];
            [self.navigationController pushViewController:addRecord animated:YES];
            break;
        default:
            break;
    }
    
}

//点击刷新
-(IBAction)clickRefresh:(id)sender {
    NSLog(@"刷新");
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
