//
//  PlayController.h
//  ClipVideo
//
//  Created by leeco on 2018/10/24.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayController : UIViewController
- (void)playWithUrl:(NSURL *)url;


- (void)setImages:(NSArray *)images;


@property(nonatomic, strong) NSArray * urlArray;

@end

NS_ASSUME_NONNULL_END
