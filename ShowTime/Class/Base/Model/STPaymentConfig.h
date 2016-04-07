//
//  STPaymentConfig.h
//  ShowTime
//
//  Created by Liang on 16/4/7.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STURLResponse.h"

typedef NS_ENUM(NSUInteger, STIAppPayType) {
    STIAppPayTypeUnknown = 0,
    STIAppPayTypeWeChat = 1 << 0,
    STIAppPayTypeAlipay = 1 << 1
};

@interface STWeChatPaymentConfig : NSObject
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *mchId;
@property (nonatomic) NSString *signKey;
@property (nonatomic) NSString *notifyUrl;

+ (instancetype)defaultConfig;
@end

@interface STAlipayConfig : NSObject
@property (nonatomic) NSString *partner;
@property (nonatomic) NSString *seller;
@property (nonatomic) NSString *productInfo;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *notifyUrl;
@end

@interface STIAppPayConfig : NSObject
@property (nonatomic) NSString *appid;
@property (nonatomic) NSString *privateKey;
@property (nonatomic) NSString *publicKey;
@property (nonatomic) NSString *notifyUrl;
@property (nonatomic) NSNumber *waresid;
@property (nonatomic) NSNumber *supportPayTypes;

+ (instancetype)defaultConfig;
@end

@interface STPaymentConfig : STURLResponse

@property (nonatomic,retain) STWeChatPaymentConfig *weixinInfo;
@property (nonatomic,retain) STAlipayConfig *alipayInfo;
@property (nonatomic,retain) STIAppPayConfig *iappPayInfo;

+ (instancetype)sharedConfig;
- (void)setAsCurrentConfig;

@end
