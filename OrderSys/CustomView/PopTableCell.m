//
//  DishTypeCell.m
//  OrderSys
//
//  Created by Macx on 15/8/19.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "PopTableCell.h"

@implementation PopTableCell

/**
 * 菜品列表cell
 **/
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellWidth:(CGFloat) cellWidth withCellHeight:(CGFloat) cellHeight {
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
        
        self.contentView.backgroundColor = RGBColor(60, 60, 60, 0.8);
        
        //类型名
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cellWidth - 20, cellHeight - 0.5)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:self.nameLabel];
        
               //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        [self.contentView addSubview:self.dividerView];
        
    }
    return self;
}


@end
