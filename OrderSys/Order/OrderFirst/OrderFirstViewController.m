//
//  OrderFirstViewController.m
//  OrderSys
//
//  Created by Macx on 15/8/12.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "OrderFirstViewController.h"

/**
 * 点餐管理首页
 **/
@interface OrderFirstViewController ()

@end

@implementation OrderFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(IBAction)clickButton:(id)sender{
    NSLog(@"返回");
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
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
