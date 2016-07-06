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
//    return YES;
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

@end
