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
#import "UIView+TZLayout.h"

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
    
    [self updatePreviewButtonState];
}

- (void)updatePreviewButtonState {
    self.previewButton.enabled = self.selectedModels.count >= 1;
    self.previewButton.backgroundColor = self.previewButton.enabled ? self.tzImagePickerController.iconThemeColor : self.grayBackgroundColor;
}

#pragma mark - Action

- (void)clickPreviewButton {
    if (self.didClickDoneButton) {
        self.didClickDoneButton();
    }
}

- (void)longPressCollectionView:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:[gesture locationInView:self.collectionView]];
            if (selectedIndexPath && selectedIndexPath.row < self.selectedModels.count) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            [self.collectionView updateInteractiveMovementTargetPosition:[gesture locationInView:self.collectionView]];
            break;
        case UIGestureRecognizerStateEnded:
        {
            NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:[gesture locationInView:self.collectionView]];
            if (selectedIndexPath && selectedIndexPath.row < self.selectedModels.count) {
                [self.collectionView endInteractiveMovement];
            } else {
                [self.collectionView cancelInteractiveMovement];
            }
        }
            break;
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tzImagePickerController.maxImagesCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YQBottomBarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YQBottomBarCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row < self.selectedModels.count) {
        cell.model = self.selectedModels[indexPath.row];
    } else {
        cell.model = nil;
    }
    cell.needShowBorder = indexPath.row == self.selectedModels.count;
    
    __weak typeof(self) weakSelf = self;
    cell.didClickDeleteButton = ^(TZAssetModel * _Nonnull model) {
        TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)weakSelf.parentViewController.navigationController;
        NSArray *selectedModels = [NSArray arrayWithArray:tzImagePickerVc.selectedModels];
        for (TZAssetModel *model_item in selectedModels) {
            if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                [tzImagePickerVc removeSelectedModel:model_item];
                [weakSelf.selectedModels removeObject:model_item];
                [weakSelf.collectionView reloadData];
                [weakSelf updatePreviewButtonState];
                break;
            }
        }
        if (tzImagePickerVc.showSelectedIndex || tzImagePickerVc.showPhotoCannotSelectLayer) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TZ_PHOTO_PICKER_RELOAD_NOTIFICATION" object:tzImagePickerVc];
        }
        TZPhotoPickerController *photoPickerVc = (TZPhotoPickerController *)weakSelf.parentViewController;
        [photoPickerVc deSelectWithModel:model];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    TZAssetModel *model = self.selectedModels[sourceIndexPath.row];
    [self.selectedModels removeObjectAtIndex:sourceIndexPath.row];
    [self.selectedModels insertObject:model atIndex:destinationIndexPath.row];
//    [self.selectedModels exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
    TZImagePickerController *tzImagePickerVc = (TZImagePickerController *)self.parentViewController.navigationController;
    NSString *selectedId = tzImagePickerVc.selectedAssetIds[sourceIndexPath.row];
    [tzImagePickerVc.selectedAssetIds removeObjectAtIndex:sourceIndexPath.row];
    [tzImagePickerVc.selectedAssetIds insertObject:selectedId atIndex:destinationIndexPath.row];
    //    [tzImagePickerVc.selectedAssetIds exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];

    TZPhotoPickerController *photoPickerVc =  (TZPhotoPickerController *)self.parentViewController;
    [photoPickerVc collectionViewReload];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectedIndexPath && indexPath.row < self.selectedModels.count) {
        self.didSelectedIndexPath(indexPath);
    }
}

#pragma mark - getter

- (NSInteger)maxImagesCount {
    return self.tzImagePickerController.maxImagesCount;
}

-(TZImagePickerController *)tzImagePickerController {
    return (TZImagePickerController *)self.parentViewController.navigationController;
}

- (UIColor *)grayBackgroundColor {
    return [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
}

#pragma mark - setter

- (void)setSelectedModels:(NSMutableArray<TZAssetModel *> *)selectedModels {
    _selectedModels = selectedModels;
    [self.collectionView reloadData];
    [self updatePreviewButtonState];
    if (selectedModels.count > 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectedModels.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
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
        NSString *title = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Select %zd photos best"], self.tzImagePickerController.maxImagesCount];
        _titleLabel.text = title;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [[UIButton alloc] init];
        _previewButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_previewButton setTitle:self.tzImagePickerController.previewBtnTitleStr forState:UIControlStateNormal];
        [_previewButton setTitle:self.tzImagePickerController.previewBtnTitleStr forState:UIControlStateDisabled];
        [_previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateDisabled];
        _previewButton.backgroundColor = self.grayBackgroundColor;
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
        _lineView.backgroundColor = self.grayBackgroundColor;
        [self addSubview:_lineView];
    }
    return _lineView;
}

@end
