//
//  TZPhotoPickerController.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TZAlbumModel;
@interface TZPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) TZAlbumModel *model;

/// 单选视频状态下，视频编辑完成
- (void)didFinishEditVideoWithURL:(NSURL *)videoURL coverImage:(UIImage *)image;

/// 单选图片状态下，图片编辑完成
- (void)didFinishEditImageWithImage:(UIImage *)image;

@end


@interface TZCollectionView : UICollectionView

@end
