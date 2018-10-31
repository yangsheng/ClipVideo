//
//  FilterModel.h
//  ClipVideo
//
//  Created by leeco on 2018/10/31.
//  Copyright © 2018年 zsw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
NS_ASSUME_NONNULL_BEGIN

@interface FilterModel : NSObject

@property(nonatomic, strong) UIImage * image;

@property(nonatomic, strong) NSString * name;

@property(nonatomic, strong) GPUImageOutput<GPUImageInput> * disFilter;

@property(nonatomic, assign) BOOL  isSelected;

@end

NS_ASSUME_NONNULL_END
