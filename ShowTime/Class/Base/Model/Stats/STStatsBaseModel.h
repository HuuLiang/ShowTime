//
//  STStatsBaseModel.h
//  STuaibo
//
//  Created by Sean Yue on 16/4/29.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STEncryptedURLRequest.h"

typedef NS_ENUM(NSUInteger, STStatsType) {
    STStatsTypeUnknown,
    STStatsTypeColumnCPC,
    STStatsTypeProgramCPC,
    STStatsTypeTabCPC,
    STStatsTypeTabPanning,
    STStatsTypeTabStay,
    STStatsTypeBannerPanning,
    STStatsTypePay = 1000
};

typedef NS_ENUM(NSInteger, STStatsNetwork) {
    STStatsNetworkUnknown = 0,
    STStatsNetworkWifi = 1,
    STStatsNetwork2G = 2,
    STStatsNetwork3G = 3,
    STStatsNetwork4G = 4,
    STStatsNetworkOther = -1
};

@interface STStatsInfo : DBPersistence

// Unique ID
@property (nonatomic) NSNumber *statsId;

// System Info
@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *pv;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *osv;

// Tab/Column/Program
@property (nonatomic) NSNumber *tabpageId;
@property (nonatomic) NSNumber *subTabpageId;
@property (nonatomic) NSNumber *columnId;
@property (nonatomic) NSNumber *columnType;
@property (nonatomic) NSNumber *programId;
@property (nonatomic) NSNumber *programType;
@property (nonatomic) NSNumber *programLocation;
@property (nonatomic) NSNumber *statsType; //STStatsType

// Accumalation stats
@property (nonatomic) NSNumber *clickCount;
@property (nonatomic) NSNumber *slideCount;
@property (nonatomic) NSNumber *stopDuration;

// Payment
@property (nonatomic) NSNumber *isPayPopup;
@property (nonatomic) NSNumber *isPayPopupClose;
@property (nonatomic) NSNumber *isPayConfirm;
@property (nonatomic) NSNumber *payStatus;
@property (nonatomic) NSNumber *paySeq;
@property (nonatomic) NSString *orderNo;
@property (nonatomic) NSNumber *network; //STStatsNetwork
//
+ (NSArray<STStatsInfo *> *)allStatsInfos;
+ (NSArray<STStatsInfo *> *)statsInfosWithStatsType:(STStatsType)statsType;
+ (NSArray<STStatsInfo *> *)statsInfosWithStatsType:(STStatsType)statsType tabIndex:(NSUInteger)tabIndex subTabIndex:(NSUInteger)subTabIndex;
+ (void)removeStatsInfos:(NSArray<STStatsInfo *> *)statsInfos;

- (BOOL)save;
- (BOOL)removeFromDB;
- (NSDictionary *)RESTData;
- (NSDictionary *)umengAttributes;

@end

@interface STStatsResponse : STURLResponse
@property (nonatomic) NSNumber *errCode;
@end

@interface STStatsBaseModel : STEncryptedURLRequest

- (NSArray<NSDictionary *> *)validateParamsWithStatsInfos:(NSArray<STStatsInfo *> *)statsInfos;
- (NSArray<NSDictionary *> *)validateParamsWithStatsInfos:(NSArray<STStatsInfo *> *)statsInfos shouldIncludeStatsType:(BOOL)includeStatsType;

@end
