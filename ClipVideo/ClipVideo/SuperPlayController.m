//
//  SuperPlayController.m
//  ClipVideo
//
//  Created by leeco on 2018/10/25.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "SuperPlayController.h"

@interface SuperPlayController ()

@end

@implementation SuperPlayController

- (ExitEditorView *)backView{
    if (_backView == nil) {
        _backView = [[ExitEditorView alloc]initWithFrame:self.view.bounds];
        _backView.delegate  = self;
        [self.view addSubview:_backView];
    }
    return _backView;
}


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

}
- (void)viewDidLoad {
    [super viewDidLoad];
   
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

- (void)backAction{
    [self.backView disPlay];
}
- (void)confirmBack{
    [super backAction];
}
@end
