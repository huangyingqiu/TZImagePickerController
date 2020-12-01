//
//  YQCustomTitleView.h
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/1.
//  Copyright © 2020 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YQCustomTitleView : UIView

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, copy) void (^didClick)(void);

@end

NS_ASSUME_NONNULL_END
