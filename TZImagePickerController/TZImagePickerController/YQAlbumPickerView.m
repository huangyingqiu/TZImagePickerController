//
//  YQAlbumPickerView.m
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/2.
//  Copyright © 2020 谭真. All rights reserved.
//

#import "YQAlbumPickerView.h"
#import <Photos/Photos.h>
#import "TZImagePickerController.h"
#import "TZPhotoPreviewController.h"
#import "TZPhotoPickerController.h"
#import "TZAssetCell.h"
#import "TZAssetModel.h"
#import "UIView+TZLayout.h"
#import "TZImageManager.h"

@interface YQAlbumPickerView ()<UITableViewDataSource, UITableViewDelegate, PHPhotoLibraryChangeObserver> {
    UITableView *_tableView;
}
@property (nonatomic, strong) NSMutableArray *albumArr;
@end

@implementation YQAlbumPickerView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        self.isFirstAppear = YES;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)configTableView {
    if (![[TZImageManager manager] authorizationStatusAuthorized]) {
        return;
    }

    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.parentViewController.navigationController;
    if (self.isFirstAppear) {
        [imagePickerVc showProgressHUD];
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[TZImageManager manager] getAllAlbumsWithFetchAssets:!self.isFirstAppear completion:^(NSArray<TZAlbumModel *> *models) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_albumArr = [NSMutableArray arrayWithArray:models];
                for (TZAlbumModel *albumModel in self->_albumArr) {
                    albumModel.selectedModels = imagePickerVc.selectedModels;
                }
                [imagePickerVc hideProgressHUD];
                
                if (self.isFirstAppear) {
                    self.isFirstAppear = NO;
                    [self configTableView];
                }
                
                if (!self->_tableView) {
                    self->_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                    self->_tableView.rowHeight = 88;
                    self->_tableView.backgroundColor = [UIColor blackColor];
                    [self->_tableView setSeparatorInset:UIEdgeInsetsMake(0, 100, 0, 0)];
                    [self->_tableView setSeparatorColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]];
                    self->_tableView.tableFooterView = [[UIView alloc] init];
                    self->_tableView.dataSource = self;
                    self->_tableView.delegate = self;
                    [self->_tableView registerClass:[YQAlbumCell class] forCellReuseIdentifier:@"YQAlbumCell"];
                    [self addSubview:self->_tableView];
                    if (imagePickerVc.albumPickerPageUIConfigBlock) {
                        imagePickerVc.albumPickerPageUIConfigBlock(self->_tableView);
                    }
                } else {
                    [self->_tableView reloadData];
                }
            });
        }];
    });
}

- (void)updateSelectedState {
    if (!self.superview) { return; }
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.parentViewController.navigationController;
    for (TZAlbumModel *albumModel in self->_albumArr) {
        albumModel.selectedModels = imagePickerVc.selectedModels;
    }
    [self->_tableView reloadData];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
//     NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configTableView];
    });
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    _tableView.frame = self.bounds;
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.parentViewController.navigationController;
    if (imagePickerVc.albumPickerPageDidLayoutSubviewsBlock) {
        imagePickerVc.albumPickerPageDidLayoutSubviewsBlock(_tableView);
    }
//    NSLog(@">>>>: table height %f", _tableView.tz_height);
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YQAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YQAlbumCell"];
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.parentViewController.navigationController;
    cell.selectedCountButton.backgroundColor = imagePickerVc.iconThemeColor;
    cell.model = _albumArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TZPhotoPickerController *photoPickerVc = (TZPhotoPickerController *)self.parentViewController;
//    photoPickerVc.columnNumber = self.columnNumber;
    TZAlbumModel *model = _albumArr[indexPath.row];
    if (![photoPickerVc.model.name isEqualToString:model.name]) {
        photoPickerVc.model = model;
        [photoPickerVc resetData];
    }
    [photoPickerVc updateTitleView];
    [UIView animateWithDuration:0.25 animations:^{
        [self setTz_height:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end


@interface YQAlbumCell ()
@property (weak, nonatomic) UIImageView *posterImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *countLabel;
@end

@implementation YQAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor blackColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}

- (void)setModel:(TZAlbumModel *)model {
    _model = model;
    self.titleLabel.text = model.name;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",model.count];
    [[TZImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
        [self setNeedsLayout];
    }];
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _selectedCountButton.frame = CGRectMake(self.contentView.tz_width - 24 - 16, (self.tz_height - 24) / 2, 24, 24);
    NSInteger titleHeight = ceil(self.titleLabel.font.lineHeight);
    self.titleLabel.frame = CGRectMake(100, 20, self.tz_width - 100 - 50, titleHeight);
    NSInteger countHeight = ceil(self.countLabel.font.lineHeight);
    self.countLabel.frame =CGRectMake(100, 20 + titleHeight + 6, self.tz_width - 100 - 50, countHeight);
    self.posterImageView.frame = CGRectMake(16, 12, 64, 64);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
}

#pragma mark - Lazy load

- (UIImageView *)posterImageView {
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        posterImageView.layer.cornerRadius = 8;
        posterImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:posterImageView];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)countLabel {
    if (_countLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _countLabel = titleLabel;
    }
    return _countLabel;
}

- (UIButton *)selectedCountButton {
    if (_selectedCountButton == nil) {
        UIButton *selectedCountButton = [[UIButton alloc] init];
        selectedCountButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        selectedCountButton.layer.cornerRadius = 12;
        selectedCountButton.clipsToBounds = YES;
        selectedCountButton.backgroundColor = [UIColor redColor];
        [selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:selectedCountButton];
        _selectedCountButton = selectedCountButton;
    }
    return _selectedCountButton;
}

@end

