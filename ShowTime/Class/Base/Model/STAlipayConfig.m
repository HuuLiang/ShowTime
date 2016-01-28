//
//  STAlipayConfig.m
//  kuaibov
//
//  Created by Sean Yue on 16/1/9.
//  Copyright © 2016年 kuaibov. All rights reserved.
//

#import "STAlipayConfig.h"
#import "NSMutableDictionary+SafeCoding.h"

static NSString *const kAlipayConfigKeyName = @"showtime_alipay_config_keyname";

@implementation STAlipayConfig

- (BOOL)isValid {
    return self.partner.length > 0 && self.privateKey.length > 0 && self.seller.length > 0 && self.notifyUrl.length > 0;
}

+ (instancetype)defaultConfig {
    static STAlipayConfig *_defaultConfig;
    static dispatch_once_t configToken;
    dispatch_once(&configToken, ^{
        NSDictionary *configDic = [[NSUserDefaults standardUserDefaults] objectForKey:kAlipayConfigKeyName];
        _defaultConfig = [[self alloc] initWithDictionary:configDic];
    });
    return _defaultConfig;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [self init];
    if (self) {
        self.partner = dic[@"partner"];
        self.privateKey = dic[@"privateKey"];
        self.productInfo = dic[@"productInfo"];
        self.seller = dic[@"seller"];
        self.notifyUrl = dic[@"notifyUrl"];
        
        if (!self.isValid) {
            self.partner = ST_ALIPAY_PARTNER;
            self.seller = ST_ALIPAY_SELLER;
            self.notifyUrl = ST_ALIPAY_NOTIFY_URL;
            self.productInfo = ST_ALIPAY_PRODUCT_INFO;
            self.privateKey = ST_ALIPAY_PRIVATE_KEY;
        }
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic safelySetObject:self.partner forKey:@"partner"];
    [dic safelySetObject:self.privateKey forKey:@"privateKey"];
    [dic safelySetObject:self.productInfo forKey:@"productInfo"];
    [dic safelySetObject:self.seller forKey:@"seller"];
    [dic safelySetObject:self.notifyUrl forKey:@"notifyUrl"];
    return dic.count > 0 ? dic : nil;
}

- (void)saveAsDefaultConfig {
    NSDictionary *dicRep = [self dictionaryRepresentation];
    if (dicRep) {
        [[NSUserDefaults standardUserDefaults] setObject:dicRep forKey:kAlipayConfigKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
