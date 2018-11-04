//
//  PlayController.m
//  ClipVideo
//
//  Created by leeco on 2018/10/24.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "PlayController.h"
#import "ZJInterceptBottomTools.h"
@interface PlayController ()<ZJInterceptBottomToolsDelegate>
{

    NSString * _presetName;
    UIButton * _selectedBtn;
}

@property (nonatomic, assign) CGFloat startTime;            //开始截取的时间
@property (nonatomic, assign) CGFloat endTime;              //结束截取的时间


@property (nonatomic,strong) GLProgressLayer *progressLayer;

@property(nonatomic, strong) UIButton * saveBtn;

@property (strong, nonatomic) IBOutlet UIView *definitionView;

@property (weak, nonatomic) IBOutlet UIButton *lowQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *mediumQulityBtn;

@property (weak, nonatomic) IBOutlet UIButton *highestQulityBtn;

@property(nonatomic, strong) ZJInterceptBottomTools * bottomToolView;

@property(nonatomic, strong) UIButton * pauseBtn;

@end

@implementation PlayController

- (void)setUrlArray:(NSArray *)urlArray{
    [super setUrlArray:urlArray];
    
    self.definitionView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    [self.view addSubview:self.definitionView];
    
    _selectedBtn = self.lowQualityBtn;
    _selectedBtn.selected = YES;
    [_selectedBtn setBackgroundColor:RGBACOLOR(252, 85, 31, 1.0)];
}
- (void)playWithUrl:(NSURL *)url{
    [super playWithUrl:url];
    //监听
    [self.currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.definitionView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    [self.view addSubview:self.definitionView];

    self.bottomToolView = [[ZJInterceptBottomTools alloc]initWithFrame:CGRectMake(0, kScreenHeight - 50 - 50 -50, kScreenWidth-0, 150) coverImgs:@[]];
    self.bottomToolView.startTime = self.startTime;
    self.bottomToolView.endTime = self.endTime;
    self.bottomToolView.delegate = self;
    [self.view addSubview:self.bottomToolView];

    [self getCoverImgs];
    
 
    self.pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(200, 200, 45, 45)];
    [self.view addSubview:_pauseBtn];
    [_pauseBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    WeakObj(self)
    [_pauseBtn bk_addEventHandler:^(id sender) {
        if ([selfWeak.avPlayer rate] == 0) {//暂停
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [selfWeak.avPlayer seekToTime:CMTimeMakeWithSeconds(selfWeak.startTime, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                        if (finished) {
                           [selfWeak.avPlayer play];
                        }
                    }];
                });
            });
            selfWeak.pauseBtn.hidden = YES;
        }else{
          
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.pauseBtn.hidden = YES;

}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    self.startTime = 0.0f + CMTimeGetSeconds(kCMTimeZero);//
    self.endTime = self.startTime;
    
    self.saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 50, 72, 50, 30)];
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setBackgroundColor:[UIColor redColor]];

    [self.saveBtn addTarget:self action:@selector(saveVideo) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.saveBtn];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disappeardefinitionView:)];
    tap.numberOfTapsRequired = 1;
    
    [self.definitionView addGestureRecognizer:tap];
    
    _presetName = AVAssetExportPresetHighestQuality;
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        AVPlayerItemStatus statues = [change[NSKeyValueChangeNewKey] integerValue];
        switch (statues) {
                // 监听到这个属性的时候，理论上视频就可以进行播放了
            case AVPlayerItemStatusReadyToPlay:
   
                [self initTimer];

                break;
                
            case AVPlayerItemStatusUnknown:
                
                
                
                break;
                // 这个就是不能播放喽，加载失败了
            case AVPlayerItemStatusFailed:
                
                // 这时可以通过`self.player.error.description`属性来找出具体的原因
                
                break;
                
            default:
                break;
        }
    }
}
- (void)playerItemDidReachEnd:(NSNotification *)notification{

    
    [self.avPlayer seekToTime:CMTimeMakeWithSeconds(self.startTime, 600)];
    
    [self.avPlayer play];
    
}
#pragma mark -- 调用plaer的对象进行UI更新
- (void)initTimer
{
    // player的定时器
    __weak typeof(self)weakSelf = self;
    // 每秒更新一次UI Slider
    [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 600) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        // 当前时间
        CGFloat nowTime = CMTimeGetSeconds(weakSelf.currentPlayerItem.currentTime);
        [weakSelf.bottomToolView updateProcess:nowTime];
    
        // sec 转换成时间点
        if (nowTime >= self.endTime) {
       
            [weakSelf.avPlayer pause];
            [weakSelf.avPlayer seekToTime:CMTimeMakeWithSeconds(weakSelf.startTime, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                if (finished) {
                    [weakSelf.avPlayer play];
                }
            }];
        }
    }];
}
- (void)getCoverImgs{
    
    
    dispatch_queue_t   queue = dispatch_queue_create("com.queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
    
    AVURLAsset *asset = (AVURLAsset *)self.currentPlayerItem.asset;

    
        NSUInteger videoDuration = 0;
    
        videoDuration = ceilf((double)asset.duration.value / (double)asset.duration.timescale); // 获取视频总时长,单位秒
        self.endTime = videoDuration;
        self.bottomToolView.endTime = videoDuration;
    
        for (int i = 0; i<videoDuration; i++) {
        
        UIImage * image = [ZJVideoTools getVideoPreViewImageFromVideo:asset atTime:i + 0.01];
        dispatch_async(dispatch_get_main_queue(), ^{
            //添加图片
            
            [self.bottomToolView addImg:image];
            
        });
  
    }
    
    });
}

- (void)disappeardefinitionView:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.3 animations:^{
        self.definitionView.frameY = kScreenHeight;
    }];
}
- (void)saveVideo{
    
    
    
   
    
    [VideoAudioComposition assetByReversingAsset:self.fileUrl starTime:self.startTime andEndTime:self.endTime complition:^(NSURL *outputPath) {
        NSLog(@"KOKOKOKOKOle");
        [outputPath saveVideoToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
            HUDNormal(@"保存至相册OK");
        }];

    }];
 
    return;
    [UIView animateWithDuration:0.3 animations:^{
        self.definitionView.frameY = 0;
    }];
}


- (void)selectedBtn:(UIButton *)btn{
    if (_selectedBtn != btn) {
        _selectedBtn.selected = NO;
        _selectedBtn.backgroundColor = [UIColor whiteColor];
        _selectedBtn = btn;
        _selectedBtn.selected = YES;
        [_selectedBtn setBackgroundColor:RGBACOLOR(252, 85, 31, 1.0)];
    }
}
- (IBAction)lowQuality:(UIButton *)sender {
    _presetName = AVAssetExportPresetLowQuality;
    [self selectedBtn:sender];
}
- (IBAction)mediumQulity:(UIButton *)sender {
    _presetName = AVAssetExportPresetMediumQuality;
     [self selectedBtn:sender];
}
- (IBAction)highestQulity:(UIButton *)sender {
    _presetName = AVAssetExportPresetHighestQuality;
     [self selectedBtn:sender];
}
- (IBAction)closeDefinitionView:(UIButton *)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.definitionView.frameY = kScreenHeight;
    }];
}
- (IBAction)saveVideo:(id)sender {
     self.progressLayer = [GLProgressLayer showProgress];
    
        VideoAudioComposition *videoAudioManager = [[VideoAudioComposition alloc] init];
        videoAudioManager.compositionName = @"test_1.mp4";
        videoAudioManager.compositionType = VideoToVideo;
        __weak typeof(self)weakSelf = self;
        //            CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimescale)
    
        [videoAudioManager compositionVideos:self.urlArray timeRanges:nil success:^(NSURL *fileUrl) {
            [weakSelf.progressLayer hiddenProgress];
    
            [fileUrl saveVideoToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
            }];
            
        }];
        videoAudioManager.progressBlock = ^(CGFloat progress) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                 weakSelf.progressLayer.progress = progress;
            });

        };
}

#pragma mark - ZJInterceptBottomToolsDelegate
- (void)seekToTime:(CGFloat)startTime enTime:(CGFloat)endTime atIndex:(NSInteger)index{
    self.startTime = startTime;
    self.endTime = endTime;
    CGFloat time = startTime;
    
    [self.avPlayer pause];
    self.pauseBtn.hidden = NO;
    
    if (index == 1) {
        time = endTime;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.avPlayer seekToTime:CMTimeMakeWithSeconds(time, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                if (finished) {
                }
            }];
        });
    });
}
- (void)playToTime:(CGFloat)startTime enTime:(CGFloat)endTime atIndex:(NSInteger)index{
    
    self.startTime = startTime;
    self.endTime = endTime;
  
}

@end
