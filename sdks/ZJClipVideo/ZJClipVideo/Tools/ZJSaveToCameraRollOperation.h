//
//  ZJSaveToCameraRollOperation.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/12.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ZJSaveToCameraRollOperation : NSObject

- (void)saveVideoURL:(NSURL *)url completion:(void(^)(NSString *, NSError *))completion;

- (void)saveImage:(UIImage *)image completion:(void(^)(NSError *))completion;

- (void)saveGIFURL:(NSURL *)url completion:(void(^)(NSString *, NSError *))completion;

@end


