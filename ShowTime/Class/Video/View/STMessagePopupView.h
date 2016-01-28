//
//  STMessagePopupView.h
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMessagePopupView : UITableView

@property (nonatomic,copy) STAction selectAction;

- (void)showInView:(UIView *)view atLeftBottomPosition:(CGPoint)leftBottomPos width:(CGFloat)width;
- (void)hide;

@end
