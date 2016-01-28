//
//  STAlipayConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/11/19.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "STEncryptedURLRequest.h"
#import "STAlipayConfig.h"

@interface STAlipayConfigModel : STEncryptedURLRequest

@property (nonatomic,readonly,retain) STAlipayConfig *fetchedConfig;

+ (instancetype)sharedModel;
- (BOOL)fetchAlipayConfigWithCompletionHandler:(STCompletionHandler)handler;

@end
