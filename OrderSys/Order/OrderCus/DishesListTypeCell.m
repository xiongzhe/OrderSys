//
//  DishesListTypeCell.m
//  OrderSys
//
//  Created by Macx on 15/8/13.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishesListTypeCell.h"

/**
 * 菜品左侧类型列表cell
 **/
@implementation DishesListTypeCell


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
        
        //类型名称
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _width / 6, cellHeight)];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
        
        //已点数量
        self.numLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width, 5, _width/12, cellHeight/2)];
        self.numLabel.layer.cornerRadius = 10;
        self.numLabel.layer.masksToBounds = YES;
        self.numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLabel.textColor =[UIColor whiteColor];
        self.numLabel.backgroundColor = [UIColor redColor];
        self.numLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.numLabel];
        
        
        //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.numLabel.frame.origin.y + self.numLabel.frame.size.height, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        //[self.contentView addSubview:self.dividerView];
        
        self.contentView.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
    }
    return self;
}


@end
