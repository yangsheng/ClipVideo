//
//  ZJSaveToCameraRollOperation.m
//  ZJPlayer
//
//  Created by leeco on 2018/10/12.
//  Copyright © 2018年 郑俱. All rights reserved.
//

#import "ZJSaveToCameraRollOperation.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZJSaveToCameraRollOperation()

@property (strong, nonatomic) void (^videoCompletion)(NSString *, NSError *);
@property (strong, nonatomic) void (^imageCompletion)(NSError *);

@end


@implementation ZJSaveToCameraRollOperation

#pragma mark - Public API

- (void)saveVideoURL:(NSURL *)url completion:(void (^)(NSString *, NSError *))completion {
    self.videoCompletion = completion;
    [self _didStart];

    UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

- (void)saveImage:(UIImage *)image completion:(void (^)(NSError *))completion {
    self.imageCompletion = completion;
    [self _didStart];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)saveGIFURL:(NSURL *)url completion:(void(^)(NSString *, NSError *))completion{
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL,
                                                                                  NSError *error) {
//        HUDNormal(@"保存成功");
//        NSLog(@"Success at %@", [assetURL path] );
        
        completion(assetURL.path,error);
    }];
}

#pragma mark - Save completions

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self _didEnd];
    
    void (^completion)(NSString *, NSError *) = self.videoCompletion;
    self.videoCompletion = nil;
    
    if (completion != nil) {
        completion(videoPath, error);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self _didEnd];
    
    void (^completion)(NSError *) = self.imageCompletion;
    self.imageCompletion = nil;
    
    if (completion != nil) {
        completion(error);
    }
}

#pragma mark - Private API

static NSMutableArray *pendingOperations = nil;

- (void)_didStart {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pendingOperations = [NSMutableArray new];
    });
    
    @synchronized(pendingOperations) {
        [pendingOperations addObject:self];
    }
}

- (void)_didEnd {
    @synchronized(pendingOperations) {
        [pendingOperations removeObject:self];
    }
}
@end
