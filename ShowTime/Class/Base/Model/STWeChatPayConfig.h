//
//  STWeChatPayConfig.h
//  kuaibov
//
//  Created by Sean Yue on 16/1/9.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "STURLResponse.h"

@interface STWeChatPayConfig : STURLResponse

@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;

- (BOOL)isValid;
+ (instancetype)defaultConfig;
- (void)saveAsDefaultConfig;

@end
