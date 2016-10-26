//
//  AccountViewController.m
//  OrderSys
//
//  Created by Macx on 15/7/31.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "AccountViewController.h"
#import "AccountCell.h"
#import "AccountButton.h"
#import "BasicInfoViewController.h"
#import "FlowsViewController.h"
#import "ReportViewController.h"
#import "CouponsViewController.h"
#import "ScheduleViewController.h"

/**
 * 账务管理首页
 **/
@interface AccountViewController ()

@property (nonatomic, retain) BasicInfoViewController *basicInfo;
@property (nonatomic, retain) FlowsViewController *flows;
@property (nonatomic, retain) ReportViewController *report;
@property (nonatomic, retain) CouponsViewController *coupons;
@property (nonatomic, retain) ScheduleViewController *schedule;

@end

@implementation AccountViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //设置导航栏
        self.title = @"账务管理";
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance].titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
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
    
    
    AccountButton *button1 = [[AccountButton alloc] initWithFrame: CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"我的收入" withImage:@"income" withTag:0];
    [button1 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    AccountButton *button2 = [[AccountButton alloc] initWithFrame: CGRectMake(button1.frame.origin.x + button1.frame.size.width, button1.frame.origin.y, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"我的支出" withImage:@"expend" withTag:1];
    [button2 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    AccountButton *button3 = [[AccountButton alloc] initWithFrame: CGRectMake(button2.frame.origin.x + button2.frame.size.width, button1.frame.origin.y, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"我的报表" withImage:@"report" withTag:2];
    [button3 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    AccountButton *button4 = [[AccountButton alloc] initWithFrame: CGRectMake(0, button1.frame.origin.y + button1.frame.size.height, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"日程管理" withImage:@"schedule" withTag:3];
    [button4 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
    
    AccountButton *button5 = [[AccountButton alloc] initWithFrame: CGRectMake(button4.frame.origin.x + button4.frame.size.width, button1.frame.origin.y + button1.frame.size.height, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"优惠券管理" withImage:@"promotion" withTag:4];
    [button5 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button5];
    
    AccountButton *button6 = [[AccountButton alloc] initWithFrame: CGRectMake(button5.frame.origin.x + button5.frame.size.width, button1.frame.origin.y + button1.frame.size.height, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"基本信息" withImage:@"baseinfo" withTag:5];
    [button6 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button6];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//点击按钮事件
-(IBAction)clickButtons:(id)sender {
    UIButton *button = (UIButton *) sender;
    NSInteger tag = button.tag;
    switch (tag) {
        case 0:
            //我的收入
            _flows = [[FlowsViewController alloc] initWithType:0];
            [self.navigationController pushViewController:_flows animated:YES];
            break;
        case 1:
            //我的支出
            _flows = [[FlowsViewController alloc] initWithType:1];
            [self.navigationController pushViewController:_flows animated:YES];
            break;
        case 2:
            //我的报告
            _report = [[ReportViewController alloc] init];
            [self.navigationController pushViewController:_report animated:YES];
            break;
        case 3:
            //日程管理
            _schedule = [[ScheduleViewController alloc] init];
            [self.navigationController pushViewController:_schedule animated:YES];
            break;
        case 4:
            //优惠券管理
            _coupons = [[CouponsViewController alloc] init];
            [self.navigationController pushViewController:_coupons animated:YES];
            break;
        case 5:
            //基本信息
            _basicInfo = [[BasicInfoViewController alloc] init];
            [self.navigationController pushViewController:_basicInfo animated:YES];
            break;
        default:
            break;
    }

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
