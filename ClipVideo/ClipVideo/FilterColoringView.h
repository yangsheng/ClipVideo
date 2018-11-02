//
//  FilterColoringView.h
//  ClipVideo
//
//  Created by leeco on 2018/11/2.
//  Copyright © 2018年 zsw. All rights reserved.
//调色板

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol FilterColoringViewDelegate <NSObject>

- (void)filterColoringView:(NSInteger )tag andValue:(float)value;

@end


@interface FilterColoringView : UIView
@property(nonatomic, weak) id<FilterColoringViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
