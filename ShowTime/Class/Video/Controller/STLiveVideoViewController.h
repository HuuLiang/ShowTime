//
//  STLiveVideoViewController.h
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STBaseViewController.h"

@interface STLiveVideoViewController : STBaseViewController

@property (nonatomic,retain,readonly) STVideo *video;

- (instancetype)initWithVideo:(STVideo *)video;

@end
