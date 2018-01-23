//
//  STActivateModel.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/15.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STEncryptedURLRequest.h"

@interface STActivateModel : STEncryptedURLRequest

+ (instancetype)sharedModel;

- (BOOL)activateWithCompletionHandler:(STCompletionHandler)handler;

@end
