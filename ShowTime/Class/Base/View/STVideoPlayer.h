//
//  STVideoPlayer.h
//  STuaibo
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STVideoPlayer : UIView

@property (nonatomic,readonly) NSURL *videoURL;
@property (nonatomic,copy) STAction endPlayAction;

- (instancetype)initWithVideoURL:(NSURL *)videoURL;
- (void)startToPlay;
- (void)pause;

@end
