//
//  EditImageViewCell.h
//  OCDeomSet
//
//  Created by ligb on 2018/10/31.
//  Copyright © 2018年 com.professional.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kEditImageViewCellIdentifier = @"EditImageViewCell";

@protocol EditImageViewCellDelegate <NSObject>
- (void)deleteItemAction:(NSInteger)index;
@end
@interface EditImageViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) id <EditImageViewCellDelegate> delegate;
@end
