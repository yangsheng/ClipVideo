//
//  SJReverseUtility.m
//  playback
//
//  Created by Lightning on 2018/7/12.
//  Copyright © 2018年 hello. All rights reserved.
//

#import "SJReverseUtility.h"


@interface SJReverseUtility()

@property (nonatomic, strong) NSMutableArray *samples;

@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) NSMutableArray *tracks;

@property (nonatomic, strong) AVMutableComposition *composition;

@property (nonatomic, strong) AVAssetWriter *writer;

@property (nonatomic, strong) AVAssetWriterInput *writerInput;

@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *writerAdaptor;

@property (nonatomic, assign) uint frame_count;

@property (nonatomic, strong) AVMutableCompositionTrack *compositionTrack;

@property (nonatomic, assign) CMTime offsetTime;

@property (nonatomic, assign) CMTime intervalTime;

@property (nonatomic, assign) CMTime segDuration;

@property (nonatomic, assign) BOOL shouldStop;

@property (nonatomic, copy) NSString *path;

@end



@implementation SJReverseUtility

- (instancetype)initWithAsset:(AVAsset *)asset outputPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _asset = asset;
        
        
        _composition = [AVMutableComposition composition];
        AVMutableCompositionTrack *ctrack = [_composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        _compositionTrack = ctrack;
        
        _timeRange = kCMTimeRangeInvalid;
        _frame_count = 0;
        _offsetTime = kCMTimeZero;
        _intervalTime = kCMTimeZero;
        [self setupWriterWithPath:path];
        
    }
    return self;
}

- (void)cancelProcessing
{
    self.shouldStop = YES;
}


- (void)startProcessing
{
    if (CMTIMERANGE_IS_INVALID(_timeRange)) {
        _timeRange = CMTimeRangeMake(kCMTimeZero, _asset.duration);
    }
    CMTime duration = _asset.duration;
    CMTime segDuration = CMTimeMake(1, 1);
    self.segDuration = segDuration;
    NSArray *videoTracks = [_asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = videoTracks[0];
    //should set before starting
    self.writerInput.transform = track.preferredTransform;//fix video orientation
    
    [self.writer startWriting];
    [self.writer startSessionAtSourceTime:kCMTimeZero]; //start processing
    
    //divide video into n segmentation
    int n = (int)(CMTimeGetSeconds(duration)/CMTimeGetSeconds(segDuration)) + 1;
    if (CMTIMERANGE_IS_VALID(_timeRange)) {
        n = (int)(CMTimeGetSeconds(_timeRange.duration)/CMTimeGetSeconds(segDuration)) + 1;
        duration = CMTimeAdd(_timeRange.start, _timeRange.duration);
        
    }
    
    __weak typeof(self) weakSelf = self;
    for (int i = 1; i < n; i++) {
        CMTime offset = CMTimeMultiply(segDuration, i);
        if (CMTimeCompare(offset, duration) > 0) {
            break;
        }
        CMTime start = CMTimeSubtract(duration, offset);
        if (CMTimeCompare(start, _timeRange.start) < 0) {
            start = kCMTimeZero;
            segDuration = CMTimeSubtract(duration, CMTimeMultiply(segDuration, i-1));
        }
        self.compositionTrack = [_composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [self.compositionTrack insertTimeRange:CMTimeRangeMake(start, segDuration) ofTrack:track atTime:kCMTimeZero error:nil];
        
        [self generateSamplesWithTrack:_composition];
        
        [self encodeSampleBuffer];

        if (self.shouldStop) {
            [self.writer cancelWriting];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_path]) {
                [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
            }
            !weakSelf.callBack? :weakSelf.callBack(weakSelf.writer.status, -1, weakSelf.writer.error);
            
            return;
        }
        
        
        [self.compositionTrack removeTimeRange:CMTimeRangeMake(start, segDuration)];
        
        !weakSelf.callBack? :weakSelf.callBack(weakSelf.writer.status, (float)i/n, weakSelf.writer.error);
    }
    
    [self.writer finishWritingWithCompletionHandler:^{//循环引用，要弱化

        if (self.callBack) {
            
             self.callBack(self.writer.status, 1.0f, self.writer.error);
        }
       
    }];
}

- (void)setupWriterWithPath:(NSString *)path
{
    NSURL *outputURL = [NSURL fileURLWithPath:path];
    AVAssetTrack *videoTrack = [[_asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    
    // Initialize the writer
    self.writer = [[AVAssetWriter alloc] initWithURL:outputURL
                                            fileType:AVFileTypeQuickTimeMovie
                                               error:nil];
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(videoTrack.estimatedDataRate), AVVideoAverageBitRateKey,
                                           nil];
    int width = videoTrack.naturalSize.width;
    int height = videoTrack.naturalSize.height;
    NSDictionary *writerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                          AVVideoCodecH264, AVVideoCodecKey,
                                          [NSNumber numberWithInt:videoTrack.naturalSize.width], AVVideoWidthKey,
                                          [NSNumber numberWithInt:videoTrack.naturalSize.height], AVVideoHeightKey,
                                          videoCompressionProps, AVVideoCompressionPropertiesKey,
                                          nil];
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                     outputSettings:writerOutputSettings
                                                                   sourceFormatHint:(__bridge CMFormatDescriptionRef)[videoTrack.formatDescriptions lastObject]];
    [writerInput setExpectsMediaDataInRealTime:NO];
    self.writerInput = writerInput;
    self.writerAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    [self.writer addInput:self.writerInput];
    
    
}

- (void)generateSamplesWithTrack:(AVAsset *)asset
{
    // Initialize the reader
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
    
    NSDictionary *readerOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];
    AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                                                        outputSettings:readerOutputSettings];
    [reader addOutput:readerOutput];
    [reader startReading];
    
    // read in the samples
    _samples = [[NSMutableArray alloc] init];
    
    CMSampleBufferRef sample;
    while((sample = [readerOutput copyNextSampleBuffer])) {
        [_samples addObject:(__bridge id)sample];
//        NSLog(@"count = %lu",(unsigned long)_samples.count);
        CFRelease(sample);
    }
    if (_samples.count > 0 ) {
        self.intervalTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.segDuration)/(float)(_samples.count), _asset.duration.timescale);
    }
    
}

- (void)encodeSampleBuffer
{
    for(NSInteger i = 0; i < _samples.count; i++) {
        // Get the presentation time for the frame
        
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp((__bridge CMSampleBufferRef)_samples[i]);
        
        presentationTime = CMTimeAdd(_offsetTime, self.intervalTime);
        
        size_t index = _samples.count - i - 1;
        
        if (0 == _frame_count) {
            presentationTime = kCMTimeZero;
            index = _samples.count - i - 2; //倒过来的第一帧是黑的丢弃
        }
        CMTimeShow(presentationTime);
        
        
        CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer((__bridge CMSampleBufferRef)_samples[index]);
        
        while (!_writerInput.readyForMoreMediaData) {
            [NSThread sleepForTimeInterval:0.1];
        }
        _offsetTime = presentationTime;
        
        BOOL success = [self.writerAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:presentationTime];
        _frame_count++;
        if (!success) {
            NSLog(@"status = %ld",(long)self.writer.status);
            NSLog(@"status = %@",self.writer.error);
        }
        
    }

}





@end
