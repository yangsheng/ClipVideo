//
//  ViewController.m
//  ClipVideo
//
//  Created by leeco on 2018/10/15.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "ViewController.h"
#import "ZJClipVideo.h"


#import "VideoAudioEdit.h"

#import "HXPhotoPicker.h"
#import "PlayController.h"
#import "FilterController.h"
#import "TransferFieldController.h"

#import <GoogleMobileAds/GoogleMobileAds.h>


@interface ViewController ()<GADBannerViewDelegate>

@property(nonatomic, strong) GADBannerView * bannerView;//广告

@property (strong, nonatomic) HXPhotoManager *manager;

@property (nonatomic,strong) GLProgressLayer *progressLayer;

@property(nonatomic, strong) NSArray<HXPhotoModel *> *videoList;

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
    
    
    self.title = @"剪影";

    
    
    
    return;
    
    GADAdSize size = GADAdSizeFromCGSize(CGSizeMake(kScreenWidth, 50));
    self.bannerView = [[GADBannerView alloc]
                       initWithAdSize:size];
    self.bannerView.delegate = self;
    [self addBannerViewToView:self.bannerView];
    //ca-app-pub-3940256099942544/2934735716
    //ca-app-pub-4593956126356094/5783636614 me
    self.bannerView.adUnitID = @"ca-app-pub-4593956126356094/5783636614";
    self.bannerView.rootViewController = self;
    
    [self.bannerView loadRequest:[GADRequest request]];
}
- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bannerView];
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:bannerView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.bottomLayoutGuide
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:bannerView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]
                                ]];
}



- (void)actionWithType:(ActionType )actionType{

    __weak typeof(self) weakSelf = self;
    
    [self hx_presentAlbumListViewControllerWithManager:self.manager done:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, BOOL original, HXAlbumListViewController *viewController) {

        
        [HXPhotoTools selectListWriteToTempPath:videoList requestList:^(NSArray *imageRequestIds, NSArray *videoSessions) {
            
        } completion:^(NSArray<NSURL *> *allUrl, NSArray<NSURL *> *imageUrls, NSArray<NSURL *> *videoUrls) {
            
            NSURL * url = videoUrls[0];
            
            NSLog(@"videoUrl:%@",url);
            
            if (actionType == VideoEditingAndSynthesis) {
                
                [weakSelf videoEditingAndSynthesisWithUrlArray:videoUrls];
            
            }else if (actionType == VideoBackgroundMusic){
                
                [weakSelf videoBackgroundMusicWithUrl:url];
                
            }else if (actionType == VideoBeautification){
                NSLog(@"未开发");
            }else if (actionType == VideoReplay){
                
                [self videoReplayWithUrl:url];
                
            }else if (actionType == VideoSpeed){
                
                [self videoSpeedWithUrl:url];
                
            }else if (actionType == VideoRatio){
                NSLog(@"未开发");
            }else if (actionType == VideoWatermark){
                [self videoWatermarkWithUrl:url];
            }else if (actionType == VideoFilter){
                [self videoFilterWithUrl:url];
            }
            
        } error:^{
            
        }];

    } cancel:^(HXAlbumListViewController *viewController) {
        NSSLog(@"取消了");
    }];
}

- (void)videoFilterWithUrl:(NSURL *)url{
    FilterController * filter = [[FilterController alloc]init];
    [self.navigationController pushViewController:filter animated:YES];
    [filter playWithUrl:url];
}

- (void)videoWatermarkWithUrl:(NSURL *)url{
    VideoAudioEdit * edit = [[VideoAudioEdit alloc]init];
    [edit watermarkForVideo:url videoName:@"merge11.mp4" success:^(NSURL *fileUrl) {
        PlayController *vc = [[PlayController alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
        
        [vc playWithUrl:fileUrl];
    }];
}
- (void)videoSpeedWithUrl:(NSURL *)url{
    
    VideoAudioComposition *videoAudioManager = [[VideoAudioComposition alloc] init];
    
    videoAudioManager.compositionName = @"merge11.mp4";
    
    [videoAudioManager compositionVideos:url scale:0.25 success:^(NSURL *fileUrl) {
    
    
       PlayController *vc = [[PlayController alloc] init];
  
       [self.navigationController pushViewController:vc animated:YES];
  
       [vc playWithUrl:fileUrl];

    }];
}

- (void)videoReplayWithUrl:(NSURL *)url{
    
    self.progressLayer = [GLProgressLayer showProgress];
    
    [VideoAudioComposition assetByReversingAsset:url complition:^(NSURL *outputPath) {
       
        [self.progressLayer hiddenProgress];
      
        PlayController *vc = [[PlayController alloc] init];
      
        [self.navigationController pushViewController:vc animated:YES];
     
        [vc playWithUrl:outputPath];

    }];
}

- (void)videoEditingAndSynthesisWithUrlArray:(NSArray *)urlArr{

//    self.progressLayer = [GLProgressLayer showProgress];
//
//    VideoAudioComposition *videoAudioManager = [[VideoAudioComposition alloc] init];
//    videoAudioManager.compositionName = @"test_1.mp4";
//    videoAudioManager.compositionType = VideoToVideo;
//    __weak typeof(self)weakSelf = self;
//    //            CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimescale)
//
//    [videoAudioManager compositionVideos:urlArr timeRanges:nil success:^(NSURL *fileUrl) {
//        [weakSelf.progressLayer hiddenProgress];
    
    
    PlayController *vc = [[PlayController alloc] init];

    vc.urlArray = urlArr;
    vc.currentTtime = CMTimeMake(0, 600);
    [self.navigationController pushViewController:vc animated:YES];
     
//        [vc playWithUrl:fileUrl];
        
//    }];
//    videoAudioManager.progressBlock = ^(CGFloat progress) {
//        weakSelf.progressLayer.progress = progress;
//    };
}
- (void)videoBackgroundMusicWithUrl:(NSURL *)url{
    //http://sc1.111ttt.cn/2018/1/03/13/396131232171.mp3
    //http://www.ytmp3.cn/down/53969.mp3
    NSURL *audioInputUrl1 = [NSURL URLWithString:@"http://sc1.111ttt.cn/2018/1/03/13/396131232171.mp3"];

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
                                       PlayController *vc = [[PlayController alloc] init];
                                       [weakSelf.navigationController pushViewController:vc animated:YES];
                                       [vc playWithUrl:fileUrl];
                                   }];
    
    videoAudioManager.progressBlock = ^(CGFloat progress) {
        weakSelf.progressLayer.progress = progress;
    };
}
#pragma mark - 剪辑合成
- (IBAction)editingAndSynthesis:(UIButton *)sender {
    [self actionWithType:VideoEditingAndSynthesis];
}
#pragma mark - 背景音乐
- (IBAction)backgroundMusic:(UIButton *)sender {
    [self actionWithType:VideoBackgroundMusic];
}
#pragma mark -视频美化
- (IBAction)vdieoBeautification:(UIButton *)sender {
    [self actionWithType:VideoBeautification];
}
#pragma mark -视频倒放
- (IBAction)videoReplay:(UIButton *)sender {
    [self actionWithType:VideoReplay];
}
#pragma mark - 视频速度
- (IBAction)videoSpeed:(UIButton *)sender {
    [self actionWithType:VideoSpeed];
}
#pragma mark -视频比例
- (IBAction)videoRatio:(UIButton *)sender {
    [self actionWithType:VideoRatio];
}
- (IBAction)addingWatermark:(id)sender {
     [self actionWithType:VideoWatermark];
}

- (IBAction)videoFilter:(id)sender {
     [self actionWithType:VideoFilter];
   
    
}
#pragma mark -- GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Tells the delegate that a full-screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full-screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full-screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}

@end
