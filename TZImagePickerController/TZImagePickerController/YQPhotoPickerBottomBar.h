//
//  YQPhotoPickerBottomBar.h
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/2.
//  Copyright © 2020 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YQPhotoPickerBottomBar : UIView

@property (nonatomic, weak) UIViewController *parentViewController;

@property (nonatomic, strong) NSMutableArray<TZAssetModel *> *selectedModels;

@property (nonatomic, copy) void (^didClickDoneButton)(void);

@end

NS_ASSUME_NONNULL_END
