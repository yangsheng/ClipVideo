//
//  SuperPlayController.m
//  ClipVideo
//
//  Created by leeco on 2018/10/25.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "SuperPlayController.h"

@interface SuperPlayController ()

@property(nonatomic, strong) AVQueuePlayer * player;
@property (nonatomic, strong) UIImage *cover;
@property (nonatomic, strong) UIImageView *coverImgView;        //封面imgview

@property(nonatomic, strong) AVPlayerItem * currentPlayerItem;



@property(nonatomic, strong) UIButton * playBtn;

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
- (UIView *)playerBgView{
    if (_playerBgView == nil) {
        _playerBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 105, kScreenWidth, 300)];
        _playerBgView.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pausePlayer)];
        tap.numberOfTapsRequired = 1;
        [_playerBgView addGestureRecognizer:tap];
        [self.view addSubview:_playerBgView];
    }
    return _playerBgView;
}
- (void)setCurrentTtime:(CMTime)currentTtime{
    _currentTtime = currentTtime;
    
    AVURLAsset *asset = (AVURLAsset *)self.currentPlayerItem.asset;
    
    UIImage * bgImage = [ZJVideoTools getVideoPreViewImageFromVideo:asset atTime:CMTimeGetSeconds(_currentTtime)+0.01];
    
    self.cover = bgImage;
    
    
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(_currentTtime), 30);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {

            [self.player play];
        }
    }];
}

- (void)setUrlArray:(NSArray *)urlArray{
    _urlArray = urlArray;
    
    NSMutableArray * items  = [NSMutableArray arrayWithCapacity:0];
    for (NSURL * url in _urlArray) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        [items addObject:playerItem];
    }
    
    self.currentPlayerItem = [items firstObject];
    
    self.player =  [AVQueuePlayer queuePlayerWithItems:items];
    
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.playerBgView.frame;
    //CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.height - 350);
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
    [self.view.layer addSublayer:playerLayer];
    // 隐藏提示框 开始播放
}
- (UIButton *)playBtn{
    if (_playBtn == nil) {
        _playBtn = [[UIButton alloc]init];
        
        [_playBtn bk_addEventHandler:^(id sender) {
            [self.player play];
            _playBtn.hidden = YES;
        } forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.playBtn];
        [_playBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.playerBgView.mas_centerX);
            make.centerY.mas_equalTo(self.playerBgView.mas_centerY);
            make.height.with.width.mas_equalTo(35);
        }];
        
    }
    return _playBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];

//    self.coverImgView = [[UIImageView alloc] init];
//    self.coverImgView.userInteractionEnabled = YES;
//    [self.view addSubview:self.coverImgView];
//    self.coverImgView.frame = CGRectMake(0, 85, kScreenWidth, 300);
  
    
    
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
- (void)pausePlayer{
    [self.player pause];
    self.playBtn.hidden = NO;
}
- (void)backAction{
    [self.backView disPlay];
}
- (void)confirmBack{
    [super backAction];
}
@end
