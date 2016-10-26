//
//  SqliteUtil.m
//  TestLabManager
//
//  Created by 张润潮 on 14-9-17.
//  Copyright (c) 2014年 xingchen. All rights reserved.
//

#import "SqliteUtil.h"
//#import "LoginInfo.h"
//#import "GoodsOrderInfo.h"
//#import "AddressInfo.h"

@implementation SqliteUtil

////创建数据库
//+(FMDatabase*) createOrOpenDatabase{
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    //dbPath： 数据库路径，在Document中。
//    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"helper.db"];
//    //创建数据库实例 db  这里说明下:如果路径中不存在"helper.db"的文件,sqlite会自动创建"Test.db"
//    FMDatabase *db= [FMDatabase databaseWithPath:dbPath] ;
//    if (![db open]) {
//        NSLog(@"Could not open db.");
//        return nil;
//    }else{
//        return db;
//    }
//}
//
////创建表
//+(BOOL) createDefaultTables{
//    FMDatabase *db=[SqliteUtil createOrOpenDatabase];
//    if (db!=nil) {
//        BOOL b;
//
//        //用户养老卡绑定表
//        BOOL b1 = [db executeUpdate:@"CREATE TABLE user_info (id integer primary key autoincrement,cert_id text,card_id text, is_auto integer)"];
//        if (b1) {
//            LoginInfo *loginInfo = [[LoginInfo alloc] init];
//            loginInfo.cert_id = @"123";
//            loginInfo.card_id = @"456";
//            loginInfo.is_auto = 0; //默认没有自动登录
//            [SqliteUtil insertLoginInfo:loginInfo];
//        }
//        
//        
//        //个人订单表
//        BOOL b2 = [db executeUpdate:@"CREATE TABLE gorder_info (id integer primary key autoincrement,gorder_id integer,gorderNum text,status integer,time text)"];
//        
//        
//        if (b1 && b2) {
//            b = YES;
//        }
//        return b;
//    }else{
//        return NO;
//    }
//   
//}
//
//
///* 用户养老卡绑定表 */
//
//
////插入数据
//+(BOOL) insertLoginInfo:(LoginInfo *) info{
//    FMDatabase *db=[SqliteUtil createOrOpenDatabase];
//    NSString *sql = @"insert into user_info (cert_id,card_id,is_auto) values(?, ?, ?)";
//    BOOL b=[db executeUpdate:sql,info.cert_id, info.card_id, [NSNumber numberWithInt:info.is_auto]];
//    [db close];
//    return b;
//}
//
////更新数据
//+(BOOL) updateLoginInfo:(LoginInfo *) info{
//    FMDatabase *db=[SqliteUtil createOrOpenDatabase];
//    NSString *sql =@"update user_info set cert_id=?,card_id=?, is_auto=? where id=1";
//    BOOL b=[db executeUpdate:sql,info.cert_id, info.card_id,[NSNumber numberWithInt:(info.is_auto)]];
//    [db close];
//    return b;
//}
//
////获取数据
//+(LoginInfo *) getLoginInfo{
//    FMDatabase *db=[SqliteUtil createOrOpenDatabase];
//    NSString *sql =@"select * from user_info";
//    FMResultSet *rs=[db executeQuery:sql];
//    LoginInfo *info = [[LoginInfo alloc] init];
//    while ([rs next]){
//        info.cert_id = [rs stringForColumn:@"cert_id"];
//        info.card_id = [rs stringForColumn:@"card_id"];
//        info.is_auto = [rs intForColumn:@"is_auto"];
//    }
//    [rs close];
//    
//    return info;
//}
//
//
//
//
//
///*******服务商信息******/
//
//
//
////读取外部db文件，sqlite文件复制到沙盒中
//+(NSString *)readDatabase:(NSString *)DBNAME{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *filePath = [paths objectAtIndex:0];
//    NSString *file = [filePath stringByAppendingPathComponent:DBNAME];
//    NSFileManager *fm = [NSFileManager defaultManager];
//    BOOL isExist = [fm fileExistsAtPath:DBNAME];
//    if (!isExist) {
//        NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:DBNAME ofType:nil];
//        [fm copyItemAtPath:backupDbPath toPath:file error:nil];
//    }
//    return file;
//}
//
//
////创建服务商外部数据库service_shop.db
//+(FMDatabase*) OpenShopDatabase{
//    NSString *dbPath = [self readDatabase:@"service_shop.db"];
//    FMDatabase *db= [FMDatabase databaseWithPath:dbPath];
//    if (![db open]) {
//        NSLog(@"Could not open db.");
//        return nil;
//    }else{
//        return db;
//    }
//}
//
////获取北京所有区的信息
//+(NSMutableArray *) getAreaInfo{
//    FMDatabase *db=[SqliteUtil OpenShopDatabase];
//    NSString *sql =@"select * from location_info where parentid=2";
//    FMResultSet *rs=[db executeQuery:sql];
//    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
//    AddressInfo *info;
//    while ([rs next]){
//        info = [[AddressInfo alloc] init];
//        info.area_id = [[rs stringForColumn:@"id"] integerValue];
//        info.area_name = [rs stringForColumn:@"name"];
//        [array addObject:info];
//    }
//    [rs close];
//    return array;
//}

@end
