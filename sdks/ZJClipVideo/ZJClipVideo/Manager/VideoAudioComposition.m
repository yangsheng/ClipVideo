//
//  VideoAudioComposition.m
//  VideoAudioCompositionDemo
//
//  Created by 高磊 on 2018/1/22.
//  Copyright © 2018年 高磊. All rights reserved.
//

#import "VideoAudioComposition.h"
#import "GLFolderManager.h"
#import <UIKit/UIKit.h>

static NSString *const kCompositionPath = @"GLComposition";

@interface VideoAudioComposition()
@property(nonatomic, strong) AVMutableVideoComposition *videoComposition;
@end



@implementation VideoAudioComposition


- (NSString *)compositionPath
{
    return [GLFolderManager createCacheFilePath:kCompositionPath];
}

- (void)compositionVideoUrl:(NSURL *)videoUrl videoTimeRange:(CMTimeRange)videoTimeRange audioUrl:(NSURL *)audioUrl audioTimeRange:(CMTimeRange)audioTimeRange success:(SuccessBlcok)successBlcok
{
    NSCAssert(_compositionName.length > 0, @"请输入转换后的名字");
    NSString *outPutFilePath = [[self compositionPath] stringByAppendingPathComponent:_compositionName];
    
    //存在该文件
    if ([GLFolderManager fileExistsAtPath:outPutFilePath]) {
        [GLFolderManager clearCachesWithFilePath:outPutFilePath];
    }
    
    // 创建可变的音视频组合
    AVMutableComposition *composition = [AVMutableComposition composition];
    // 音频通道
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    AVMutableCompositionTrack *videoTrack = nil;
    
    
    // 视频采集
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    videoTimeRange = [self fitTimeRange:videoTimeRange avUrlAsset:videoAsset];
    
    // 音频采集
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
    
    audioTimeRange =  videoTimeRange;
    //[self fitTimeRange:audioTimeRange avUrlAsset:audioAsset];

    
    if (_compositionType == VideoAudioToVideo) {
        //以视频时间为标准 若视频时间小于音频时间 则让音频时间和视频时间保持一致
        if (CMTimeCompare(videoTimeRange.duration,audioTimeRange.duration))
        {
            audioTimeRange.duration = videoTimeRange.duration;
        }
        //在测试中发现 VideoAudioToAudio如果不用 视频通道  就不要去创建 否则会失败
        videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    }

    

    // 音频采集通道
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    // 加入合成轨道之中
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];

    
    switch (_compositionType) {
        case VideoAudioToAudio:
        {
            //  音频采集通道
            AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            //  把采集轨道数据加入到可变轨道之中
            [audioTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:audioTimeRange.duration error:nil];
        }
            break;
        case VideoAudioToVideo:{

            //  视频采集通道
            AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            //  把采集轨道数据加入到可变轨道之中
            [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
        }
            break;
        default:
            break;
    }

    [self composition:composition storePath:outPutFilePath success:successBlcok];
}

- (void)compositionVideoUrl:(NSURL *)videoUrl videoTimeRange:(CMTimeRange)videoTimeRange mergeVideoUrl:(NSURL *)mergeVideoUrl mergeVideoTimeRange:(CMTimeRange)mergeVideoTimeRange success:(SuccessBlcok)successBlcok
{
    switch (_compositionType) {
        case VideoToVideo:
        {
            NSArray *timeRanges = [NSArray arrayWithObjects:[NSValue valueWithCMTimeRange:videoTimeRange],[NSValue valueWithCMTimeRange:mergeVideoTimeRange] ,nil];
            [self compositionVideos:@[videoUrl,mergeVideoUrl] timeRanges:timeRanges success:successBlcok];
        }
            break;
        case VideoToAudio:{
            NSArray *timeRanges = [NSArray arrayWithObjects:[NSValue valueWithCMTimeRange:videoTimeRange],[NSValue valueWithCMTimeRange:mergeVideoTimeRange] ,nil];
            [self compositionAudios:@[videoUrl,mergeVideoUrl] timeRanges:timeRanges success:successBlcok];
        }
            break;
        default:
            break;
    }
}

- (void)compositionVideos:(NSArray<NSURL *> *)videos timeRanges:(NSArray<NSValue *> *)timeRanges success:(SuccessBlcok)successBlcok
{
    [self compositionMedia:videos timeRanges:timeRanges type:0 success:successBlcok];
}

- (void)compositionAudios:(NSArray<NSURL *> *)audios timeRanges:(NSArray<NSValue *> *)timeRanges success:(SuccessBlcok)successBlcok
{
    [self compositionMedia:audios timeRanges:timeRanges type:1 success:successBlcok];
}


#pragma mark == private method
- (void)compositionMedia:(NSArray<NSURL *> *)media timeRanges:(NSArray<NSValue *> *)timeRanges type:(NSInteger)type success:(SuccessBlcok)successBlcok
{
    NSCAssert(_compositionName.length > 0, @"请输入转换后的名字");
    NSCAssert((timeRanges.count == 0 || timeRanges.count == media.count), @"请输入正确的timeRange");
    NSString *outPutFilePath = [[self compositionPath] stringByAppendingPathComponent:_compositionName];
   
    //存在该文件
    if ([GLFolderManager fileExistsAtPath:outPutFilePath]) {
        [GLFolderManager clearCachesWithFilePath:outPutFilePath];
    }

    // 创建可变的音视频组合
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    
    //----------实验转场--
    AVMutableVideoComposition *videoComposition = nil;
    videoComposition = [AVMutableVideoComposition videoComposition];
    NSMutableArray *instructions = [NSMutableArray array];
    
    CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * 3);
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * 3);
 
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset *videoAsset11 = nil;
    CMTime transitionDuration = CMTimeMakeWithSeconds(1, 600);
    //----------实验转场--
    
    if (type == 0) {
        // 视频通道
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        // 音频通道
        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        CMTime atTime = kCMTimeZero;
        
        for (int i = 0;i < media.count;i ++) {
            NSURL *url = media[i];
            CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
            if (timeRanges.count > 0) {
                timeRange = [timeRanges[i] CMTimeRangeValue];
            }
            
            // 视频采集
            AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
            timeRange = [self fitTimeRange:timeRange avUrlAsset:videoAsset];
            
            // 视频采集通道
            AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            // 把采集轨道数据加入到可变轨道之中
            [videoTrack insertTimeRange:timeRange ofTrack:videoAssetTrack atTime:atTime error:nil];
            
            // 音频采集通道
            AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            // 加入合成轨道之中
            [audioTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:atTime error:nil];
            
            atTime = CMTimeAdd(atTime, timeRange.duration);
            
            //----------实验转场--
            videoAsset11 = videoAsset;

            CMTime halfClipDuration = [videoAsset duration];
            halfClipDuration.timescale *= 2;
            
            transitionDuration = CMTimeMinimum(transitionDuration, halfClipDuration);
            
            
            CMTimeRange timeRangeInAsset;

            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
            
            passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
//            if (i > 0)
//            {
                passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start,  CMTimeMakeWithSeconds(1, 600));
                passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration,  CMTimeMakeWithSeconds(1, 600));
//            }
//            if (i+1 < 3)
//            {
//                passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration,  CMTimeMakeWithSeconds(1, 600));
//            }
            
            nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
            nextClipStartTime = CMTimeSubtract(nextClipStartTime,  CMTimeMakeWithSeconds(1, 600));
             transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime,  CMTimeMakeWithSeconds(1, 600));
            
            // Pass through clip i.
            AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            passThroughInstruction.timeRange = passThroughTimeRanges[i];
            
            AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
            [instructions addObject:passThroughInstruction];
            
            
            // Add transition from clip i to clip i+1.
            AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            transitionInstruction.timeRange = transitionTimeRanges[i];
            
            AVMutableVideoCompositionLayerInstruction *fromLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            AVMutableVideoCompositionLayerInstruction *toLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            //right
            [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity toEndTransform:CGAffineTransformMakeTranslation(-composition.naturalSize.width, 0.0) timeRange:transitionTimeRanges[i]];
            
            [toLayer setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(composition.naturalSize.width, 0.0) toEndTransform:CGAffineTransformIdentity timeRange:transitionTimeRanges[i]];
            
            
            transitionInstruction.layerInstructions = [NSArray arrayWithObjects:fromLayer, toLayer, nil];
            [instructions addObject:transitionInstruction];
            
            //----------实验转场--
            
        }
    }else{
        // 音频通道
        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        CMTime atTime = kCMTimeZero;
        
        for (int i = 0;i < media.count;i ++) {
            NSURL *url = media[i];
            CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
            if (timeRanges.count > 0) {
                timeRange = [timeRanges[i] CMTimeRangeValue];
            }
            
            // 音频采集
            AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
            timeRange = [self fitTimeRange:timeRange avUrlAsset:audioAsset];
            
            // 音频采集通道
            AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            // 加入合成轨道之中
            [audioTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:atTime error:nil];
            
            atTime = CMTimeAdd(atTime, timeRange.duration);
        }
    }
    
    //----实验转场-
    
    AVAssetTrack *clipVideoTrack = [[videoAsset11 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0 / clipVideoTrack.nominalFrameRate, clipVideoTrack.naturalTimeScale);
    videoComposition.renderSize = composition.naturalSize;
    
    videoComposition.instructions = instructions;
    self.videoComposition = videoComposition;
    //------实验转场-
    
    
    [self composition:composition storePath:outPutFilePath success:successBlcok];
}
- (void)compositionVideos:(NSURL*)videoUrl scale:(float )scale success:(SuccessBlcok)successBlcok{
    
    NSString *outPutFilePath = [[self compositionPath] stringByAppendingPathComponent:_compositionName];
    
    //存在该文件
    if ([GLFolderManager fileExistsAtPath:outPutFilePath]) {
        [GLFolderManager clearCachesWithFilePath:outPutFilePath];
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 视频通道
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    // 音频通道
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    

    CMTime atTime = kCMTimeZero;
    
  
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimeZero);

        // 视频采集
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    
    timeRange = [self fitTimeRange:timeRange avUrlAsset:videoAsset];
        
        // 视频采集通道
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        // 把采集轨道数据加入到可变轨道之中
    
    [videoTrack insertTimeRange:timeRange ofTrack:videoAssetTrack atTime:atTime error:nil];
        
        // 音频采集通道
    
    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        // 加入合成轨道之中
    
    [audioTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:atTime error:nil];
    
    // 根据速度比率调节音频和视频
    [videoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale)) toDuration:CMTimeMake(videoAsset.duration.value * scale , videoAsset.duration.timescale)];
    [audioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale)) toDuration:CMTimeMake(videoAsset.duration.value * scale, videoAsset.duration.timescale)];

    [self composition:composition storePath:outPutFilePath success:successBlcok];
}

//得到合适的时间
- (CMTimeRange)fitTimeRange:(CMTimeRange)timeRange avUrlAsset:(AVURLAsset *)avUrlAsset
{
    CMTimeRange fitTimeRange = timeRange;
    
    if (CMTimeCompare(avUrlAsset.duration,timeRange.duration))
    {
        fitTimeRange.duration = avUrlAsset.duration;
    }
    if (CMTimeCompare(timeRange.duration,kCMTimeZero))
    {
        fitTimeRange.duration = avUrlAsset.duration;
    }
    return fitTimeRange;
}

//输出
- (void)composition:(AVMutableComposition *)avComposition
          storePath:(NSString *)storePath
            success:(SuccessBlcok)successBlcok
{
    // 创建一个输出
    
    if (_presetName == nil) {
        _presetName = AVAssetExportPresetHighestQuality;
    }
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:avComposition presetName:_presetName];
    
    
    
    
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    // 输出地址
    assetExport.outputURL = [NSURL fileURLWithPath:storePath];
    // 优化
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    
    //---------实验转场
//    assetExport.videoComposition = self.videoComposition;
    //---------实验转场
    
    
    __block NSTimer *timer = nil;

    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@" 打印信息:%f",assetExport.progress);
        if (self.progressBlock) {
            self.progressBlock(assetExport.progress);
        }
    }];

    NSLog(@"%@",[AVAssetExportSession allExportPresets]);

    // 合成完毕
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        // 回到主线程
        switch (assetExport.status) {
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"exporter Unknow");
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"exporter Canceled");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"%@", [NSString stringWithFormat:@"exporter Failed%@",assetExport.error.description]);
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"exporter Waiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"exporter Exporting");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"exporter Completed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 调用播放方法
                    successBlcok([NSURL fileURLWithPath:storePath]);
                });
                break;
        }
    }];
}


//-(AVAudioMix *)buildAudioMixWithVideoTrack:(AVCompositionTrack *)videoTrack VideoVolume:(float)videoVolume BGMTrack:(AVCompositionTrack *)BGMTrack BGMVolume:(float)BGMVolume controlVolumeRange:(CMTime)volumeRange {
//    // 创建音频混合类
//    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
//
//    // 拿到视频声音轨道设置音量
//    AVMutableAudioMixInputParameters *Videoparameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:videoTrack];
//    [Videoparameters setVolume:videoVolume atTime:volumeRange];
//
//    // 设置背景音乐音量
//    AVMutableAudioMixInputParameters *BGMparameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:BGMTrack];
//    [BGMparameters setVolume:BGMVolume atTime:volumeRange];
//
//    // 加入混合数组
//    audioMix.inputParameters = @[Videoparameters,BGMparameters];
//
//    return audioMix;
//}

+ (void)assetByReversingAsset:(NSURL *)assetUrl complition:(void (^)(NSURL *outputPath)) completionHandle{
    NSError *error;
    AVAsset *asset = [AVAsset assetWithURL:assetUrl];
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    NSDictionary *readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
    AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                                                        outputSettings:readerOutputSettings];
    [reader addOutput:readerOutput];
    [reader startReading];
    
    NSMutableArray *samples = [[NSMutableArray alloc] init];
    
    CMSampleBufferRef sample;
    while((sample = [readerOutput copyNextSampleBuffer])) {
        [samples addObject:(__bridge id)sample];
        CFRelease(sample);
    }
    NSURL *outputURL = [self exporterPath];
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:outputURL
                                                      fileType:AVFileTypeMPEG4
                                                         error:&error];
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(videoTrack.estimatedDataRate), AVVideoAverageBitRateKey,
                                           nil];
    NSDictionary *writerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                          AVVideoCodecTypeH264, AVVideoCodecKey,
                                          [NSNumber numberWithInt:videoTrack.naturalSize.width], AVVideoWidthKey,
                                          [NSNumber numberWithInt:videoTrack.naturalSize.height], AVVideoHeightKey,
                                          videoCompressionProps, AVVideoCompressionPropertiesKey,
                                          nil];
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                     outputSettings:writerOutputSettings
                                                                   sourceFormatHint:(__bridge CMFormatDescriptionRef)[videoTrack.formatDescriptions lastObject]];
    [writerInput setExpectsMediaDataInRealTime:NO];
    
    //防止视频宽大于手机最大分辨率导致的视频方向问题提
    writerInput.transform = videoTrack.preferredTransform;
    
    AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
    [writer addInput:writerInput];
    
    [writer startWriting];
    [writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[0])];
    for(NSInteger i = 0; i < samples.count; i++) {
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)samples[i]);
        CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer((__bridge CMSampleBufferRef)samples[samples.count - i - 1]);
        
        while (!writerInput.readyForMoreMediaData) {
            [NSThread sleepForTimeInterval:0.1];
        }
        
        [pixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:presentationTime];
        
    }
    
    [writer finishWritingWithCompletionHandler:^{
        
        
        NSLog(@"完成倒放生成视频:%@",outputURL);
        
        return completionHandle(outputURL);
        
    }];
    
    
}

#pragma mark - 输出路径
+ (NSURL *)exporterPath {
    
    NSInteger nowInter = (long)[[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"output%ld.mp4",(long)nowInter];
    
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    NSString *outputFilePath =[documentsDirectory stringByAppendingPathComponent:fileName];
    
    if([[NSFileManager defaultManager]fileExistsAtPath:outputFilePath]){
        
        [[NSFileManager defaultManager]removeItemAtPath:outputFilePath error:nil];
    }
    
    return [NSURL fileURLWithPath:outputFilePath];
}


@end
