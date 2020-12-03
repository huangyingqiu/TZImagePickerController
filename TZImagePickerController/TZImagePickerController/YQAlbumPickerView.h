//
//  YQAlbumPickerView.h
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/2.
//  Copyright © 2020 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YQAlbumPickerView : UIView 
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, weak) UIViewController *parentViewController;
- (void)configTableView;
@end

@class TZAlbumModel;
@interface YQAlbumCell : UITableViewCell
@property (nonatomic, strong) TZAlbumModel *model;
@property (weak, nonatomic) UIButton *selectedCountButton;
@end

NS_ASSUME_NONNULL_END
