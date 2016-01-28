//
//  STRocketBarrageView.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STRocketBarrageView.h"

static NSString *const kRocketAnimationKey = @"STRocketAnimationKey";
static const CGFloat kTitleOffset = 30;

@interface STRocketBarrageView ()
{
    UIImageView *_rocketIV;
    UILabel *_titleLabel;
}
@end

@implementation STRocketBarrageView

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImage *rocketImage = [UIImage animatedImageWithImages:@[[UIImage imageNamed:@"rocket_move1"], [UIImage imageNamed:@"rocket_move2"]] duration:0.5];
        _rocketIV = [[UIImageView alloc] initWithImage:rocketImage];
        [self addSubview:_rocketIV];
        {
            [_rocketIV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.centerY.equalTo(self);
                make.size.mas_equalTo(rocketImage.size);
            }];
        }
        
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.];
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.backgroundColor = [UIColor colorWithHexString:@"#fb8e4a"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.layer.anchorPoint = CGPointMake(0, 0.5);
        _titleLabel.layer.position = CGPointMake(CGRectGetMaxX(_rocketIV.frame)-kTitleOffset, CGRectGetHeight(_rocketIV.frame)/2);
        [self insertSubview:_titleLabel belowSubview:_rocketIV];
//        {
//            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(_rocketIV.mas_right);
//                make.centerY.equalTo(_rocketIV);
//                make.size.mas_equalTo(CGSizeMake(200, _titleLabel.layer.cornerRadius*2));
//            }];
//        }
        
        [_titleLabel aspect_hookSelector:@selector(textRectForBounds:limitedToNumberOfLines:)
                             withOptions:AspectPositionInstead
                              usingBlock:^(id<AspectInfo> aspectInfo, CGRect bounds, NSInteger numberOfLines)
        {
            CGRect textRect = CGRectMake(bounds.origin.x+kTitleOffset, bounds.origin.y, bounds.size.width, bounds.size.height);
            [[aspectInfo originalInvocation] setReturnValue:&textRect];
        } error:nil];
        self.layer.anchorPoint = CGPointMake(0, 0);
    }
    return self;
}

- (void)moveInView:(UIView *)view withTitle:(NSString *)title {
    _titleLabel.text = title;
    
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:_titleLabel.font}];
    _titleLabel.layer.bounds = CGRectMake(0, 0, titleSize.width + kTitleOffset, titleSize.height * 2);
    _titleLabel.layer.cornerRadius = CGRectGetHeight(_titleLabel.frame) / 2;
    self.layer.bounds = CGRectMake(0, 0, CGRectGetWidth(_rocketIV.frame)+CGRectGetWidth(_titleLabel.frame), CGRectGetHeight(_rocketIV.frame));
    
    [self.layer removeAllAnimations];
    if (![view.subviews containsObject:self]) {
        
        self.layer.position = CGPointMake(0, -CGRectGetHeight(self.layer.bounds));
        [view addSubview:self];
    }
    
    CGPoint orignalPosition = CGPointMake(CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)/4);
    self.layer.position = orignalPosition;
    [UIView animateWithDuration:5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.layer.position = CGPointMake(-CGRectGetWidth(self.layer.bounds), orignalPosition.y);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

@end
