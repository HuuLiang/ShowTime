//
//  STBaseViewController.h
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STProgram;

@interface STBaseViewController : UIViewController

- (void)switchToPlayProgram:(STProgram *)program;
- (void)payForProgram:(STProgram *)program;

- (void)playVideo:(STProgram *)video withTimeControl:(BOOL)hasTimeControl shouldPopPayment:(BOOL)shouldPopPayment;
//- (void)play

@end
