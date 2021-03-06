//
//  BarCell.m
//  OrderSys
//
//  Created by Macx on 15/8/6.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "CouponsCell.h"

@implementation CouponsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(CGFloat) cellHeight {
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
        
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, _width - 10, cellHeight - 20)];
        borderView.backgroundColor = [UIColor whiteColor];
        
        //优惠券名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(borderView.frame.origin.x + 5, borderView.frame.origin.y - 2, 70, ROW_HEIGHT - 15)];
        _nameLabel.layer.cornerRadius = 3;
        _nameLabel.backgroundColor = [UIColor redColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:13.0];
        _nameLabel.text = @"满减类";
        
        //优惠券详情
        self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, borderView.frame.size.width, ROW_HEIGHT - 10)];
        self.infoLabel.backgroundColor = [UIColor clearColor];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        self.infoLabel.textColor = [UIColor redColor];
        self.infoLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [borderView addSubview:self.infoLabel];
        
        //分割线
        UIView *divider1View = [[UIView alloc] initWithFrame:CGRectMake(5, self.infoLabel.frame.origin.y + self.infoLabel.frame.size.height, borderView.frame.size.width - 10, 0.5)];
        divider1View.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        
        //涉及菜品类型标识
        UIButton *dishButton = [[UIButton alloc] initWithFrame:CGRectMake(5, divider1View.frame.origin.y + divider1View.frame.size.height, 100, ROW_HEIGHT - 30)];
        dishButton.backgroundColor = [UIColor clearColor];
        [dishButton setTitle:@"涉及菜品类型" forState:UIControlStateNormal];
        dishButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [dishButton setTitleColor:RGBColorWithoutAlpha(100, 100, 100) forState:UIControlStateNormal];
        [borderView addSubview:dishButton];
        
        //涉及菜品
        _dishesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, dishButton.frame.origin.y + dishButton.frame.size.height, borderView.frame.size.width - 40, cellHeight - ROW_HEIGHT * 2 + 40)];
        _dishesLabel.textColor = RGBColorWithoutAlpha(100, 100, 100);
        _dishesLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _dishesLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _dishesLabel.textAlignment = NSTextAlignmentLeft;
        _dishesLabel.numberOfLines = 0;
        [borderView addSubview:_dishesLabel];
        
        [self.contentView addSubview:borderView];
        [self.contentView addSubview:_nameLabel];
        
        //分割线
        self.dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, borderView.frame.origin.y + borderView.frame.size.height, _width, 0.5)];
        self.dividerView.backgroundColor = RGBColor(235.0, 235.0, 235.0, 1.0);
        //[self.contentView addSubview:self.dividerView];
        self.contentView.backgroundColor = RGBColorWithoutAlpha(226, 229, 228);
    }
    return self;
}


@end
