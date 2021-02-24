//
//  PHAsset+TZEditAsset.h
//  TZImagePickerController
//
//  Created by yunyu on 2021/2/24.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (TZEditAsset)

/// 编辑后的本地视频URL
@property (nonatomic, strong, nullable) NSURL *editVideoURL;

/// 编辑后的图片
@property (nonatomic, strong, nullable) UIImage *editImage;

@end

NS_ASSUME_NONNULL_END
