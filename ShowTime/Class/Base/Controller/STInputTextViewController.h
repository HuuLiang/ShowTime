//
//  STInputTextViewController.h
//  YuePaoBa
//
//  Created by Sean Yue on 15/12/24.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "STBaseViewController.h"

typedef BOOL (^STInputTextCompletionHandler)(id sender, NSString *text);
typedef BOOL (^STInputTextChangeHandler)(id sender, NSString *text);

@interface STInputTextViewController : STBaseViewController

@property (nonatomic) NSUInteger limitedTextLength;
@property (nonatomic) NSString *placeholder;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *completeButtonTitle;

@property (nonatomic,copy) STInputTextCompletionHandler completionHandler;
@property (nonatomic,copy) STInputTextChangeHandler changeHandler;

@end
