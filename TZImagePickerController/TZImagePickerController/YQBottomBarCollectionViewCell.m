//
//  YQBottomBarCollectionViewCell.m
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/2.
//  Copyright © 2020 谭真. All rights reserved.
//

#import "YQBottomBarCollectionViewCell.h"
#import "TZImagePickerController.h"
#import "UIView+Layout.h"

@interface YQBottomBarCollectionViewCell()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation YQBottomBarCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.contentView.layer.borderColor = self.themeColor.CGColor;
        self.contentView.layer.borderWidth = 2;
    } else {
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        self.contentView.layer.borderWidth = 0;
    }
}

- (void)setupSubviews {
    self.themeColor = [UIColor colorWithRed:59 / 255.0 green:195 / 255.0 blue:255 / 255.0 alpha:1.0];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.deleteButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.contentView.bounds;
    self.deleteButton.frame = CGRectMake(self.tz_width - 20, 2, 18, 18);
}

#pragma mark - Action

- (void)clickDeleteButton {
    if (self.didClickDeleteButton) {
        self.didClickDeleteButton(self.model);
    }
}

#pragma mark - setter

- (void)setModel:(TZAssetModel *)model {
    _model = model;
    self.representedAssetIdentifier = model.asset.localIdentifier;
    int32_t imageRequestID = [[TZImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        // Set the cell's thumbnail image if it's still showing the same asset.
        if ([self.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            self.imageView.image = photo;
            [self setNeedsLayout];
        } else {
            // NSLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
//            [self hideProgressView];
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
    
//    self.type = (NSInteger)model.type;
    // 让宽度/高度小于 最小可选照片尺寸 的图片不能选中
    if (![[TZImageManager manager] isPhotoSelectableWithAsset:model.asset]) {
//        if (_selectImageView.hidden == NO) {
//            self.selectPhotoButton.hidden = YES;
//            _selectImageView.hidden = YES;
//        }
    }
    [self setNeedsLayout];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage tz_imageNamedFromMyBundle:@"ic_album_default_video"];
    }
    return _imageView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setImage:[UIImage tz_imageNamedFromMyBundle:@"photo_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

@end
