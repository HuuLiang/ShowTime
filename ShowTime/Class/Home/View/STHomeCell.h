//
//  STHomeCell.h
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STHomeCell : UICollectionViewCell

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *title;
@property (nonatomic) NSUInteger numberOfGuests;
@property (nonatomic) BOOL showFooter;
@property (nonatomic,getter=isShowTrival) BOOL showTrival;

@end
