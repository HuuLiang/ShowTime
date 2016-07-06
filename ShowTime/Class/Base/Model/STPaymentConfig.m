//
//  STPaymentConfig.m
//  ShowTime
//
//  Created by Liang on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//
#import "STPaymentConfig.h"

@implementation STWeChatPaymentConfig

+ (instancetype)defaultConfig {
    STWeChatPaymentConfig *config = [[self alloc] init];
    config.appId = @"wx4af04eb5b3dbfb56";
    config.mchId = @"1281148901";
    config.signKey = @"hangzhouquba20151112qwertyuiopas";
    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyWx.json";
    return config;
}
@end

@implementation STAlipayConfig

@end

@implementation STIAppPayConfig

+ (instancetype)defaultConfig {
    STIAppPayConfig *config = [[self alloc] init];
    config.appid = @"3004625633";
    config.privateKey = @"MIICXAIBAAKBgQCGANSVZxyAKcG7comgGjpNZ9SIABwmAVgBJoiSjCZam6aaEzWXE2p9ZeikuT3xvM1x+8OyfC2HO+EBD2P6ZppoMoPUet/F/wU/yVBfBE733n1Uy4jkR7tnknsMKlV3oqMzIV8EEQw6tNYwzp+9+krh3PVuXVsGzaBLL0uDxNEMPQIDAQABAoGAa/wHU04APZdosvEdzpLUIMRnFCFijY3PqT2wGMgvsBx2KPsJ2HChA+Q3kWZlcIRA2nWTwiUnWy75pq0MWCCOk/YikF7wf27C+ICTUogBaDQUWFWfPQiYjOMTHc0Jpo/8pzD0pqp1C3ArqUFFo6IW/TFVczVmOtx3adumPlQhT4ECQQDChCrzgVC0hDI+xAp0zLa0fN6s9bYecHsaN71W50Rup0FCxiWqwXwKQt1Nka3Ig3a1yCiw8LzgYwSosRPD0LkJAkEAsFwUeWKJsUHJ1cy/Jeno9DF07VjTCAM2yqsdf4jc0JPsh5PjMXAAlbd7EtmmIpCbmx0KXdKLhx+AVJ3XKgMKlQJBALApdKCtd8LUipCviOy4zart/9jSespcghB/dJl0v1QbY44u18QqkMTWQ4hRq/qRnPwKt1dv3w60fm6sWEMaD8kCQGXkTU/0RmlLATmtGaLmCdlL2apnb0Vp1fYx9tEAWdOII1gRcWnWs//MCidR6FKACecMWDjstABViudYaj+zkiECQCfnt3TNNuyZEQRoX7AsWFh3cFLnqd8zo4sLy2dyvfu9N+vXGg9ht5V2WjIYty9LGySoa0PCUpLYxitp0lpSb88=";
    config.publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCPr3vQFyTpKH7E8RQMBivbTDEYuyyWjub8+o24RhiC/zvSOI4Q1rt/62NQaS+kBga3krMPx/4ATid/rjjIYfjof7LzKO/O6pfpwTjaMhPsAvdckuRjryDzibj2iGNeJOpiXnYaXs6kLgnByB+d4KcJsk2WLRAclK1WgHXWEukT3wIDAQAB";
    config.waresid = @(1);
    return config;
}

@end

@implementation STVIAPayConfig

//+ (instancetype)defaultConfig {
//    STVIAPayConfig *config = [[self alloc] init];
//    //config.packageId = @"5361";
//    config.supportPayTypes = @(STSubPayTypeAlipay);
//    return config;
//}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    //    [dicRep safelySetObject:self.packageId forKey:@"packageId"];
    [dicRep safelySetObject:self.supportPayTypes forKey:@"supportPayTypes"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    STVIAPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}
@end

@implementation STSPayConfig

//+ (instancetype)defaultConfig {
//    STSPayConfig *config = [[self alloc] init];
//    config.mchId = @"5712000010";
//    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyWft.json";
//    config.signKey = @"5afe11de0df374f5f78839db1904ff0d";
//    return config;
//}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    [dicRep safelySetObject:self.mchId forKey:@"mchId"];
    [dicRep safelySetObject:self.signKey forKey:@"signKey"];
    [dicRep safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    STSPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}
@end

@implementation STHTPayConfig

+ (instancetype)defaultConfig {
    STHTPayConfig *config = [[self alloc] init];
    config.mchId = @"10605";
    config.key = @"e7c549c833cb9108e6524d075942119d";
    config.notifyUrl = @"http://phas.ihuiyx.com/pd-has/notifyHtPay.json";
    return config;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dicRep = [NSMutableDictionary dictionary];
    [dicRep safelySetObject:self.mchId forKey:@"mchId"];
    [dicRep safelySetObject:self.key forKey:@"key"];
    [dicRep safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    return dicRep;
}

+ (instancetype)configFromDictionary:(NSDictionary *)dic {
    STHTPayConfig *config = [[self alloc] init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj) {
            [config setValue:obj forKey:key];
        }
    }];
    return config;
}

@end



@interface STPaymentConfigRespCode : NSObject
@property (nonatomic) NSNumber *value;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *message;
@end

@implementation STPaymentConfigRespCode

@end

static STPaymentConfig *_shardConfig;

@interface STPaymentConfig ()
@property (nonatomic) STPaymentConfigRespCode *code;
@end

@implementation STPaymentConfig

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shardConfig = [[self alloc] init];
        [_shardConfig loadDefaultConfig];
    });
    return _shardConfig;
}

- (NSNumber *)success {
    return self.code.value.unsignedIntegerValue == 100 ? @(1) : (0);
}

- (NSString *)resultCode {
    return self.code.value.stringValue;
}

- (Class)codeClass {
    return [STPaymentConfigRespCode class];
}

- (Class)weixinInfoClass {
    return [STWeChatPaymentConfig class];
}

- (Class)alipayInfoClass {
    return [STAlipayConfig class];
}

- (Class)iappPayInfoClass {
    return [STIAppPayConfig class];
}

- (Class)syskPayInfoClass {
    return [STVIAPayConfig class];
}

- (Class)wftPayInfoClass {
    return [STSPayConfig class];
}

- (Class)haitunPayInfoClass {
    return [STHTPayConfig class];
}

- (void)loadDefaultConfig {
    self.weixinInfo = [STWeChatPaymentConfig defaultConfig];
    self.haitunPayInfo = [STHTPayConfig defaultConfig];
}


- (void)setAsCurrentConfig {
    STPaymentConfig *currentConfig = [[self class] sharedConfig];
    currentConfig.weixinInfo = self.weixinInfo;
    currentConfig.iappPayInfo = self.iappPayInfo;
    currentConfig.alipayInfo = self.alipayInfo;
    currentConfig.syskPayInfo = self.syskPayInfo;
    currentConfig.wftPayInfo = self.wftPayInfo;
    currentConfig.haitunPayInfo = self.haitunPayInfo;
}
@end
