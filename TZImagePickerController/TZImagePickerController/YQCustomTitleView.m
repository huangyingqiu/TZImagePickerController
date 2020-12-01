//
//  YQCustomTitleView.m
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/1.
//  Copyright © 2020 谭真. All rights reserved.
//

#import "YQCustomTitleView.h"

@implementation YQCustomTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
        [self addGestureRecognizer:tap];
        [self addSubview:self.label];
        self.label.frame = self.bounds;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

- (void)click {
    if (self.didClick) {
        self.didClick();
    }
}


- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:16];
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

@end
