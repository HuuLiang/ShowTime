//
//  STAppDelegate.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STAppDelegate.h"
#import "STHomeViewController.h"
#import "STAnchorViewController.h"
#import "STMineViewController.h"
#import "STActivateModel.h"
#import "STUserAccessModel.h"
#import "STPaymentModel.h"
#import "STSystemConfigModel.h"
#import "STPaymentManager.h"
#import "STWeChatPayQueryOrderRequest.h"
#import "STPaymentViewController.h"
#import "WXApi.h"
#import "MobClick.h"
#import "WeChatPayManager.h"
#import <AlipaySDK/AlipaySDK.h>
//#import "AlipayManager.h"
#import "STKLaunchView.h"
#import "STSystemConfigModel.h"

@interface STAppDelegate () <WXApiDelegate,UITabBarControllerDelegate>
@property (nonatomic,retain) STWeChatPayQueryOrderRequest *wechatPayOrderQueryRequest;
@end

@implementation STAppDelegate

DefineLazyPropertyInitialization(STWeChatPayQueryOrderRequest, wechatPayOrderQueryRequest)

- (UIWindow *)window {
    if (_window) {
        return _window;
    }
    
    STAnchorViewController *anchorVC = [[STAnchorViewController alloc] init];
    anchorVC.title = @"深夜福利";
    
    UINavigationController *anchorNav = [[UINavigationController alloc] initWithRootViewController:anchorVC];
    anchorNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:anchorVC.title
                                                         image:[[UIImage imageNamed:@"anchor_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                 selectedImage:[[UIImage imageNamed:@"anchor_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    STHomeViewController *homeVC = [[STHomeViewController alloc] init];
    homeVC.title = @"大厅";
    
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                       image:[[UIImage imageNamed:@"home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                               selectedImage:[[UIImage imageNamed:@"home_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    homeNav.tabBarItem.imageInsets = UIEdgeInsetsMake(-15, 0, 15, 0);
    
    STMineViewController *mineVC = [[STMineViewController alloc] init];
    mineVC.title = @"我的";
    
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:mineVC.title
                                                       image:[[UIImage imageNamed:@"mine_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                               selectedImage:[[UIImage imageNamed:@"mine_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[anchorNav, homeNav, mineNav];
    tabBarController.selectedViewController = homeNav;
    tabBarController.delegate = self;
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = tabBarController;
    return _window;
}

- (void)setupCommonStyles {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setTitleVerticalPositionAdjustment:-6 forBarMetrics:UIBarMetricsDefault];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    [[UITabBar appearance] setTintColor:[UIColor colorWithHexString:@"#fc5087"]];
    
    [UIViewController aspect_hookSelector:@selector(viewDidLoad)
                              withOptions:AspectPositionAfter
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIViewController *thisVC = [aspectInfo instance];
                                   thisVC.navigationController.navigationBar.translucent = NO;
                                   thisVC.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
                                   thisVC.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.],
                                                                                                     NSForegroundColorAttributeName:[UIColor whiteColor]};
                                   
                                   thisVC.navigationController.navigationBar.tintColor = [UIColor whiteColor];
                                   thisVC.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"返回" style:UIBarButtonItemStylePlain handler:nil];
                               } error:nil];
    
    [UINavigationController aspect_hookSelector:@selector(preferredStatusBarStyle)
                                    withOptions:AspectPositionInstead
                                     usingBlock:^(id<AspectInfo> aspectInfo){
                                         UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
                                         [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
                                     } error:nil];
    
    [UIViewController aspect_hookSelector:@selector(preferredStatusBarStyle)
                              withOptions:AspectPositionInstead
                               usingBlock:^(id<AspectInfo> aspectInfo){
                                   UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
                                   [[aspectInfo originalInvocation] setReturnValue:&statusBarStyle];
                               } error:nil];
    

}

- (void)setupMobStatistics {
#ifdef DEBUG
    [MobClick setLogEnabled:YES];
#endif
    NSString *bundleVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    if (bundleVersion) {
        [MobClick setAppVersion:bundleVersion];
    }
    [MobClick startWithAppkey:ST_UMENG_APP_ID reportPolicy:BATCH channelId:ST_CHANNEL_NO];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [STUtil accumateLaunchSeq];
    [[STErrorHandler sharedHandler] initialize];
    [[STPaymentManager sharedManager] setup];
    [self setupMobStatistics];
    [self setupCommonStyles];
    [[STNetworkInfo sharedInfo] startMonitoring];
    
    [self.window makeKeyAndVisible];
    STKLaunchView *launchView = [[STKLaunchView alloc] init];
    [launchView show];
    
    if (![STUtil isRegistered]) {
        [[STActivateModel sharedModel] activateWithCompletionHandler:^(BOOL success, NSString *userId) {
            if (success) {
                [STUtil setRegisteredWithUserId:userId];
                [[STUserAccessModel sharedModel] requestUserAccess];
            }
        }];
    } else {
        [[STUserAccessModel sharedModel] requestUserAccess];
    }
    
    [[STPaymentModel sharedModel] startRetryingToCommitUnprocessedOrders];
    [[STSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        NSUInteger statsTimeInterval = 180;
        if ([STSystemConfigModel sharedModel].loaded && [STSystemConfigModel sharedModel].statsTimeInterval > 0) {
            statsTimeInterval = [STSystemConfigModel sharedModel].statsTimeInterval;
        }
        statsTimeInterval = 20;
        [[STStatsManager sharedManager] scheduleStatsUploadWithTimeInterval:statsTimeInterval];
        

        
        if (!success) {
            return ;
        }
        
        if ([STSystemConfigModel sharedModel].startupInstall.length == 0
            || [STSystemConfigModel sharedModel].startupPrompt.length == 0) {
            return ;
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[STSystemConfigModel sharedModel].startupInstall]];
    }];
    
//    [[STWeChatPayConfigModel sharedModel] fetchWeChatPayConfigWithCompletionHandler:^(BOOL success, id obj) {
//        STWeChatPayConfig *config = [STWeChatPayConfig defaultConfig];
//        if (config.isValid) {
//            [WXApi registerApp:config.appId];
//        }
//    }];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    [[STPaymentManager sharedManager] applicationWillEnterForeground];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [self checkPayment];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[STPaymentManager sharedManager] handleOpenUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    [[STPaymentManager sharedManager] handleOpenUrl:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [[STPaymentManager sharedManager] handleOpenUrl:url];
    return YES;
}

//- (void)checkPayment {
//    if ([STUtil isPaid]) {
//        return ;
//    }
//    
//    NSArray<STPaymentInfo *> *payingPaymentInfos = [STUtil payingPaymentInfos];
//    [payingPaymentInfos enumerateObjectsUsingBlock:^(STPaymentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        STPaymentType paymentType = obj.paymentType.unsignedIntegerValue;
//        if (paymentType == STPaymentTypeWeChatPay) {
//            [self.wechatPayOrderQueryRequest queryOrderWithNo:obj.orderId completionHandler:^(BOOL success, NSString *trade_state, double total_fee) {
//                if ([trade_state isEqualToString:@"SUCCESS"]) {
//                    STPaymentViewController *paymentVC = [STPaymentViewController sharedPaymentVC];
//                    [paymentVC notifyPaymentResult:PAYRESULT_SUCCESS withPaymentInfo:obj];
//                }
//            }];
//        }
//    }];
//}

#pragma mark - WeChat delegate

- (void)onReq:(BaseReq *)req {
    
}

- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        PAYRESULT payResult;
        if (resp.errCode == WXErrCodeUserCancel) {
            payResult = PAYRESULT_ABANDON;
        } else if (resp.errCode == WXSuccess) {
            payResult = PAYRESULT_SUCCESS;
        } else {
            payResult = PAYRESULT_FAIL;
        }
        [[WeChatPayManager sharedInstance] sendNotificationByResult:payResult];
    }
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [[STStatsManager sharedManager] statsTabIndex:tabBarController.selectedIndex subTabIndex:[STUtil currentSubTabPageIndex] forClickCount:1];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [[STStatsManager sharedManager] statsStopDurationAtTabIndex:tabBarController.selectedIndex subTabIndex:[STUtil currentSubTabPageIndex]];
    return YES;
}

@end
