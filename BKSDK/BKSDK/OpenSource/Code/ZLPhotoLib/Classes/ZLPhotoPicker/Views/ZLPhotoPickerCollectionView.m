//
//  PickerCollectionView.m
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoPickerCollectionView.h"
#import "ZLPhotoPickerCollectionViewCell.h"
#import "ZLPhotoPickerImageView.h"
#import "ZLPhotoPickerFooterCollectionReusableView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZLPhotoAssets.h"
#import "ZLPhoto.h"
#import "UIImage+ZLPhotoLib.h"

@interface ZLPhotoPickerCollectionView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic , strong) ZLPhotoPickerFooterCollectionReusableView *footerView;

// 判断是否是第一次加载
@property (nonatomic , assign , getter=isFirstLoadding) BOOL firstLoadding;

@end

@implementation ZLPhotoPickerCollectionView

#pragma mark -getter
- (NSMutableArray *)selectsIndexPath{
    if (!_selectsIndexPath) {
        _selectsIndexPath = [NSMutableArray array];
    }
    //修改：注释防止重新排序
//    if (_selectsIndexPath) {
//        NSSet *set = [NSSet setWithArray:_selectsIndexPath];
//        _selectsIndexPath = [NSMutableArray arrayWithArray:[set allObjects]];
//    }
    return _selectsIndexPath;
}

- (void)setMaxCount:(NSInteger)maxCount{
    _maxCount = maxCount;
    
}

#pragma mark -setter
- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    
    // 需要记录选中的值的数据
    if (self.isRecoderSelectPicker){
//        NSMutableArray *selectAssets = [NSMutableArray array];
//        for (ZLPhotoAssets *asset in self.selectAssets) {
//            for (ZLPhotoAssets *asset2 in self.dataArray) {
//
//                if (![asset isKindOfClass:[ZLPhotoAssets class]] || ![asset2 isKindOfClass:[ZLPhotoAssets class]]) {
//                    continue;
//                }
//
//                if ([asset.assetURL isEqual:asset2.asset.defaultRepresentation.url]) {
//                    [selectAssets addObject:asset2];
//                    break;
//                }
//            }
//        }
        //修改： 当拍照时记录拍照后的顺序数字
        self.isRecoderSelectPicker = NO;
        __block NSMutableArray *changeNum = [NSMutableArray arrayWithCapacity:_selectAssets.count];
        [self.selectsIndexPath enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [changeNum addObject:@(obj.integerValue + 1)];
        }];
        //添加每次拍照后图片为第一个，所以记录为1
        [changeNum addObject:@(1)];
        [self.selectsIndexPath setArray:changeNum];
        
//        _selectAssets = _selectAssets;
    }
    
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _selectAssets = [NSMutableArray array];
    }
    return self;
}

#pragma mark -<UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ZLPhotoPickerCollectionViewCell *cell = [ZLPhotoPickerCollectionViewCell cellWithCollectionView:collectionView
                                                                             cellForItemAtIndexPath:indexPath];
    
    if(indexPath.item == 0 && self.topShowPhotoPicker && self.isShowCamera){
        UIImageView *imageView = [[cell.contentView subviews] lastObject];
        // 判断真实类型
        if (![imageView isKindOfClass:[UIImageView class]]) {
            imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
            imageView.backgroundColor = [UIColor colorWithRed:240/255.0 green:239/255.0 blue:245/255.0 alpha:1.0];
            imageView.contentMode = UIViewContentModeCenter;
            imageView.clipsToBounds = YES;
            imageView.userInteractionEnabled = YES;
            [cell.contentView addSubview:imageView];
            if (_isShowSeeAll) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, imageView.zl_height - 40, 40, 40);
                [button setImage:[UIImage imageNamed:@"def_reply_gallery"] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(selectedPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:button];
            }
        }
        imageView.tag = indexPath.item;
        //修改相机图片
        imageView.image = [UIImage imageNamed:@"def_reply_camera"];//ml_imageFromBundleNamed:@"camera"];
    }else{
        ZLPhotoPickerImageView *cellImgView = [[ZLPhotoPickerImageView alloc] initWithFrame:cell.bounds];
        // 需要记录选中的值的数据
        if (self.isRecoderSelectPicker) {
            for (ZLPhotoAssets *asset in self.selectAssets) {
                if ([asset isKindOfClass:[ZLPhotoAssets class]] && [[asset assetURL] isEqual:[(ZLPhotoAssets *)self.dataArray[indexPath.item] asset].defaultRepresentation.url]) {
                    [self.selectsIndexPath addObject:@(indexPath.row)];
                }
            }
        }
        
        [cell.contentView addSubview:cellImgView];

        cellImgView.isClickHaveAnimation = NO;
        BOOL contains = [self.selectsIndexPath containsObject:@(indexPath.row)];
        cellImgView.selectedCount = contains ? ([self.selectsIndexPath indexOfObject:@(indexPath.row)] + 1) : 0;
        cellImgView.maskViewFlag = contains;
        ZLPhotoAssets *asset = self.dataArray[indexPath.item];
        cellImgView.isVideoType = asset.isVideoType;
        if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
            [asset thumbImageCallBack:^(UIImage *image) {
                asset.thumbImage = image;
                cellImgView.image = image;
            }];
        }
    }
    
    return cell;
}

//选择相册
- (void)selectedPhotoLibrary {
    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewAgainSelect:)]) {
        [self.collectionViewDelegate pickerCollectionViewAgainSelect:self];
    }
}

- (BOOL)validatePhotoCount:(NSInteger)maxCount{
    if (self.selectAssets.count >= maxCount || maxCount < 0) {
        NSString *format = [NSString stringWithFormat:@"最多只能選擇%zd張圖片",maxCount];
        if (maxCount <= 0) {
            format = [NSString stringWithFormat:@"您已經選滿了圖片."];
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:format delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alertView show];
        return NO;
    }
    return YES;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if (self.topShowPhotoPicker && indexPath.item == 0 && self.isShowCamera) {
        NSUInteger maxCount = (self.maxCount == 0) ? KPhotoShowMaxCount :  self.maxCount;
        if (![self validatePhotoCount:maxCount]){
            return ;
        }
        if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidCameraSelect:)]) {
            [self.collectionViewDelegate pickerCollectionViewDidCameraSelect:self];
        }
        return ;
    }
    
    if (!self.lastDataArray) {
        self.lastDataArray = [NSMutableArray array];
    }
    
    ZLPhotoPickerCollectionViewCell *cell = (ZLPhotoPickerCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    
    ZLPhotoAssets *asset = self.dataArray[indexPath.row];
    ZLPhotoPickerImageView *pickerImageView = [cell.contentView.subviews lastObject];
    // 如果没有就添加到数组里面，存在就移除
    if (pickerImageView.isMaskViewFlag) {
        [self.selectsIndexPath removeObject:@(indexPath.row)];
        [self.selectAssets removeObject:asset];
        [self.lastDataArray removeObject:asset];
        [collectionView reloadData];
    }else{
        // 1 判断图片数超过最大数或者小于0
        NSInteger maxCount = (self.maxCount == 0) ? KPhotoShowMaxCount :  self.maxCount;
        if (![self validatePhotoCount:maxCount]){
            return ;
        }
        
        [self.selectsIndexPath addObject:@(indexPath.row)];
        [self.selectAssets addObject:asset];
        [self.lastDataArray addObject:asset];
    }
    // 告诉代理现在被点击了!
    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidSelected: deleteAsset:)]) {
        if (pickerImageView.isMaskViewFlag) {
            // 删除的情况下
            [self.collectionViewDelegate pickerCollectionViewDidSelected:self deleteAsset:asset];
        }else{
            [self.collectionViewDelegate pickerCollectionViewDidSelected:self deleteAsset:nil];
        }
    }
    
    pickerImageView.isClickHaveAnimation = YES;
    pickerImageView.selectedCount = self.selectAssets.count;
    pickerImageView.maskViewFlag = ([pickerImageView isKindOfClass:[ZLPhotoPickerImageView class]]) && !pickerImageView.isMaskViewFlag;
    
}

#pragma mark 底部View
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ZLPhotoPickerFooterCollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionFooter) {
        ZLPhotoPickerFooterCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        footerView.count = self.dataArray.count;
        reusableView = footerView;
        self.footerView = footerView;
    }else{
        
    }
    return reusableView;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    // 时间置顶的话
    if (self.status == ZLPickerCollectionViewShowOrderStatusTimeDesc) {
        if (!self.firstLoadding && self.contentSize.height > [[UIScreen mainScreen] bounds].size.height) {
            // 滚动到最底部（最新的）
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            // 展示图片数
            self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + 100);
            self.firstLoadding = YES;
        }
    }else if (self.status == ZLPickerCollectionViewShowOrderStatusTimeAsc){
        // 滚动到最底部（最新的）
        if (!self.firstLoadding && self.contentSize.height > [[UIScreen mainScreen] bounds].size.height) {
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            // 展示图片数
            self.contentOffset = CGPointMake(self.contentOffset.x, -self.contentInset.top);
            self.firstLoadding = YES;
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
