//
//  ZJVideoTools.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/12.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJVideoTools.h"





@implementation ZJVideoTools

+ (void)mixVideo:(AVAsset *)videoAsset startTime:(CMTime)startTime WithVideoCroppingFrame:(CGRect)videoCroppingFrame toUrl:(NSURL*)outputUrl outputFileType:(NSString*)outputFileType withMaxDuration:(CMTime)maxDuration compositionProgressBlock:(void(^)(CGFloat progress))compositionProgressBlock withCompletionBlock:(void(^)(NSError *error))completionBlock{
    
    NSError * error = nil;
    //1 — 采集
    
    //不添加背景音乐
    NSURL *audioUrl =nil;
    //AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];

    // 2 创建AVMutableComposition实例. apple developer 里边的解释 【AVMutableComposition is a mutable subclass of AVComposition you use when you want to create a new composition from existing assets. You can add and remove tracks, and you can add, remove, and scale time ranges.】
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3 - 视频通道  工程文件中的轨道，有音频轨、视频轨等，里面可以插入各种对应的素材
    
    // 这块是裁剪,rangtime .前面的是开始时间,后面是裁剪多长
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime,maxDuration);
    
    
    NSArray * videoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    
    //音频轨道
    
    //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
    
    AVMutableCompositionTrack *compositionVoiceTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    for (AVAssetTrack * track in [videoAsset tracksWithMediaType:AVMediaTypeAudio]) {
        [compositionVoiceTrack insertTimeRange:videoTimeRange ofTrack:track atTime:kCMTimeZero error:&error];
        
        if (error != nil) {
            completionBlock(error);
            return;
        }
    }
    
    for (AVAssetTrack * track in videoTracks) {
        [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:track atTime:kCMTimeZero error:&error];
        
        if (error != nil) {
            completionBlock(error);
            return;
        }
    }

    // 3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    AVAssetTrack *videoAssetTrack = [videoTracks objectAtIndex:0];
    
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    // AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];

    mainCompositionInst.accessibilityFrame = videoCroppingFrame;
    mainCompositionInst.renderSize = videoCroppingFrame.size;//裁剪的视频size
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    //声音长度截取范围==视频长度
    CMTimeRange audioTimeRange = videoTimeRange;
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];
    
    
    __block NSTimer *timer = nil;
    
    // 5 - Create exporter
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = outputUrl;
    exportSession.outputFileType = outputFileType;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.videoComposition = mainCompositionInst;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{

        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
             compositionProgressBlock(exportSession.progress);
            
            NSError * error = nil;
            if (exportSession.error != nil) {
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:exportSession.error.userInfo];
                NSString * subLocalizedDescription = [userInfo objectForKey:NSLocalizedDescriptionKey];
                [userInfo removeObjectForKey:NSLocalizedDescriptionKey];
                [userInfo setObject:@"Failed to mix audio and video" forKey:NSLocalizedDescriptionKey];
                [userInfo setObject:exportSession.outputFileType forKey:@"OutputFileType"];
                [userInfo setObject:exportSession.outputURL forKey:@"OutputUrl"];
                [userInfo setObject:subLocalizedDescription forKey:@"CauseLocalizedDescription"];
                
                [userInfo setObject:[AVAssetExportSession allExportPresets] forKey:@"AllExportSessions"];
                
                error = [NSError errorWithDomain:@"ZJVideoScreenshot" code:500 userInfo:userInfo];
            }
            
            completionBlock(error);
            
        });
    }];
    
    if (@available(iOS 10.0, *)) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            if (compositionProgressBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    compositionProgressBlock(exportSession.progress);
                    
                });
            }
        }];
    } else {
        // Fallback on earlier versions
    }
}

+ (UIImage*)getVideoPreViewImageFromVideo:(AVAsset *)videoAsset atTime:(float)atTime{
    // AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
//    AVURLAsset *asset = (AVURLAsset *)self.playerItem.asset;
    if ([videoAsset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
        return nil;
    }
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    gen.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    gen.appliesPreferredTrackTransform = YES;
    
    //防止时间出现偏差 当你指定要获取time时刻的帧，如果不设置这两个属性，系统会默认如果在指定time段内有缓存，就从缓存中直接返回结果，但并不准确，这是为了优化性能
    //    gen.requestedTimeToleranceAfter = kCMTimeZero;
    //    gen.requestedTimeToleranceBefore = kCMTimeZero;
    
    CMTime time = CMTimeMakeWithSeconds(atTime, 600);//atTime  第几秒的截图,是当前视频播放到的帧数的具体时间; 600 首选的时间尺度 "每秒的帧数"
    
    NSError *error = nil;
    CMTime actualTime;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];//线上视频比较耗时(新创建的AVURLAsset比较耗时)，用上一个AVURLAsset,或等player缓冲可以看了的时候，再截屏耗时短
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"一张图片耗时：====--%f", end - start);
    
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    UIGraphicsBeginImageContext(CGSizeMake([[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width, [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height));//asset.naturalSize.width, asset.naturalSize.height)
    [img drawInRect:CGRectMake(0, 0, [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width, [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(image);
    
    return scaledImage;
}
///获取本地视频的时长
+ (NSInteger)durationWithVideo:(NSString *)videoPath {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:opts];     //初始化视频媒体文件
    NSUInteger second = 0;
    second = ceilf((double)urlAsset.duration.value / (double)urlAsset.duration.timescale); // 获取视频总时长,单位秒
    return second;
}
@end
