//
//  STAlipayConfig.h
//  kuaibov
//
//  Created by Sean Yue on 16/1/9.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "STURLResponse.h"

@interface STAlipayConfig : STURLResponse

@property (nonatomic,retain) NSString *partner;
@property (nonatomic,retain) NSString *privateKey;
@property (nonatomic,retain) NSString *productInfo;
@property (nonatomic,retain) NSString *seller;
@property (nonatomic,retain) NSString *notifyUrl;

- (BOOL)isValid;
+ (instancetype)defaultConfig;
- (void)saveAsDefaultConfig;

@end
