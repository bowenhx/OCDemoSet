//
//  ZLPhotoPickerBrowserPhotoScrollView.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-14.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoPickerBrowserPhotoScrollView.h"
#import "ZLPhotoPickerDatas.h"
#import "DACircularProgressView.h"
#import "ZLPhotoPickerCommon.h"
#import "ZLPhotoRect.h"
#import "UIImageView+WebCache.h"

#define YY_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))

// Private methods and properties
@interface ZLPhotoPickerBrowserPhotoScrollView ()<UIActionSheetDelegate> {
    ZLPhotoPickerBrowserPhotoView *_tapView; // for background taps
}

@property (assign,nonatomic) CGFloat progress;
@property (strong,nonatomic) DACircularProgressView *progressView;
@property (assign,nonatomic) BOOL isLoadingDone;

@property (nonatomic, assign) NSInteger fromItemIndex;
@property (nonatomic, assign) BOOL isPresented;
@property (nonatomic, assign) CGPoint panGestureBeginPoint;

@end

@implementation ZLPhotoPickerBrowserPhotoScrollView

- (id)init{
    if ((self = [super init])) {
        
        // Setup
        // Tap view for background
        _tapView = [[ZLPhotoPickerBrowserPhotoView alloc] initWithFrame:self.bounds];
        _tapView.tapDelegate = self;
        _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tapView.backgroundColor = [UIColor blackColor];
        [self addSubview:_tapView];
        
        // Image view
        _photoImageView = [[ZLPhotoPickerBrowserPhotoImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.tapDelegate = self;
        _photoImageView.contentMode = UIViewContentModeCenter;
        _photoImageView.backgroundColor = [UIColor blackColor];
        [self addSubview:_photoImageView];
        
        // Setup
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
        [self addGestureRecognizer:longGesture];
        
        DACircularProgressView *progressView = [[DACircularProgressView alloc] init];
        progressView.frame = CGRectMake(0, 0, ZLPickerProgressViewW, ZLPickerProgressViewH);
        progressView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
        progressView.roundedCorners = YES;
        if (iOS7gt) {
            progressView.thicknessRatio = 0.1;
            progressView.roundedCorners = NO;
        } else {
            progressView.thicknessRatio = 0.2;
            progressView.roundedCorners = YES;
        }
        progressView.hidden = YES;
        
        [self addSubview:progressView];
        self.progressView = progressView;
    }
    return self;
}

- (void)longGesture:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        if (!self.sheet) {
            self.sheet = [[UIActionSheet alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存到相册" otherButtonTitles:nil, nil];
        }
        
        [self.sheet showInView:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(long)buttonIndex{
    if (buttonIndex == 0){
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];
            [assetsLibrary writeImageToSavedPhotosAlbum:[_photoImageView.image CGImage] orientation:(ALAssetOrientation)_photoImageView.image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    NSLog(@"Save image fail：%@",error);
                }else{
                    NSLog(@"Save image succeed.");
                }
            }];
        }else{
            if (_photoImageView.image) {
                [self showMessageWithText:@"没有用户权限,保存失败"];
            }
        }
    }
}

- (void)showMessageWithText:(NSString *)text{
    UILabel *alertLabel = [[UILabel alloc] init];
    alertLabel.font = [UIFont systemFontOfSize:15];
    alertLabel.text = text;
    alertLabel.textAlignment = NSTextAlignmentCenter;
    alertLabel.layer.masksToBounds = YES;
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.bounds = CGRectMake(0, 0, 100, 80);
    alertLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    alertLabel.backgroundColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0];
    alertLabel.layer.cornerRadius = 10.0f;
    [[UIApplication sharedApplication].keyWindow addSubview:alertLabel];
    
    [UIView animateWithDuration:.5 animations:^{
        alertLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [alertLabel removeFromSuperview];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPhoto:(ZLPhotoPickerBrowserPhoto *)photo{
    _photo = photo;
    
    if ([photo isKindOfClass:[UIImage class]]) {
        _photoImageView.image = (UIImage *)photo;
        self.isLoadingDone = YES;
        [self displayImage];
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    if (photo.photoURL.absoluteString.length) {
        // 本地相册
        NSRange photoRange = [photo.photoURL.absoluteString rangeOfString:@"assets-library"];
        if (photoRange.location != NSNotFound){
            [[ZLPhotoPickerDatas defaultPicker] getAssetsPhotoWithURLs:photo.photoURL callBack:^(UIImage *obj) {
                _photoImageView.image = obj;
                self.isLoadingDone = YES;
                [weakSelf displayImage];
            }];
        }else{
            UIImage *thumbImage = photo.thumbImage;
            if (thumbImage == nil) {
                thumbImage = _photoImageView.image;
            }else{
                _photoImageView.image = thumbImage;
            }
            
            _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
            _photoImageView.frame = [ZLPhotoRect setMaxMinZoomScalesForCurrentBoundWithImageView:_photoImageView];
            
            if (_photoImageView.image == nil) {
                [self setProgress:0.01];
            }
            // 网络URL
            [_photoImageView sd_setImageWithURL:photo.photoURL placeholderImage:thumbImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                [self setProgress:(double)receivedSize / expectedSize];
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    [self setProgress:1.0];
                }
                self.isLoadingDone = YES;
                if (image) {
                    photo.photoImage = image;
                    _photoImageView.image = image;
                    [weakSelf displayImage];
                }else{
                    [_photoImageView removeScaleBigTap];
                }
            }];
        }
        
    } else if (photo.photoImage){
        _photoImageView.image = photo.photoImage;
        self.isLoadingDone = YES;
        [self displayImage];
    } else if (photo.thumbImage){
        photo.photoImage = photo.thumbImage;
        _photoImageView.image = photo.thumbImage;
        self.isLoadingDone = YES;
        [self displayImage];
    }
}

#pragma mark - setProgress
- (void)setProgress:(CGFloat)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        _progress = progress;
        self.progressView.hidden = NO;
        if (progress == 0) {
            [self.progressView setProgress:0.01 animated:YES];
            return;
        }
        if (progress / 1.0 != 1.0) {
            [self.progressView setProgress:progress animated:YES];
        }else{
            [self.progressView removeFromSuperview];
            self.progressView = nil;
        }
    });
}


#pragma mark - Image
// Get and display image
- (void)displayImage {
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeMake(0, 0);
    
    // Get image from browser as it handles ordering of fetching
    UIImage *img = _photoImageView.image;
    if (img) {
        
        // Set image
        _photoImageView.image = img;
        _photoImageView.hidden = NO;
        
        // Setup photo frame
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = img.size;
        _photoImageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        
        // Set zoom to minimum zoom
        [self setMaxMinZoomScalesForCurrentBounds];
        
    }
    [self setNeedsLayout];
}

#pragma mark - Loading Progress
#pragma mark - Setup
- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_photoImageView) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _photoImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;
        
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = xScale;
        }
    }
    return zoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail if no image
    if (_photoImageView.image == nil) return;
    
    //    _photoImageView.frame = [ZLPhotoRect setMaxMinZoomScalesForCurrentBoundWithImageView:_photoImageView];
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = _photoImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    
    CGFloat minScale = MIN(xScale, yScale);
    // CGFloat maxScale = MAX(xScale, yScale);
    // use minimum of these to allow the image to become fully visible
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = MIN(xScale, yScale);
    }
    
    self.maximumZoomScale = xScale * 2;
    self.minimumZoomScale = xScale;
    
    self.zoomScale = self.minimumZoomScale;
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        if (yScale >= xScale) {
            self.scrollEnabled = NO;
        }
    }
    
    self.contentOffset = CGPointMake(0, 0);
    self.contentSize = CGSizeMake(0, self.contentSize.height);
    // Layout
    [self setNeedsLayout];
    
}

#pragma mark - Layout

- (void)layoutSubviews {
    // Super
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
        _photoImageView.frame = frameToCenter;
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Pan
- (void)imageView:(UIImageView *)imageView panChangeDetected:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            _panGestureBeginPoint = [pan locationInView:self];
            NSLog(@"😺");
        }
            break;
        case UIGestureRecognizerStateChanged: {
            NSLog(@"😹");
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [pan locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            self.zl_y = deltaY;
            
            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            alpha = YY_CLAMP(alpha, 0, 1);
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                _photoImageView.alpha = alpha;
            } completion:nil];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            NSLog(@"💪");
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint v = [pan velocityInView:self];
            CGPoint p = [pan locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                //[self cancelAllImageLoad];
                _isPresented = NO;
//                [[UIApplication sharedApplication] setStatusBarHidden:_fromNavigationBarHidden withAnimation:UIStatusBarAnimationFade];
                
                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = 2.5;//(moveToTop ? _scrollView.zl_y + _scrollView.zl_h) : self.height - _scrollView.top) / vy;
                duration *= 0.8;
                duration = YY_CLAMP(duration, 0.05, 0.3);
                
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
//                    _blurBackground.alpha = 0;
//                    _pager.alpha = 0;
                    if (moveToTop) {
                        self.zl_y = -self.zl_height;
                    } else {
                        self.zl_y = self.zl_height;
                    }
                } completion:^(BOOL finished) {
//                    [self removeFromSuperview];
                }];
                
//                _background.image = _snapshotImage;
//                [_background.layer addFadeAnimationWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut];
            } else {
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.zl_y = 0;
//                    _blurBackground.alpha = 1;
//                    _pager.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled: {
            NSLog(@"👎");
             self.zl_y = 0;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Tap Detection
- (void)handleDoubleTap:(CGPoint)touchPoint {
    // Zoom
    if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
        
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        if (self.isLoadingDone) {
            // Zoom in to twice the size
            CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 1.5);
            CGFloat xsize = self.bounds.size.width / newZoomScale;
            CGFloat ysize = self.bounds.size.height / newZoomScale;
            [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        }
    }
}

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch{
    [self disMissTap:nil];
}

#pragma mark - disMissTap
- (void) disMissTap:(UITapGestureRecognizer *)tap{
    if (self.callback){
        self.callback(nil);
    }else if ([self.photoScrollViewDelegate respondsToSelector:@selector(pickerPhotoScrollViewDidSingleClick:)]) {
        [self.photoScrollViewDelegate pickerPhotoScrollViewDidSingleClick:self];
    }
}

// Image View
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch{
    [self disMissTap:nil];
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}

@end
