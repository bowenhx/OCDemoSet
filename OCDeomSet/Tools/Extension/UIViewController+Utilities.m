//
//  UIViewController+Utilities.m
//  OCDeomSet
//
//  Created by ligb on 2018/10/26.
//  Copyright © 2018年 com.professional.cn. All rights reserved.
//

#import "UIViewController+Utilities.h"

@implementation UIViewController (Utilities)

- (void)setParames:(id)parames {
}

- (void)showNextControllerName:(NSString *)className
                        params:(id)params
                        isPush:(BOOL)isPush {
    UIViewController *controller = [[NSClassFromString(className) alloc] init];
    if (params) [controller setParames:params];
    if (isPush) {
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

@end
