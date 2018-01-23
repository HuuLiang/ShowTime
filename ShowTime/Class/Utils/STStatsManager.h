//
//  STStatsManager.h
//  STuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STStatsPayAction) {
    STStatsPayActionUnknown,
    STStatsPayActionClose,
    STStatsPayActionGoToPay,
    STStatsPayActionPayBack
};

@class STStatsInfo;
@class STChannel;
@interface STStatsManager : NSObject

+ (instancetype)sharedManager;

- (void)addStats:(STStatsInfo *)statsInfo;
- (void)removeStats:(NSArray<STStatsInfo *> *)statsInfos;
- (void)scheduleStatsUploadWithTimeInterval:(NSTimeInterval)timeInterval;

// Helper Methods
- (void)statsCPCWithChannel:(STChannel *)channel inTabIndex:(NSUInteger)tabIndex;
- (void)statsCPCWithProgram:(STProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(STChannel *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex;

- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forClickCount:(NSUInteger)clickCount;
- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forSlideCount:(NSUInteger)slideCount;
- (void)statsTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex forBanner:(NSNumber *)bannerColumnId withSlideCount:(NSUInteger)slideCount;
- (void)statsStopDurationAtTabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex;

- (void)statsPayWithOrderNo:(NSString *)orderNo
                  payAction:(STStatsPayAction)payAction
                  payResult:(NSInteger)payResult
                 forProgram:(STProgram *)program
            programLocation:(NSUInteger)programLocation
                  inChannel:(STChannel *)channel
                andTabIndex:(NSUInteger)tabIndex
                subTabIndex:(NSUInteger)subTabIndex;

- (void)statsPayWithPaymentInfo:(STPaymentInfo *)paymentInfo
                   forPayAction:(STStatsPayAction)payAction
                    andTabIndex:(NSUInteger)tabIndex
                    subTabIndex:(NSUInteger)subTabIndex;

@end
