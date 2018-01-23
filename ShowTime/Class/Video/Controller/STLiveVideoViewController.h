//
//  STLiveVideoViewController.h
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STBaseViewController.h"

@interface STLiveVideoViewController : STBaseViewController

@property (nonatomic,retain,readonly) STProgram *video;
@property (nonatomic)BOOL isTrival;
@property (nonatomic) NSUInteger videoLocation;
@property (nonatomic,retain) STChannel *channel;

- (instancetype)initWithVideo:(STVideo *)video;

@end
