//
//  CommonUtil.m
//  OrderSys
//
//  Created by Macx on 15/8/19.
//  Copyright (c) 2015年 北京星辰万合. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

//弹窗
+ (void) showAlert:(NSString *) text{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:text delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

//获取字体展示高度
+ (CGFloat)getHeight:(NSString *) content withWidth:(CGFloat) width{
    if (IOS7 >= 7.0) {
        CGSize size = CGSizeMake(width,2000); //设置一个行高上限
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]};
        CGSize labelsize =  [content boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        return labelsize.height + 10;
    } else {
        CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)];
        return contentSize.height + 10;
    }
}

//将汉字字符串转换成16进制字符串
+(Byte *)chineseToHex:(NSString*)chineseStr
{
    NSStringEncoding encodingGB18030= CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *responseData =[chineseStr dataUsingEncoding:encodingGB18030 ];
    Byte *bytes = (Byte *)[responseData bytes];
    return bytes;
}

@end
