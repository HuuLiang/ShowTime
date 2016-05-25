//
//  STLiveVideoPlayer.h
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface STLiveVideoPlayer : UIView

@property (nonatomic) NSURL *videoURL;
@property (nonatomic,retain)UILabel *loadingLabel;
@property (nonatomic,retain) AVPlayer *player;

- (instancetype)initWithVideoURL:(NSURL *)videoURL;
- (void)startToPlay;

@end
