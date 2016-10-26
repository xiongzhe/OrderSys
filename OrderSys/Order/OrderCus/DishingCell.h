//
//  DishingCell.h
//  OrderSys
//
//  Created by Macx on 15/8/14.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonView.h"

@interface DishingCell : UITableViewCell

@property(nonatomic,retain) UILabel *nameLabel; //菜名
@property(nonatomic,retain) UILabel *numLabel; //数量
@property(nonatomic,retain) ButtonView *waiterButton; //服务员状态
@property(nonatomic,retain) ButtonView *kitchenButton; //后厨状态
@property(nonatomic,retain) UIView *dividerView; //分割线
@property(nonatomic,assign) CGFloat width;//cell宽度

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(CGFloat) cellHeight withPercentArray:(NSArray *) percents;

@end
