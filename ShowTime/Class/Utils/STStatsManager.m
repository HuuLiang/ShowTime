//
//  STStatsManager.m
//  STuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STStatsManager.h"
#import "STCPCStatsModel.h"
#import "STTabStatsModel.h"
#import "STPayStatsModel.h"
#import "STPaymentInfo.h"
#import "MobClick.h"

static NSString *const kUmengCPCChannelEvent = @"CPC_CHANNEL";
static NSString *const kUmengCPCProgramEvent = @"CPC_PROGRAM";
static NSString *const kUmengTabEvent = @"TAB_STATS";
static NSString *const kUmengPayEvent = @"PAY_STATS";

@interface STStatsManager ()
@property (nonatomic,retain) dispatch_queue_t queue;
@property (nonatomic,retain,readonly) STCPCStatsModel *cpcStats;
@property (nonatomic,retain,readonly) STTabStatsModel *tabStats;
@property (nonatomic,retain,readonly) STPayStatsModel *payStats;
@property (nonatomic,retain,readonly) NSDate *statsDate;
@end

@implementation STStatsManager
@synthesize cpcStats = _cpcStats;
@synthesize tabStats = _tabStats;
@synthesize payStats = _payStats;

DefineLazyPropertyInitialization(STCPCStatsModel, cpcStats)
DefineLazyPropertyInitialization(STTabStatsModel, tabStats)
DefineLazyPropertyInitialization(STPayStatsModel, payStats)

- (dispatch_queue_t)queue {
    if (_queue) {
        return _queue;
    }
    
    _queue = dispatch_queue_create("com.STuaibo.app.statsq", nil);
    return _queue;
}

+ (instancetype)sharedManager {
    static STStatsManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _statsDate = [NSDate date];
    }
    return self;
}

- (void)addStats:(STStatsInfo *)statsInfo {
    dispatch_async(self.queue, ^{
        [statsInfo save];
    });
}

- (void)removeStats:(NSArray<STStatsInfo *> *)statsInfos {
    dispatch_async(self.queue, ^{
        [STStatsInfo removeStatsInfos:statsInfos];
    });
}

- (void)scheduleStatsUploadWithTimeInterval:(NSTimeInterval)timeInterval {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        while (1) {
            dispatch_async(self.queue, ^{
                [self uploadStatsInfos:[STStatsInfo allStatsInfos]];
            });
            sleep(timeInterval);
        }
    });
}

- (void)uploadStatsInfos:(NSArray<STStatsInfo *> *)statsInfos {
    if (statsInfos.count == 0) {
        return ;
    }
    
    NSArray<STStatsInfo *> *cpcStats = [statsInfos bk_select:^BOOL(STStatsInfo *statsInfo) {
        return statsInfo.statsType.unsignedIntegerValue == STStatsTypeColumnCPC
        || statsInfo.statsType.unsignedIntegerValue == STStatsTypeProgramCPC;
    }];
    
    NSArray<STStatsInfo *> *tabStats = [statsInfos bk_select:^BOOL(STStatsInfo *statsInfo) {
        return statsInfo.statsType.unsignedIntegerValue == STStatsTypeTabCPC
        || statsInfo.statsType.unsignedIntegerValue == STStatsTypeTabPanning
        || statsInfo.statsType.unsignedIntegerValue == STStatsTypeTabStay
        || statsInfo.statsType.unsignedIntegerValue == STStatsTypeBannerPanning;
    }];
    
    NSArray<STStatsInfo *> *payStats = [statsInfos bk_select:^BOOL(STStatsInfo *statsInfo) {
        return statsInfo.statsType.unsignedIntegerValue == STStatsTypePay;
    }];
    
    if (cpcStats.count > 0) {
        DLog(@"Commit CPC stats...");
        [self.cpcStats statsCPCWithStatsInfos:cpcStats completionHandler:^(BOOL success, id obj) {
            if (success) {
                [STStatsInfo removeStatsInfos:cpcStats];
                DLog(@"Commit CPC stats successfully!");
            } else {
                DLog(@"Commit CPC stats with failure: %@", obj);
            }
        }];
    }
    
    if (tabStats.count > 0) {
        DLog(@"Commit TAB stats...");
        [self.tabStats statsTabWithStatsInfos:tabStats completionHandler:^(BOOL success, id obj) {
            if (success) {
                [STStatsInfo removeStatsInfos:tabStats];
                DLog(@"Commit TAB stats successfully");
            } else {
                DLog(@"Commint TAB stats with failure: %@", obj);
            }
        }];
    }
    
    if (payStats.count > 0) {
        DLog(@"Commit PAY stats...");
        [self.payStats statsPayWithStatsInfos:payStats completionHandler:^(BOOL success, id obj) {
            if (success) {
                [STStatsInfo removeStatsInfos:payStats];
                DLog(@"Commit PAY stats successfully!");
            } else {
                DLog(@"Commit PAY stats with failure: %@", obj);
            }
        }];
    }
}

- (void)statsCPCWithChannel:(STChannel *)channel inTabIndex:(NSUInteger)tabIndex {
    STStatsInfo *statsInfo = [[STStatsInfo alloc] init];
    statsInfo.tabpageId = @(tabIndex+1);
    statsInfo.columnId = channel.realColumnId;
    statsInfo.columnType = channel.type;
    statsInfo.statsType = @(STStatsTypeColumnCPC);
    [self addStats:statsInfo];
    
    [MobClick event:kUmengCPCChannelEvent attributes:[statsInfo umengAttributes]];
}

- (void)statsCPCWithProgram:(STProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(STChannel *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex
{
    STStatsInfo *statsInfo = [[STStatsInfo alloc] init];
    if (channel) {
        statsInfo.columnId = channel.realColumnId;
        statsInfo.columnType = channel.type;
    }
    statsInfo.tabpageId = @(tabIndex+1);
    if (subTabIndex != NSNotFound) {
        statsInfo.subTabpageId = @(subTabIndex+1);
    }
    
    statsInfo.programId = program.programId;
    statsInfo.programType = program.type;
    statsInfo.programLocation = @(programLocation+1);
    statsInfo.statsType = @(STStatsTypeProgramCPC);
    [self addStats:statsInfo];
    
    [MobClick event:kUmengCPCProgramEvent attributes:statsInfo.umengAttributes];
}

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forClickCount:(NSUInteger)clickCount {
    dispatch_async(self.queue, ^{
        NSArray<STStatsInfo *> *statsInfos = [STStatsInfo statsInfosWithStatsType:STStatsTypeTabCPC tabIndex:tabIndex subTabIndex:subTabIndex];
        STStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[STStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex+1);
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex+1);
            }
            statsInfo.statsType = @(STStatsTypeTabCPC);
        }
        
        statsInfo.clickCount = @(statsInfo.clickCount.unsignedIntegerValue + clickCount);
        [statsInfo save];
        
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forSlideCount:(NSUInteger)slideCount {
    dispatch_async(self.queue, ^{
        NSArray<STStatsInfo *> *statsInfos = [STStatsInfo statsInfosWithStatsType:STStatsTypeTabPanning tabIndex:tabIndex subTabIndex:subTabIndex];
        STStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[STStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex+1);
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex+1);
            }
            statsInfo.statsType = @(STStatsTypeTabPanning);
        }
        
        statsInfo.slideCount = @(statsInfo.slideCount.unsignedIntegerValue + slideCount);
        [statsInfo save];
        
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsStopDurationAtTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex {
    dispatch_async(self.queue, ^{
        NSArray<STStatsInfo *> *statsInfos = [STStatsInfo statsInfosWithStatsType:STStatsTypeTabStay tabIndex:tabIndex subTabIndex:subTabIndex];
        STStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[STStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex+1);
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex+1);
            }
            statsInfo.statsType = @(STStatsTypeTabStay);
        }
        
        NSUInteger durationSinceStats = [[NSDate date] timeIntervalSinceDate:self.statsDate];
        statsInfo.stopDuration = @(statsInfo.stopDuration.unsignedIntegerValue + durationSinceStats);
        [statsInfo save];
        
        [self resetStatsDate];
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forBanner:(NSNumber *)bannerColumnId withSlideCount:(NSUInteger)slideCount {
    dispatch_async(self.queue, ^{
        NSArray<STStatsInfo *> *statsInfos = [STStatsInfo statsInfosWithStatsType:STStatsTypeBannerPanning tabIndex:tabIndex subTabIndex:subTabIndex];
        STStatsInfo *statsInfo = statsInfos.firstObject;
        if (!statsInfo) {
            statsInfo = [[STStatsInfo alloc] init];
            statsInfo.tabpageId = @(tabIndex+1);
            statsInfo.statsType = @(STStatsTypeBannerPanning);
            statsInfo.columnId = bannerColumnId;
            if (subTabIndex != NSNotFound) {
                statsInfo.subTabpageId = @(subTabIndex+1);
            }
        }
        
        statsInfo.slideCount = @(statsInfo.slideCount.unsignedIntegerValue + slideCount);
        [statsInfo save];
        
        [MobClick event:kUmengTabEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)resetStatsDate {
    _statsDate = [NSDate date];
}

- (void)statsPayWithOrderNo:(NSString *)orderNo
                  payAction:(STStatsPayAction)payAction
                  payResult:(NSInteger)payResult
                 forProgram:(STProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(STChannel *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex
{
    dispatch_async(self.queue, ^{
        STStatsInfo *statsInfo = [[STStatsInfo alloc] init];
        statsInfo.tabpageId = @(tabIndex+1);
        if (subTabIndex != NSNotFound) {
            statsInfo.subTabpageId = @(subTabIndex+1);
        }
        statsInfo.columnId = channel.realColumnId;
        statsInfo.columnType = channel.type;
        statsInfo.programId = program.programId;
        statsInfo.programType = program.type;
        statsInfo.programLocation = @(programLocation+1);
        statsInfo.isPayPopup = @(1);
        statsInfo.orderNo = orderNo;
        if (payAction == STStatsPayActionClose) {
            statsInfo.isPayPopupClose = @(1);
        } else if (payAction == STStatsPayActionGoToPay) {
            statsInfo.isPayConfirm = @(1);
        } else if (payAction == STStatsPayActionPayBack) {
            NSDictionary *payStautsMapping = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(2), @(PAYRESULT_ABANDON):@(3)};
            NSNumber *payStatus = payStautsMapping[@(payResult)];
            statsInfo.payStatus = payStatus;
        } else {
            return ;
        }
        
        statsInfo.paySeq = @([STUtil launchSeq]);
        statsInfo.statsType = @(STStatsTypePay);
        statsInfo.network = @([STNetworkInfo sharedInfo].networkStatus);
        [statsInfo save];
        
        [MobClick event:kUmengPayEvent attributes:statsInfo.umengAttributes];
    });
}

- (void)statsPayWithPaymentInfo:(STPaymentInfo *)paymentInfo
                   forPayAction:(STStatsPayAction)payAction
                    andTabIndex:(NSUInteger)tabIndex
                    subTabIndex:(NSUInteger)subTabIndex
{
    dispatch_async(self.queue, ^{
        STStatsInfo *statsInfo = [[STStatsInfo alloc] init];
        statsInfo.tabpageId = @(tabIndex+1);
        if (subTabIndex != NSNotFound) {
            statsInfo.subTabpageId = @(subTabIndex+1);
        }
        statsInfo.columnId = paymentInfo.columnId;
        statsInfo.columnType = paymentInfo.columnType;
        statsInfo.programId = paymentInfo.contentId;
        statsInfo.programType = paymentInfo.contentType;
        statsInfo.programLocation = paymentInfo.contentLocation;
        statsInfo.isPayPopup = @(1);
        statsInfo.orderNo = paymentInfo.orderId;
        if (payAction == STStatsPayActionClose) {
            statsInfo.isPayPopupClose = @(1);
        } else if (payAction == STStatsPayActionGoToPay) {
            statsInfo.isPayConfirm = @(1);
        } else if (payAction == STStatsPayActionPayBack) {
            NSDictionary *payStautsMapping = @{@(PAYRESULT_SUCCESS):@(1), @(PAYRESULT_FAIL):@(2), @(PAYRESULT_ABANDON):@(3)};
            NSNumber *payStatus = payStautsMapping[paymentInfo.paymentResult];
            statsInfo.payStatus = payStatus;
        } else {
            return ;
        }
    
        statsInfo.paySeq = @([STUtil launchSeq]);
        statsInfo.statsType = @(STStatsTypePay);
        statsInfo.network = @([STNetworkInfo sharedInfo].networkStatus);
        [statsInfo save];
        
        [MobClick event:kUmengPayEvent attributes:statsInfo.umengAttributes];
    });
}

@end
