//
//  ViewController.h
//  ClipVideo
//
//  Created by leeco on 2018/10/15.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef NS_ENUM(NSInteger,ActionType) {
    VideoEditingAndSynthesis = 0,
    VideoBackgroundMusic,
    VideoBeautification,
    VideoReplay,
    VideoSpeed,
    VideoRatio,
    VideoWatermark
};


@interface ViewController : UIViewController


@property (nonatomic,assign) ActionType actionType;




@end

