//
//  YQPhotoPreviewBottomBar.m
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/2.
//  Copyright © 2020 谭真. All rights reserved.
//

#import "YQPhotoPreviewBottomBar.h"
#import "YQPhotoPreviewBottomListCell.h"
#import "TZImagePickerController.h"
#import "TZPhotoPickerController.h"
#import "UIView+TZLayout.h"

@interface YQPhotoPreviewBottomBar() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation YQPhotoPreviewBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
}

#pragma mark - Public
- (void)scrollToIndex:(NSInteger)index {
    self.currentIndex = index;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self.collectionView reloadData];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - Action

- (void)clickPreviewButton {
    if (self.didClickDoneButton) {
        self.didClickDoneButton();
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YQPhotoPreviewBottomListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YQPhotoPreviewBottomListCell" forIndexPath:indexPath];
    cell.themeColor = self.tzImagePickerController.iconThemeColor;
    [cell setupBorder:self.currentIndex == indexPath.row];
//    cell
    if (indexPath.row < self.selectedModels.count) {
        cell.model = self.selectedModels[indexPath.row];
    } else {
        cell.model = nil;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectedIndexPath && indexPath.row < self.selectedModels.count) {
        self.didSelectedIndexPath(indexPath);
        self.currentIndex = indexPath.row;
        [self.collectionView reloadData];
    }
}

#pragma mark - getter

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
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(68, 68);
        layout.minimumInteritemSpacing = 3;
//        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = self.backgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
//        _collectionView.contentInset = UIEdgeInsetsMake(12, 12, 12, 12);
        _collectionView.showsHorizontalScrollIndicator = NO;
    
        [self addSubview:_collectionView];
        [_collectionView registerClass:[YQPhotoPreviewBottomListCell class] forCellWithReuseIdentifier:@"YQPhotoPreviewBottomListCell"];
    }
    return _collectionView;
}

@end
