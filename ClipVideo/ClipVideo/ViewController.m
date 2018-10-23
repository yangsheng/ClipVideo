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
#import "HXPhotoPicker.h"


@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,strong) GLProgressLayer *progressLayer;

@property (strong, nonatomic) HXPhotoManager *manager;

@end

@implementation ViewController

- (HXPhotoManager *)manager
{
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypeVideo];
        _manager.configuration.videoMaxNum = 5;
        _manager.configuration.deleteTemporaryPhoto = NO;
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.saveSystemAblum = YES;
        //        _manager.configuration.supportRotation = NO;
        //        _manager.configuration.cameraCellShowPreview = NO;
        //        _manager.configuration.themeColor = [UIColor redColor];
        _manager.configuration.navigationBar = ^(UINavigationBar *navigationBar) {
            //            [navigationBar setBackgroundImage:[UIImage imageNamed:@"APPCityPlayer_bannerGame"] forBarMetrics:UIBarMetricsDefault];
            //            navigationBar.barTintColor = [UIColor redColor];
        };
        //        _manager.configuration.sectionHeaderTranslucent = NO;
        //        _manager.configuration.navBarBackgroudColor = [UIColor redColor];
        //        _manager.configuration.sectionHeaderSuspensionBgColor = [UIColor redColor];
        //        _manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
        //        _manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        //        _manager.configuration.selectedTitleColor = [UIColor redColor];
        __weak typeof(self) weakSelf = self;
        _manager.configuration.photoListBottomView = ^(HXDatePhotoBottomView *bottomView) {
//            bottomView.bgView.barTintColor = weakSelf.bottomViewBgColor;
        };
        _manager.configuration.previewBottomView = ^(HXDatePhotoPreviewBottomView *bottomView) {
//            bottomView.bgView.barTintColor = weakSelf.bottomViewBgColor;
        };
        _manager.configuration.albumListCollectionView = ^(UICollectionView *collectionView) {
            //            NSSLog(@"albumList:%@",collectionView);
        };
        _manager.configuration.photoListCollectionView = ^(UICollectionView *collectionView) {
            //            NSSLog(@"photoList:%@",collectionView);
        };
        _manager.configuration.previewCollectionView = ^(UICollectionView *collectionView) {
            //            NSSLog(@"preview:%@",collectionView);
        };
        //        _manager.configuration.movableCropBox = YES;
        //        _manager.configuration.movableCropBoxEditSize = YES;
        //        _manager.configuration.movableCropBoxCustomRatio = CGPointMake(1, 1);
        
        // 使用自动的相机  这里拿系统相机做示例
        _manager.configuration.shouldUseCamera = ^(UIViewController *viewController, HXPhotoConfigurationCameraType cameraType, HXPhotoManager *manager) {
            
            // 这里拿使用系统相机做例子
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = (id)weakSelf;
            imagePickerController.allowsEditing = NO;
            NSString *requiredMediaTypeImage = ( NSString *)kUTTypeImage;
            NSString *requiredMediaTypeMovie = ( NSString *)kUTTypeMovie;
            NSArray *arrMediaTypes;
            if (cameraType == HXPhotoConfigurationCameraTypePhoto) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage,nil];
            }else if (cameraType == HXPhotoConfigurationCameraTypeVideo) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeMovie,nil];
            }else {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage, requiredMediaTypeMovie,nil];
            }
            [imagePickerController setMediaTypes:arrMediaTypes];
            // 设置录制视频的质量
            [imagePickerController setVideoQuality:UIImagePickerControllerQualityTypeHigh];
            //设置最长摄像时间
            [imagePickerController setVideoMaximumDuration:60.f];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            imagePickerController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        };
    }
    return _manager;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"剪影";

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
 
//    [self openPhotos];
    __weak typeof(self) weakSelf = self;
    [self hx_presentAlbumListViewControllerWithManager:self.manager done:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, BOOL original, HXAlbumListViewController *viewController) {
//        weakSelf.total.text = [NSString stringWithFormat:@"总数量：%ld   ( 照片：%ld   视频：%ld )",allList.count, photoList.count, videoList.count];
//        weakSelf.original.text = original ? @"YES" : @"NO";
        NSSLog(@"all - %@",allList);
        NSSLog(@"photo - %@",photoList);
        NSSLog(@"video - %@",videoList);
    } cancel:^(HXAlbumListViewController *viewController) {
        NSSLog(@"取消了");
    }];
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
