//
//  UIImage+ZJSaveToCameraRoll.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/12.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "UIImage+ZJSaveToCameraRoll.h"
#import "ZJSaveToCameraRollOperation.h"

@implementation UIImage (ZJSaveToCameraRoll)

- (void)saveToCameraRollWithCompletion:(void (^)(NSError * _Nullable))completion {
    ZJSaveToCameraRollOperation *saveToCameraRoll = [ZJSaveToCameraRollOperation new];
    [saveToCameraRoll saveImage:self completion:completion];
}

@end
