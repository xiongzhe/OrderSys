//
//  TimeView.h
//  OrderSys
//
//  Created by Macx on 15/8/3.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 自定义时间控件确认事件代理
 **/
@protocol TimeViewDelegate <NSObject>

@optional
- (void) clickConfirm;

@end

@interface TimeView : UIView{
    id <TimeViewDelegate> delegate;
}
@property (nonatomic, retain) id <TimeViewDelegate> delegate;

@property(nonatomic,retain) UIViewController *viewController;//控制器

@property(nonatomic,retain) UILabel *stimeText;//开始时间
@property(nonatomic,retain) UILabel *etimeText;//结束时间
@property(nonatomic,retain) UIView *timePickerView; //时间选择器布局
@property(nonatomic,retain) UIButton *confirmButton; //时间选择器确定
@property(nonatomic,retain) UIButton *cancelButton; //时间选择器取消
@property(nonatomic,retain) UIDatePicker *datePicker; //日期选择器

@property(nonatomic,retain) NSString *stime; //开始时间
@property(nonatomic,retain) NSString *etime; //开始时间

@property(nonatomic,assign) NSInteger timeType;//当前弹出的时间类型 0 开始时间 1 结束时间

@property(nonatomic,assign) CGFloat bottomY; //view最低端的高度

- (instancetype) initWithHeight:(CGFloat) height withViewController:(UIViewController *) viewController;//初始化控件
-(void) setTimePickerView; //设置日期控件

@end
