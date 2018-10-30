//
//  FilterController.m
//  ClipVideo
//
//  Created by leeco on 2018/10/30.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "FilterController.h"
#import "GPUImage.h"
@interface FilterController ()
{

    GPUImageMovieWriter *movieWriter;
    NSTimer * timer;
}

@property (nonatomic,strong)GPUImageOutput<GPUImageInput> * pixellateFilter;//视频滤镜

@property (nonatomic,strong)GPUImageMovie * gpuMovie;//接管视频数据

@property (nonatomic,strong)GPUImageView * gpuView;//预览视频内容

@property (nonatomic,strong)UIScrollView * EditView;//滤镜选择视图

@property (nonatomic,strong)NSArray * GPUImgArr;//存放滤镜数组

@property (nonatomic,copy)NSURL * filePath;//照片库第一个视频路径
@end

@implementation FilterController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self createUI];
    
 
}
-(void)createUI{

}
- (void)playWithUrl:(NSURL *)url{
    _filePath = url;
    _gpuMovie = [[GPUImageMovie alloc] initWithURL:url];
    _gpuMovie.runBenchmark = YES;
    _gpuMovie.playAtActualSpeed = YES;
    _gpuMovie.shouldRepeat = NO;
    _pixellateFilter = [[GPUImageSepiaFilter alloc] init];
    //    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    
    [_gpuMovie addTarget:_pixellateFilter];
    
    // Only rotate the video for display, leave orientation the same for recording
    _gpuView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 200)];
    [self.view addSubview:_gpuView];
    [_pixellateFilter addTarget:_gpuView];
    
    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    [_pixellateFilter addTarget:movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    movieWriter.shouldPassthroughAudio = YES;
    _gpuMovie.audioEncodingTarget = movieWriter;
    [_gpuMovie enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    
    [movieWriter startRecording];
    [_gpuMovie startProcessing];
    
    //    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
    //                                             target:self
    //                                           selector:@selector(retrievingProgress)
    //                                           userInfo:nil
    //                                            repeats:YES];
    
    [movieWriter setCompletionBlock:^{
//        [_pixellateFilter removeTarget:movieWriter];
//        [movieWriter finishRecording];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [timer invalidate];
            //            self.progressLabel.text = @"100%";
        });
    }];
    
     [self createEditView];
    
}

-(void)createEditView{
    
    _EditView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, kScreenHeight-190, kScreenWidth, 100)];
    _EditView.showsVerticalScrollIndicator = NO;
    AVURLAsset * myAsset = [AVURLAsset assetWithURL:_filePath];
    
    //初始化AVAssetImageGenerator
    AVAssetImageGenerator * imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    UIImage *inputImage = [UIImage imageNamed:@"origin"];
    
    // First image
    //创建第一张预览图
//    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:nil];
//    if (halfWayImage != NULL) {
//        inputImage = [[UIImage alloc] initWithCGImage:halfWayImage];
//    }
    
    
    _GPUImgArr = [self CreateGPUArr];
    
    for (int i = 0; i<_GPUImgArr.count; i++) {
        
        
        UIButton * effectImg = [UIButton buttonWithType:UIButtonTypeCustom];
        effectImg.frame = CGRectMake(10+i*((kScreenWidth-10)/5), 10, (kScreenWidth-10)/5-10,  (kScreenWidth-10)/5-10);
        [effectImg setImage:inputImage forState:UIControlStateNormal];
        
        if (i>0) {
            
            GPUImageOutput<GPUImageInput> * disFilter = (GPUImageOutput<GPUImageInput> *)[_GPUImgArr[i] objectForKey:@"filter"];
            
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
            
            
            [effectImg setImage:newImage forState:UIControlStateNormal];
            
        }
        
        effectImg.layer.cornerRadius = ((kScreenWidth-10)/5-10)/2;
        effectImg.layer.masksToBounds = YES;
        effectImg.tag = 1000+i;
        
        [effectImg addTarget:self action:@selector(effectImgClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            effectImg.layer.borderWidth = 2;
            effectImg.layer.borderColor = [UIColor redColor].CGColor;
        }
        
        UILabel * effectName = [[UILabel alloc]initWithFrame:CGRectMake(effectImg.frame.origin.x, CGRectGetMaxY(effectImg.frame)+10, effectImg.frame.size.width, 20)];
        effectName.textColor = [UIColor whiteColor];
        effectName.textAlignment = NSTextAlignmentCenter;
        effectName.font = [UIFont systemFontOfSize:12];
        effectName.text = _GPUImgArr[i][@"name"];
        
        [_EditView addSubview:effectImg];
        [_EditView addSubview:effectName];
        
        _EditView.contentSize = CGSizeMake(_GPUImgArr.count*(kScreenWidth-10)/5+10, _EditView.frame.size.height);
    }
    
    
    [self.view addSubview:_EditView];
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
    
    GPUImageOutput<GPUImageInput> * Filter8 = [[GPUImageGrayscaleFilter alloc] init];
    NSString * title8 = @"灰度";
    NSDictionary * dic8 = [NSDictionary dictionaryWithObjectsAndKeys:Filter8,@"filter",title8,@"name", nil];
    [arr addObject:dic8];
    
    GPUImageOutput<GPUImageInput> * Filter9 = [[GPUImageHistogramGenerator alloc] init];
    NSString * title9 = @"色彩直方图？";
    NSDictionary * dic9 = [NSDictionary dictionaryWithObjectsAndKeys:Filter9,@"filter",title9,@"name", nil];
    [arr addObject:dic9];
    
    
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
    NSString * title12 = @"单色";
    NSDictionary * dic12 = [NSDictionary dictionaryWithObjectsAndKeys:Filter12,@"filter",title12,@"name", nil];
    [arr addObject:dic12];
    
    GPUImageOutput<GPUImageInput> * Filter13 = [[GPUImageSobelEdgeDetectionFilter alloc] init];
    //    [(GPUImageSobelEdgeDetectionFilter *)Filter13 ];
    NSString * title13 = @"漫画反色";
    NSDictionary * dic13 = [NSDictionary dictionaryWithObjectsAndKeys:Filter13,@"filter",title13,@"name", nil];
    [arr addObject:dic13];
    
    GPUImageOutput<GPUImageInput> * Filter14 = [[GPUImageXYDerivativeFilter alloc] init];
    //    [(GPUImageSobelEdgeDetectionFilter *)Filter13 ];
    NSString * title14 = @"蓝绿边缘";
    NSDictionary * dic14 = [NSDictionary dictionaryWithObjectsAndKeys:Filter14,@"filter",title14,@"name", nil];
    [arr addObject:dic14];
    
    
    GPUImageOutput<GPUImageInput> * Filter15 = [[GPUImageSketchFilter alloc] init];
    //    [(GPUImageSobelEdgeDetectionFilter *)Filter13 ];
    NSString * title15 = @"素描";
    NSDictionary * dic15 = [NSDictionary dictionaryWithObjectsAndKeys:Filter15,@"filter",title15,@"name", nil];
    [arr addObject:dic15];
    
    GPUImageOutput<GPUImageInput> * Filter16 = [[GPUImageSmoothToonFilter alloc] init];
    //    [(GPUImageSobelEdgeDetectionFilter *)Filter13 ];
    NSString * title16 = @"卡通";
    NSDictionary * dic16 = [NSDictionary dictionaryWithObjectsAndKeys:Filter16,@"filter",title16,@"name", nil];
    [arr addObject:dic16];
    
    
    GPUImageOutput<GPUImageInput> * Filter17 = [[GPUImageColorPackingFilter alloc] init];
    //    [(GPUImageSobelEdgeDetectionFilter *)Filter13 ];
    NSString * title17 = @"监控";
    NSDictionary * dic17 = [NSDictionary dictionaryWithObjectsAndKeys:Filter17,@"filter",title17,@"name", nil];
    [arr addObject:dic17];
    
    
    return arr;
}

#pragma mark ---------------------------选择滤镜----------------------------

-(void)effectImgClick:(UIButton *)button{
    
    for (int i = 0 ; i<_GPUImgArr.count ;i++) {
        UIButton *btn = [_EditView viewWithTag:1000+i];
        btn.layer.borderWidth = 0;
        btn.userInteractionEnabled = YES;
    }
    button.userInteractionEnabled = NO;
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor redColor].CGColor;
    
    
//    [_gpuMovie cancelProcessing];
    [_gpuMovie removeAllTargets];

    if (button.tag == 1000) {
        _pixellateFilter = nil;
        [_gpuMovie addTarget:_gpuView];

    }else{
        _pixellateFilter = (GPUImageOutput<GPUImageInput> *)[_GPUImgArr[button.tag-1000] objectForKey:@"filter"];
        [_gpuMovie addTarget:_pixellateFilter];
       
        if (_gpuView != nil) {
            [_gpuView removeFromSuperview];
        }
        _gpuView = [[GPUImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 200)];
        [_pixellateFilter addTarget:_gpuView];
        [self.view addSubview:_gpuView];
    }

//    [_gpuMovie startProcessing];
    
}
@end
