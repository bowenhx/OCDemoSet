/**
 -  ToolbarImagesView.m
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/24.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 */

#import "ToolbarImagesView.h"
#import "EmoticonInputView.h"
#import "PhotosGroupView.h"

@interface ToolbarImagesView () <EmoticonViewDelegate>
@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) EmoticonInputView *emoticonView;
@property (nonatomic, strong) PhotosGroupView *photosListView;
@property (nonatomic, strong) NSMutableArray <UIButton *> *buttons;
@end

@implementation ToolbarImagesView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self mLayoutView];
    }
    return self;
}

- (void)mLayoutView {
    _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kToolBarViewHeight)];
    CALayer *topLine = [[CALayer alloc] init];
    topLine.frame = CGRectMake(0, 0, _toolbarView.w, 1);
    topLine.backgroundColor = [UIColor lightGrayColor].CGColor;
    _buttons = [NSMutableArray arrayWithCapacity:2];
    NSArray *images = @[@[@"def_reply_emoji", @"def_reply_input"],
                        @[@"def_reply_photo", @"def_reply_input"]];
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10 + i * (kToolItemHeight + 10), 2.5, kToolItemHeight, kToolItemHeight);
        if (i == 2) {
            button.x = kSCREEN_WIDTH - kToolItemHeight - 10;
            [button setImage:[UIImage imageNamed:@"def_reply_upload"] forState:UIControlStateNormal];
            button.hidden = YES;
        } else {
            [button setImage:[UIImage imageNamed:images[i][0]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:images[i][1]] forState:UIControlStateSelected];
        }
        [_toolbarView addSubview:button];
        [_buttons addObject:button];
        [button addTarget:self action:@selector(selectedToolBarItem:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
    }
    
    [_toolbarView.layer addSublayer:topLine];
    [self addSubview:_toolbarView];
    
    _emoticonView = [EmoticonInputView new];
    _emoticonView.y = _toolbarView.maxY;
    _emoticonView.delegate = self;
    [self addSubview:_emoticonView];
    
    _photosListView = [PhotosGroupView new];
    _photosListView.y = _toolbarView.maxY;
    [self addSubview:_photosListView];
    
    @WEAKSELF(self);
    _photosListView.showInsertButton = ^(BOOL show) {
        selfWeak.buttons.lastObject.hidden = !show;
    };
}

- (void)selectedToolBarItem:(UIButton *)button {
    button.selected = !button.selected;
    
    if (_selectedFinish) {
        _selectedFinish(nil, button.tag > 1 ? _photosListView.selectAssets : nil, button);
    }
    if (button.tag == 0) {//选择表情
        if (button.selected) {
            _emoticonView.hidden = NO;
            _photosListView.hidden = YES;
            self.buttons[1].selected = NO;
            //显示表情view
            [self showEmoticonView:YES];
        } else {
            //显示键盘
            [self showEmoticonView:NO];
        }
        
    } else if (button.tag == 1) { //选择相册图片
        if (button.selected) {
            _emoticonView.hidden = YES;
            _photosListView.hidden = NO;
            self.buttons.firstObject.selected = NO;
            //显示图片
            [self showPhotosView:YES];
        } else {
            //显示键盘
            [self showPhotosView:NO];
        }
    } else { //插入照片
        self.buttons[1].selected = NO;
        [self showPhotosView:NO];
        [self.photosListView.selectAssets removeAllObjects];
        [self.photosListView reloadPhotos];
        button.hidden = YES;
    }
}

- (void)emoticonInputDidTapText:(SmiliesModel *)model {
    if (_selectedFinish) {
        _selectedFinish(model, nil, nil);
    }
}

- (void)setMaxCount:(NSUInteger)maxCount {
    _maxCount = maxCount;
    self.buttons[1].enabled = _maxCount;
    self.photosListView.maxCount = maxCount;
}

- (void)hiddenImagesView {
    [self showPhotosView:NO];
    [self showEmoticonView:NO];
    self.buttons[1].selected = NO;
    self.buttons.firstObject.selected = NO;
}

- (void)showEmoticonView:(BOOL)show {
    [UIView animateWithDuration:0.3 animations:^{
        if (show) {
            self.h = self.toolbarView.h + self.emoticonView.h;
            self.y = kSCREEN_HEIGHT - self.h;
        } else {
            self.h = kToolBarViewHeight;
            self.y = kSCREEN_HEIGHT - self.h;
        }
    }];
}

- (void)showPhotosView:(BOOL)show {
    [UIView animateWithDuration:0.3 animations:^{
        if (show) {
            self.h = self.toolbarView.h + self.photosListView.h;
            self.y = kSCREEN_HEIGHT - self.h;
        } else {
            self.h = kToolBarViewHeight;
            self.y = kSCREEN_HEIGHT - self.h;
        }
    }];
}

@end
