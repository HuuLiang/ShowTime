//
//  STPaymentConfigModel.m
//  ShowTime
//
//  Created by Liang on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STPaymentConfigModel.h"
#import "NSDictionary+STSign.h"

static NSString *const SSignKey = @"qdge^%$#@(sdwHs^&";
static NSString *const SPaymentEncryptionPassword = @"wdnxs&*@#!*qb)*&qiang";

@implementation STPaymentConfigModel

+ (Class)responseClass {
    return [STPaymentConfig class];
}

+ (instancetype)sharedModel {
    static STPaymentConfigModel *_sharedModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedModel = [[self alloc] init];
    });
    return _sharedModel;
}

- (NSURL *)baseURL {
    return nil;
}

- (BOOL)shouldPostErrorNotification {
    return NO;
}

- (STURLRequestMethod)requestMethod {
    return STURLPostRequest;
}

+ (NSString *)signKey {
    return SSignKey;
}

- (NSDictionary *)encryptWithParams:(NSDictionary *)params {
    NSDictionary *signParams = @{  @"appId":ST_REST_APP_ID,
                                   @"key":SSignKey,
                                   @"imsi":@"999999999999999",
                                   @"channelNo":ST_CHANNEL_NO,
                                   @"pV":ST_PAYMENT_PV };
    
    NSString *sign = [signParams signWithDictionary:[self class].commonParams keyOrders:[self class].keyOrdersOfCommonParams];
    NSString *encryptedDataString = [params encryptedStringWithSign:sign password:SPaymentEncryptionPassword excludeKeys:@[@"key"]];
    return @{@"data":encryptedDataString, @"appId":ST_REST_APP_ID};
}

- (BOOL)fetchConfigWithCompletionHandler:(STCompletionHandler)handler {
    @weakify(self);
    BOOL ret = [self requestURLPath:ST_PAYMENT_CONFIG_URL
                     standbyURLPath:[NSString stringWithFormat:ST_STANDBY_PAYMENT_CONFIG_URL, ST_REST_APP_ID]
                         withParams:@{@"appId":ST_REST_APP_ID, @"channelNo":ST_CHANNEL_NO, @"pV":ST_PAYMENT_PV}
                    responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
                {
                    @strongify(self);
                    if (!self) {
                        return ;
                    }
                    
                    STPaymentConfig *config;
                    if (respStatus == STURLResponseSuccess) {
                        self->_loaded = YES;
                        config = self.response;
                        [config setAsCurrentConfig];
                        DLog(@"Payment config loaded!");
                    }
                    if (handler) {
                        handler(respStatus == STURLResponseSuccess, config);
                    }
                }];
    return ret;
}

@end
