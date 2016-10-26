//
//  DishCell.m
//  OrderSys
//
//  Created by Macx on 15/7/30.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishCell.h"

@implementation DishCell

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
        
//        //菜单名称
//        self.dishName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _width/2, cellHeight - 0.5)];
//        self.dishName.textAlignment = NSTextAlignmentLeft;
//        self.dishName.textColor = RGBColorWithoutAlpha(100, 100, 100);
//        self.dishName.font = [UIFont systemFontOfSize:15];
//        
//        //菜单数量
//        self.dishNum = [[UILabel alloc] initWithFrame:CGRectMake(self.dishName.frame.size.width, 0, _width/2, cellHeight - 0.5)];
//        self.dishNum.textAlignment = NSTextAlignmentCenter;
//        self.dishNum.textColor = RGBColorWithoutAlpha(100, 100, 100);
//        self.dishNum.font = [UIFont systemFontOfSize:15];
        
        //菜品名称
        self.dishName = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, (_width - 20) * 1/2, cellHeight - 0.5)];
        self.dishName.backgroundColor = [UIColor clearColor];
        self.dishName.textAlignment = NSTextAlignmentLeft;
        self.dishName.font = [UIFont systemFontOfSize:15.0];
        self.dishName.textColor = RGBColorWithoutAlpha(100, 100, 100);
        [self.contentView addSubview:self.dishName];
        
        //数量
        self.dishNum = [[UILabel alloc] initWithFrame:CGRectMake(self.dishName.frame.origin.x + self.dishName.frame.size.width, 0, (_width - 20)  * 1/4 , self.dishName.frame.size.height)];
        self.dishNum.backgroundColor = [UIColor clearColor];
        self.dishNum.textAlignment = NSTextAlignmentCenter;
        self.dishNum.font = [UIFont systemFontOfSize:15.0];
        self.dishNum.textColor = RGBColorWithoutAlpha(100, 100, 100);
        [self.contentView addSubview:self.dishNum];
        
        //金额
        self.dishMoney = [[UILabel alloc] initWithFrame:CGRectMake(self.dishNum.frame.origin.x + self.dishNum.frame.size.width, 0, (_width - 20)  * 1/4, self.dishName.frame.size.height)];
        self.dishMoney.backgroundColor = [UIColor clearColor];
        self.dishMoney.textAlignment = NSTextAlignmentCenter;
        self.dishMoney.font = [UIFont systemFontOfSize:15.0];
        self.dishMoney.textColor = RGBColorWithoutAlpha(100, 100, 100);
        [self.contentView addSubview:self.dishMoney];
        
        //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.dishName.frame.size.height, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        
        [self.contentView addSubview:self.dishName];
        [self.contentView addSubview:self.dishNum];
        //[self.contentView addSubview:self.dividerView];
    }
    return self;
}

@end
