//
//  ZJVideoTools.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/12.
//  Copyright © 2018年 郑俱. All rights reserved.
//视频工具

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface ZJVideoTools : NSObject
/**
 剪裁视频

 @param videoAsset 视频媒体资源
 @param startTime 开始时间
 @param videoCroppingFrame 裁剪frame
 @param outputUrl 输出路径
 @param outputFileType 输出视频类型
 @param maxDuration 时长
 @param completionBlock error回调
 */
+ (void)mixVideo:(AVAsset *)videoAsset startTime:(CMTime)startTime WithVideoCroppingFrame:(CGRect)videoCroppingFrame toUrl:(NSURL*)outputUrl outputFileType:(NSString*)outputFileType withMaxDuration:(CMTime)maxDuration compositionProgressBlock:(void(^)(CGFloat progress))compositionProgressBlock withCompletionBlock:(void(^)(NSError *error))completionBlock;

+ (UIImage*)getVideoPreViewImageFromVideo:(AVAsset *)videoAsset atTime:(float)atTime;

@end


