//
//  UITextView+TextStorage.h
//  OCDeomSet
//
//  Created by ligb on 2018/10/31.
//  Copyright © 2018年 com.professional.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (TextStorage)

/**
 表情代码转化成表情图片插入文字中

 @param encode 表情代码
 @param img 表情图片
 @param rang 位置
 @param isInsert 是否插入
 */
- (void)emoticonEncode:(NSString *)encode
           emoticonImg:(UIImage *)img
                  rang:(NSRange)rang
                insert:(BOOL)isInsert;


/**
 表情图片转成代码

 @return 返回文本（文字 + 表情代码）
 */
- (NSString *)attstringEncodeEmoticon;
@end
