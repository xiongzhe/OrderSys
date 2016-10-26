//
//  CouponsTypeListObj.h
//  OrderSys
//
//  Created by Macx on 15/8/29.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 优惠券类型列表
 **/
@interface CouponsTypeListObj : NSObject

+ (NSArray *) getTypeList;

+ (NSString *) getTypeById:(NSString *) typeRet;

@end
