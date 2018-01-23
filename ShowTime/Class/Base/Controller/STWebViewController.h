//
//  STWebViewController.h
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STBaseViewController.h"

@interface STWebViewController : STBaseViewController

@property (nonatomic,readonly) NSURL *url;

- (instancetype)initWithURL:(NSURL *)URL;

@end
