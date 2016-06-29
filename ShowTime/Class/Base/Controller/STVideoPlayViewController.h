//
//  STVideoPlayViewController.h
//  ShowTime
//
//  Created by ylz on 16/6/20.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STBaseViewController.h"
#import "STProgram.h"

@interface STVideoPlayViewController : STBaseViewController

@property (nonatomic) NSUInteger videoLocation;
@property (nonatomic,retain) STChannel *channel;
@property (nonatomic) BOOL shouldPopupPaymentIfNotPaid;
@property (nonatomic,retain,readonly) STProgram *video;

- (instancetype)initWithVideo:(STProgram *)video;
@end
