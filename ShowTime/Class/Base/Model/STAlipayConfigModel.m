//
//  STAlipayConfigModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/11/19.
//  Copyright © 2015年 kuaibov. All rights reserved.
//

#import "STAlipayConfigModel.h"

@implementation STAlipayConfigModel

+ (instancetype)sharedModel {
    static STAlipayConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [STAlipayConfig class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (STAlipayConfig *)fetchedConfig {
    return self.response;
}

- (BOOL)fetchAlipayConfigWithCompletionHandler:(STCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:ST_ALIPAY_CONFIG_URL
                     //standbyURLPath:ST_STANDBY_ALIPAY_CONFIG_URL
                         withParams:nil
                    responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        STAlipayConfig *config;
        if (respStatus == STURLResponseSuccess) {
            config = self.response;
            [config saveAsDefaultConfig];
        }
        
        if (handler) {
            handler(respStatus==STURLResponseSuccess, config);
        }
    }];
    return ret;
}

@end
