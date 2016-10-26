//
//  ButtonView.h
//  OrderSys
//
//  Created by Macx on 15/8/6.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonView : UIButton

@property(nonatomic,assign) NSInteger isChoose;//是否已选

- (instancetype)initWithFrame:(CGRect)frame withType:(NSInteger) isChoose withTag:(NSInteger) tag withTitle:(NSString *) title;

- (void) setChooseType:(NSInteger) isChoose;

@end
