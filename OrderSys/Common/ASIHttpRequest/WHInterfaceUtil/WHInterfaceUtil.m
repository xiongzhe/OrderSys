//
//  WHInterfaceUtil.m
//  TestLabManager
//
//  Created by 张润潮 on 14-9-22.
//  Copyright (c) 2014年 xingchen. All rights reserved.
//

#import "WHInterfaceUtil.h"
#import "ASIFormDataRequest.h"
#import "NotifyClient.h"
#import "SecretUtil.h"
#import "AppDelegate.h"
#import "GlobeVars.h"

@implementation WHInterfaceUtil

//接口url
+(NSString*) serverPath{
    return @"http://210.14.154.178:18890";
}

+(NSString *) boolToJsonString:(NSString *) name withValue:(Boolean) value{
    if (value) {
        return [NSString stringWithFormat:@"\"%@\":%@",name,@"true"];
    } else {
        return [NSString stringWithFormat:@"\"%@\":%@",name,@"false"];
    }
}

+(NSString *) stringToJsonString:(NSString *) name withValue:(NSString *) value{
    return [NSString stringWithFormat:@"\"%@\":\"%@\"",name,value];
}

+(NSString *) charPointerToJsonString:(NSString *) name withValue:(char *) value{
    return [NSString stringWithFormat:@"\"%@\":\"%s\"",name,value];
}

+(NSString *) intToJsonString:(NSString *) name withValue:(int) value{
    return [NSString stringWithFormat:@"\"%@\":%d",name,value];
}

+(NSString *) longToJsonString:(NSString *) name withValue:(long long) value{
    return [NSString stringWithFormat:@"\"%@\":%lld",name,value];
}

+(NSString *) byteArrayToJsonString:(NSString *) name withValue:(  char  *) value withLength:(int) length{
    char * buffer =  alloca(length*10)+100;
    char * ptr = buffer;
    
    ptr+=sprintf(ptr,"[%d",  value[0] );
    
    for (int i =1 ;i<length;i++)
    {
        ptr+=sprintf(ptr,",%d",  value[i] );
    }
   
    *ptr=']';
    ptr++;
    *ptr=0;
    
    NSString * ret = [NSString stringWithFormat:@"\"%@\":%s",name,buffer];
  //  ::free(buffer);
    return ret;
}


//拼接接口url
+(NSString*) serverUrlSuffix:(NSString*) suffix{
    NSString *serverPath=[[NSString alloc] initWithFormat:@"%@/%@",[WHInterfaceUtil serverPath],suffix];
    return serverPath;
}


//解析接口参数（参数是个字符串）
+(NSString *) jsonStringWithString:(NSString *) string{
    return [NSString stringWithFormat:@"\"%@\"",
            [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""]
            ];
}

//解析接口参数（参数是个array）
+(NSString *) jsonStringWithArray:(NSArray *)array{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [WHInterfaceUtil jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}

//解析接口参数（参数是个dictionary）
+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary{
    NSArray *keys = [dictionary allKeys];
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"{"];
    NSMutableArray *keyValues = [NSMutableArray array];
    for (int i=0; i<[keys count]; i++) {
        NSString *name = [keys objectAtIndex:i];
        id valueObj = [dictionary objectForKey:name];
        NSString *value = [WHInterfaceUtil jsonStringWithObject:valueObj];
        if (value) {
            [keyValues addObject:[NSString stringWithFormat:@"\"%@\":%@",name,value]];
        }
    }
    [reString appendFormat:@"%@",[keyValues componentsJoinedByString:@","]];
    [reString appendString:@"}"];
    return reString;
}

//解析接口参数
+(NSString *) jsonStringWithObject:(id) object{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [WHInterfaceUtil jsonStringWithString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        value = [WHInterfaceUtil jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]){
        value = [WHInterfaceUtil jsonStringWithArray:object];
    }
    return value;
}


//判断接口返回值是否为空
+(BOOL) isValid:(NSObject*)obj{
    if ((NSNull*)obj != [NSNull null]) {
        return YES;
    }else{
        return NO;
    }
}

//普通接口调用
+(NSDictionary*) sendMessageToServerUrlSuffix:(NSString*) url param:(NSDictionary*) param{
    NSURL *u = [NSURL URLWithString:url];
    ASIFormDataRequest *request =[ASIFormDataRequest requestWithURL:u];
    [request setRequestMethod:@"POST"];
    [request setValidatesSecureCertificate:NO];
    if (param!=nil) {
        for (NSString *key in param) {
            [request addPostValue:param[key] forKey:key];
        }
    }
    [request startSynchronous];
    NSError *error1 = [request error];
    NSData *resData = [request responseData];
    if (!error1 && resData) { //获取成功
        NSDictionary *dics = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        return dics;
    } else{ //获取失败
        return nil;
    }
}


//星辰万合框架专用
+(NSDictionary*) sendMessageToServerUrl:(NSString*) url param:(NSString*) param urlValue:(NSString*) value{
    NSMutableData *tempJsonData = [NSMutableData dataWithData:nil];
    NSString *urlStr = [self serverUrlSuffix:url];
    NSURL *u = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:u];
    if (param!=nil) {
        NSData *jsonData = [param dataUsingEncoding: NSUTF8StringEncoding];
        tempJsonData = [NSMutableData dataWithData:jsonData];
    }
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setValidatesSecureCertificate:NO];
    [request addRequestHeader:@"JSONAction" value:value];
    [request setPostBody:tempJsonData];
    [request startSynchronous];
    NSError *error1 = [request error];
    if (!error1) {
        NSString *response = [request responseString];
        response = [response stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        response = [response stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        response = [response stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSData *resData = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
        NSError *error = nil;
        NSDictionary *dics = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:&error];
        if(dics != nil || [dics count] != 0){
            return dics;
        } else {
            return nil;
        }
    }else{
        NSLog(@"i'm error.%@",error1);
    }
    return nil;
}

//星辰万合框架专用(无返回数据)
+(BOOL) sendMessageToServerUrlNoResult:(NSString*) url param:(NSDictionary*) param urlValue:(NSString*) value{
    NSMutableData *tempJsonData = [NSMutableData dataWithData:nil];
    NSString *urlStr = [self serverUrlSuffix:url];
    NSURL *u = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:u];
    if (param!=nil) {
        NSData *jsonData = [[self jsonStringWithDictionary:param] dataUsingEncoding: NSUTF8StringEncoding];
        tempJsonData = [NSMutableData dataWithData:jsonData];
    }
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setValidatesSecureCertificate:NO];
    [request addRequestHeader:@"JSONAction" value:value];
    [request setPostBody:tempJsonData];
    [request startSynchronous];
    NSError *error1 = [request error];
    if (!error1) {
        NSString *response = [request responseString];
        response = [response stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        response = [response stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        response = [response stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        if([response isEqualToString:[[NSString alloc]  initWithFormat:@"Success"]]){
            return YES;
        } else {
            return NO;
        }
    }else{
        NSLog(@"i'm error.%@",error1);
    }
    return NO;
}



//登录接口
+(NSDictionary*) loginWithUrl:(NSString*) url urlValue:(NSString*) value withParams:(NSDictionary *) params {
    NSString *unameStr = [params objectForKey:@"uname"];
    NSString *pwdStr = [params objectForKey:@"pwd"];
    const char *uname =[unameStr UTF8String];
    const char *pwd =[pwdStr UTF8String];
    //获取时间戳
    int timeStamp = [SecretUtil getTimestamp];
    //获取token
    unsigned char token[16];
    createSecretKey((unsigned char *)token);
    //获取加密mac地址、加密密码
    unsigned long long iMac=[SecretUtil getIMac];
    unsigned long long secMac = getCryptedWLanMAC(token, iMac, timeStamp);
    char cryptedPasswd[33];
    getCryptedPassword(iMac, uname, pwd, timeStamp, (unsigned char *)token, (char *)cryptedPasswd);
    NSString *param =[NSString stringWithFormat:@"{%@,%@,%@,%@,%@,%@,%@}"
                      ,[WHInterfaceUtil stringToJsonString:@"name" withValue:unameStr]
                      ,[WHInterfaceUtil intToJsonString:@"version" withValue:(int)[params objectForKey:@"version"]]
                      ,[WHInterfaceUtil intToJsonString:@"system" withValue:(int)[params objectForKey:@"system"]]
                      ,[WHInterfaceUtil intToJsonString:@"timeStamp" withValue:timeStamp]
                      ,[WHInterfaceUtil byteArrayToJsonString:@"secrtKey" withValue: (char *)token withLength:16]
                      ,[WHInterfaceUtil charPointerToJsonString:@"pwd" withValue: cryptedPasswd ]
                      ,[WHInterfaceUtil longToJsonString:@"iden" withValue:(secMac)]
                      ];
    NSLog(@"%@",param);
   
    NSDictionary *dics = [self sendMessageToServerUrl:url param:param urlValue:value];
    return dics;

}

//非登录接口
+(NSDictionary*) noLoginWithUrl:(NSString*) url urlValue:(NSString*) value withParams:(NSString *) paramsStr{
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    NSNumber *uid = app.loginInfo.uid;
    NSNumber *rid = app.loginInfo.rid;
    //获取时间戳
    int timeStamp = [SecretUtil getTimestamp];
    uint64_t uid64 = (uint64_t)cryptLongWithTimeStamp(gLoginRespToken, timeStamp, [uid longLongValue]);
    uint64_t rid64 = (uint64_t)cryptLongWithTimeStamp(gLoginRespToken, timeStamp, [rid longLongValue]);
    //获取加密mac地址、加密密码
    unsigned long long iMac=[SecretUtil getIMac];
    unsigned long long secMac = getCryptedWLanMAC(gLoginRespToken, iMac, timeStamp);
    NSString *param =[NSString stringWithFormat:@"{%@,%@,%@,%@,%@"
                      ,[WHInterfaceUtil longToJsonString:@"uId" withValue:uid64]
                      ,[WHInterfaceUtil longToJsonString:@"rId" withValue:rid64]
                      ,[WHInterfaceUtil intToJsonString:@"timeStamp" withValue:timeStamp]
                      ,[WHInterfaceUtil byteArrayToJsonString:@"token" withValue: (char *)gLoginRespToken withLength:16]
                      ,[WHInterfaceUtil longToJsonString:@"iden" withValue:(secMac)]
                      ];
    if (paramsStr != nil) {//判断是否有其他参数
        param = [NSString stringWithFormat:@"%@,%@", param, paramsStr];
    }
    param = [NSString stringWithFormat:@"%@}", param];
    NSLog(@"%@",param);
    
    
    NSDictionary *dics = [self sendMessageToServerUrl:url param:param urlValue:value];
    return dics;
}


@end
