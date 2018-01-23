//
//  STSystemConfigModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STSystemConfigModel.h"

@implementation STSystemConfigResponse

- (Class)confisElementClass {
    return [STSystemConfig class];
}

@end

@implementation STSystemConfigModel

+ (instancetype)sharedModel {
    static STSystemConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[STSystemConfigModel alloc] init];
    });
    return _sharedModel;
}

+ (Class)responseClass {
    return [STSystemConfigResponse class];
}

- (BOOL)fetchSystemConfigWithCompletionHandler:(STFetchSystemConfigCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:ST_SYSTEM_CONFIG_URL
                             withParams:@{@"type" : @([STUtil  deviceType])}
                        responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        if (respStatus == STURLResponseSuccess) {
            STSystemConfigResponse *resp = self.response;
            
            [resp.confis enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                STSystemConfig *config = obj;
                
                if ([config.name isEqualToString:ST_SYSTEM_CONFIG_PAY_AMOUNT]) {
                    self.payAmount = config.value.doubleValue / 100.;
                } else if ([config.name isEqualToString:ST_SYSTEM_CONFIG_PAY_IMG]) {
                    self.paymentImage = config.value;
                } else if ([config.name isEqualToString:ST_SYSTEM_CONFIG_CHANNEL_TOP_IMAGE]) {
                    self.channelTopImage = config.value;
                } else if ([config.name isEqualToString:ST_SYSTEM_CONFIG_STARTUP_INSTALL]) {
                    self.startupInstall = config.value;
                    self.startupPrompt = config.memo;
                } else if ([config.name isEqualToString:ST_SYSTEM_CONFIG_SPREAD_TOP_IMAGE]) {
                    self.spreadTopImage = config.value;
                } else if ([config.name isEqualToString:ST_SYSTEM_CONFIG_SPREAD_URL]) {
                    self.spreadURL = config.value;
                }else if ([config.name isEqualToString:ST_SYSTEM_CONFIG_STATS_TIME_INTERVAL]) {
                    self.statsTimeInterval = config.value.integerValue;
                }else if ([config.name isEqualToString:ST_SYSTEM_CONFIG_CONTACT]) {
                    self.contact = config.value;
                }
            }];
            _loaded = YES;
        }
        
        if (handler) {
            handler(respStatus==STURLResponseSuccess);
        }
    }];
    return success;
}

@end
