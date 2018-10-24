//
//  UIImage+ZJSaveToCameraRoll.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/12.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ZJSaveToCameraRoll)
- (void)saveToCameraRollWithCompletion:(void (^__nullable)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
