//
//  PHAsset+TZEditAsset.m
//  TZImagePickerController
//
//  Created by yunyu on 2021/2/24.
//

#import "PHAsset+TZEditAsset.h"
#import <objc/runtime.h>

static NSString *kVideoURLKey = @"VideoURLKey";
static NSString *kEditImageKey = @"EditImageKey";

@implementation PHAsset (TZEditAsset)

- (void)setEditVideoURL:(NSURL *)editVideoURL {
    objc_setAssociatedObject(self, &kVideoURLKey, editVideoURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)editVideoURL {
    return objc_getAssociatedObject(self, &kVideoURLKey);
}

- (void)setEditImage:(UIImage *)editImage {
    objc_setAssociatedObject(self, &kEditImageKey, editImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)editImage {
    return objc_getAssociatedObject(self, &kEditImageKey);
}

@end
