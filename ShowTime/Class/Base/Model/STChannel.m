//
//  STChannel.m
//  ShowTime
//
//  Created by ylz on 16/6/28.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STChannel.h"

@implementation STChannel


- (Class)programListElementClass {
    return [STProgram class];
}
//- (BOOL)isEqual:(id)object {
//    if (![object isKindOfClass:[STChannel class]]) {
//        return NO;
//    }
//    
//    return [self.columnId isEqualToNumber:[object columnId]];
//}
//
//- (NSUInteger)hash {
//    return self.columnId.hash;
//}
//
//- (Class)programListElementClass {
//    return [STProgram class];
//}
//
//+ (NSString *)cryptPasswordForProperty:(NSString *)propertyName withInstance:(id)instance {
//    if ([instance class] == [STChannel class]) {
//        NSArray *cryptProperties = @[@"columnDesc",@"name",@"columnImg",@"spreadUrl"];
//        if ([cryptProperties containsObject:propertyName]) {
//            return kPersistenceCryptPassword;
//        }
//    } else if ([instance class] == [STProgram class]) {
//        NSArray *cryptProperties = @[@"videoUrl",@"coverImg",@"offUrl",@"title",@"specialDesc"];
//        if ([cryptProperties containsObject:propertyName]) {
//            return kPersistenceCryptPassword;
//        }
//    }
//    return nil;
//}

@end
