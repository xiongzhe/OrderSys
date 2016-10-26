//
//  WHInterfaceUtil.h
//  TestLabManager
//
//  Created by 张润潮 on 14-9-22.
//  Copyright (c) 2014年 xingchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
@interface WHInterfaceUtil : NSObject<ASIHTTPRequestDelegate>
+(NSString*) serverUrlSuffix:(NSString*) str;
+(NSString*) serverPath;
+(NSString*) sendMessageToServerUrlSuffix:(NSString*) url param:(NSDictionary*) param;
//+(NSString *) jsonStringWithString:(NSString *) string;
//+(NSString *) jsonStringWithArray:(NSArray *)array;
//+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary;
//+(NSString *) jsonStringWithObject:(id) object;
+(BOOL) isValid:(NSObject*)obj;
+(NSDictionary*) sendMessageToServerUrl:(NSString*) url param:(NSString*) param urlValue:(NSString*) value;
//+(BOOL) sendMessageToServerUrlResultCode:(NSString*) url param:(NSDictionary*) param urlValue:(NSString*) value;
+(BOOL) sendMessageToServerUrlNoResult:(NSString*) url param:(NSDictionary*) param urlValue:(NSString*) value;

+(NSString *) boolToJsonString:(NSString *) name withValue:(Boolean) value;
+(NSString *) stringToJsonString:(NSString *) name withValue:(NSString *) value;
+(NSString *) charPointerToJsonString:(NSString *) name withValue:(char *) value;
+(NSString *) intToJsonString:(NSString *) name withValue:(int) value;
+(NSString *) longToJsonString:(NSString *) name withValue:(long long) value;
+(NSString *) byteArrayToJsonString:(NSString *) name withValue:(  char  *) value withLength:(int) length;

+(NSDictionary*) loginWithUrl:(NSString*) url urlValue:(NSString*) value withParams:(NSDictionary *) params;
+(NSDictionary*) noLoginWithUrl:(NSString*) url urlValue:(NSString*) value withParams:(NSString *) paramsStr;

@end
