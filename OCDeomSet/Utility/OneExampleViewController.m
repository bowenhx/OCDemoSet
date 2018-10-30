/**
 -  OneExampleViewController.m
 -  OCDeomSet
 -  Created by ligb on 2018/10/26.
 -  Copyright © 2018年 com.professional.cn. All rights reserved.
 */

#import "OneExampleViewController.h"
#import "ToolHeader.h"
#import "ThemeDetailMoreView.h"
#import "ToolbarInputView.h"
#import "ToolbarImagesView.h"
@interface OneExampleViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) ToolbarInputView *inputView;
@property (nonatomic, strong) NSMutableArray <ZLPhotoAssets *>*dataSource;
@end

@implementation OneExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"post_top_more"] style:UIBarButtonItemStylePlain target:self action:@selector(showRightView)];
    
    //1.快速回复
//    _inputView = [[ToolbarInputView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT - 49, kSCREEN_WIDTH, 49)];
//    [self.view addSubview:_inputView];
    
    [_collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    _collectionView.layer.borderWidth = 1;
    _textView.layer.borderWidth = 1;
    _textView.layer.borderColor = [UIColor redColor].CGColor;
    _dataSource = [NSMutableArray array];
    //2.发布主题
    ToolbarImagesView *inputView = [[ToolbarImagesView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT - 49, kSCREEN_WIDTH, 49)];
    [self.view addSubview:inputView];
    
    @WEAKSELF(self);
    inputView.selectedFinish = ^(NSArray<ZLPhotoAssets *> *photos) {
        if (photos.count) {
            [selfWeak.dataSource setArray:photos];
            [selfWeak.collectionView reloadData];
        }
    };
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedPhotos:) name:@"selectedPhotosNotification" object:nil];
    
}

- (void)showRightView {
    ThemeDetailMoreView.view.showMaxPage(30).selectedPageAction = ^(NSInteger page, UIButton *button) {
        if (button) {
            NSLog(@"tag = %ld",button.tag);
        } else {
            NSLog(@"page = %ld",page);
        }
    };
}

- (void)selectedPhotos:(NSNotification *)notification {
    NSArray *photos = [notification object];
    if (photos.count) {
        [self.dataSource setArray:photos];
        [self.collectionView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    UIImageView *imageView;
    if (![cell viewWithTag:10]) {
        imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        [cell.contentView addSubview:imageView];
    }
    imageView.image = self.dataSource[indexPath.row].originImage;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWH = _collectionView.w / 3 - 10;
    return CGSizeMake(itemWH, itemWH);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 1, 0, 1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_inputView) [_inputView endEditing];
    
}



@end
