/**
 -  ThemeDetailMoreView.h
 -  EduKingdom
 -  Created by ligb on 2018/10/17.
 -  Copyright © 2018年 com.mobile-kingdom.ekapps. All rights reserved.
 -  说明：主题详情中侧滑更多view
 */

#import <UIKit/UIKit.h>

@interface ThemeDetailMoreView : UIView
//当前view
@property (class, readonly, strong) ThemeDetailMoreView *view;

//設置最大頁數 并显示view
@property (nonatomic, readonly) ThemeDetailMoreView *(^showMaxPage)(NSInteger);

//block 返回
@property (nonatomic, copy) void (^ selectedPageAction)(NSInteger page, UIButton *button);
@end
