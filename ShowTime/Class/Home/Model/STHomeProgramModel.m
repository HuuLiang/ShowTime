//
//  STHomeProgramModel.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/5.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STHomeProgramModel.h"

@implementation STHomeProgramResponse

- (Class)columnListElementClass {
    return [STChannel class];
}

@end

@implementation STHomeProgramModel

+ (Class)responseClass {
    return [STHomeProgramResponse class];
}

+ (BOOL)shouldPersistURLResponse {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        STHomeProgramResponse *resp = (STHomeProgramResponse *)self.response;
        _fetchedProgramList = resp.columnList;
        
        [self filterProgramTypes];
    }
    return self;
}

- (BOOL)fetchHomeProgramsWithCompletionHandler:(STFetchHomeProgramsCompletionHandler)handler {
    @weakify(self);
    BOOL success = [self requestURLPath:ST_HOME_PAGE_URL
                         //standbyURLPath:KB_STANDBY_HOME_PAGE_URL
                             withParams:nil
                        responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
    {
        @strongify(self);
        
        if (!self) {
            return ;
        }
        
        NSArray *programs;
        if (respStatus == STURLResponseSuccess) {
            STHomeProgramResponse *resp = (STHomeProgramResponse *)self.response;
            programs = resp.columnList;
            self->_fetchedProgramList = programs;
            
            [self filterProgramTypes];
        }
        
        if (handler) {
            handler(respStatus==STURLResponseSuccess, programs);
        }
    }];
    return success;
}

- (void)filterProgramTypes {
    _fetchedVideoAndAdProgramList = [self.fetchedProgramList bk_select:^BOOL(id obj)
                                           {
                                               STProgramType type = ((STChannel *)obj).type.unsignedIntegerValue;
                                               return type == STProgramTypeVideo || type == STProgramTypeAd || type == STProgramTypeTrival;
                                           }];
    
    NSArray<STChannel *> *bannerProgramList = [self.fetchedProgramList bk_select:^BOOL(id obj)
                                                {
                                                    STProgramType type = ((STChannel *)obj).type.unsignedIntegerValue;
                                                    return type == STProgramTypeBanner;
                                                }];
    
    NSMutableArray *bannerPrograms = [NSMutableArray array];
    [bannerProgramList enumerateObjectsUsingBlock:^(STChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.programList.count > 0) {
            [bannerPrograms addObjectsFromArray:obj.programList];
        }
    }];
    _fetchedBannerPrograms = bannerPrograms;
}
@end
