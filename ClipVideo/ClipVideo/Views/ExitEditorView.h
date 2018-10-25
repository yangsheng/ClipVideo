//
//  ExitEditorView.h
//  ClipVideo
//
//  Created by leeco on 2018/10/25.
//  Copyright © 2018年 zsw. All rights reserved.
//是否退出界面

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ExitEditorViewDelegate <NSObject>

- (void)exitEditorViewConfirm;
- (void)exitEditorViewCancel;


@end


@interface ExitEditorView : UIView

@property(nonatomic, weak) id<ExitEditorViewDelegate> delegate;

- (void)disPlay;

- (void)disappera;

@end

NS_ASSUME_NONNULL_END
