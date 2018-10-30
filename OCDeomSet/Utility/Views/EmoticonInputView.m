/**
 -  EmoticonInputView.m
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/15.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 */

#import "EmoticonInputView.h"
#import "ToolHeader.h"

static float kViewHeight = 190;
static float kOneEmoticonHeight = 50;
static float kOnePageCount = 21;

@interface EmoticonCell : UICollectionViewCell
@property (nonatomic, strong) SmiliesModel *emoticon;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation EmoticonCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _imageView = [UIImageView new];
    _imageView.size = CGSizeMake(40, 40);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageView];
    return self;
}

- (void)setEmoticon:(SmiliesModel *)emoticon {
    if (emoticon) {
        _emoticon = emoticon;
        _imageView.image = [UIImage imageWithContentsOfFile:emoticon.replace];
        _imageView.hidden = NO;
        if ([emoticon.replace rangeOfString:@"em"].location != NSNotFound ||
            [emoticon.replace rangeOfString:@"icon"].location != NSNotFound) {
            _imageView.contentMode = UIViewContentModeCenter;
        } else {
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    } else {
        _imageView.image = nil;
        _imageView.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout];
}

- (void)updateLayout {
    _imageView.center = CGPointMake(self.w / 2, self.h / 2);
}
@end




@interface EmoticonFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, strong) NSMutableDictionary *sectionDic;
@property (nonatomic, strong) NSMutableArray *allAttributes;
@end

@implementation EmoticonFlowLayout

- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _sectionDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    self.allAttributes = [NSMutableArray array];
    //获取section的数量
    NSUInteger section = [self.collectionView numberOfSections];
    for (int sec = 0; sec < section; sec++) {
        //获取每个section的cell个数
        NSUInteger count = [self.collectionView numberOfItemsInSection:sec];
        for (NSUInteger item = 0; item<count; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:sec];
            //重新排列
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.allAttributes addObject:attributes];
        }
    }
}

- (CGSize)collectionViewContentSize {
    //每个section的页码的总数
    NSInteger actualLo = 0;
    for (NSString *key in [_sectionDic allKeys]) {
        actualLo += [_sectionDic[key] integerValue];
    }
    return CGSizeMake(actualLo*self.collectionView.frame.size.width, self.collectionView.contentSize.height);
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes {
    if (attributes.representedElementKind != nil) return;
    //attributes 的宽度
    CGFloat itemW = attributes.frame.size.width;
    //attributes 的高度
    CGFloat itemH = attributes.frame.size.height;
    
    //collectionView 的宽度
    CGFloat width = self.collectionView.frame.size.width;
    //collectionView 的高度
    CGFloat height = self.collectionView.frame.size.height;
    //每个attributes的下标值 从0开始
    NSInteger itemIndex = attributes.indexPath.item;
    
    CGFloat stride = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? width : height;
    
    //获取现在的attributes是第几组
    NSInteger section = attributes.indexPath.section;
    //获取每个section的item的个数
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
    
    CGFloat offset = section * stride;
    //计算x方向item个数
    NSInteger xCount = (width / itemW);
    //计算y方向item个数
    NSInteger yCount = (height / itemH);
    //计算一页总个数
    NSInteger allCount = (xCount * yCount);
    //获取每个section的页数，从0开始
    NSInteger page = itemIndex / allCount;
    
    //余数，用来计算item的x的偏移量
    NSInteger remain = (itemIndex % xCount);
    
    //取商，用来计算item的y的偏移量
    NSInteger merchant = (itemIndex-page*allCount)/xCount;
    
    
    //x方向每个item的偏移量
    CGFloat xCellOffset = remain * itemW;
    
    //y方向每个item的偏移量
    CGFloat yCellOffset = merchant * itemH;
    
    //获取每个section中item占了几页
    NSInteger pageRe = (itemCount % allCount == 0)? (itemCount / allCount) : (itemCount / allCount) + 1;
    //将每个section与pageRe对应，计算下面的位置
    [_sectionDic setValue:@(pageRe) forKey:[NSString stringWithFormat:@"%ld", section]];
    
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        NSInteger actualLo = 0;
        //将每个section中的页数相加
        for (NSString *key in [_sectionDic allKeys]) {
            actualLo += [_sectionDic[key] integerValue];
        }
        //获取到的最后的数减去最后一组的页码数
        actualLo -= [_sectionDic[[NSString stringWithFormat:@"%ld", [_sectionDic allKeys].count-1]] integerValue];
        xCellOffset += page * width + actualLo * width;
    } else {
        yCellOffset += offset;
    }
    attributes.frame = CGRectMake(xCellOffset, yCellOffset, itemW, itemH);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForItemAtIndexPath:indexPath].copy;
    [self applyLayoutAttributes:attr];
    return attr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.allAttributes;
}
@end




@protocol EmoticonScrollViewDelegate <UICollectionViewDelegate>
- (void)emoticonScrollViewDidTapCell:(EmoticonCell *)cell;
@end

@interface EmoticonCollectionView : UICollectionView
@property (nonatomic, assign) NSUInteger pageIndex;
@property (nonatomic, strong) UIImageView *magnifierContent;
@end

@implementation EmoticonCollectionView {
    BOOL _touchMoved;
    UIImageView *_magnifier;
    __weak EmoticonCell *_currentMagnifierCell;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [UIView new];
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.clipsToBounds = NO;
    self.canCancelContentTouches = NO;
    self.multipleTouchEnabled = NO;
    _magnifier = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"post_emoji_zoom_bj"]];
    _magnifierContent = [UIImageView new];
    _magnifierContent.size = CGSizeMake(60, 60);
    _magnifierContent.centerX = _magnifier.w / 2;
    _magnifierContent.contentMode = UIViewContentModeCenter;
    [_magnifier addSubview:_magnifierContent];
    _magnifier.hidden = YES;
    [self addSubview:_magnifier];
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchMoved = NO;
    EmoticonCell *cell = [self cellForTouches:touches];
    _currentMagnifierCell = cell;
    [self showMagnifierForCell:_currentMagnifierCell];
    
    if (cell.imageView.image) {
        [[UIDevice currentDevice] playInputClick];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchMoved = YES;
    EmoticonCell *cell = [self cellForTouches:touches];
    if (cell != _currentMagnifierCell) {
        _currentMagnifierCell = cell;
        [self showMagnifierForCell:cell];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    EmoticonCell *cell = [self cellForTouches:touches];
    if (cell.emoticon && !_touchMoved) {
        if ([self.delegate respondsToSelector:@selector(emoticonScrollViewDidTapCell:)]) {
            [((id<EmoticonScrollViewDelegate>) self.delegate) emoticonScrollViewDidTapCell:cell];
        }
    }
    [self hideMagnifier];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideMagnifier];
}

- (EmoticonCell *)cellForTouches:(NSSet<UITouch *> *)touches {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    if (indexPath) {
        EmoticonCell *cell = (id)[self cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (void)showMagnifierForCell:(EmoticonCell *)cell {
    if (!cell.imageView.image) {
        [self hideMagnifier];
        return;
    }
    CGRect rect = [cell convertRect:cell.bounds toView:self];
    _magnifier.centerX = CGRectGetMidX(rect);
    CGFloat x = _pageIndex * kSCREEN_WIDTH;
    if (_magnifier.x < x) _magnifier.centerX += 11;
    x = (_pageIndex + 1) * kSCREEN_WIDTH;
    if (_magnifier.maxX > x) _magnifier.centerX -= 11;
    _magnifier.y = CGRectGetMaxY(rect) - 45 - _magnifier.h;
    _magnifier.hidden = NO;
    
    _magnifierContent.image = cell.imageView.image;
    _magnifierContent.y = 20;
    
    [_magnifierContent.layer removeAllAnimations];
    NSTimeInterval dur = 0.1;
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.magnifierContent.y = 3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.magnifierContent.y = 12;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.magnifierContent.y = 10;
            } completion:^(BOOL finished) {
            }];
        }];
    }];
}

- (void)hideMagnifier {
    _magnifier.hidden = YES;
}

@end




@interface EmoticonInputView () <UICollectionViewDelegate, UICollectionViewDataSource, UIInputViewAudioFeedback, EmoticonScrollViewDelegate>
@property (nonatomic, strong) EmoticonCollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger emoticonTotalPageCount;
@property (nonatomic, assign) NSInteger emoticonLastPageCount;
@property (nonatomic, assign) NSInteger currentPageIndex;
@end

@implementation EmoticonInputView

- (void)dealloc {
    [_collectionView removeObserver:self forKeyPath:@"contentOffset"];
}

- (instancetype)init {
    self = [super init];
    self.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kViewHeight);
    self.backgroundColor = [UIColor whiteColor];
    [self initCollectionView];
    return self;
}

- (void)initCollectionView {
    _currentPageIndex = NSNotFound;
    CGFloat smiliesNum = [[SmiliesManager sharedInstance].smiliesArray count];
    //分页显示表情，每页有21个表情
    _emoticonTotalPageCount = ceilf(smiliesNum / (kOnePageCount));
    _emoticonLastPageCount = smiliesNum - (_emoticonTotalPageCount - 1) * kOnePageCount;
    CGFloat itemWidth = kSCREEN_WIDTH / 7.0;
    CGFloat paddingLeft = (kSCREEN_WIDTH - 7 * itemWidth) / 2.0;
    CGFloat paddingRight = kSCREEN_WIDTH - paddingLeft - itemWidth * 7;
    
    EmoticonFlowLayout *layout = [EmoticonFlowLayout new];
    layout.itemSize = CGSizeMake(itemWidth, kOneEmoticonHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, paddingLeft, 0, paddingRight);
    
    _collectionView = [[EmoticonCollectionView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kOneEmoticonHeight * 3) collectionViewLayout:layout];
    [_collectionView registerClass:[EmoticonCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.y = 5;
    [self addSubview:_collectionView];
    
    _pageControl = [UIPageControl new];
    _pageControl.size = CGSizeMake(kSCREEN_WIDTH, 20);
    _pageControl.y = _collectionView.maxY + 5;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.numberOfPages = _emoticonTotalPageCount;
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    [self addSubview:_pageControl];
    
    [_collectionView addObserver:self
                  forKeyPath:@"contentOffset"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
}

- (SmiliesModel *)emoticonForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger index = section * kOnePageCount + indexPath.row;
    //获取到表情数据
    NSArray *smilies = [SmiliesManager sharedInstance].smiliesArray;
    return smilies[index];
}

#pragma mark WBEmoticonScrollViewDelegate
- (void)emoticonScrollViewDidTapCell:(EmoticonCell *)cell {
    if (!cell) return;
    if (cell.emoticon) {
        NSLog(@"text  = %@",cell.emoticon.search);
        if (self.delegate && [self.delegate respondsToSelector:@selector(emoticonInputDidTapText:)]) {
            [self.delegate emoticonInputDidTapText:cell.emoticon];
        }
    }
}

#pragma mark UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = round(scrollView.contentOffset.x / scrollView.w);
    if (page < 0) page = 0;
    CGFloat lastPage = scrollView.contentSize.width - scrollView.contentOffset.x - 20;
    if (lastPage < kSCREEN_WIDTH) page = 6;
    if (page == _currentPageIndex) return;
    _currentPageIndex = page;
    _pageControl.currentPage = page;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _emoticonTotalPageCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == _emoticonTotalPageCount - 1) return _emoticonLastPageCount;
    return kOnePageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.emoticon = [self emoticonForIndexPath:indexPath];
    return cell;
}

#pragma mark - UIInputViewAudioFeedback
- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"contentOffset"]) {
        //表情跟随pageControll滑动
        int currentPage = floor((_collectionView.contentOffset.x - kSCREEN_WIDTH / 2) / kSCREEN_WIDTH) + 1;
        self.pageControl.currentPage = currentPage;
        self.collectionView.pageIndex = currentPage;
    }
}

@end

