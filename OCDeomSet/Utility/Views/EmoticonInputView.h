/**
 -  EmoticonInputView.h
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/15.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 -  说明：表情view
 */

static const float kToolBarViewHeight = 49;      //输入工具栏的高度
static const float kToolItemHeight = 44.f;

#import "SmiliesManager.h"

@protocol EmoticonViewDelegate <NSObject>
@optional
- (void)emoticonInputDidTapText:(SmiliesModel *)model;
@end

@interface EmoticonInputView : UIView
@property (nonatomic, weak) id<EmoticonViewDelegate> delegate;
@end
