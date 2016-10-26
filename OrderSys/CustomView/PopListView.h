//
//  PopView.h
//  OrderSys
//
//  Created by Macx on 15/8/19.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 自定义弹出列表点击事件代理
 **/
@protocol PopClickDelegate <NSObject>

@optional
- (void) clickItem:(NSInteger) index;

@end

@interface PopListView : UIView
{
    id <PopClickDelegate> delegate;
    NSInteger row; //当前点击的row
}
@property (nonatomic, retain) id <PopClickDelegate> delegate;

@property(nonatomic,retain) NSArray *datas;//数据列表
@property(nonatomic,retain) UILabel *showView;//显示视图
@property(nonatomic,assign) NSInteger type; //类型


- (instancetype)initWithFrame:(CGRect)frame withShowView:(UILabel *) showView withArray:(NSArray *) datas withBackgroundColor:(UIColor *) backColor;

- (void) addTypesLabels;

@end
