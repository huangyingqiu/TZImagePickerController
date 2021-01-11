//
//  YQCustomTitleView.m
//  TZImagePickerController
//
//  Created by yunyu on 2020/12/1.
//  Copyright © 2020 谭真. All rights reserved.
//

#import "YQCustomTitleView.h"
#import "TZImagePickerController.h"

@interface YQCustomTitleView()
@property (nonatomic, strong) UILabel *label;
@end

@implementation YQCustomTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
        [self addGestureRecognizer:tap];
        [self addSubview:self.label];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.bounds;
}

- (void)click {
    if (self.didClick) {
        self.didClick();
    }
}

- (void)updateLabelState {
    if (!self.title) { return; }
    // 1.文本
    NSString *text = [NSString stringWithFormat:@"%@ ", self.title];
    NSMutableAttributedString *attri =  [[NSMutableAttributedString alloc] initWithString:text];
    [attri addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, text.length)];
    [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, text.length)];
    
    // 2.图片
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    attch.image = self.isSelected ? [UIImage tz_imageNamedFromMyBundle:@"album_ic_up"] : [UIImage tz_imageNamedFromMyBundle:@"album_ic_down"];
    attch.bounds = self.isSelected ? CGRectMake(0, -2, 11, 11) : CGRectMake(0, 2, 11, 11);
    
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    [attri appendAttributedString:string];
    
    self.label.attributedText = attri;
}

#pragma mark - setter

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    [self updateLabelState];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self updateLabelState];
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
