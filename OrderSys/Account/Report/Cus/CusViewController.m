//
//  CustomerViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/4.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "CusViewController.h"
#import "TimeView.h"
#import "VipViewController.h"
#import "FavViewController.h"
#import "EatTimesViewController.h"
#import "PerViewController.h"
#import "BannerView.h"

/**
 * 顾客分析首页
 **/
@interface CusViewController ()

@end

@implementation CusViewController

- (instancetype)initWithStime:(NSString *) stime withEtime:(NSString *) etime {
    self = [super init];
    if (self) {
        
        self.title = @"顾客分析";
        //设置导航栏
        UIColor *color = [UIColor whiteColor];
        NSDictionary * dict=[NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
        [UINavigationBar appearance] .titleTextAttributes = dict;
        //设置导航栏返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"返回";
        self.navigationItem.backBarButtonItem = backItem;
        
        
        //VIP顾客分析
        BannerView *vipView = [[BannerView alloc] initWithFrame:CGRectMake(0, STATU_BAR_HEIGHT + NAV_HEIGHT + 10, SCREEN_WIDTH, ROW_HEIGHT) withImage:@"vip" withTitle:@"VIP顾客分析" withTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0) withImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)  withButtonWidth:130];
        vipView.userInteractionEnabled = YES;
        vipView.tag = 0;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickType:)];
        [vipView addGestureRecognizer:singleTap];
        [self.view addSubview:vipView];
        
        //顾客就餐时段分析
        BannerView *eatTimesView = [[BannerView alloc] initWithFrame:CGRectMake(0, vipView.frame.origin.y + vipView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT) withImage:@"timequantum" withTitle:@"顾客就餐时段分析" withTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0) withImageEdgeInsets:UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0)  withButtonWidth:165];
        eatTimesView.userInteractionEnabled = YES;
        eatTimesView.tag = 1;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickType:)];
        [eatTimesView addGestureRecognizer:singleTap];
        [self.view addSubview:eatTimesView];
        
        //顾客偏好分析
        BannerView *favView = [[BannerView alloc] initWithFrame:CGRectMake(0, eatTimesView.frame.origin.y + eatTimesView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT) withImage:@"love" withTitle:@"顾客偏好分析" withTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0) withImageEdgeInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 0.0) withButtonWidth:130];
        favView.userInteractionEnabled = YES;
        favView.tag = 2;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickType:)];
        [favView addGestureRecognizer:singleTap];
        [self.view addSubview:favView];
        
        //人均消费
        BannerView *perView = [[BannerView alloc] initWithFrame:CGRectMake(0, favView.frame.origin.y + favView.frame.size.height + 10, SCREEN_WIDTH, ROW_HEIGHT) withImage:@"sales" withTitle:@"人均消费" withTitleEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0) withImageEdgeInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 0.0) withButtonWidth:100];
        perView.userInteractionEnabled = YES;
        perView.tag = 3;
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickType:)];
        [perView addGestureRecognizer:singleTap];
        [self.view addSubview:perView];
      
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

//点击类型事件
-(IBAction)clickType:(id)sender {
    UIGestureRecognizer *gesture = (UIGestureRecognizer*)sender;
    NSInteger tag = [gesture view].tag;
    VipViewController *vip;
    FavViewController *fav;
    EatTimesViewController *eatTimes;
    PerViewController *per;
    switch (tag) {
        case 0:
            //VIP顾客分析
            NSLog(@"VIP顾客分析");
            vip = [[VipViewController alloc] init];
            [self.navigationController pushViewController:vip animated:YES];
            break;
        case 1:
            //顾客就餐时段分析
            NSLog(@"顾客就餐时段分析");
            eatTimes = [[EatTimesViewController alloc] init];
            [self.navigationController pushViewController:eatTimes animated:YES];
            break;
        case 2:
            //顾客偏好分析
            NSLog(@"顾客偏好分析");
            fav = [[FavViewController alloc] init];
            [self.navigationController pushViewController:fav animated:YES];
            break;
        case 3:
            //人均消费
            NSLog(@"人均消费");
            per = [[PerViewController alloc] init];
            [self.navigationController pushViewController:per animated:YES];
            break;
        default:
            break;
    }
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
