/**
 -  BKException.m
 -  BKSDK
 -  Created by ligb on 16/11/21.
 -  Copyright © 2016年 HY. All rights reserved.
 */


#include <sys/types.h>
#include <sys/sysctl.h>
#import <sys/utsname.h>
#import "BKException.h"
#import "BKNetworking.h"
#import "BKDefineFile.h"
#import "BKSaveData.h"
#import "BKTool.h"

#define  ErrorLog @"errlog.plist"

@implementation BKException


#pragma mark - 使用AvoidCrash类，捕获到了崩溃，由于做了崩溃处理，这个时候APP不会闪退，直接上传app崩溃日志
+ (void)uploadExceptionByAvoidCrash:(NSString *)errorUrl token:(NSString *)token uuid:(NSString *)uuid crashInfo:(NSDictionary *)crashInfo {
    //获取设备类型
    NSString *deviceType = [BKTool getDeviceName];
    //手机系统版本
    NSString* VersionCode = [[UIDevice currentDevice] systemVersion];
    __block NSString *netStr = @"wi－fi";
    [[BKNetworking share] checkNetworkBlock:^(NSString *netMeg, BOOL status) {
        netStr = netMeg;
    }];
    if ([BKNetworking share].apiValues.count > 3) {
        [[BKNetworking share].apiValues removeObjectAtIndex:0];
    }
    NSString *size = NSStringFromCGSize(kSCREEN_SIZE);
    NSString *lastAPI = [[BKNetworking share].apiValues componentsJoinedByString:@"\n"];
    NSString *lastPage = [[BKSaveData getArray:kLastPageNameKey] componentsJoinedByString:@"\n"];
    NSString *text = [NSString stringWithFormat:@"Hardware Model : %@ \n Device Version : iOS %@ \n NetworkingType : %@ \n Devices Size : %@ \n Exception Type : %@ \n Version Code : %@ \n LastPage : %@ \n LastAPI : %@ \n Class Name : %@ \n Crash Reason : %@ \n Thread Stack Info : %@",deviceType, VersionCode, netStr, size, crashInfo[@"errorName"], APP_VERSION, lastPage, lastAPI, crashInfo[@"errorPlace"], crashInfo[@"errorReason"], crashInfo];
    
    NSDictionary *parameter = @{@"text":text,
                             @"machine":deviceType};
    
#ifdef DEBUG
    NSLog(@"打印debug 异常信息：%@",parameter);
#else
    if ([BKSaveData writeDicToFile:parameter fileName:ErrorLog]) {
        NSLog(@"AvoidCrash捕获错误日志成功： %@",parameter);
    }
    [self startExceptionHandler:errorUrl token:token uuid:uuid];
    
#endif
}


#pragma mark - 崩溃后APP闪退，错误日志暂时保存到本地，等下次进入APP上传崩溃日志
+ (void)startExceptionHandler:(NSString *)errorUrl token:(NSString *)token uuid:(NSString *)uuid {
    
    NSDictionary *tempDic = [BKSaveData readDicByFile:ErrorLog];
 
    //添加token，和uuid参数
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
    [paramsDic setValue:token forKey:@"token"];
    [paramsDic setValue:uuid forKey:@"uuid"];
   
    if (tempDic.allKeys.count) {
        //上传错误日志信息
        [[BKNetworking share] post:errorUrl params:paramsDic precent:^(float precent) {
        } completion:^(BKNetworkModel *model, NSString *netErr) {
            if (!netErr) {
                NSLog(@"日志上传成功");
                [BKSaveData writeDicToFile:@{} fileName:ErrorLog];
            }
        }];
    }
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *crashPage = [BKTool getCrashViewMethod:arr];
    if (crashPage == nil) {
        crashPage = @"崩溃方法定位失败";
    }
    NSString *exReason = [exception reason];//crash 原因
    NSString *exType = [exception name];//异常类型
    //获取设备类型
    NSString *deviceType = [BKTool getDeviceName];
    //手机系统版本
    NSString *VersionCode = [[UIDevice currentDevice] systemVersion];
    __block NSString *netStr = @"wi－fi";
    [[BKNetworking share] checkNetworkBlock:^(NSString *netMeg, BOOL status) {
        netStr = netMeg;
    }];
    if ([BKNetworking share].apiValues.count > 3) {
        [[BKNetworking share].apiValues removeObjectAtIndex:0];
    }
    
    NSString *size = NSStringFromCGSize(kSCREEN_SIZE);
    NSString *lastAPI = [[BKNetworking share].apiValues componentsJoinedByString:@"\n"];
    NSString *lastPage = [[BKSaveData getArray:kLastPageNameKey] componentsJoinedByString:@"\n"];
    NSString *text = [NSString stringWithFormat:@"Hardware Model : %@ \n Device Version : iOS %@ \n NetworkingType : %@ \n Devices Size : %@ \n Exception Type : %@ \n Version Code : %@ \n LastPage : %@ \n LastAPI : %@ \n Error Place : %@ \n Crash Reason : %@ \n Thread Stack Info : %@ \n " ,deviceType ,VersionCode , netStr, size, exType, APP_VERSION, lastPage, lastAPI, crashPage, exReason , arr];
   
    NSDictionary *info = @{@"text":text,
                           @"machine":deviceType
                           };
#ifdef DEBUG
    NSLog(@"打印debug 异常信息：%@",info);
#else
    if ([BKSaveData writeDicToFile:info fileName:ErrorLog]) {
        NSLog(@"错误日志信息保持成功: %@",info);
    }
#endif
}


@end
