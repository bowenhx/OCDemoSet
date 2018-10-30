/**
 -  BKSDK.h
 -  BKSDK
 -  Created by ligb on 2017/3/29.
 -  Copyright © 2017年 BaByKingdom. All rights reserved.
 -  外部使用BKSDK，只需导入 #import <BKSDK/BKSDK.h> 
 -  包含了所有的对外公开使用类的头文件
 */


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


/** -------------- 常用工具 -------------- */

//常用宏定义
#import "BKDefineFile.h"

//网络交互模块
#import "BKNetworking.h"

//工具类
#import "BKTool.h"

//数据存储
#import "BKSaveData.h"

//上传崩溃信息
#import "BKException.h"

//自定义导航栏view
#import "BKCustomNavigation.h"

//自定义滑动view
#import "BKMenuViewController.h"

//UIWindow的类别
#import "UIWindow+Util.h"

//UIImage的类别
#import "UIImage+Util.h"

//UIView的类别
#import "UIView+Util.h"

//UIImageView的类别
#import "UIImageView+PlayGIF.h"

//清除缓存
#import "BKCleanCache.h"

//显示内存使用和cpu使用的类
#import "BKMemoryUsege.h"


/** -------------- 第三方开源库 -------------- */

//友盟统计
#import "MobClick.h"

//加密解密第三方库
#import "AESCrypt.h"

//防止崩溃的第三方库
#import "AvoidCrash.h"

//刷新的第三方库
#import "MJRefresh.h"

//textView添加占位符的第三方库
#import "SAMTextView.h"

//UIAlertView添加block的第三方库
#import "UIAlertView+Blocks.h"

//SDWebImage的第三方库
#import "UIImageView+WebCache.h"

//SDWebImage的第三方库
#import "UIButton+WebCache.h"

//横向滚动的选择列表视图的第三方库
#import "HTHorizontalSelectionList.h"

//loadin加载指示器
#import "MBProgressHUD+Add.h"

//多样化的定制UIActionSheet弹出视图
#import "LGActionSheet.h"

//给view添加约束，布局框架
#import "Masonry.h"

//JSON与Model的转换
#import "YYModel.h"

//照片选择第三方库
#import "ZLPhoto.h"

