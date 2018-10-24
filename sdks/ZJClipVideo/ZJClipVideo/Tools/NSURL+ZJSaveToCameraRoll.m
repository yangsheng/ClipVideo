//
//  NSURL+ZJSaveToCameraRoll.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/12.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "NSURL+ZJSaveToCameraRoll.h"

#import "ZJSaveToCameraRollOperation.h"


@implementation NSURL (ZJSaveToCameraRoll)

- (void)saveVideoToCameraRollWithCompletion:(void (^)(NSString * _Nullable path, NSError * _Nullable error))completion {
    ZJSaveToCameraRollOperation *saveToCameraRoll = [ZJSaveToCameraRollOperation new];
    [saveToCameraRoll saveVideoURL:self completion:completion];
}

- (void)saveGIFToCameraRollWithCompletion:(void (^__nullable)(NSString * _Nullable path, NSError * _Nullable error))completion{
    ZJSaveToCameraRollOperation *saveToCameraRoll = [ZJSaveToCameraRollOperation new];
    [saveToCameraRoll saveGIFURL:self completion:completion];
}

@end
