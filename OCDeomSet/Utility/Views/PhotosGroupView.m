/**
 -  PhotosGroupView.m
 -  EmoticonInputDemo
 -  Created by ligb on 2018/10/24.
 -  Copyright © 2018年 com.mobile-kingdom. All rights reserved.
 */

#import "PhotosGroupView.h"


static NSString *const kCellIdentifier = @"cell";


@interface PhotosGroupView () <ZLPhotoPickerCollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) ZLPhotoPickerCollectionView *collectionView;
@property (nonatomic, copy) NSArray *groups;
@property (nonatomic, strong) NSMutableArray <ZLPhotoAssets *> *dataArray;
@property (nonatomic, strong) ZLPhotoPickerGroup *photoGroup;

@property (nonatomic, assign) CGFloat imageWH;
@end

@implementation PhotosGroupView

- (instancetype)init {
    self = [super init];
    _imageWH = (kSCREEN_WIDTH - 4) / 3;
    self.frame = CGRectMake(0, 0, kSCREEN_WIDTH, _imageWH + 2);
    self.backgroundColor = [UIColor whiteColor];
    [self initCollectionView];
    [self getPhotosData];
    return self;
}

- (void)getPhotosData {
    ZLPhotoPickerDatas *datas = [ZLPhotoPickerDatas defaultPicker];
    // 获取所有的图片URLs
    [datas getAllGroupWithAllPhotos:^(NSArray *groups) {
        self.groups = groups;
        [self showPhotosView:NO];
    }];
}

- (void)showPhotosView:(BOOL)isCamera {
    ZLPhotoPickerGroup *gp = nil;
    for (ZLPhotoPickerGroup *group in self.groups) {
        if ([group.groupName isEqualToString:@"Camera Roll"] ||
             [group.groupName isEqualToString:@"相機膠捲"]) {
            gp = group;
            break;
        } else if ([group.groupName isEqualToString:@"Saved Photos"] ||
                   [group.groupName isEqualToString:@"保存相冊"]) {
            gp = group;
            break;
        } else if ([group.groupName isEqualToString:@"Stream"] ||
                  [group.groupName isEqualToString:@"我的照片流"]) {
            gp = group;
            break;
        }
    }
    if (!gp) return;
    
    __weak typeof(self) weakSelf = self;
    [[ZLPhotoPickerDatas defaultPicker] getGroupPhotosWithGroup:gp finished:^(NSArray *assets) {
        [assets enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            __block ZLPhotoAssets *zlAsset = [[ZLPhotoAssets alloc] init];
            zlAsset.asset = asset;
            [weakSelf.dataArray addObject:zlAsset];
        }];
        if (isCamera) {
            weakSelf.collectionView.isRecoderSelectPicker = YES;
            [weakSelf.collectionView.selectAssets addObject:weakSelf.dataArray.firstObject];
            weakSelf.selectAssets = weakSelf.collectionView.selectAssets;
            if (weakSelf.showInsertButton) {
                weakSelf.showInsertButton(@(weakSelf.selectAssets.count).boolValue);
            }
        }
        
        if (weakSelf.collectionView.isShowCamera) {
            ZLPhotoAssets *zlAsset = [[ZLPhotoAssets alloc] init];
            [weakSelf.dataArray insertObject:zlAsset atIndex:0];
        }
        weakSelf.collectionView.dataArray = weakSelf.dataArray;
    }];
}

- (void)setMaxCount:(NSUInteger)maxCount {
    _maxCount = maxCount;
    self.collectionView.maxCount = _maxCount;
}

- (void)reloadPhotos {
    self.collectionView.isRecoderSelectPicker = NO;
    [self.collectionView.selectAssets removeAllObjects];
    [self.collectionView.selectsIndexPath removeAllObjects];
    [self.collectionView reloadData];
}

#pragma mark - ZLPhotoPickerCollectionViewDelegate
// 选择相片就会调用
- (void)pickerCollectionViewDidSelected:(ZLPhotoPickerCollectionView *)pickerCollectionView
                            deleteAsset:(ZLPhotoAssets *)deleteAssets {
    [self.selectAssets setArray:pickerCollectionView.selectAssets];
    if (_showInsertButton) {
        _showInsertButton(@(self.selectAssets.count).boolValue);
    }
}

// 点击拍照就会调用
- (void)pickerCollectionViewDidCameraSelect:(ZLPhotoPickerCollectionView *)pickerCollectionView {
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.delegate = self;
    ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window.rootViewController presentViewController:ctrl animated:YES completion:nil];
}

//重新进入系统相册，查看竖屏全部图片
- (void)pickerCollectionViewAgainSelect:(ZLPhotoPickerCollectionView *)pickerCollectionView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedPhotosNotification" object:nil];
}


#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 处理
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.6)];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_PHOTO object:nil userInfo:@{@"image":image}];
        });
                
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"请在真机使用!");
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        NSLog(@"保存相册成功");
        [self.dataArray removeAllObjects];
        [self showPhotosView:YES];
    } else {
        ///图片未能保存到本地
        NSLog(@"图片保存本地失败");
    }
}


- (void)initCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(_imageWH , _imageWH);
    layout.sectionInset = UIEdgeInsetsMake(0, 1, 1, 1);
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    _collectionView = [[ZLPhotoPickerCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.status = ZLPickerCollectionViewShowOrderStatusTimeAsc;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:ZLPhotoPickerCollectionViewCell.class forCellWithReuseIdentifier:kCellIdentifier];
    _collectionView.maxCount = _maxCount;
    _collectionView.isShowCamera = YES;
    _collectionView.isShowSeeAll = YES;
    _collectionView.topShowPhotoPicker = YES;
    _collectionView.collectionViewDelegate = self;
    [self addSubview:_collectionView];
}

- (NSMutableArray <ZLPhotoAssets *>*)selectAssets {
    if (!_selectAssets) {
        _selectAssets = [NSMutableArray array];
    }
    return _selectAssets;
}

- (NSMutableArray <ZLPhotoAssets *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
@end
