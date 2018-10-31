/**
 -  PhotosGroupView.h
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/24.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 -  说明：底部相册照片浏览view
 */

#import <UIKit/UIKit.h>
#import "ToolHeader.h"

@interface PhotosGroupView : UIView
// 记录选中的assets
@property (nonatomic, strong) NSMutableArray <ZLPhotoAssets *> *selectAssets;
@property (nonatomic, assign) NSUInteger maxCount;
@property (nonatomic, copy) void(^showInsertButton)(BOOL show);
- (void)reloadPhotos;
@end
