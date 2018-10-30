//
//  UIViewController+Utilities.h
//  OCDeomSet
//
//  Created by ligb on 2018/10/26.
//  Copyright © 2018年 com.professional.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Utilities)

- (void)setParames:(id)parames;

- (void)showNextControllerName:(NSString *)className
                        params:(id)params
                        isPush:(BOOL)isPush;
@end
