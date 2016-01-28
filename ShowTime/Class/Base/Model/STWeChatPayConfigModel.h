//
//  STWeChatPayConfigModel.h
//  kuaibov
//
//  Created by Sean Yue on 16/1/8.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "STEncryptedURLRequest.h"
#import "STWeChatPayConfig.h"

@interface STWeChatPayConfigModel : STEncryptedURLRequest

+ (instancetype)sharedModel;
- (BOOL)fetchWeChatPayConfigWithCompletionHandler:(STCompletionHandler)handler;

@end
