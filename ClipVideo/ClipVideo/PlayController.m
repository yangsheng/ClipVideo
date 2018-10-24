//
//  PlayController.m
//  ClipVideo
//
//  Created by leeco on 2018/10/24.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "PlayController.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayController ()
{

    NSString * _presetName;
    UIButton * _selectedBtn;
}
@property (nonatomic,strong) GLProgressLayer *progressLayer;

@property(nonatomic, strong) UIButton * saveBtn;

@property (strong, nonatomic) IBOutlet UIView *definitionView;

@property (weak, nonatomic) IBOutlet UIButton *lowQualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *mediumQulityBtn;

@property (weak, nonatomic) IBOutlet UIButton *highestQulityBtn;
@end

@implementation PlayController

- (void)setUrlArray:(NSArray *)urlArray{
    _urlArray = urlArray;
    
    NSMutableArray * items  = [NSMutableArray arrayWithCapacity:0];
    for (NSURL * url in _urlArray) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        [items addObject:playerItem];
    }
  
    AVQueuePlayer * player =  [AVQueuePlayer queuePlayerWithItems:items];
    
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.height - 350);
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
    [self.view.layer addSublayer:playerLayer];
    // 隐藏提示框 开始播放
    // 播放
    [player play];
    
    self.definitionView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    [self.view addSubview:self.definitionView];
    
    _selectedBtn = self.lowQualityBtn;
    _selectedBtn.selected = YES;
    [_selectedBtn setBackgroundColor:RGBACOLOR(252, 85, 31, 1.0)];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 50, 80, 50, 30)];
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setBackgroundColor:[UIColor redColor]];

    
    [self.saveBtn addTarget:self action:@selector(saveVideo) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.saveBtn];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(disappeardefinitionView:)];
    tap.numberOfTapsRequired = 1;
    
    [self.definitionView addGestureRecognizer:tap];
    
    
    _presetName = AVAssetExportPresetHighestQuality;
    
}
- (void)disappeardefinitionView:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.3 animations:^{
        self.definitionView.frameY = kScreenHeight;
    }];
}
- (void)saveVideo{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.definitionView.frameY = 0;
    }];
}

- (void)playWithUrl:(NSURL *)url{
    // 传入地址
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    // 播放器
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 300);
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
    [self.view.layer addSublayer:playerLayer];
    // 隐藏提示框 开始播放
    // 播放
    [player play];
}
- (void)setImages:(NSArray *)images
{
    for (int i = 0; i < images.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100+i*200, 200, 200)];
        imageView.image = images[i];
        [self.view addSubview:imageView];
    }
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
                NSLog(@"空空空空空空空");
            }];
            
        }];
        videoAudioManager.progressBlock = ^(CGFloat progress) {
            weakSelf.progressLayer.progress = progress;
        };
}
@end
