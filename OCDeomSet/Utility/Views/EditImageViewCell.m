//
//  EditImageViewCell.m
//  OCDeomSet
//
//  Created by ligb on 2018/10/31.
//  Copyright © 2018年 com.professional.cn. All rights reserved.
//

#import "EditImageViewCell.h"

@interface EditImageViewCell ()
@end

@implementation EditImageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)deleteAction:(UIButton *)sender {
    if (self.delegate && [_delegate respondsToSelector:@selector(deleteItemAction:)]) {
        [_delegate deleteItemAction:sender.tag];
    }
}
@end
