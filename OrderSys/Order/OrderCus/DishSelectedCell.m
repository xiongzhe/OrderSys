//
//  DishSelectedCell.m
//  OrderSys
//
//  Created by Macx on 15/8/14.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishSelectedCell.h"

/**
 * 已选菜品列表cell
 **/
@implementation DishSelectedCell

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
        self.image.contentMode=UIViewContentModeScaleAspectFill;
        self.image.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.image];
        
        //右侧视图
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.image.frame.origin.x + self.image.frame.size.width + 5, 5, _width * 2/3, cellHeight - 10)];
        
        //菜品名称
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rightView.frame.size.width/2, rightView.frame.size.height/3)];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel.text = @"毛肚";
        [rightView addSubview:self.nameLabel];
        
        
        //价格视图
        UIView *oprationView = [[UIView alloc] initWithFrame:CGRectMake(0, rightView.frame.size.height *2/3, rightView.frame.size.width, rightView.frame.size.height/3)];
        oprationView.backgroundColor = [UIColor clearColor];
        
        
        //菜品价格
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, oprationView.frame.size.width/4, oprationView.frame.size.height)];
        self.priceLabel.textAlignment = NSTextAlignmentLeft;
        self.priceLabel.textColor = [UIColor redColor];
        self.priceLabel.text = @"￥20.5";
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.font = [UIFont systemFontOfSize:16];
        [oprationView addSubview:self.priceLabel];
        
        //点餐份数
        self.numLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.priceLabel.frame.origin.x + self.priceLabel.frame.size.width, 0, oprationView.frame.size.width/4, oprationView.frame.size.height)];
        self.numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLabel.textColor = [UIColor redColor];
        self.numLabel.text = @"*2";
        self.numLabel.backgroundColor = [UIColor clearColor];
        self.numLabel.font = [UIFont systemFontOfSize:16];
        [oprationView addSubview:self.numLabel];
        
        //价格 * 份数
        self.totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.numLabel.frame.origin.x + self.numLabel.frame.size.width, 0, oprationView.frame.size.width/2, oprationView.frame.size.height)];
        self.totalLabel.textAlignment = NSTextAlignmentCenter;
        self.totalLabel.textColor = [UIColor redColor];
        self.totalLabel.text = @"￥41";
        self.totalLabel.backgroundColor = [UIColor clearColor];
        self.totalLabel.font = [UIFont systemFontOfSize:16];
        [oprationView addSubview:self.totalLabel];
        
        [rightView addSubview:oprationView];
        [self.contentView addSubview:rightView];
        
        
        //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.image.frame.origin.y + self.image.frame.size.height + 5, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        [self.contentView addSubview:self.dividerView];
        
        self.contentView.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
    }
    return self;
}


@end
