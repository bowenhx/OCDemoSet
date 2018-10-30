/**
 -  ToolbarInputView.h
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/18.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 -  说明：
 */

#import <UIKit/UIKit.h>
@interface ToolbarInputView : UIView
@property (nonatomic, copy) void(^toolbarItemAction)(UIButton *button, NSString *content);
- (void)endEditing;
@end
