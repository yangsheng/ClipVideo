//
//  ZJInterceptBottomTools.h
//  ZJPlayer
//
//  Created by leeco on 2018/10/13.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@protocol ZJInterceptBottomToolsDelegate <NSObject>

- (void)seekToTime:(CGFloat)startTime enTime:(CGFloat)endTime atIndex:(NSInteger)index;

- (void)playToTime:(CGFloat)startTime enTime:(CGFloat)endTime atIndex:(NSInteger)index;

@end


@interface ZJInterceptBottomTools : UIView


@property(nonatomic, assign) BOOL  isSliderViewhandlePan;

@property (nonatomic, assign) CGFloat startChangeTime;            //开始截取的时间
@property (nonatomic, assign) CGFloat endChangeTime;              //结束截取的时间

@property (nonatomic, assign) CGFloat startTime;            //开始截取的时间
@property (nonatomic, assign) CGFloat endTime;              //结束截取的时间
@property(nonatomic, weak) id<ZJInterceptBottomToolsDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame coverImgs:(NSArray *)coverImgs;

- (void)addImg:(UIImage *)image;

- (void)updateProcess:(CGFloat)process;


@end

NS_ASSUME_NONNULL_END
