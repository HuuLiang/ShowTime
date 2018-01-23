//
//  STErrorHandler.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STErrorHandler.h"
#import "STURLRequest.h"

NSString *const kNetworkErrorNotification = @"STNetworkErrorNotification";
NSString *const kNetworkErrorCodeKey = @"STNetworkErrorCodeKey";
NSString *const kNetworkErrorMessageKey = @"STNetworkErrorMessageKey";

@implementation STErrorHandler

+ (instancetype)sharedHandler {
    static STErrorHandler *_handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[STErrorHandler alloc] init];
    });
    return _handler;
}

- (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkError:) name:kNetworkErrorNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onNetworkError:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    STURLResponseStatus resp = (STURLResponseStatus)(((NSNumber *)userInfo[kNetworkErrorCodeKey]).unsignedIntegerValue);
    
    if (resp == STURLResponseFailedByInterface) {
        [[STHudManager manager] showHudWithText:@"获取网络数据失败"];
    } else if (resp == STURLResponseFailedByNetwork) {
        [[STHudManager manager] showHudWithText:@"网络错误，请检查网络连接！"];
    }
    
}
@end
