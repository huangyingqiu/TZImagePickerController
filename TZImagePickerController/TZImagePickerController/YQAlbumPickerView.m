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
#import "UIView+Layout.h"
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
        if (@available(iOS 13.0, *)) {
            self.backgroundColor = UIColor.tertiarySystemBackgroundColor;
        } else {
            self.backgroundColor = [UIColor whiteColor];
        }
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
                    self->_tableView.rowHeight = 70;
                    if (@available(iOS 13.0, *)) {
                        self->_tableView.backgroundColor = [UIColor tertiarySystemBackgroundColor];
                    } else {
                        self->_tableView.backgroundColor = [UIColor whiteColor];
                    }
                    self->_tableView.tableFooterView = [[UIView alloc] init];
                    self->_tableView.dataSource = self;
                    self->_tableView.delegate = self;
                    [self->_tableView registerClass:[TZAlbumCell class] forCellReuseIdentifier:@"TZAlbumCell"];
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
    TZAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TZAlbumCell"];
    if (@available(iOS 13.0, *)) {
        cell.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    }
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.parentViewController.navigationController;
    cell.albumCellDidLayoutSubviewsBlock = imagePickerVc.albumCellDidLayoutSubviewsBlock;
    cell.albumCellDidSetModelBlock = imagePickerVc.albumCellDidSetModelBlock;
    cell.selectedCountButton.backgroundColor = imagePickerVc.iconThemeColor;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TZPhotoPickerController *photoPickerVc = (TZPhotoPickerController *)self.parentViewController;//[[TZPhotoPickerController alloc] init];
//    photoPickerVc.columnNumber = self.columnNumber;
    TZAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.model = model;
    [photoPickerVc resetData];
//    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self setTz_height:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
