//
//  STWeChatPayConfigModel.m
//  kuaibov
//
//  Created by Sean Yue on 16/1/8.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "STWeChatPayConfigModel.h"

@implementation STWeChatPayConfigModel

+ (instancetype)sharedModel {
    static STWeChatPayConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [STWeChatPayConfig class];
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (BOOL)fetchWeChatPayConfigWithCompletionHandler:(STCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:ST_WECHATPAY_CONFIG_URL
                         withParams:nil
                    responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        STWeChatPayConfig *config;
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
