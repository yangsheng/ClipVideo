//
//  FilterColoringView.m
//  ClipVideo
//
//  Created by leeco on 2018/11/2.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "FilterColoringView.h"


@interface FilterColoringView()

@end


@implementation FilterColoringView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self conmfigureUI];
    }
    return self;
}
- (void)conmfigureUI{
    
    self.backgroundColor = [UIColor blackColor];
    
    CGFloat sliderW = kScreenWidth / 2.0 - 55 - 20;
    

        UIImageView * imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20 + 0*35, 35, 35)];
        imageView1.backgroundColor = [UIColor redColor];
        [self addSubview:imageView1];
        UISlider * slider1 = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView1.frame)+20, 20+ 0*35, sliderW, 35)];
        slider1.tag = 100+0;
    slider1.minimumValue = -1;
    slider1.maximumValue = 1;
    [slider1 setValue:0];
        slider1.continuous = YES;//默认YES  如果设置为NO，则每次滑块停止移动后才触发事件
        [slider1 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider1];
        
        UIImageView * imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2.0, 20+ 0*35, 35, 35)];
        imageView2.backgroundColor = [UIColor redColor];
        [self addSubview:imageView2];
        UISlider * slider2 = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView2.frame)+20, 20+ 0*35, sliderW, 35)];
    slider2.minimumValue = 0;
    slider2.maximumValue = 2;
    [slider2 setValue:1];
        [slider2 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        slider2.tag = 101;
        [self addSubview:slider2];
    
    UIImageView * imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20 + 1*35, 35, 35)];
    imageView3.backgroundColor = [UIColor redColor];
    [self addSubview:imageView3];
    UISlider * slider3 = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView3.frame)+20, 20+ 1*35, sliderW, 35)];
    slider3.tag = 102;
    slider3.minimumValue = 0;
    slider3.maximumValue = 4;
    [slider3 setValue:1.0];
    slider3.continuous = YES;//默认YES  如果设置为NO，则每次滑块停止移动后才触发事件
    [slider3 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider3];
    
    UIImageView * imageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2.0, 20+ 1*35, 35, 35)];
    imageView4.backgroundColor = [UIColor redColor];
    [self addSubview:imageView4];
    UISlider * slider4 = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView4.frame)+20, 20+ 1*35, sliderW, 35)];
    slider4.minimumValue = 0;
    slider4.maximumValue = 2;
    [slider4 setValue:1];
    [slider4 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    slider4.tag = 103;
    [self addSubview:slider4];
    
    UIImageView * imageView5 = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20 + 2*35, 35, 35)];
    imageView5.backgroundColor = [UIColor redColor];
    [self addSubview:imageView5];
    UISlider * slider5 = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView5.frame)+20, 20+ 2*35, sliderW, 35)];
    slider5.tag = 104;
    slider4.minimumValue = -10;
    slider4.maximumValue = 10;
    [slider4 setValue:0];
    slider5.continuous = YES;//默认YES  如果设置为NO，则每次滑块停止移动后才触发事件
    [slider5 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider5];
    
    UIImageView * imageView6 = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth/2.0, 20+ 2*35, 35, 35)];
    imageView6.backgroundColor = [UIColor redColor];
    [self addSubview:imageView6];
    UISlider * slider6 = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView6.frame)+20, 20+ 2*35, sliderW, 35)];
    [slider6 addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    slider6.tag = 105;
    [self addSubview:slider6];
    
}

- (void) sliderChange:(UISlider *)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        
        NSLog(@"%ld",(long)sender.tag);
        
        UISlider * slider = sender;
        CGFloat value = slider.value;
        NSLog(@"%f", value);
        
        if ([self.delegate respondsToSelector:@selector(filterColoringView:andValue:)]) {
            [self.delegate filterColoringView:sender.tag andValue:sender.value];
        }
        
    }
}
@end
