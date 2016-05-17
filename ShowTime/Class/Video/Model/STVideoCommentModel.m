//
//  STVideoCommentModel.m
//  ShowTime
//
//  Created by yang on 16/5/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STVideoCommentModel.h"

@implementation STCommentResponse

- (Class)commentListElementClass {
    return [STComment class];
}
@end

@implementation STVideoCommentModel

+ (Class)responseClass {
    return [STCommentResponse class];
}
+ (BOOL)shouldPersistURLResponse {
    return YES;
}


- (BOOL)fetchCommentWithCompletionHandler:(STCommentCompletionHandler)handler {
    
    @weakify(self);
    BOOL success = [self requestURLPath:ST_COMMENT_URL withParams:nil responseHandler:^(STURLResponseStatus respStatus, NSString *errorMessage) {
        @strongify(self);
        if (!self) {
            return ;
        }
        NSArray *commentArr = [NSMutableArray array];
        if (respStatus == STURLResponseSuccess) {
            STCommentResponse *resp = (STCommentResponse *)self.response;
            commentArr = resp.commentList;
            self->_contentList = commentArr;

        }
        
        if (handler) {
            handler(respStatus == STURLResponseSuccess,commentArr);
        }
    }];
    
    return success;
}


@end
