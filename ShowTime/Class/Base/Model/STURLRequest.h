//
//  STURLRequest.h
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STURLResponse.h"

typedef NS_ENUM(NSUInteger, STURLResponseStatus) {
    STURLResponseSuccess,
    STURLResponseFailedByInterface,
    STURLResponseFailedByNetwork,
    STURLResponseFailedByParsing,
    STURLResponseFailedByParameter,
    STURLResponseNone
};

typedef NS_ENUM(NSUInteger, STURLRequestMethod) {
    STURLGetRequest,
    STURLPostRequest
};
typedef void (^STURLResponseHandler)(STURLResponseStatus respStatus, NSString *errorMessage);

@interface STURLRequest : NSObject

@property (nonatomic,retain) id response;

+ (Class)responseClass;  // override this method to provide a custom class to be used when instantiating instances of STURLResponse
+ (BOOL)shouldPersistURLResponse;
- (NSURL *)baseURL; // override this method to provide a custom base URL to be used
- (NSURL *)standbyBaseURL; // override this method to provide a custom standby base URL to be used

- (BOOL)shouldPostErrorNotification;
- (STURLRequestMethod)requestMethod;

- (BOOL)requestURLPath:(NSString *)urlPath
            withParams:(NSDictionary *)params
             isStandby:(BOOL)isStandBy
     shouldNotifyError:(BOOL)shouldNotifyError
       responseHandler:(STURLResponseHandler)responseHandler;
- (BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(STURLResponseHandler)responseHandler;


//- (BOOL)requestURLPath:(NSString *)urlPath standbyURLPath:(NSString *)standbyUrlPath withParams:(NSDictionary *)params responseHandler:(STURLResponseHandler)responseHandler;

// For subclass pre/post processing response object
- (void)processResponseObject:(id)responseObject withResponseHandler:(STURLResponseHandler)responseHandler;

@end
