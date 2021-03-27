//
//  YQPhotoPreviewBottomListCell.h
//  YQImagePickerController
//
//  Created by yunyu on 2020/12/2.
//  Copyright © 2020 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YQPhotoPreviewBottomListCell : UICollectionViewCell

@property (nonatomic, strong, nullable) TZAssetModel *model;

@property (nonatomic, strong) UIColor *themeColor;

@property (nonatomic, copy) void (^didClickDeleteButton)(TZAssetModel *model);

@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) int32_t imageRequestID;

- (void)setupBorder:(BOOL)needShowBorder;

@end

NS_ASSUME_NONNULL_END
