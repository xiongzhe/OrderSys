//
//  MLButton.m
//  GCDTemp
//
//  Created by molon on 5/21/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLButton.h"
#import "UIView+ColorPointAndMask.h"

@implementation MLButton

#define logo_width 50
#define logo_height 52

@synthesize row,column;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    float width =  self.frame.size.width;
    float height =  self.frame.size.height;
    
    return CGRectMake(0, height/2+10, width, 25);
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    float width =  self.frame.size.width;
    float height =  self.frame.size.height;
    return CGRectMake(width/2 - logo_width/2, height/2-logo_height/6*5, logo_width, logo_height);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL result = [super pointInside:point withEvent:event];
    if (!self.isIgnoreTouchInTransparentPoint) {
        return result;
    }
    
    if (result) {
        return ![self isTansparentOfPoint:point];
    }
    return NO;
}

@end
