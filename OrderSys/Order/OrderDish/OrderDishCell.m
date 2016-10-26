//
//  OrderDishCell.m
//  OrderSys
//
//  Created by Macx on 15/8/17.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "OrderDishCell.h"
#import "DBImageView.h"

/**
 * 菜品管理列表cell
 **/
@implementation OrderDishCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(CGFloat) cellHeight{
    if (WIDTH_RATE >1 && WIDTH_RATE < 1.5) {
        _width = 375.0;
    }else if(WIDTH_RATE>1.5){
        _width = 621.0;
    }else if(WIDTH_RATE ==1){
        _width = 320.0;
    }else{
        //_width = 100;
    }
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        //菜品图片
        self.image = [[DBImageView alloc] initWithFrame:CGRectMake(5, 5, _width * 2/3 * 1/3, cellHeight - 10)];
        self.image.contentMode=UIViewContentModeScaleAspectFit;
        [self.image setImage:[UIImage imageNamed:@"select_yes"]];
        [self.contentView addSubview:self.image];
        
        //右侧视图
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.image.frame.origin.x + self.image.frame.size.width + 5, 5, _width * 3/4 - 15, cellHeight - 10)];
        
        //菜品名称
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rightView.frame.size.width/4, rightView.frame.size.height/3)];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel.text = @"毛肚";
        [rightView addSubview:self.nameLabel];
        
        //菜品优惠券标识
        self.shelfButton = [[UIButton alloc] initWithFrame:CGRectMake(self.nameLabel.frame.origin.x + self.nameLabel.frame.size.width + 5, 0, rightView.frame.size.width/3, rightView.frame.size.height/3)];
        self.shelfButton.userInteractionEnabled = NO;
        [self.shelfButton setImage:[UIImage imageNamed:@"select_yes"] forState:(UIControlStateNormal)];
        [rightView addSubview:self.shelfButton];
        
        
        //菜品价格
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, rightView.frame.size.height/3, rightView.frame.size.width/3, rightView.frame.size.height/3)];
        self.priceLabel.textAlignment = NSTextAlignmentLeft;
        self.priceLabel.textColor = [UIColor redColor];
        self.priceLabel.text = @"$20.5";
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.font = [UIFont systemFontOfSize:16];
        [rightView addSubview:self.priceLabel];
        
        
        //编辑按钮
        self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(rightView.frame.size.width - 50, 0, 50, rightView.frame.size.height/3)];
        self.editButton.userInteractionEnabled = YES;
        self.editButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [self.editButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.editButton.backgroundColor = [UIColor clearColor];
        [rightView addSubview:self.editButton];
        
        [self.contentView addSubview:rightView];
        
        
        //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.image.frame.origin.y + self.image.frame.size.height + 5, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        [self.contentView addSubview:self.dividerView];
        
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}


@end
