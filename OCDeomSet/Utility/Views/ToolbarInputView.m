/**
 -  ToolbarInputView.m
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/18.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 */

#import "ToolbarInputView.h"
#import "EmoticonInputView.h"
#import "SmiliesModel.h"
#import "ToolHeader.h"
#import "UITextView+TextStorage.h"

const float kMaxVisibleLine  = 5;          //最多显示5行
const float kTextViewSpace   = 6.5;
const float kTextViewHeight  = 36;


@interface ToolbarInputView () <UITextViewDelegate, EmoticonViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholder;
@property (nonatomic, strong) UIView *toolbarView;
@property (nonatomic, strong) EmoticonInputView *emoticonView;
@property (nonatomic, strong) NSMutableArray <UIButton *> *buttons;
@property (nonatomic, assign) CGFloat keyboardY;
@end

@implementation ToolbarInputView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:_textView];
}

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
                        @[@"def_reply_annex", @"def_reply_send"]];
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        float btnX = i > 0 ? (kSCREEN_WIDTH - 49) : 5;
        button.tag = i;
        button.frame = CGRectMake(btnX, 2.5, kToolItemHeight, kToolItemHeight);
        [button setImage:[UIImage imageNamed:images[i][0]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:images[i][1]] forState:UIControlStateSelected];
        [_toolbarView addSubview:button];
        [_buttons addObject:button];
        [button addTarget:self action:@selector(selectedToolBarItem:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(_buttons.firstObject.x + _buttons.firstObject.w + 10, (self.h - kTextViewHeight) / 2, kSCREEN_WIDTH - 2 * 44 - 30, kTextViewHeight)];
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.layer. masksToBounds = YES;
    _textView.layer.cornerRadius = 4.0f;
    _textView.layer.borderWidth = 0.5f;
    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    _textView.scrollsToTop = NO;
    _textView.delegate = self;
    
    _placeholder = [[UILabel alloc] initWithFrame:_textView.bounds];
    _placeholder.x += 5;
    _placeholder.font = [UIFont systemFontOfSize:16];
    _placeholder.text = @"快速回覆";
    _placeholder.textColor = [UIColor lightGrayColor];
    
    [_textView addSubview:_placeholder];
    [_toolbarView.layer addSublayer:topLine];
    [_toolbarView addSubview:_textView];
    [self addSubview:_toolbarView];
    [self mAddNotification];
    
    _emoticonView = [[EmoticonInputView alloc] init];
    _emoticonView.y = _toolbarView.h;
    _emoticonView.delegate = self;
    [self addSubview:_emoticonView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:_textView];
}

- (void)selectedToolBarItem:(UIButton *)button {
    if (button.tag == 0) {
        button.selected = !button.selected;
        if (button.selected) {
            if ([_textView isFirstResponder]) [_textView resignFirstResponder];
            self.h = self.toolbarView.h + _emoticonView.h;
            self.y = kSCREEN_HEIGHT - self.h;
        } else {
            [_textView becomeFirstResponder];
        }
    } else {
        if (_toolbarItemAction) {
            _toolbarItemAction(button, [self.textView attstringEncodeEmoticon]);
            
            if (_textView.text.length) {
                [self endEditing];
                //还原输入框
                _placeholder.hidden = NO;
                [UIView animateWithDuration:.25 animations:^{
                    self.textView.text = @"";
                    [self changeFrame:36];
                }];
            }
        }
    }
}

- (void)mAddNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - EmoticonInputDelegate
- (void)emoticonInputDidTapText:(SmiliesModel *)model {
    UIImage *image = [UIImage imageWithContentsOfFile:model.replace];
    [_textView emoticonEncode:model.search emoticonImg:image rang:_textView.selectedRange insert:YES];
    NSRange wholeRange = NSMakeRange(0, _textView.textStorage.length);
    [_textView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    [_textView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f] range:wholeRange];
    [self changeFrame:ceilf([_textView sizeThatFits:_textView.size].height)];
    self.h = self.toolbarView.h + _emoticonView.h;
    self.y = kSCREEN_HEIGHT - self.h;
    _placeholder.hidden = YES;
    [self sendButtonStatus];
}

#pragma mark -TextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self changeFrame:ceilf([textView sizeThatFits:textView.size].height)];
    self.buttons.firstObject.selected = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self changeFrame:ceilf([textView sizeThatFits:textView.size].height)];
}

- (void)changeFrame:(CGFloat)height {
    CGFloat maxH = ceil(self.textView.font.lineHeight * (kMaxVisibleLine - 1) + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom);
    self.textView.scrollEnabled = height > maxH && maxH > 0;
    if (self.textView.scrollEnabled) {
        height = 5 + maxH;
    }
    CGFloat totalH = height + kTextViewSpace * 2;
    self.y = self.keyboardY - totalH;
    self.h = totalH;
    self.toolbarView.h = totalH;
    self.textView.y = kTextViewSpace;
    self.textView.h = height;
    self.emoticonView.y = totalH;
    self.buttons.firstObject.y = self.buttons.lastObject.y = self.h - kToolItemHeight - 2.5;
    [self.textView scrollRangeToVisible:NSMakeRange(0, self.textView.text.length)];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardY = keyboardF.origin.y;
    [UIView animateWithDuration:duration animations:^{
        if (self.keyboardY > kSCREEN_HEIGHT) {
            self.y = kSCREEN_HEIGHT - self.h;
        } else {
            self.y = self.keyboardY - self.h;
        }
    }];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration animations:^{
        if (keyboardF.origin.y > kSCREEN_HEIGHT) {
            self.y = kSCREEN_HEIGHT - self.h;
        } else {
            self.y = keyboardF.origin.y - self.h;
        }
    }];
}

- (void)textViewEditChanged:(NSNotification *)obj {
    UITextView *textView = (UITextView *)obj.object;
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (!position) {
        _placeholder.hidden = textView.text.length;
    } else {
        _placeholder.hidden = YES;
    }
    [self sendButtonStatus];
}

- (void)sendButtonStatus {
    if (_placeholder.hidden) {
        _buttons.lastObject.selected = YES;
        UIImage *iamge = [_buttons.lastObject imageForState:UIControlStateSelected];
        [_buttons.lastObject setImage:iamge forState:UIControlStateNormal];
    } else {
        _buttons.lastObject.selected = NO;
        UIImage *iamge = [UIImage imageNamed:@"def_reply_annex"];
        [_buttons.lastObject setImage:iamge forState:UIControlStateNormal];
    }
}

- (void)endEditing {
    [self endEditing:YES];
    self.h = self.toolbarView.h;
    self.y = kSCREEN_HEIGHT - self.h;
}

@end
