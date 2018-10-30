/**
 - BKMobile
 - SmiliesManager.h
 - Created by HY on 2018/7/20.
 - Copyright © 2018年 com.mobile-kingdom.bkapps. All rights reserved.
 - 说明：表情管理类，管理表情的下载和使用
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ToolHeader.h"
#import "SmiliesModel.h"

@interface SmiliesManager : NSObject


//存储表情数据源
@property (nonatomic , strong) NSMutableArray *smiliesArray;


/**
 获取实例

 @return 返回当前实例对象
 */
+ (SmiliesManager *)sharedInstance;


/**
 下载表情数据
 */
- (void)mDownloadSmilies;


/**
 根据表情代码，返回本地表情图片
 
 @param str 传入表情代码
 @return 返回表情UIImage
 */
- (UIImage *)coreImageRuleMate:(NSString *)str;


/**
 根据表情代码，返回本地表情路径
 
 @param str 传入表情代码
 @return 返回表情路径
 */
- (NSString *)coreImagePath:(NSString *)str;

@end
