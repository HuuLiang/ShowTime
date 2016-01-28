//
//  STFootedView.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STFootedView.h"

@interface STFootedView ()
{
    UIImageView *_thumbImageView;
    
    UIView *_footerView;
    UILabel *_titleLabel;
    UILabel *_guestsLabel;
    UIImageView *_guestsThumb;
}
@end

@implementation STFootedView

- (instancetype)init {
    self = [super init];
    if (self) {
        _showFooterBar = YES;
        
        _thumbImageView = [[UIImageView alloc] init];
        [self addSubview:_thumbImageView];
        
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_footerView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.];
        [_footerView addSubview:_titleLabel];
        
        _guestsThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_guest"]];
        [_footerView addSubview:_guestsThumb];
        
        _guestsLabel = [[UILabel alloc] init];
        _guestsLabel.font = [UIFont systemFontOfSize:12.];
        _guestsLabel.text = @"0";
        _guestsLabel.textColor = [UIColor grayColor];
        [_footerView addSubview:_guestsLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _thumbImageView.frame = self.bounds;
    
    const CGFloat footerHeight = MIN(self.bounds.size.height * 0.2, 30);
    const CGFloat footerWidth = self.bounds.size.width;
    const CGFloat footerY = self.bounds.size.height - footerHeight;
    _footerView.frame = CGRectMake(0, footerY, footerWidth, footerHeight);
    
    [_guestsLabel sizeToFit];
    const CGFloat guestX = footerWidth - 5 - _guestsLabel.bounds.size.width;
    const CGFloat guestY = (footerHeight - _guestsLabel.bounds.size.height) / 2;
    _guestsLabel.frame = CGRectMake(guestX, guestY, _guestsLabel.bounds.size.width, _guestsLabel.bounds.size.height);
    
    const CGFloat thumbWidth = 14.5;
    const CGFloat thumbHeight = 11;
    const CGFloat thumbX = guestX - 2 - thumbWidth;
    const CGFloat thumbY = (footerHeight - thumbHeight) / 2;
    _guestsThumb.frame = CGRectMake(thumbX, thumbY, thumbWidth, thumbHeight);
    
    [_titleLabel sizeToFit];
    const CGFloat titleHeight = _titleLabel.bounds.size.height;
    const CGFloat titleWidth = thumbX - 10;
    const CGFloat titleX = 5;
    const CGFloat titleY = (footerHeight - titleHeight) / 2;
    _titleLabel.frame = CGRectMake(titleX, titleY, titleWidth, titleHeight);
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [_thumbImageView sd_setImageWithURL:imageURL];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setNumberOfGuests:(NSUInteger)numberOfGuests {
    _numberOfGuests = numberOfGuests;
    if (numberOfGuests > 10000) {
        _guestsLabel.text = @"10000+";
    } else {
        _guestsLabel.text = @(numberOfGuests).stringValue;
    }
    
    [self setNeedsLayout];
}

- (void)setShowFooterBar:(BOOL)showFooterBar {
    _showFooterBar = showFooterBar;
    _footerView.hidden = !showFooterBar;
}
@end
