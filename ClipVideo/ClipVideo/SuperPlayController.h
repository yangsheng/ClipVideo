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

- (void)playWithUrl:(NSURL *)url;


- (void)setImages:(NSArray *)images;


- (void)confirmBack;



@end

NS_ASSUME_NONNULL_END
