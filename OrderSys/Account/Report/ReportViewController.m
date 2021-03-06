//
//  ReportViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/1.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "ReportViewController.h"
#import "TimeView.h"
#import "ProfitViewController.h"
#import "DishesViewController.h"
#import "CusViewController.h"
#import "BarViewController.h"
#import "BannerView.h"

#define BUTTON_HEIGHT 60

/**
 * 我的报表首页
 **/
@interface ReportViewController ()

@property(nonatomic,retain) TimeView *timeView;//时间选择视图
@property(nonatomic,assign) NSInteger timeType;//当前弹出的时间类型 0 开始时间 1 结束时间

@property(nonatomic,retain) ProfitViewController *profit;//收益分析
@property(nonatomic,retain) DishesViewController *dishes;//菜品分析
@property(nonatomic,retain) CusViewController *customer;//顾客分析
@property(nonatomic,retain) BarViewController *bar;//台号分析

@end

@implementation ReportViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置导航栏
        self.title = @"我的报表";
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        //时间选择视图
        self.timeView = [[TimeView alloc] initWithHeight:STATU_BAR_HEIGHT + NAV_HEIGHT + 5 withViewController:self];
        //[self.view addSubview:self.timeView];
        
        //条件按钮视图
        UIView *buttonsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.timeView.bottomY, SCREEN_WIDTH, SCREEN_HEIGHT - self.timeView.bottomY - 10)];
        buttonsView.backgroundColor = [UIColor clearColor];
        
        //收益分析
        BannerView *profitView = [[BannerView alloc] initWithFrame:CGRectMake(0, 10, buttonsView.frame.size.width, ROW_HEIGHT) withImage:@"income_analysis" withTitle:@"收益分析" withTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0) withImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) withButtonWidth:100];
        profitView.userInteractionEnabled = YES;
        profitView.tag = 0;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickButtons:)];
        [profitView addGestureRecognizer:singleTap];
        [buttonsView addSubview:profitView];

        //菜品分析
        BannerView *dishesView = [[BannerView alloc] initWithFrame:CGRectMake(0, profitView.frame.origin.y + profitView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT) withImage:@"dish_analysis" withTitle:@"菜品分析" withTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0) withImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) withButtonWidth:100];
        dishesView.userInteractionEnabled = YES;
        dishesView.tag = 1;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickButtons:)];
        [dishesView addGestureRecognizer:singleTap];
        [buttonsView addSubview:dishesView];
        
        //顾客分析
        BannerView *customerView = [[BannerView alloc] initWithFrame:CGRectMake(0, dishesView.frame.origin.y + dishesView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT) withImage:@"customer_analysis" withTitle:@"顾客分析" withTitleEdgeInsets:UIEdgeInsetsMake(0.0, 2.0, 0.0, 0.0) withImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) withButtonWidth:100];
        UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0);
        customerView.userInteractionEnabled = YES;
        customerView.tag = 2;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickButtons:)];
        [customerView addGestureRecognizer:singleTap];
        [buttonsView addSubview:customerView];

        //台号分析
        BannerView *barNumView = [[BannerView alloc] initWithFrame:CGRectMake(0, customerView.frame.origin.y + customerView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT) withImage:@"table_analysis" withTitle:@"台号分析" withTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0) withImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) withButtonWidth:100];
        barNumView.userInteractionEnabled = YES;
        barNumView.tag = 3;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickButtons:)];
        [barNumView addGestureRecognizer:singleTap];
        [buttonsView addSubview:barNumView];

        [self.view addSubview:buttonsView];
        
        //时间控件
        [self.timeView setTimePickerView];

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//点击按钮事件
-(IBAction)clickButtons:(id)sender{
    UIGestureRecognizer *gesture = (UIGestureRecognizer*)sender;
    NSInteger tag = [gesture view].tag;
    switch (tag) {
        case 0:
            //收益分析
            NSLog(@"收益分析");
            _profit = [[ProfitViewController alloc] initWithStime:_timeView.stime withEtime:_timeView.etime];
            [self.navigationController pushViewController:_profit animated:YES];
            break;
        case 1:
            //菜品分析
            NSLog(@"菜品分析");
            _dishes = [[DishesViewController alloc] initWithStime:_timeView.stime withEtime:_timeView.etime];
            [self.navigationController pushViewController:_dishes animated:YES];
            break;
        case 2:
            //顾客分析
            NSLog(@"顾客分析");
            _customer = [[CusViewController alloc] initWithStime:_timeView.stime withEtime:_timeView.etime];
            [self.navigationController pushViewController:_customer animated:YES];
            break;
        case 3:
            //台号分析
            NSLog(@"台号分析");
            _bar = [[BarViewController alloc] initWithStime:_timeView.stime withEtime:_timeView.etime];
            [self.navigationController pushViewController:_bar animated:YES];
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
