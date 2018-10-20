//
//  ViewController.m
//  ClipVideo
//
//  Created by leeco on 2018/10/15.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "ViewController.h"
#import "ZJClipVideo.h"
#import "VideoAudioComposition.h"
#import "GLProgressLayer.h"
#import "VideoAudioEdit.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,strong) GLProgressLayer *progressLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"剪影";

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
 
    [self openPhotos];
}


- (void)openPhotos {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //转场动画
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    /* 选择所有媒体文件夹
     picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary
     */
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
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

#pragma mark -UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:self completion:^{
        
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    
    
    NSURL * url  = info[@"UIImagePickerControllerMediaURL"];

    [picker dismissViewControllerAnimated:self completion:^{
        
    }];
    
    //__weak typeof(self)weakSelf = self;

    
  //  url = [NSURL URLWithString:@"http://www.ytmp3.cn/down/53969.mp3"];
    
//    VideoAudioComposition *videoAudioManager = [[VideoAudioComposition alloc] init];
//    videoAudioManager.compositionName = @"merge11.mp4";
    
   // [videoAudioManager compositionVideos:url scale:0.25 success:^(NSURL *fileUrl) {
        
//                ViewController *vc = [[ViewController alloc] init];
//                [weakSelf.navigationController pushViewController:vc animated:YES];
//                [vc playWithUrl:url];
    
   // }];
    
    
//    [VideoAudioComposition assetByReversingAsset:url complition:^(NSURL *outputPath) {
//        [weakSelf.progressLayer hiddenProgress];
//        ViewController *vc = [[ViewController alloc] init];
//        [weakSelf.navigationController pushViewController:vc animated:YES];
//        [vc playWithUrl:outputPath];
//
//    }];
    
    
    [self mix:url];
    
}
- (void)test:(NSURL *)url{
    
    NSURL *audioInputUrl1 = [NSURL URLWithString:@"http://www.ytmp3.cn/down/53969.mp3"];
    
    // 视频来源
    NSURL *videoInputUrl = url;
    
    self.progressLayer = [GLProgressLayer showProgress];
    
    VideoAudioComposition *videoAudioManager = [[VideoAudioComposition alloc] init];
    videoAudioManager.compositionName = @"test_1.mp4";
    videoAudioManager.compositionType = VideoAudioToVideo;
    __weak typeof(self)weakSelf = self;
    //            CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimescale)
    [videoAudioManager compositionVideoUrl:videoInputUrl
                            videoTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(30, 1))
                                  audioUrl:audioInputUrl1
                            audioTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(30, 1))
                                   success:^(NSURL *fileUrl) {
                                       [weakSelf.progressLayer hiddenProgress];
                                       ViewController *vc = [[ViewController alloc] init];
                                       [weakSelf.navigationController pushViewController:vc animated:YES];
                                       [vc playWithUrl:fileUrl];
                                   }];
    
    videoAudioManager.progressBlock = ^(CGFloat progress) {
        weakSelf.progressLayer.progress = progress;
    };
}

- (void)mix:(NSURL *)url{
    //http://sc1.111ttt.cn/2018/1/03/13/396131232171.mp3
    //http://www.ytmp3.cn/down/53969.mp3
    NSURL *audioInputUrl1 = [NSURL URLWithString:@"http://sc1.111ttt.cn/2018/1/03/13/396131232171.mp3"];
    // 视频来源
//    NSURL *videoInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"大王叫我来巡山" ofType:@"mp4"]];
    
    self.progressLayer = [GLProgressLayer showProgress];
    
    VideoAudioComposition *videoAudioManager = [[VideoAudioComposition alloc] init];
    videoAudioManager.compositionName = @"merge11.mp4";
    videoAudioManager.compositionType = VideoAudioToVideo;
    __weak typeof(self)weakSelf = self;
    [videoAudioManager compositionVideoUrl:url
                            videoTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(30, 1))
                                  audioUrl:audioInputUrl1
                            audioTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(30, 1))
                                   success:^(NSURL *fileUrl) {
                                       [weakSelf.progressLayer hiddenProgress];
                                       ViewController *vc = [[ViewController alloc] init];
                                       [weakSelf.navigationController pushViewController:vc animated:YES];
                                       [vc playWithUrl:fileUrl];
                                   }];
    
    videoAudioManager.progressBlock = ^(CGFloat progress) {
        weakSelf.progressLayer.progress = progress;
    };
}


@end
