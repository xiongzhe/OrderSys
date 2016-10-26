//
//  FlowsTypeListObj.m
//  OrderSys
//
//  Created by Macx on 15/8/27.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "FlowsTypeListObj.h"

@implementation FlowsTypeListObj

+ (NSArray *) getTypeRetList {
    NSArray *flowsRetTypes = [[NSArray alloc] initWithObjects:@"ShouldIn", @"Discount",@"WhenSpending", @"Vouchers",@"Score", @"Int",@"Recharge", @"Charge",@"Rent", @"WaterFee",@"ElectricCharge",@"Salary", @"Award",@"Material", @"OtherRevenue", @"OtherSpending",  nil];
    return flowsRetTypes;
}

+ (NSArray *)getTypeList
{
    NSArray *flowsTypes = [[NSArray alloc] initWithObjects:@"未打折应收", @"打折",@"满减", @"代金劵抵扣",@"积分抵扣", @"抹零",@"预付费充值", @"预付费结帐",@"房租", @"水费",@"电费",@"人员工资", @"人员奖金",@"材料采购", @"其它非经营收入", @"其它非经营支出",  nil];
    return flowsTypes;
}

+ (NSArray *)getTypeNumList
{
    NSArray *flowsNumTypes = [[NSArray alloc] initWithObjects:@"1", @"100",@"200", @"300",@"400", @"500",@"600", @"700",@"1000", @"1001",@"1002", @"1003",@"1004", @"1005", @"1100",@"1200",  nil];
    return flowsNumTypes;
}

@end
