/**
 -  ToolbarImagesView.h
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/24.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 -  说明：底部Toolbar view 工具条
 */

#import <UIKit/UIKit.h>
#import "ToolHeader.h"
#import "SmiliesModel.h"

@interface ToolbarImagesView : UIView
@property (nonatomic, assign) NSUInteger maxCount;
@property (nonatomic, copy) void(^selectedFinish)(SmiliesModel *model, NSArray <ZLPhotoAssets *> *photos, UIButton *button);
- (void)hiddenImagesView;
@end
