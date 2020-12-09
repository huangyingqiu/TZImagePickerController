//
//  YQShowMediaTypeView.m
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/9.
//  Copyright © 2020 谭真. All rights reserved.
//

#import "YQShowMediaTypeView.h"
#import "TZImagePickerController.h"

@interface YQShowMediaTypeView()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation YQShowMediaTypeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = [NSBundle tz_localizedStringForKey:@"Photos"];

    }
    return _titleLabel;
}

@end
