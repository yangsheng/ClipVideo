//
//  FilterBottomView.h
//  ClipVideo
//
//  Created by leeco on 2018/10/31.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilterModel;
NS_ASSUME_NONNULL_BEGIN


@interface filterCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) FilterModel * model;


@end


@protocol FilterBottomViewDelegate <NSObject>

- (void)effectImgClickFilter:(FilterModel *)model;

@end



@interface FilterBottomView : UIView


@property(nonatomic, weak) id<FilterBottomViewDelegate> delegate;

- (void)addFilter:(FilterModel *)filterModel;

- (void)addFilterArray:(NSMutableArray *)filterArray;



@end

NS_ASSUME_NONNULL_END
