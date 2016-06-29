//
//  STURLRequest.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/3.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "STURLRequest.h"
#import <AFNetworking.h>

@interface STURLRequest ()
@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;
@property (nonatomic,retain) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic,retain) AFHTTPSessionManager *standbySessionManager;
@property (nonatomic,retain) NSURLSessionDataTask *standbySessionDataTask;

-(BOOL)requestURLPath:(NSString *)urlPath
           withParams:(NSDictionary *)params
            isStandby:(BOOL)isStandBy
    shouldNotifyError:(BOOL)shouldNotifyError
      responseHandler:(STURLResponseHandler)responseHandler;
@end

@implementation STURLRequest

+ (Class)responseClass {
    return [STURLResponse class];
}

+ (BOOL)shouldPersistURLResponse {
    return NO;
}

+ (NSString *)persistenceFilePath {
    NSString *fileName = NSStringFromClass([self responseClass]);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.plist", [NSBundle mainBundle].resourcePath, fileName];
    return filePath;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([[[self class] responseClass] isSubclassOfClass:[STURLResponse class]]) {
            NSDictionary *lastResponse = [NSDictionary dictionaryWithContentsOfFile:[[self class] persistenceFilePath]];
            if (lastResponse) {
                STURLResponse *urlResponse = [[[[self class] responseClass] alloc] init];
                [urlResponse parseResponseWithDictionary:lastResponse];
                self.response = urlResponse;
            }
        }
        
    }
    return self;
}

- (NSURL *)baseURL {
    return [NSURL URLWithString:ST_BASE_URL];
}

- (NSURL *)standbyBaseURL {
    return [NSURL URLWithString:ST_STANDBY_BASE_URL];
}

- (BOOL)shouldPostErrorNotification {
    return YES;
}

- (STURLRequestMethod)requestMethod {
    return STURLGetRequest;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL]];
    return _sessionManager;
}

- (AFHTTPSessionManager *)standbySessionManager {
    if (_standbySessionManager) {
        return _standbySessionManager;
    }
    
    _standbySessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self standbyBaseURL]];
    return _standbySessionManager;
}

-(BOOL)requestURLPath:(NSString *)urlPath
           withParams:(NSDictionary *)params
            isStandby:(BOOL)isStandBy
    shouldNotifyError:(BOOL)shouldNotifyError
      responseHandler:(STURLResponseHandler)responseHandler
{
    if (urlPath.length == 0) {
        if (responseHandler) {
            responseHandler(STURLResponseFailedByParameter, nil);
        }
        return NO;
    }
    
    DLog(@"Requesting %@ !\nwith parameters: %@\n", urlPath, params);
    
    @weakify(self);
    self.response = [[[[self class] responseClass] alloc] init];
    
    void (^success)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject) {
        @strongify(self);
        
        DLog(@"Response for %@ : %@\n", urlPath, responseObject);
        [self processResponseObject:responseObject withResponseHandler:responseHandler];
    };
    
    void (^failure)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        DLog(@"Error for %@ : %@\n", urlPath, error.localizedDescription);
        
        if (shouldNotifyError) {
            if ([self shouldPostErrorNotification]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkErrorNotification
                                                                    object:self
                                                                  userInfo:@{kNetworkErrorCodeKey:@(STURLResponseFailedByNetwork),
                                                                             kNetworkErrorMessageKey:error.localizedDescription}];
            }
        }
        
        if (responseHandler) {
            responseHandler(STURLResponseFailedByNetwork,error.localizedDescription);
        }
    };
    
    NSURLSessionDataTask *sessionDataTask;
    if (self.requestMethod == STURLGetRequest) {
        sessionDataTask = [isStandBy?self.standbySessionManager:self.sessionManager GET:urlPath parameters:params progress:nil success:success failure:failure];
    } else {
        sessionDataTask = [isStandBy?self.standbySessionManager:self.sessionManager POST:urlPath parameters:params progress:nil success:success failure:failure];
    }
    
    if (isStandBy) {
        self.standbySessionDataTask = sessionDataTask;
    } else {
        self.sessionDataTask = sessionDataTask;
    }
    return YES;
}

//- (BOOL)requestURLPath:(NSString *)urlPath standbyURLPath:(NSString *)standbyUrlPath withParams:(NSDictionary *)params responseHandler:(STURLResponseHandler)responseHandler {
//    BOOL useStandbyRequest = standbyUrlPath.length > 0;
//    BOOL success = [self requestURLPath:urlPath
//                             withParams:params
//                              isStandby:NO
//                      shouldNotifyError:!useStandbyRequest
//                        responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage)
//    {
//        if (useStandbyRequest && respStatus == STURLResponseFailedByNetwork) {
//            [self requestURLPath:standbyUrlPath withParams:params isStandby:YES shouldNotifyError:YES responseHandler:responseHandler];
//        } else {
//            if (responseHandler) {
//                responseHandler(respStatus,errorMessage);
//            }
//        }
//    }];
//    return success;
//}

-(BOOL)requestURLPath:(NSString *)urlPath withParams:(NSDictionary *)params responseHandler:(STURLResponseHandler)responseHandler
{
    return [self requestURLPath:urlPath withParams:params isStandby:NO shouldNotifyError:YES responseHandler:responseHandler];
    //return [self requestURLPath:urlPath standbyURLPath:nil withParams:params responseHandler:responseHandler];
}

- (void)processResponseObject:(id)responseObject withResponseHandler:(STURLResponseHandler)responseHandler {
    STURLResponseStatus status = STURLResponseNone;
    NSString *errorMessage;
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if ([self.response isKindOfClass:[STURLResponse class]]) {
            STURLResponse *urlResp = self.response;
            [urlResp parseResponseWithDictionary:responseObject];
            
            status = urlResp.success.boolValue ? STURLResponseSuccess : STURLResponseFailedByInterface;
            errorMessage = (status == STURLResponseSuccess) ? nil : [NSString stringWithFormat:@"ResultCode: %@", urlResp.resultCode];
        } else {
            status = STURLResponseFailedByParsing;
            errorMessage = @"Parsing error: incorrect response class for JSON dictionary.\n";
        }
        
        if ([[self class] shouldPersistURLResponse]) {
            NSString *filePath = [[self class] persistenceFilePath];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (![((NSDictionary *)responseObject) writeToFile:filePath atomically:YES]) {
                    DLog(@"Persist response object fails!");
                }
            });
        }
    } else if ([responseObject isKindOfClass:[NSString class]]) {
        if ([self.response isKindOfClass:[NSString class]]) {
            self.response = responseObject;
            status = STURLResponseSuccess;
        } else {
            status = STURLResponseFailedByParsing;
            errorMessage = @"Parsing error: incorrect response class for JSON string.\n";
        }
    } else {
        errorMessage = @"Error data structure of response from interface!\n";
        status = STURLResponseFailedByInterface;
    }
    
    if (status != STURLResponseSuccess) {
        DLog(@"Error message : %@\n", errorMessage);
        
        if ([self shouldPostErrorNotification]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkErrorNotification
                                                                object:self
                                                              userInfo:@{kNetworkErrorCodeKey:@(status),
                                                                         kNetworkErrorMessageKey:errorMessage}];
        }
    }
    
    if (responseHandler) {
        responseHandler(status, errorMessage);
    }

}
@end
