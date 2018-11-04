//
//  SuperPlayController.h
//  ClipVideo
//
//  Created by leeco on 2018/10/25.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import "SuperController.h"
#import "ExitEditorView.h"
NS_ASSUME_NONNULL_BEGIN

@interface SuperPlayController : SuperController<ExitEditorViewDelegate>

@property(nonatomic, strong) ExitEditorView * backView;
@property(nonatomic, strong) NSArray * urlArray;
@property(nonatomic, strong) AVPlayerItem * currentPlayerItem;
@property(nonatomic, strong) NSURL * fileUrl;
@property(nonatomic, strong) AVPlayer *avPlayer;

/**
 当前观看时间
 */
@property(assign,nonatomic) CMTime  currentTtime;

/**
 视频播放器背景
 */
@property(nonatomic, strong) UIView * playerBgView;

- (void)playWithUrl:(NSURL *)url;


- (void)setImages:(NSArray *)images;


- (void)confirmBack;



@end

NS_ASSUME_NONNULL_END
