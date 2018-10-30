/**
 -  ToolbarImagesView.h
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/24.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 -  说明：
 */

#import <UIKit/UIKit.h>
#import "ToolHeader.h"

@interface ToolbarImagesView : UIView
@property (nonatomic, copy) void(^selectedFinish)(NSArray <ZLPhotoAssets *> *photos);

@end
