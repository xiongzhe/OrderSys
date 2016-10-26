//
//  ViewController.m
//  OrderSys
//
//  Created by Macx on 15/7/27.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "ViewController.h"
#import "BarNumViewController.h"
#import "AccountViewController.h"
#import "OrderCusViewController.h"
#import "OrderBarViewController.h"
#import "OrderDishViewController.h"
#import "OrderFirstViewController.h"
#import "UploadDishViewController.h"
#import "BarCardViewController.h"
#import "HisOrderViewController.h"
#import "DBImageView.h"
#import "AccountButton.h"
#import "CommonUtil.h"

#define ROW 20

@interface ViewController ()<UITabBarControllerDelegate>

@property(nonatomic, retain) BarNumViewController *barNum;
@property(nonatomic, retain) AccountViewController *account;
@property(nonatomic, retain) OrderCusViewController *cusOrder;
@property(nonatomic, retain) OrderBarViewController *orderBar;
@property(nonatomic, retain) OrderDishViewController *orderDish;
@property(nonatomic, retain) OrderFirstViewController *orderFirst;
@property(nonatomic, retain) BarCardViewController *barCard;
@property(nonatomic, retain) HisOrderViewController *hisOrder;
@property(nonatomic, retain) UITabBarController *orderTabBar;
@property(nonatomic, retain) UITabBarController *cashierTabBar;
@property(nonatomic, retain) UIBarButtonItem *uploadRightItem;//上传菜品按钮
@property(nonatomic, retain) UIBarButtonItem *searchRightItem;//上传菜品按钮

@end

@implementation ViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //设置navigationbar的颜色
        [[UINavigationBar appearance] setBarTintColor:[UIColor redColor]];
        
        //设置导航栏
        self.title = @"重庆老灶火锅";
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
    
        //标识图
        DBImageView *headImage = [[DBImageView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT/3)];
        [headImage setImage:[UIImage imageNamed:@"main_bg"]];
        [self.view addSubview:headImage];
        
        AccountButton *button1 = [[AccountButton alloc] initWithFrame: CGRectMake(0, headImage.frame.origin.y + headImage.frame.size.height, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"点餐管理" withImage:@"zhangwu" withTag:0];
        [button1 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button1];
        
        AccountButton *button2 = [[AccountButton alloc] initWithFrame: CGRectMake(button1.frame.origin.x + button1.frame.size.width, button1.frame.origin.y, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"顾客管理" withImage:@"zhangwu" withTag:1];
        [button2 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button2];
        
        AccountButton *button3 = [[AccountButton alloc] initWithFrame: CGRectMake(button2.frame.origin.x + button2.frame.size.width, button1.frame.origin.y, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"收银管理" withImage:@"zhangwu" withTag:2];
        [button3 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button3];
        
        AccountButton *button4 = [[AccountButton alloc] initWithFrame: CGRectMake(0, button1.frame.origin.y + button1.frame.size.height, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"账务管理" withImage:@"zhangwu" withTag:3];
        [button4 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button4];
        
        AccountButton *button5 = [[AccountButton alloc] initWithFrame: CGRectMake(button4.frame.origin.x + button4.frame.size.width, button1.frame.origin.y + button1.frame.size.height, SCREEN_WIDTH/3, SCREEN_WIDTH/3) withName:@"活动管理" withImage:@"zhangwu" withTag:4];
        [button5 addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button5];
        
        //导航栏右侧上传菜品按钮
        UIButton *uploadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, NAV_HEIGHT)];
        [uploadButton setTitle:@"上传菜品" forState:UIControlStateNormal];
        uploadButton.titleLabel.textColor = [UIColor whiteColor];
        uploadButton.backgroundColor = [UIColor clearColor];
        uploadButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [uploadButton addTarget:self action:@selector(clickUploadDish:) forControlEvents:UIControlEventTouchUpInside];
        _uploadRightItem = [[UIBarButtonItem alloc] initWithCustomView:uploadButton];
        
        //导航栏右侧搜索按钮
        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, NAV_HEIGHT)];
        [searchButton setImage:[UIImage imageNamed:@"select_yes"] forState:UIControlStateNormal];
        searchButton.titleLabel.textColor = [UIColor whiteColor];
        searchButton.backgroundColor = [UIColor clearColor];
        searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [searchButton addTarget:self action:@selector(clickSearch:) forControlEvents:UIControlEventTouchUpInside];
        _searchRightItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
        
    }
    return self;
}


//点击管理模块事件
-(void) clickButtons:(id) sender{
    UIButton *button = (UIButton*) sender;
    NSInteger tag = button.tag;
    UINavigationController* navVC;
    UIBarButtonItem *backItem;
    switch (tag) {
        case 0:
            self.orderTabBar = [[UITabBarController alloc] init];
            self.orderTabBar.title = @"顾客点餐";
            backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"返回";
            self.orderTabBar.navigationItem.backBarButtonItem = backItem;
            self.orderTabBar.delegate = self;
            [[UITabBar appearance] setTintColor:[UIColor redColor]];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.backgroundColor = [UIColor whiteColor];
            self.window.rootViewController = self.orderTabBar;
            _orderFirst = [[OrderFirstViewController alloc] init];
            _orderFirst.tabBarItem.title = @"首页";
            _orderFirst.tabBarItem.image=[UIImage imageNamed:@"home"];
            _cusOrder = [[OrderCusViewController alloc] init];
            _cusOrder.tabBarItem.title = @"顾客点餐";
            _cusOrder.tabBarItem.image=[UIImage imageNamed:@"order_order_manage"];
            _orderBar = [[OrderBarViewController alloc] init];
            _orderBar.tabBarItem.title = @"台号管理";
            _orderBar.tabBarItem.image=[UIImage imageNamed:@"order_table_manage"];
            _orderDish = [[OrderDishViewController alloc] init];
            _orderDish.tabBarItem.title = @"菜品管理";
            _orderDish.tabBarItem.image=[UIImage imageNamed:@"order_dish_manage"];
            self.orderTabBar.viewControllers = [NSArray arrayWithObjects: _orderFirst ,_cusOrder, _orderBar, _orderDish, nil];
            self.orderTabBar.selectedIndex = 1;
            navVC = [[UINavigationController alloc]initWithRootViewController:self.orderTabBar];
            [navVC.navigationBar setTintColor:[UIColor whiteColor]];
            [self presentViewController:navVC animated:YES completion:nil];
            break;
        case 1:
            [CommonUtil showAlert:@"顾客管理"];
            break;
        case 2:
            self.cashierTabBar = [[UITabBarController alloc] init];
            self.cashierTabBar.title = @"收银";
            backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"返回";
            self.cashierTabBar.navigationItem.backBarButtonItem = backItem;
            self.cashierTabBar.delegate = self;
            [[UITabBar appearance] setTintColor:[UIColor redColor]];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.backgroundColor = [UIColor whiteColor];
            self.window.rootViewController = self.cashierTabBar;
            _orderFirst = [[OrderFirstViewController alloc] init];
            _orderFirst.tabBarItem.title = @"首页";
            _orderFirst.tabBarItem.image=[UIImage imageNamed:@"home"];
            _barNum = [[BarNumViewController alloc] init];
            _barNum.tabBarItem.title = @"收银";
            _barNum.tabBarItem.image=[UIImage imageNamed:@"s_sy"];
            _barCard = [[BarCardViewController alloc] init];
            _barCard.tabBarItem.title = @"储值管理";
            _barCard.tabBarItem.image=[UIImage imageNamed:@"s_czgl"];
            _hisOrder = [[HisOrderViewController alloc] init];
            _hisOrder.tabBarItem.title = @"历史订单";
            _hisOrder.tabBarItem.image=[UIImage imageNamed:@"s_lsdd"];
            self.cashierTabBar.viewControllers = [NSArray arrayWithObjects: _orderFirst ,_barNum, _barCard, _hisOrder, nil];
            self.cashierTabBar.selectedIndex = 1;
            navVC = [[UINavigationController alloc]initWithRootViewController:self.cashierTabBar];
            [navVC.navigationBar setTintColor:[UIColor whiteColor]];
            [self presentViewController:navVC animated:YES completion:nil];
            break;
        case 3:
            //[self showAlert:@"账务管理"];
            _account = [[AccountViewController alloc] init];
            [self.navigationController pushViewController:_account animated:YES];
            break;
        case 4:
            [CommonUtil showAlert:@"活动管理"];
            break;
        default:
            break;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //设置导航栏返回按钮为白色
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //设置背景颜色
    self.view.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
}

//点击不同的tabBarItem事件
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController == _orderTabBar) { //点餐管理
        NSInteger index = tabBarController.selectedIndex;
        NSString *title;
        switch (index) {
            case 0:
                [self dismissViewControllerAnimated:YES completion:nil];
                self.orderTabBar.navigationItem.rightBarButtonItem = nil;//设置右侧按钮
                break;
            case 1:
                title = @"顾客点餐";
                self.orderTabBar.navigationItem.rightBarButtonItem = nil;//设置右侧按钮
                [_cusOrder getData];
                break;
            case 2:
                title = @"台号管理";
                self.orderTabBar.navigationItem.rightBarButtonItem = nil;//设置右侧按钮
                [_orderBar getData];
                break;
            case 3:
                title = @"菜单管理";
                self.orderTabBar.navigationItem.rightBarButtonItem = _uploadRightItem;//设置右侧按钮
                [_orderDish getDishesData];
                break;
            default:
                break;
        }
        self.orderTabBar.title = title;
        
    } else { //收银管理
        NSInteger index = tabBarController.selectedIndex;
        NSString *title;
        switch (index) {
            case 0:
                [self dismissViewControllerAnimated:YES completion:nil];
                self.cashierTabBar.navigationItem.rightBarButtonItem = nil;//设置右侧按钮
                break;
            case 1:
                title = @"收银";
                self.cashierTabBar.navigationItem.rightBarButtonItem = nil;//设置右侧按钮
                break;
            case 2:
                title = @"储值管理";
                self.cashierTabBar.navigationItem.rightBarButtonItem = nil;//设置右侧按钮
                break;
            case 3:
                title = @"历史订单";
                self.cashierTabBar.navigationItem.rightBarButtonItem = _searchRightItem;//设置右侧按钮
                break;
            default:
                break;
        }
        self.cashierTabBar.title = title;
    }
}


//点击上传菜品按钮事件
-(IBAction)clickUploadDish:(id)sender {
    UploadDishViewController *uploadDish = [[UploadDishViewController alloc] initWithOrderDishInfo:nil];
    [self.orderTabBar.navigationController pushViewController:uploadDish animated:YES];
}

//点击搜索按钮事件
-(IBAction)clickSearch:(id)sender {
    NSLog(@"搜索事件");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
