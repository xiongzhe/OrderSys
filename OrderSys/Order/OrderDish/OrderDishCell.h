//
//  OrderDishCell.h
//  OrderSys
//
//  Created by Macx on 15/8/17.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBImageView.h"

@interface OrderDishCell : UITableViewCell

@property(nonatomic,retain) DBImageView *image; //图片
@property(nonatomic,retain) UILabel *nameLabel; //菜品名称
@property(nonatomic,retain) UIButton *shelfButton; //是否上架标识
@property(nonatomic,retain) UILabel *priceLabel; //菜品价格
@property(nonatomic,retain) UIButton *editButton; //编辑按钮
@property(nonatomic,retain) UIView *dividerView; //分割线
@property(nonatomic,assign) CGFloat width;//cell宽度

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(CGFloat) cellHeight;

@end
