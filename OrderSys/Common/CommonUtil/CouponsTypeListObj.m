//
//  CouponsTypeListObj.m
//  OrderSys
//
//  Created by Macx on 15/8/29.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "CouponsTypeListObj.h"

@implementation CouponsTypeListObj

//名称 	值 	说明
//NONE	0	购买
//Full_Cut	1	满减
//Full_Discount	2	满折
//Deduction	3	无条件扣减
//Discount	4	无条件打折
//Credit_Money	5	积分对换金额
//Credit_Buy	6	积分对换菜品
//Buy_Present	17	买赠
//Full_Present	18	满赠
//Force_Present	20	无条件赠送

+ (NSArray *) getTypeList {
    NSArray *couponsTypes = [[NSArray alloc] initWithObjects: @"满减", @"满折",@"无条件扣减", @"无条件打折", @"买赠", @"满赠",@"无条件赠送",  nil];
    return couponsTypes;
}

+ (NSString *) getTypeById: (NSString *) typeRet {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *couponsTypes = [[NSArray alloc] initWithObjects:@"购买", @"满减", @"满折",@"无条件扣减", @"无条件打折",@"积分兑换金额",@"积分兑换菜品", @"买赠", @"满赠",@"无条件赠送",  nil];
    NSArray *couponsRet = [[NSArray alloc] initWithObjects:@"NONE", @"Full_Cut",@"Full_Discount", @"Deduction",@"Discount", @"Credit_Money", @"Credit_Buy",@"Buy_Present",@"Full_Present",@"Force_Present",  nil];
    for (int i=0; i<[couponsTypes count]; i++) {
        [dic setObject:[couponsTypes objectAtIndex:i] forKey:[couponsRet objectAtIndex:i]];
    }
    if ([typeRet isEqualToString:@"Credit_Money"] || [typeRet isEqualToString:@"Credit_Buy"]) {
        return nil;
    } else {
        return [dic objectForKey:typeRet];
    }
}

@end
