//
//  CouponsInfo.h
//  OrderSys
//
//  Created by Macx on 15/8/20.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 优惠券实体
 **/
@interface CouponsInfo : NSObject

@property(nonatomic,assign) NSInteger PromotionId; //id
@property(nonatomic,assign) NSInteger *PromotionTypeId; //优惠券类型id
@property(nonatomic,retain) NSString *PromotionType; //优惠券类型名
@property(nonatomic,assign) CGFloat HighTrigger; //最高限额
@property(nonatomic,assign) CGFloat LowTrigger; //触发门限 用于满减、满折、满赠， 买赠为购买数
@property(nonatomic,assign) NSInteger DiscountRate; //折扣率
@property(nonatomic,retain) NSString* PresentFoodName;//赠送菜品名
@property(nonatomic,assign) NSInteger PresentCount;//赠送数量
@property(nonatomic,assign) CGFloat DiscountAmount;//折扣金额 用于扣减
@property(nonatomic,retain) NSString* BuyFoodName;//购买菜品名
@property(nonatomic,retain) NSArray *WithDishTypeNames; //优惠券涉及菜品
@property(nonatomic,retain) NSString *dishTypeStr; //优惠券涉及菜品字符串

@end
