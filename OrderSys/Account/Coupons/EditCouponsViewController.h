//
//  EditCouponsViewController.h
//  OrderSys
//
//  Created by Macx on 15/8/6.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponsInfo.h"

@interface EditCouponsViewController : UIViewController

- (instancetype)initWithType:(NSInteger) type withCouponsInfo:(CouponsInfo *) couponsInfo;

@end
