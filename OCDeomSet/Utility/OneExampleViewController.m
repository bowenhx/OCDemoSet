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
#import "EditImageViewCell.h"

static NSInteger const kMaxCount = 9; //最多选9张

@interface OneExampleViewController () <UITextViewDelegate, EditImageViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) ToolbarImagesView *inputImgView;

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
    
    _flowLayout.minimumLineSpacing = 1;
    //最小item间距（默认为10）
    _flowLayout.minimumInteritemSpacing = 1;
    float cellW = (_collectionView.w - 4) / 3.0;
    _flowLayout.itemSize = CGSizeMake(cellW, cellW);
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1);
    [_collectionView registerNib:[UINib nibWithNibName:kEditImageViewCellIdentifier bundle:nil] forCellWithReuseIdentifier:kEditImageViewCellIdentifier];
//    [_collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"cell"];
    _collectionView.layer.borderWidth = 1;
    _textView.layer.borderWidth = 1;
    _textView.layer.borderColor = [UIColor redColor].CGColor;
    _dataSource = [NSMutableArray array];
    
    //2.发布主题
    _inputImgView = [[ToolbarImagesView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT - 49, kSCREEN_WIDTH, 49)];
    _inputImgView.maxCount = kMaxCount;
    [self.view addSubview:_inputImgView];
    
    @WEAKSELF(self);
    _inputImgView.selectedFinish = ^(NSArray<ZLPhotoAssets *> *photos, UIButton *button) {
        if (photos && photos.count) {
            [selfWeak.dataSource addObjectsFromArray:photos];
            [selfWeak.collectionView reloadData];
            selfWeak.inputImgView.maxCount = kMaxCount - selfWeak.dataSource.count;
        } else {
            if (button.selected) {
                [selfWeak.textView resignFirstResponder];
            } else {
                [selfWeak.textView becomeFirstResponder];
            }
        }
    };
    
    [self mAddNotification];
}

- (void)mAddNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedAllPhotos) name:@"selectedPhotosNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
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


- (void)selectedAllPhotos {
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.maxCount = kMaxCount - self.dataSource.count;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.photoStatus = PickerPhotoStatusPhotos;
    pickerVc.topShowPhotoPicker = YES;
    pickerVc.isShowCamera = YES;
    @WEAKSELF(self);
    pickerVc.callBack = ^(NSArray<ZLPhotoAssets *> *status) {
        if (status.count) {
            [selfWeak.dataSource addObjectsFromArray:status];
            [selfWeak.collectionView reloadData];
            selfWeak.inputImgView.maxCount = kMaxCount - selfWeak.dataSource.count;
        }
    };
    [pickerVc showPickerVc:self];
    
}

- (void)deleteItemAction:(NSInteger)index {
    [self.dataSource removeObjectAtIndex:index];
    [self.collectionView reloadData];
    self.inputImgView.maxCount = kMaxCount - self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EditImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kEditImageViewCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    cell.delegate = self;
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn setTitle:kStringInt(indexPath.row) forState:UIControlStateNormal];
    UIImage *image = self.dataSource[indexPath.row].originImage;
    if (image) {
       cell.imageView.image = image;
    }
    return cell;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [_inputImgView hiddenImagesView];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
//    _keyboardY = keyboardF.origin.y;
    [UIView animateWithDuration:duration animations:^{
        if (keyboardF > kSCREEN_HEIGHT) {
            self.inputImgView.y = kSCREEN_HEIGHT - self.inputImgView.h;
        } else {
            self.inputImgView.y = keyboardF - self.inputImgView.h;
        }
    }];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration animations:^{
        if (keyboardF.origin.y > kSCREEN_HEIGHT) {
            self.inputImgView.y = kSCREEN_HEIGHT - self.inputImgView.h;
        } else {
            self.inputImgView.y = keyboardF.origin.y - self.inputImgView.h;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_inputView) [_inputView endEditing];
    
}



@end
