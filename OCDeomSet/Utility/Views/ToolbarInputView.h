/**
 -  ToolbarInputView.h
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/18.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 -  说明：1.底部带有输入框的工具条
         2.最多能显示5行文字
 */

#import <UIKit/UIKit.h>
@interface ToolbarInputView : UIView
@property (nonatomic, copy) void(^toolbarItemAction)(UIButton *button, NSString *content);
- (void)endEditing;
@end
