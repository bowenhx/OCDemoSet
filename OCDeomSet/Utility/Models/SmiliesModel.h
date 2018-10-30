/**
 - BKMobile
 - SmiliesModel.h
 - Created by HY on 2018/7/20.
 - Copyright © 2018年 com.mobile-kingdom.bkapps. All rights reserved.
 - 说明：表情数据模型
 */

#import <Foundation/Foundation.h>

@interface SmiliesModel : NSObject

//表情代码
@property (nonatomic , copy) NSString *search;

//表情本地的url
@property (nonatomic , copy) NSString *replace;

@end
