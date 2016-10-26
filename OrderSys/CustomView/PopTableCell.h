//
//  DishTypeCell.h
//  OrderSys
//
//  Created by Macx on 15/8/19.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopTableCell : UITableViewCell

@property(nonatomic,retain) UILabel *nameLabel; //类型名
@property(nonatomic,retain) UIView *dividerView; //分割线
@property(nonatomic,assign) CGFloat width;//cell宽度

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellWidth:(CGFloat) cellWidth  withCellHeight:(CGFloat) cellHeight;

@end
