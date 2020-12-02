//
//  YQPhotoPickerBottomBar.m
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/2.
//  Copyright © 2020 谭真. All rights reserved.
//

#import "YQPhotoPickerBottomBar.h"
#import "YQBottomBarCollectionViewCell.h"
#import "TZImagePickerController.h"
#import "TZPhotoPickerController.h"
#import "UIView+Layout.h"

@interface YQPhotoPickerBottomBar() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation YQPhotoPickerBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = CGRectMake(0, 0, self.tz_width, 90);
    self.lineView.frame = CGRectMake(0, 90, self.tz_width, 1);
    
    self.previewButton.frame = CGRectMake(self.tz_width - 90, self.tz_height - 10 - 28, 75, 28);
    
    self.titleLabel.frame = CGRectMake(15, self.tz_height - 30, self.tz_width - 120, 16);
}

#pragma mark - Action

- (void)clickPreviewButton {
    
}

- (void)longPressCollectionView:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:[gesture locationInView:self.collectionView]];
            if (selectedIndexPath) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            [self.collectionView updateInteractiveMovementTargetPosition:[gesture locationInView:self.collectionView]];
            break;
        case UIGestureRecognizerStateEnded:
            [self.collectionView endInteractiveMovement];
            break;
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YQBottomBarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YQBottomBarCollectionViewCell" forIndexPath:indexPath];
//    cell.titleLabel.text = [NSString stringWithFormat:@"%@", self.dataSources[indexPath.row]];
    cell.model = self.selectedModels[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    cell.didClickDeleteButton = ^(TZAssetModel * _Nonnull model) {
        TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)weakSelf.parentViewController.navigationController;
        NSArray *selectedModels = [NSArray arrayWithArray:tzImagePickerVc.selectedModels];
        for (TZAssetModel *model_item in selectedModels) {
            if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                [tzImagePickerVc removeSelectedModel:model_item];
                [weakSelf.selectedModels removeObject:model_item];
                break;
            }
        }
        TZPhotoPickerController *photoPickerVc =  (TZPhotoPickerController *)self.parentViewController;
        NSInteger index = [photoPickerVc.model.models indexOfObject:model];
        TZAssetModel *deSelectModel = photoPickerVc.model.models[index];
        deSelectModel.isSelected = NO;
        [photoPickerVc reloadData];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.selectedModels exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
//    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.parentViewController.navigationController;
//    [tzImagePickerVc.selectedModels exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
//    TZPhotoPickerController *photoPickerVc =  (TZPhotoPickerController *)self.parentViewController;
//    [photoPickerVc reloadData];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - getter

- (NSInteger)maxImagesCount {
    return self.tzImagePickerController.maxImagesCount;
}

-(TZImagePickerController *)tzImagePickerController {
    return (TZImagePickerController *)self.parentViewController.navigationController;
}

#pragma mark - setter

- (void)setSelectedModels:(NSMutableArray<TZAssetModel *> *)selectedModels {
    _selectedModels = selectedModels;
    [self.collectionView reloadData];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(62, 62);
        layout.minimumInteritemSpacing = 15;
//        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = self.backgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.contentInset = UIEdgeInsetsMake(12, 12, 12, 12);
        _collectionView.showsHorizontalScrollIndicator = NO;
    
        [self addSubview:_collectionView];
        [_collectionView registerClass:[YQBottomBarCollectionViewCell class] forCellWithReuseIdentifier:@"YQBottomBarCollectionViewCell"];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCollectionView:)];
        [_collectionView addGestureRecognizer:longPress];
    }
    return _collectionView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = @"选择7个素材最佳";
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [[UIButton alloc] init];
        _previewButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_previewButton setTitle:self.tzImagePickerController.previewBtnTitleStr forState:UIControlStateNormal];
        [_previewButton setTitle:self.tzImagePickerController.previewBtnTitleStr forState:UIControlStateDisabled];
        [_previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        _previewButton.backgroundColor = self.tzImagePickerController.iconThemeColor;
        [_previewButton addTarget:self action:@selector(clickPreviewButton) forControlEvents:UIControlEventTouchUpInside];
        _previewButton.layer.cornerRadius = 14;
        _previewButton.layer.masksToBounds = YES;
        [self addSubview:_previewButton];
    }
    return _previewButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
        [self addSubview:_lineView];
    }
    return _lineView;
}

@end
