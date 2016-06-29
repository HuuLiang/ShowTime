//
//  STNetworkInfo.h
//  STuaibo
//
//  Created by Sean Yue on 16/5/10.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, STNetworkStatus) {
    STNetworkStatusUnknown = -1,
    STNetworkStatusNotReachable = 0,
    STNetworkStatusWiFi = 1,
    STNetworkStatus2G = 2,
    STNetworkStatus3G = 3,
    STNetworkStatus4G = 4
};

@interface STNetworkInfo : NSObject

@property (nonatomic,readonly) STNetworkStatus networkStatus;
@property (nonatomic,readonly) NSString *carriarName;

+ (instancetype)sharedInfo;
- (void)startMonitoring;

@end
