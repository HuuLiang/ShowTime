//
//  STUtil.m
//  STuaibo
//
//  Created by Sean Yue on 15/12/25.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "STUtil.h"
#import <SFHFKeychainUtils.h>
#import <sys/sysctl.h>
#import "NSDate+Utilities.h"
#import "STPaymentInfo.h"
#import "STVideo.h"
#import "STBaseViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

NSString *const kPaymentInfoKeyName = @"jqkuaibov_paymentinfo_keyname";

static NSString *const kRegisterKeyName = @"jqkuaibov_register_keyname";
static NSString *const kUserAccessUsername = @"jqkuaibov_user_access_username";
static NSString *const kUserAccessServicename = @"jqkuaibov_user_access_service";

@implementation STUtil

+ (NSString *)accessId {
    NSString *accessIdInKeyChain = [SFHFKeychainUtils getPasswordForUsername:kUserAccessUsername andServiceName:kUserAccessServicename error:nil];
    if (accessIdInKeyChain) {
        return accessIdInKeyChain;
    }
    
    accessIdInKeyChain = [NSUUID UUID].UUIDString.md5;
    [SFHFKeychainUtils storeUsername:kUserAccessUsername andPassword:accessIdInKeyChain forServiceName:kUserAccessServicename updateExisting:YES error:nil];
    return accessIdInKeyChain;
}

+ (BOOL)isRegistered {
    return [self userId] != nil;
}

+ (void)setRegisteredWithUserId:(NSString *)userId {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kRegisterKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray<STPaymentInfo *> *)allPaymentInfos {
    NSArray<NSDictionary *> *paymentInfoArr = [[NSUserDefaults standardUserDefaults] objectForKey:kPaymentInfoKeyName];
    
    NSMutableArray *paymentInfos = [NSMutableArray array];
    [paymentInfoArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STPaymentInfo *paymentInfo = [STPaymentInfo paymentInfoFromDictionary:obj];
        [paymentInfos addObject:paymentInfo];
    }];
    return paymentInfos;
}

+ (NSArray<STPaymentInfo *> *)payingPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        STPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus.unsignedIntegerValue == STPaymentStatusPaying;
    }];
}

+ (NSArray<STPaymentInfo *> *)paidNotProcessedPaymentInfos {
    return [self.allPaymentInfos bk_select:^BOOL(id obj) {
        STPaymentInfo *paymentInfo = obj;
        return paymentInfo.paymentStatus.unsignedIntegerValue == STPaymentStatusNotProcessed;
    }];
}

+ (STPaymentInfo *)successfulPaymentInfo {
    return [self.allPaymentInfos bk_match:^BOOL(id obj) {
        STPaymentInfo *paymentInfo = obj;
        if (paymentInfo.paymentResult.unsignedIntegerValue == PAYRESULT_SUCCESS) {
            return YES;
        }
        return NO;
    }];
}

+ (BOOL)isPaid {
        return YES;
    return [self successfulPaymentInfo] != nil;
}

+ (NSString *)userId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRegisterKeyName];
}

+ (NSString *)deviceName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}

+ (STDeviceTypes)deviceType {
    NSString *deviceName = [self deviceName];
    if ([deviceName rangeOfString:@"iPhone3,"].location == 0) {
        return STDeviceType_iPhone4;
    } else if ([deviceName rangeOfString:@"iPhone4,"].location == 0) {
        return STDeviceType_iPhone4S;
    } else if ([deviceName rangeOfString:@"iPhone5,1"].location == 0 || [deviceName rangeOfString:@"iPhone5,2"].location == 0) {
        return STDeviceType_iPhone5;
    } else if ([deviceName rangeOfString:@"iPhone5,3"].location == 0 || [deviceName rangeOfString:@"iPhone5,4"].location == 0) {
        return STDeviceType_iPhone5C;
    } else if ([deviceName rangeOfString:@"iPhone6,"].location == 0) {
        return STDeviceType_iPhone5S;
    } else if ([deviceName rangeOfString:@"iPhone7,1"].location == 0) {
        return STDeviceType_iPhone6P;
    } else if ([deviceName rangeOfString:@"iPhone7,2"].location == 0) {
        return STDeviceType_iPhone6;
    } else if ([deviceName rangeOfString:@"iPhone8,1"].location == 0) {
        return STDeviceType_iPhone6S;
    } else if ([deviceName rangeOfString:@"iPhone8,2"].location == 0) {
        return STDeviceType_iPhone6SP;
    } else if ([deviceName rangeOfString:@"iPhone8,4"].location == 0) {
        return STDeviceType_iPhoneSE;
    }else if ([deviceName rangeOfString:@"iPad"].location == 0){
        
        return STDeviceType_iPad;
    } else {
        return STDeviceTypeUnknown;
    }
}


+ (NSString *)appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)paymentReservedData {
    return [NSString stringWithFormat:@"%@$%@", ST_REST_APP_ID, ST_CHANNEL_NO];
}



+ (NSUInteger)launchSeq {
    NSNumber *launchSeq = [[NSUserDefaults standardUserDefaults] objectForKey:kLaunchSeqKeyName];
    return launchSeq.unsignedIntegerValue;
}

+ (void)accumateLaunchSeq {
    NSUInteger launchSeq = [self launchSeq];
    [[NSUserDefaults standardUserDefaults] setObject:@(launchSeq+1) forKey:kLaunchSeqKeyName];
}



+ (NSUInteger)currentTabPageIndex {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)rootVC;
        return tabVC.selectedIndex;
    }
    return 0;
}

+ (NSUInteger)currentSubTabPageIndex {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)rootVC;
        if ([tabVC.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navVC = (UINavigationController *)tabVC.selectedViewController;
            if ([navVC.visibleViewController isKindOfClass:[STBaseViewController class]]) {
                STBaseViewController *baseVC = (STBaseViewController *)navVC.visibleViewController;
                return [baseVC currentIndex];
            }
        }
    }
    return NSNotFound;
}

+ (UIViewController *)currentVisibleViewController {
    UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *selectedVC = tabBarController.selectedViewController;
    if ([selectedVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVC = (UINavigationController *)selectedVC;
        return navVC.visibleViewController;
    }
    return selectedVC;
}


+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

@end
