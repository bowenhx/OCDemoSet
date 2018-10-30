/**
 -  ThemeDetailMoreView.m
 -  EduKingdom
 -  Created by ligb on 2018/10/17.
 -  Copyright © 2018年 com.mobile-kingdom.ekapps. All rights reserved.
 */

#import "ThemeDetailMoreView.h"
#import "ToolHeader.h"

@interface CenterTextCell : UITableViewCell
@property (nonatomic, strong) UILabel *text;
@end

@implementation CenterTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self mLayoutText];
    return self;
}

- (void)mLayoutText {
    _text = [[UILabel alloc] initWithFrame:CGRectZero];
    _text.size = CGSizeMake(150, 44);
    _text.font = [UIFont systemFontOfSize:14];
    _text.textColor = [UIColor darkTextColor];
    _text.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_text];
}
@end




@interface ThemeDetailMoreView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *taxisBtn;
@property (nonatomic, assign) NSInteger vMaxPage;
@end

@implementation ThemeDetailMoreView

+ (ThemeDetailMoreView *)view {
    static ThemeDetailMoreView *iView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iView = [[self alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];//initWithFrame:SCREEN_BOUNDS];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:iView];
    });
    return iView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.hidden = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.250];
        [self mAddUILayout];
    }
    return self;
}

- (void)mAddUILayout {
    _rightView = [[UIView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH, kNAV_BAR_HEIGHT, 150, kSCREEN_HEIGHT-kNAV_BAR_HEIGHT)];
    _rightView.backgroundColor = [UIColor whiteColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rightView.w, 45)];
    headerView.backgroundColor = [UIColor redColor];
    headerView.alpha = 0.3;
    
    NSArray *imageNames = @[@[@"post_more_along",@"post_more_pour"],@"post_more_share",@"post_more_home"];
    float space = (_rightView.w - 10) / 3;
    for (int i = 0; i < 3; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * space + 5, 0, space, space);
        button.tag = i;
        if (i == 0) {
            UIImage *normal = [UIImage imageNamed:imageNames[i][0]];
            UIImage *select = [UIImage imageNamed:imageNames[i][1]];
            [button setImage:normal forState:UIControlStateNormal];
            [button setImage:select forState:UIControlStateSelected];
            _taxisBtn = button;
        } else {
            UIImage *image = [UIImage imageNamed:imageNames[i]];
            [button setImage:image forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(selectedMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:button];
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headerView.h, _rightView.w, _rightView.h - headerView.h)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
     _tableView.separatorInset = UIEdgeInsetsMake(0, 30, 0, 30);
    [_tableView registerClass:[CenterTextCell class] forCellReuseIdentifier:@"cell"];
    
    [_rightView addSubview:headerView];
    [_rightView addSubview:_tableView];
    [self addSubview:_rightView];
}


- (void)selectedMoreAction:(UIButton *)btn {
    if (btn.tag == 0) {
        btn.selected = !btn.selected;
    }
    if (_selectedPageAction) {
        _selectedPageAction(NSNotFound, btn);
    }
}

- (void)show:(BOOL)isShow {
    [UIView animateWithDuration:0.35 animations:^{
        if (isShow) {
            self.hidden = NO;
            self.rightView.x = kSCREEN_WIDTH - self.rightView.w;
        } else {
            self.rightView.x = kSCREEN_WIDTH;
        }
    } completion:^(BOOL finished) {
        if (isShow) {
            //设置
        } else {
            self.hidden = YES;
        }
    }];
}

- (ThemeDetailMoreView *(^)(NSInteger))showMaxPage {
    return ^(NSInteger maxPage) {
        self.vMaxPage = maxPage;
        [self show:YES];
        return self;
    };
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:_rightView];
    if (!CGRectContainsPoint(_rightView.bounds, point)) {
        [self show:NO];
    }
}


#pragma mark -- TableViewDeletage
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _vMaxPage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CenterTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.text.text = [NSString stringWithFormat:@"第%ld頁",indexPath.row + 1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedPageAction) {
        _selectedPageAction(indexPath.row + 1, nil);
    }
}



@end
