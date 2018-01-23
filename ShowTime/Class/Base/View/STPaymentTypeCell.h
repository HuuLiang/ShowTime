//
//  STPaymentTypeCell.h
//  STuaibo
//
//  Created by Sean Yue on 16/7/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPaymentButton.h"

@class STPaymentButton;

@interface STPaymentTypeCell : UICollectionViewCell

@property (nonatomic,retain,readonly) STPaymentButton *paymentButton;
@property (nonatomic,copy) STAction paymentAction;

@end
