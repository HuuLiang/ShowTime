//
//  STNetworkInfo.m
//  STuaibo
//
//  Created by Sean Yue on 16/5/10.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STNetworkInfo.h"
#import <AFNetworking.h>

@import SystemConfiguration;
@import CoreTelephony;

@interface STNetworkInfo ()
@property (nonatomic,retain,readonly) CTTelephonyNetworkInfo *networkInfo;
@end

@implementation STNetworkInfo
@synthesize networkInfo = _networkInfo;

DefineLazyPropertyInitialization(CTTelephonyNetworkInfo, networkInfo)

+ (instancetype)sharedInfo {
    static STNetworkInfo *_sharedInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInfo = [[self alloc] init];
    });
    return _sharedInfo;
}

- (void)startMonitoring {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (STNetworkStatus)networkStatus {
    
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusNotReachable) {
        return STNetworkStatusNotReachable;
    } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        return STNetworkStatusWiFi;
    } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        NSString *radioAccess = self.networkInfo.currentRadioAccessTechnology;
        if ([radioAccess isEqualToString:CTRadioAccessTechnologyGPRS]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyEdge]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
            return STNetworkStatus2G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyWCDMA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSDPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSUPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            return STNetworkStatus3G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyLTE]) {
            return STNetworkStatus4G;
        }
    }
    return STNetworkStatusUnknown;
}

- (NSString *)carriarName {
    return self.networkInfo.subscriberCellularProvider.carrierName;
}
@end
