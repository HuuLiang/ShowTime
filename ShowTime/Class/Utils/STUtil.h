//
//  STUtil.h
//  STuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPaymentInfoKeyName;

@class STPaymentInfo;
@class STVideo;

@interface STUtil : NSObject

+ (BOOL)isRegistered;
+ (void)setRegisteredWithUserId:(NSString *)userId;

+ (NSArray<STPaymentInfo *> *)allPaymentInfos;
+ (NSArray<STPaymentInfo *> *)payingPaymentInfos;
+ (NSArray<STPaymentInfo *> *)paidNotProcessedPaymentInfos;
+ (STPaymentInfo *)successfulPaymentInfo;

+ (BOOL)isPaid;

+ (NSString *)accessId;
+ (NSString *)userId;
+ (NSString *)deviceName;
+ (NSString *)appVersion;
+ (NSInteger)deviceType;

+ (NSString *)paymentReservedData;

+ (NSUInteger)launchSeq;
+ (void)accumateLaunchSeq;
+ (NSUInteger)currentTabPageIndex;
+ (NSUInteger)currentSubTabPageIndex;

+ (NSString *)getIPAddress;

+ (UIViewController *)currentVisibleViewController;

@end
