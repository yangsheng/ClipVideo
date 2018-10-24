//
//  NSURL+ZJSaveToCameraRoll.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/12.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (ZJSaveToCameraRoll)

- (void)saveVideoToCameraRollWithCompletion:(void (^__nullable)(NSString * _Nullable path, NSError * _Nullable error))completion;

- (void)saveGIFToCameraRollWithCompletion:(void (^__nullable)(NSString * _Nullable path, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
