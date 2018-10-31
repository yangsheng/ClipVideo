//
//  FilterController.m
//  ClipVideo
//
//  Created by leeco on 2018/10/30.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "FilterController.h"
#import "FilterBottomView.h"
#import "FilterModel.h"
#import "GPUImage.h"
@interface FilterController ()<GPUImageMovieDelegate,FilterBottomViewDelegate>
{

    NSTimer * timer;
}

@property (nonatomic,strong)GPUImageOutput<GPUImageInput> * pixellateFilter;//视频滤镜

@property(nonatomic, strong) GPUImageMovieWriter *movieWriter;;

@property (nonatomic,strong)GPUImageMovie * gpuMovie;//接管视频数据

@property (nonatomic,strong)GPUImageMovie * gpuSaveMovie;//接管视频数据

@property (nonatomic,strong)GPUImageView * gpuView;//预览视频内容

@property (nonatomic,strong)NSArray * GPUImgArr;//存放滤镜数组

@property (nonatomic,copy)NSURL * filePath;//照片库第一个视频路径

@property(nonatomic, strong) AVPlayer * player;

@property(nonatomic, strong) AVPlayerItem * playerItem;

@property(nonatomic, strong) FilterBottomView * bottomView;

@property(nonatomic, strong) UIButton * pauseBtn;//暂停btn



@end

@implementation FilterController
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupVideo];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.rightBtn setTitle:@"导出" forState:UIControlStateNormal];
    
    
    [self createUI];
    
}

- (void)rightAction{
    [self saveVideo];
}

-(void)createUI{
    
    self.bottomView  = [[FilterBottomView alloc]initWithFrame:CGRectMake(0, kScreenHeight - 150, kScreenWidth, 150)];
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
    [self createEditView];
    
    self.pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 72 +kScreenWidth, 45, 45)];
    [self.view addSubview:self.pauseBtn];
    [self.pauseBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    WeakObj(self)
    [self.pauseBtn bk_addEventHandler:^(id sender) {
        if ([selfWeak.player rate] == 0) {//暂停
            
            [selfWeak.gpuMovie startProcessing];
            [selfWeak.player play];
        }else{

            [selfWeak.gpuMovie cancelProcessing];
            [selfWeak.player pause];
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupVideo{
    
    _pixellateFilter = [[GPUImageSepiaFilter alloc] init];
    
    _gpuView = [[GPUImageView alloc]initWithFrame:CGRectMake(0,72, kScreenWidth,kScreenWidth)];
    
    [self.view addSubview:_gpuView];
    
    [_pixellateFilter addTarget:_gpuView];
}

- (void)setupMovie{

    _gpuMovie = [[GPUImageMovie alloc] initWithPlayerItem:_playerItem];
    
    //是否重复播放
    _gpuMovie.shouldRepeat = YES;
    
    /**
     这使当前视频处于基准测试的模式，记录并输出瞬时和平均帧时间到控制台
     *
     * 每隔一段时间打印： Current frame time : 51.256001 ms，直到播放或加滤镜等操作完毕
     **/
//    _gpuMovie.runBenchmark = YES;
    
    /**控制GPUImageView预览视频时的速度是否要保持真实的速度。
     如果设为NO，则会将视频的所有帧无间隔渲染，导致速度非常快。
     设为YES，则会根据视频本身时长计算出每帧的时间间隔，然后每渲染一帧，就sleep一个时间间隔，从而达到正常的播放速度。**/
    _gpuMovie.playAtActualSpeed = YES;//
    
    _gpuMovie.delegate  = self;

    [_gpuMovie addTarget:_pixellateFilter];
    
    //开始预览
    [_gpuMovie startProcessing];

}

- (void)playWithUrl:(NSURL *)url{
    
    _filePath = url;
    
    _playerItem = [[AVPlayerItem alloc]initWithURL:_filePath];
    
    //监听AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
     _player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    
    [self setupMovie];
    
    [_player play];
    
}
/**
 不播放视频，视频添加滤镜直接保存本地
 */
- (void)saveVideo {
    
    // 初始化 movie
    _gpuSaveMovie = [[GPUImageMovie alloc] initWithURL:_filePath];
    _gpuSaveMovie.shouldRepeat = NO;
    _gpuSaveMovie.playAtActualSpeed = YES;
    
    // 设置加滤镜视频保存路径
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL       = [NSURL fileURLWithPath:pathToMovie];
    
    // 初始化
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480, 640)];
    _movieWriter.encodingLiveVideo = NO;
//    _movieWriter.shouldPassthroughAudio = NO;

    _movieWriter.shouldPassthroughAudio = YES;//是否使用源音源
    
//    _gpuSaveMovie.audioEncodingTarget = _movieWriter;//加入声音
    
    /**
     如果你设置了 _movie.audioEncodingTarget = _writer;
     会报如下错误：
     *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[AVAssetWriterInput appendSampleBuffer:] Cannot append sample buffer: Input buffer must be in an uncompressed format when outputSettings is not nil'
     暂时没去深究，以后再解决！
     */
    
    // 添加滤镜


    GPUImageToonFilter *filter = [[GPUImageToonFilter alloc] init];

    
    
    [_gpuSaveMovie addTarget:filter];
    [filter addTarget:_movieWriter];
    
    [_gpuSaveMovie enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    
    [_movieWriter startRecording];
    [_gpuSaveMovie startProcessing];

    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                          target:self
                                                        selector:@selector(retrievingProgress)
                                                        userInfo:nil
                                                         repeats:YES];
    
    
    __weak typeof(self) weakSelf = self;
    
    [_movieWriter setCompletionBlock:^{
        NSLog(@"OK");
        NSLog(@"path;;;:%@",movieURL);
//        [weakSelf.pixellateFilter removeTarget:weakSelf.movieWriter];
//        [weakSelf.movieWriter finishRecording];
        
        [movieURL saveVideoToCameraRollWithCompletion:^(NSString * _Nullable path, NSError * _Nullable error) {
            NSLog(@"保存ok");
        }];
        
    }];
    
}
- (void)retrievingProgress
{
    NSLog(@"%f",_gpuSaveMovie.progress);
    
}

-(void)createEditView{

    UIImage *inputImage = [UIImage imageNamed:@"girl"];

    _GPUImgArr = [self CreateGPUArr];
    
    for (int i = 0; i<_GPUImgArr.count; i++) {
        
        FilterModel * model = [[FilterModel alloc]init];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               if (i>0) {
                   GPUImageOutput<GPUImageInput> * disFilter = (GPUImageOutput<GPUImageInput> *)[self->_GPUImgArr[i] objectForKey:@"filter"];
                   //设置要渲染的区域
                   [disFilter useNextFrameForImageCapture];
                   //获取数据源
                   GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:inputImage];
                   //添加上滤镜
                   [stillImageSource addTarget:disFilter];
                   //开始渲染
                   [stillImageSource processImage];
                   //获取渲染后的图片
                   UIImage *newImage = [disFilter imageFromCurrentFramebuffer];
                   
                   model.image  = newImage;
                   model.disFilter = disFilter;
                   
               }else{
                   model.image = inputImage;
               }
                
                model.name = self->_GPUImgArr[i][@"name"];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.bottomView addFilter:model];
                });
                
            });
    }
}
#pragma mark ------------------------滤镜数组-----------------------

-(NSArray *)CreateGPUArr{
    NSMutableArray * arr = [[NSMutableArray alloc]init];
    
    NSString * title0 = @"原图";
    NSDictionary * dic0 = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"filter",title0,@"name", nil];
    [arr addObject:dic0];
    
    
    GPUImageOutput<GPUImageInput> * Filter5 = [[GPUImageGammaFilter alloc] init];
    [(GPUImageGammaFilter *)Filter5 setGamma:1.5];
    NSString * title5 = @"伽马线";
    NSDictionary * dic5 = [NSDictionary dictionaryWithObjectsAndKeys:Filter5,@"filter",title5,@"name", nil];
    [arr addObject:dic5];
    
    
    GPUImageOutput<GPUImageInput> * Filter6 = [[GPUImageColorInvertFilter alloc] init];
    NSString * title6 = @"反色";
    NSDictionary * dic6 = [NSDictionary dictionaryWithObjectsAndKeys:Filter6,@"filter",title6,@"name", nil];
    [arr addObject:dic6];
    
    GPUImageOutput<GPUImageInput> * Filter7 = [[GPUImageSepiaFilter alloc] init];
    NSString * title7 = @"褐色怀旧";
    NSDictionary * dic7 = [NSDictionary dictionaryWithObjectsAndKeys:Filter7,@"filter",title7,@"name", nil];
    [arr addObject:dic7];
    
    GPUImageOutput<GPUImageInput> * Filter71 = [[GPUImageLevelsFilter alloc] init];
    NSString * title71 = @"色阶";
    NSDictionary * dic71 = [NSDictionary dictionaryWithObjectsAndKeys:Filter71,@"filter",title71,@"name", nil];
    [arr addObject:dic71];
    
    
    GPUImageOutput<GPUImageInput> * Filter8 = [[GPUImageGrayscaleFilter alloc] init];
    NSString * title8 = @"灰度";
    NSDictionary * dic8 = [NSDictionary dictionaryWithObjectsAndKeys:Filter8,@"filter",title8,@"name", nil];
    [arr addObject:dic8];
    
    GPUImageOutput<GPUImageInput> * Filter9 = [[GPUImageHistogramGenerator alloc] init];
    NSString * title9 = @"色彩直方图？";
    NSDictionary * dic9 = [NSDictionary dictionaryWithObjectsAndKeys:Filter9,@"filter",title9,@"name", nil];
    [arr addObject:dic9];
    
    GPUImageOutput<GPUImageInput> * Filter91 = [[GPUImageToneCurveFilter alloc] init];
    NSString * title91 = @"色调曲线";
    NSDictionary * dic91 = [NSDictionary dictionaryWithObjectsAndKeys:Filter91,@"filter",title91,@"name", nil];
    [arr addObject:dic91];
    
    
    GPUImageOutput<GPUImageInput> * Filter10 = [[GPUImageRGBFilter alloc] init];
    NSString * title10 = @"RGB";
    [(GPUImageRGBFilter *)Filter10 setRed:0.8];
    [(GPUImageRGBFilter *)Filter10 setGreen:0.3];
    [(GPUImageRGBFilter *)Filter10 setBlue:0.5];
    NSDictionary * dic10 = [NSDictionary dictionaryWithObjectsAndKeys:Filter10,@"filter",title10,@"name", nil];
    [arr addObject:dic10];
    
    
    
    GPUImageOutput<GPUImageInput> * Filter11 = [[GPUImageMonochromeFilter alloc] init];
    [(GPUImageMonochromeFilter *)Filter11 setColorRed:0.3 green:0.5 blue:0.8];
    NSString * title11 = @"单色";
    NSDictionary * dic11 = [NSDictionary dictionaryWithObjectsAndKeys:Filter11,@"filter",title11,@"name", nil];
    [arr addObject:dic11];
    
    GPUImageOutput<GPUImageInput> * Filter12 = [[GPUImageBoxBlurFilter alloc] init];
    //    [(GPUImageMonochromeFilter *)Filter11 setColorRed:0.3 green:0.5 blue:0.8];
    NSString * title12 = @"盒状模糊";
    NSDictionary * dic12 = [NSDictionary dictionaryWithObjectsAndKeys:Filter12,@"filter",title12,@"name", nil];
    [arr addObject:dic12];
    
    GPUImageOutput<GPUImageInput> * Filter121 = [[GPUImageBulgeDistortionFilter alloc] init];
    [(GPUImageBulgeDistortionFilter *)Filter121 setScale: 1];
    NSString * title121 = @"鱼眼";
    NSDictionary * dic121 = [NSDictionary dictionaryWithObjectsAndKeys:Filter121,@"filter",title121,@"name", nil];
    [arr addObject:dic121];

    GPUImageOutput<GPUImageInput> * Filter13 = [[GPUImageSobelEdgeDetectionFilter alloc] init];
    NSString * title13 = @"漫画反色";
    NSDictionary * dic13 = [NSDictionary dictionaryWithObjectsAndKeys:Filter13,@"filter",title13,@"name", nil];
    [arr addObject:dic13];
    
    GPUImageOutput<GPUImageInput> * Filter14 = [[GPUImageXYDerivativeFilter alloc] init];
    NSString * title14 = @"蓝绿边缘";
    NSDictionary * dic14 = [NSDictionary dictionaryWithObjectsAndKeys:Filter14,@"filter",title14,@"name", nil];
    [arr addObject:dic14];
    
    
    GPUImageOutput<GPUImageInput> * Filter15 = [[GPUImageSketchFilter alloc] init];
    NSString * title15 = @"素描";
    NSDictionary * dic15 = [NSDictionary dictionaryWithObjectsAndKeys:Filter15,@"filter",title15,@"name", nil];
    [arr addObject:dic15];
    
    GPUImageOutput<GPUImageInput> * Filter16 = [[GPUImageSmoothToonFilter alloc] init];
    NSString * title16 = @"卡通";
    NSDictionary * dic16 = [NSDictionary dictionaryWithObjectsAndKeys:Filter16,@"filter",title16,@"name", nil];
    [arr addObject:dic16];
    
    
    GPUImageOutput<GPUImageInput> * Filter17 = [[GPUImageColorPackingFilter alloc] init];
    NSString * title17 = @"监控";
    NSDictionary * dic17 = [NSDictionary dictionaryWithObjectsAndKeys:Filter17,@"filter",title17,@"name", nil];
    [arr addObject:dic17];
    
    GPUImageOutput<GPUImageInput> * Filter18 = [[GPUImageMosaicFilter alloc] init];
    NSString * title18 = @"黑白马赛克";
    NSDictionary * dic18 = [NSDictionary dictionaryWithObjectsAndKeys:Filter18,@"filter",title18,@"name", nil];
    [arr addObject:dic18];
    
    GPUImageOutput<GPUImageInput> * Filter19 = [[GPUImageVignetteFilter alloc] init];
    NSString * title19 = @"晕影";
    NSDictionary * dic19 = [NSDictionary dictionaryWithObjectsAndKeys:Filter19,@"filter",title19,@"name", nil];
    [arr addObject:dic19];
    
    GPUImageOutput<GPUImageInput> * Filter20 = [[GPUImageGlassSphereFilter alloc] init];
    NSString * title20 = @"水晶球";
    NSDictionary * dic20 = [NSDictionary dictionaryWithObjectsAndKeys:Filter20,@"filter",title20,@"name", nil];
    [arr addObject:dic20];
    
    GPUImageOutput<GPUImageInput> * Filter21 = [[GPUImageEmbossFilter alloc] init];
    NSString * title21 = @"浮雕";
    NSDictionary * dic21 = [NSDictionary dictionaryWithObjectsAndKeys:Filter21,@"filter",title21,@"name", nil];
    [arr addObject:dic21];
    
    return arr;
}


#pragma mark - GPUImageMovieDelegate
- (void)didCompletePlayingMovie{
    
}

#pragma 监听AVPlayer播放完成通知
- (void)playerItemDidReachEnd:(NSNotification *)notification{
    
    NSLog(@"ok....");
    
    [_gpuMovie cancelProcessing];
    
    [_gpuMovie startProcessing];

    [_player seekToTime:kCMTimeZero];
    
    [_player play];
    
}
#pragma mark - FilterBottomViewDelegate
- (void)effectImgClickFilter:(FilterModel *)model{
    
    [_gpuMovie removeAllTargets];
    
    if (model.disFilter == nil) {
        
        _pixellateFilter = nil;
        [_gpuMovie addTarget:_gpuView];
        
    }else{
    
        _pixellateFilter = model.disFilter;
    
        [_gpuMovie addTarget:_pixellateFilter];
        
        if (_gpuView != nil) {
            [_gpuView removeFromSuperview];
        }
        _gpuView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 72, kScreenWidth,kScreenWidth)];
        [_pixellateFilter addTarget:_gpuView];
        [self.view addSubview:_gpuView];
    }
}
@end
