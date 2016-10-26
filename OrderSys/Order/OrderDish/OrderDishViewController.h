//
//  OrderDishViewController.h
//  OrderSys
//
//  Created by Macx on 15/8/12.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDishInfo.h"
#import "OrderDishDelegate.h"

@interface OrderDishViewController : UIViewController{
    id <OrderDishDelegate> delegate;
}

@property(nonatomic,retain) id<OrderDishDelegate> delegate;

//获取菜单列表
-(void)getDishesData;

@end
