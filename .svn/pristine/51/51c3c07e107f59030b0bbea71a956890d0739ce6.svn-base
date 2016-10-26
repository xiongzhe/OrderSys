//
//  DishingCell.m
//  OrderSys
//
//  Created by Macx on 15/8/14.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "DishingCell.h"
#import "ButtonView.h"

/**
 * 顾客点餐已点菜或已上全菜单列表cell
 **/
@implementation DishingCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(CGFloat) cellHeight withPercentArray:(NSArray *) percents{
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
        
        //菜名
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (_width - 20) *[[percents objectAtIndex:0] floatValue], cellHeight - 0.5)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        self.nameLabel.font = [UIFont systemFontOfSize:14.0];
        self.nameLabel.text = @"毛肚";
        [self.contentView addSubview:self.nameLabel];
        
        //数量
        self.numLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.frame.origin.x + self.nameLabel.frame.size.width, 0, (_width - 20) *[[percents objectAtIndex:1] floatValue], self.nameLabel.frame.size.height)];
        self.numLabel.backgroundColor = [UIColor clearColor];
        self.numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        self.numLabel.font = [UIFont systemFontOfSize:14.0];
        self.numLabel.text = @"1";
        [self.contentView addSubview:self.numLabel];
        
        //服务员状态
        self.kitchenButton = [[ButtonView alloc] initWithFrame:CGRectMake(self.numLabel.frame.origin.x + self.numLabel.frame.size.width+ 10, 10, (_width - 20) *[[percents objectAtIndex:2] floatValue] - 20, self.nameLabel.frame.size.height - 20) withType:0 withTag:0 withTitle:@"未上"];
        [self.contentView addSubview:self.kitchenButton];
        
        //后厨状态
        self.waiterButton = [[ButtonView alloc] initWithFrame:CGRectMake(self.kitchenButton.frame.origin.x + self.kitchenButton.frame.size.width + 20, 10, (_width - 20) *[[percents objectAtIndex:3] floatValue] - 20, self.nameLabel.frame.size.height - 20) withType:0 withTag:0 withTitle:@"未上"];
        [self.contentView addSubview:self.waiterButton];
        
        //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        [self.contentView addSubview:self.dividerView];
    }
    return self;
}

@end
