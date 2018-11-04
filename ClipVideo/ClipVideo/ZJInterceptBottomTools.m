//
//  ZJInterceptBottomTools.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/13.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJInterceptBottomTools.h"

#define kClipTimeScrollTag  20
#define kLeftX 20

@interface ZJInterceptBottomTools()

{
    CGFloat _leftSliderImgViewW;
    CGFloat _RightSliderImgViewW;
    int _index;
}

@property (nonatomic, strong) UIScrollView *scrollView;         //视频封面的滚动

@property (nonatomic, strong) UIImageView *leftSliderImgView;   //左滑块
@property (nonatomic, strong) UIImageView *rightSliderImgView;  //右滑块
@property (nonatomic, strong) UIView *leftOpacityImgView;  //左边白色遮罩
@property (nonatomic, strong) UIView *rightOpacityImgView; //右边白色遮罩

@property(nonatomic, strong) UIView * processLine;

@property (nonatomic, strong) UILabel *selDurationLabel;        //显示时间label

@property(nonatomic, strong) UILabel * startTimeL;//开始时间
@property(nonatomic, strong) UILabel * endTimeL;//结束时间



@property (nonatomic, assign) unsigned long videoDuration;  //截取的时间长度


@property (nonatomic, assign) CGFloat imgWidth;   //指示器图片宽
@property (nonatomic, assign) CGFloat minWidth;   //两个指示器间隔距离最短 对应时间是1秒
@property (nonatomic, assign) CGFloat maxWidth;   //两个指示器间隔距离最长(屏幕宽) 对应时间是30秒
@property (nonatomic, assign) CGFloat timeScale;  //每个像素占多少秒

@property (nonatomic, strong) NSArray *coverImgs;               //封面图片

@property (nonatomic, assign) CGFloat tempStartTime;    //滚动的偏移量的开始时间
@property (nonatomic, assign) CGFloat tempEndTime;      //滚动的偏移量的结束时间

@end


@implementation ZJInterceptBottomTools
- (void)setStartTime:(CGFloat)startTime{
    _startTime = startTime;
   
    self.startChangeTime = _startTime;
}
- (void)setStartChangeTime:(CGFloat)startChangeTime{
    _startChangeTime = startChangeTime;
    self.selDurationLabel.text = [NSString stringWithFormat:@"%.1f",_endChangeTime - _startChangeTime];
     self.startTimeL.text = [NSString stringWithFormat:@"%.1f",_startChangeTime];
}
- (void)setEndTime:(CGFloat)endTime{
    _endTime = endTime;
    self.endChangeTime = endTime;
    self.timeScale = (self.endTime - self.startTime)/(kScreenWidth-2*kLeftX - self.leftSliderImgView.frameW - self.rightSliderImgView.frameW);
    self.selDurationLabel.text = [NSString stringWithFormat:@"%.1f",_endChangeTime - _startChangeTime];
    self.minWidth = 1.0f/self.timeScale;//1秒钟占的宽
}
- (void)setEndChangeTime:(CGFloat)endChangeTime{
    _endChangeTime  = endChangeTime;
    self.endTimeL.text = [NSString stringWithFormat:@"%.1f",_endChangeTime];

}
- (instancetype)initWithFrame:(CGRect)frame  coverImgs:(NSArray *)coverImgs{
    if (self = [super initWithFrame:frame]) {
        self.coverImgs = coverImgs;
        self.isSliderViewhandlePan = NO;
        [self configureUI];
    }
    return self;
}
- (void)configureUI{
    
    self.backgroundColor = [UIColor grayColor];
    
    _index = 0;
    
    //下面的小图
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kLeftX, 30, kScreenWidth - 2*kLeftX, 50)];
    [self.scrollView setTag:kClipTimeScrollTag];
    [self.scrollView setAlwaysBounceHorizontal:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self addSubview:self.scrollView];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.scrollView setContentSize:CGSizeMake(kScreenWidth - 2*kLeftX, 50)];

    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    UIImage *leftSliderImg = [UIImage imageNamed:@"resume_btn_control_l"];
    UIImage *rightSliderImg = [UIImage imageNamed:@"resume_btn_control_r"];

    self.leftSliderImgView = [[UIImageView alloc] initWithImage:leftSliderImg];
    self.leftSliderImgView.userInteractionEnabled = YES;

    self.leftSliderImgView.frame = CGRectMake(kLeftX, 30, leftSliderImg.size.width, 60);

    [self.leftSliderImgView addGestureRecognizer:leftPan];
    [self addSubview:self.leftSliderImgView];
    self.leftSliderImgView.backgroundColor = [UIColor redColor];
    
    self.rightSliderImgView = [[UIImageView alloc] initWithImage:rightSliderImg];
    self.rightSliderImgView.userInteractionEnabled = YES;
    
    self.rightSliderImgView.backgroundColor = [UIColor redColor];

    self.rightSliderImgView.frame = CGRectMake(kScreenWidth - kLeftX -  rightSliderImg.size.width, 30, rightSliderImg.size.width, 60);

    [self.rightSliderImgView addGestureRecognizer:rightPan];
    [self addSubview:self.rightSliderImgView];
    
    
    //透明度
    self.leftOpacityImgView = [[UIView alloc] initWithFrame:CGRectMake(kLeftX, 30, self.leftSliderImgView.frameX - kLeftX, _scrollView.frameH)];
    self.leftOpacityImgView.backgroundColor = [UIColor redColor];
    self.leftOpacityImgView.alpha = 0.6;
    [self addSubview:self.leftOpacityImgView];
    
    self.rightOpacityImgView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.rightSliderImgView.frame),30,kScreenWidth - kLeftX - CGRectGetMaxX(self.rightSliderImgView.frame), _scrollView.frameH)];
    [self addSubview:self.rightOpacityImgView];
    self.rightOpacityImgView.backgroundColor = [UIColor redColor];
    self.rightOpacityImgView.alpha = 0.6;

    _leftSliderImgViewW = self.leftSliderImgView.frameW;
    _RightSliderImgViewW = self.rightSliderImgView.frameW;
    
    
    self.timeScale = (self.endTime - self.startTime)/(kScreenWidth-2*kLeftX - self.leftSliderImgView.frameW - self.rightSliderImgView.frameW);
    self.minWidth = 1.0f/self.timeScale;//1秒钟占的宽
    
    
    //选中片段时长
    self.selDurationLabel = [[UILabel alloc] init];
    self.selDurationLabel.textColor = [UIColor whiteColor];
    self.selDurationLabel.font = [UIFont systemFontOfSize:15];
    self.selDurationLabel.text = @"0.0s";
    [self.selDurationLabel sizeToFit];
    [self addSubview:self.selDurationLabel];
    [self.selDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).with.offset(5);
    }];
    
    self.startTimeL = [[UILabel alloc] init];
    self.startTimeL.textColor = [UIColor whiteColor];
    self.startTimeL.font = [UIFont systemFontOfSize:15];
    [self.startTimeL sizeToFit];
    [self addSubview:self.startTimeL];
    [self.startTimeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.equalTo(self.mas_top).with.offset(5);
    }];
    
    self.endTimeL = [[UILabel alloc] init];
    self.endTimeL.textColor = [UIColor whiteColor];
    self.endTimeL.font = [UIFont systemFontOfSize:15];

    [self.endTimeL sizeToFit];
    [self addSubview:self.endTimeL];
    [self.endTimeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.equalTo(self.mas_top).with.offset(5);
    }];
    
    
    self.processLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.leftSliderImgView.frame), 30, 1, _scrollView.frameH)];
    self.processLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.processLine];
    
    
}
- (void)addImg:(UIImage *)image{
    
    float imgWidth = kScreenWidth/8.0;
    
     UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    [imageView setFrame:CGRectMake(_index*imgWidth, 0, imgWidth, 50)];
    
    [self.scrollView addSubview:imageView];
    
    _index ++;
}

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:gesture.view];
        
        CGFloat rightX = self.rightSliderImgView.frame.origin.x;
        
        CGFloat leftX = self.leftSliderImgView.frame.origin.x + translation.x;
        
        if (leftX <= kLeftX) {
            leftX = kLeftX;
        }
        else if (leftX >= rightX - _minWidth - _leftSliderImgViewW) {//设置最小间距
            leftX = rightX - _minWidth - _leftSliderImgViewW;
        }
        
        CGFloat width = rightX - CGRectGetMaxX(self.leftSliderImgView.frame);
        CGFloat selDuration = width * self.timeScale;
        self.startChangeTime = self.startTime + leftX *self.timeScale;
        self.endChangeTime = self.startChangeTime + selDuration;
        
        if (self.startChangeTime < 0.) {
            self.startChangeTime = 0.;
        }
        
        self.selDurationLabel.text = [NSString stringWithFormat:@"%.1fs", selDuration];
        self.leftSliderImgView.frameX = leftX;
        
        self.leftOpacityImgView.frameW = self.leftSliderImgView.frameX - kLeftX;
        
        
        [gesture setTranslation:CGPointZero inView:gesture.view];

        if ([self.delegate respondsToSelector:@selector(seekToTime:enTime:atIndex:)]) {
            [self.delegate seekToTime:self.startChangeTime enTime:self.endChangeTime atIndex:0];
        }
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(playToTime:enTime:atIndex:)]) {
            [self.delegate playToTime:self.startChangeTime enTime:self.endChangeTime atIndex:0];
        }
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture locationInView:gesture.view];
        CGFloat leftX = self.leftSliderImgView.frame.origin.x;
        CGFloat rightX = self.rightSliderImgView.frame.origin.x + translation.x;

        if (rightX >= kScreenWidth - self.rightSliderImgView.frameW - kLeftX) {
            rightX = kScreenWidth - self.rightSliderImgView.frameW - kLeftX;
        }
        
        if (rightX <= leftX + _minWidth + _leftSliderImgViewW) {
            rightX = leftX + _minWidth + _leftSliderImgViewW;
        }

        CGFloat width = rightX - CGRectGetMaxX(self.leftSliderImgView.frame);
        CGFloat selDuration = width * self.timeScale;
        self.endChangeTime = self.startChangeTime + selDuration;
        
        
        self.selDurationLabel.text = [NSString stringWithFormat:@"%.1fs", selDuration];
        
        self.rightSliderImgView.frameX = rightX;
        
        self.rightOpacityImgView.frameX = CGRectGetMaxX(self.rightSliderImgView.frame);
        self.rightOpacityImgView.frameW = self.scrollView.frameW - self.rightOpacityImgView.frameX +kLeftX;
        
        
        [gesture setTranslation:CGPointZero inView:gesture.view];

        if ([self.delegate respondsToSelector:@selector(seekToTime:enTime:atIndex:)]) {
            [self.delegate seekToTime:self.startChangeTime enTime:self.endChangeTime atIndex:1];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded){

        if ([self.delegate respondsToSelector:@selector(playToTime:enTime:atIndex:)]) {
            [self.delegate playToTime:self.startChangeTime enTime:self.endChangeTime atIndex:1];
        }
    }
}
- (void)updateProcess:(CGFloat)process{
    
    self.processLine.frameX = (process -self.startChangeTime) / self.timeScale + CGRectGetMaxX(self.leftSliderImgView.frame);
}
@end
