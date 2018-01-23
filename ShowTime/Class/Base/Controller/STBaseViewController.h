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

- (NSUInteger)currentIndex;

//- (void)switchToPlayProgram:(STProgram *)program;
//- (void)switchToPlayProgram:(STProgram *)program isTrival:(BOOL)isTrival;
//- (void)payForProgram:(STProgram *)program;
- (void)switchToPlayProgram:(STProgram *)program isTrival:(BOOL)isTrival
            programLocation:(NSUInteger)programLocation
                  inChannel:(STChannel *)channel;

- (void)payForProgram:(STProgram *)program programLocation:(NSUInteger)programLocation
            inChannel:(STChannel *)channel;

//- (void)playVideo:(STProgram *)video withTimeControl:(BOOL)hasTimeControl shouldPopPayment:(BOOL)shouldPopPayment;
//- (void)play

@end
