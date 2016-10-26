//
//  OrderDishInfo.h
//  OrderSys
//
//  Created by Macx on 15/8/17.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderDishInfo : NSObject

//            菜品ID	DishId	long	N	添加时传-1
//            菜品名称	DishName	String	N
//            菜品类型ID	TypeId	long
//            菜品类型名称	TypeName	String
//            菜品价格	DishPrice	int	N
//            菜品数量	DishCount	Integer	Y	如果count为int.max 表示不用计算库存，否则大于0表示需要计算库存
//            菜品图片	DishPic	String	N
//            菜品介绍	DishDesc	String	Y
//            菜品状态	DishStatus	EnumFoodStatus	N	0 下架 1 上架
//            用户是否有实物优惠券	IsHavePromotion	Integer	Y	0没有 1有
//            实物优惠券id	PromotionId	Integer	Y

@property(nonatomic,assign) NSInteger DishId; //菜品id
@property(nonatomic,retain) NSString *DishName; //菜名
@property(nonatomic,retain) NSNumber *DishPrice; //价格
@property(nonatomic,retain) NSString *DishPic; //图片url
@property(nonatomic,assign) NSInteger TypeId; //菜品类型id
@property(nonatomic,retain) NSString *TypeName; //菜品类型名
@property(nonatomic,retain) NSString *DishDesc; //菜品介绍
@property(nonatomic,assign) NSInteger DishCount; //库存
@property(nonatomic,assign) NSInteger DishStatus; //是否上架 0 下架  1 上架
@property(nonatomic,assign) NSInteger IsHavePromotion; //用户是否有实物优惠券 0没有 1有
@property(nonatomic,assign) NSInteger PromotionId; //实物优惠券id

@end
