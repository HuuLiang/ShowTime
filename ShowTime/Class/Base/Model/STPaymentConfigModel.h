//
//  STPaymentConfigModel.h
//  ShowTime
//
//  Created by Liang on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STEncryptedURLRequest.h"
#import "STPaymentConfig.h"

@interface STPaymentConfigModel : STEncryptedURLRequest

@property (nonatomic,readonly) BOOL loaded;


+ (instancetype)sharedModel;

- (BOOL)fetchConfigWithCompletionHandler:(STCompletionHandler)handler;

@end
