//
//  PickerImageView.m
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoPickerImageView.h"
#import "UIImage+ZLPhotoLib.h"

@interface ZLPhotoPickerImageView ()

@property (nonatomic , weak) UIView *maskView;
@property (nonatomic , weak) UIButton *tickImageView;
@property (nonatomic , weak) UIImageView *videoView;

@end

@implementation ZLPhotoPickerImageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    return self;
}

- (UIView *)maskView{
    if (!_maskView) {
        UIView *maskView = [[UIView alloc] init];
        maskView.frame = self.bounds;
        maskView.backgroundColor = [UIColor whiteColor];
        maskView.alpha = 0.5;
        [self addSubview:maskView];
        self.maskView = maskView;
    }
    return _maskView;
}

- (UIImageView *)videoView{
    if (!_videoView) {
        UIImageView *videoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.bounds.size.height - 40, 30, 30)];
        videoView.image = [UIImage ml_imageFromBundleNamed:@"video"];
        videoView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:videoView];
        self.videoView = videoView;
    }
    return _videoView;
}

- (UIButton *)tickImageView{
    if (!_tickImageView) {
        UIButton *tickImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        tickImageView.frame = CGRectMake(self.bounds.size.width - 28, 5, 25, 25);
        //修改：替换图片
        [tickImageView setBackgroundImage:[UIImage imageNamed:@"def_reply_default"] forState:UIControlStateNormal];
//        [tickImageView setImage:[UIImage ml_imageFromBundleNamed:@"icon_image_no"] forState:UIControlStateNormal];
        [tickImageView.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:tickImageView];
        self.tickImageView = tickImageView;
    }
    return _tickImageView;
}

- (void)setIsVideoType:(BOOL)isVideoType{
    _isVideoType = isVideoType;
    
    self.videoView.hidden = !(isVideoType);
}

- (void)setMaskViewFlag:(BOOL)maskViewFlag {
    _maskViewFlag = maskViewFlag;
    
    //    self.maskView.hidden = !maskViewFlag;
    self.animationRightTick = maskViewFlag;
}

- (void)setMaskViewColor:(UIColor *)maskViewColor{
    _maskViewColor = maskViewColor;
    
    self.maskView.backgroundColor = maskViewColor;
}

- (void)setMaskViewAlpha:(CGFloat)maskViewAlpha{
    _maskViewAlpha = maskViewAlpha;
    
    self.maskView.alpha = maskViewAlpha;
}

- (void)setAnimationRightTick:(BOOL)animationRightTick{
    _animationRightTick = animationRightTick;
    //修改：添加个数显示
    if (animationRightTick) {
        [self.tickImageView setBackgroundImage:[UIImage imageNamed:@"def_reply_select"] forState:UIControlStateNormal];
        NSString *count = [NSString stringWithFormat:@"%ld",self.selectedCount];
        [self.tickImageView setTitle:count forState:UIControlStateNormal];
//        [self.tickImageView setImage:[UIImage ml_imageFromBundleNamed:@"icon_image_yes"] forState:UIControlStateNormal];
    }else{
        [self.tickImageView setBackgroundImage:[UIImage imageNamed:@"def_reply_default"] forState:UIControlStateNormal];
        [self.tickImageView setTitle:@"" forState:UIControlStateNormal];
//        [self.tickImageView setImage:[UIImage ml_imageFromBundleNamed:@"icon_image_no"] forState:UIControlStateNormal];
    }
    
    if (!self.isClickHaveAnimation) {
        return;
    }
    CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaoleAnimation.duration = 0.25;
    scaoleAnimation.autoreverses = YES;
    scaoleAnimation.values = @[[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.2],[NSNumber numberWithFloat:1.0]];
    scaoleAnimation.fillMode = kCAFillModeForwards;
    
    if (self.isVideoType) {
        [self.videoView.layer removeAllAnimations];
        [self.videoView.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
    }else{
        [self.tickImageView.layer removeAllAnimations];
        [self.tickImageView.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
    }
}
@end
