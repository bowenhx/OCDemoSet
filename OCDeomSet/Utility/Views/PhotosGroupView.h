/**
 -  PhotosGroupView.h
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/24.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 -  说明：相册照片浏览view
 */

#import <UIKit/UIKit.h>
#import "ToolHeader.h"
@protocol PhotosGroupViewDelegate <NSObject>
- (void)selectedPhotos:(ZLPhotoAssets *)phtotos;
@end

@interface PhotosGroupView : UIView
// 记录选中的assets
@property (nonatomic , strong) NSMutableArray <ZLPhotoAssets *> *selectAssets;
@property (nonatomic, weak) id <PhotosGroupViewDelegate> delegate;
@end
