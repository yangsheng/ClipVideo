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
    [super setUrlArray:urlArray];
    
    self.definitionView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    [self.view addSubview:self.definitionView];
    
    _selectedBtn = self.lowQualityBtn;
    _selectedBtn.selected = YES;
    [_selectedBtn setBackgroundColor:RGBACOLOR(252, 85, 31, 1.0)];
}
- (void)playWithUrl:(NSURL *)url{
    [super playWithUrl:url];
    self.definitionView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
    [self.view addSubview:self.definitionView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
