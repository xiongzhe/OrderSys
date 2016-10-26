//
//  BarCell.h
//  OrderSys
//
//  Created by Macx on 15/8/6.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponsCell : UITableViewCell

@property(nonatomic,retain) UILabel *nameLabel; //优惠券名
@property(nonatomic,retain) UILabel *infoLabel; //优惠券详细信息
@property(nonatomic,retain) UILabel *dishesLabel; //优惠券设计菜品类型
@property(nonatomic,retain) UIView *dividerView; //分割线
@property(nonatomic,assign) CGFloat width;//cell宽度

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(CGFloat) cellHeight;

@end
