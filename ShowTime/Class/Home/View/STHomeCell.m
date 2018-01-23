//
//  STHomeCell.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STHomeCell.h"
#import "STFootedView.h"

@interface STHomeCell ()
{
    STFootedView *_footedView;
    UIImageView *_trivalLabel;
}
@end

@implementation STHomeCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _footedView = [[STFootedView alloc] init];
        [self addSubview:_footedView];
        {
            [_footedView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        _trivalLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shibo"]];

        _trivalLabel.hidden = YES;
        [_footedView addSubview:_trivalLabel];
        {
        [_trivalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(_footedView).mas_offset(5);
            make.right.mas_equalTo(self);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(18);
        }];
        
        }
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = @"试播";
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont systemFontOfSize:12.];
        textLabel.textColor = [UIColor whiteColor];
        [_trivalLabel addSubview:textLabel];
        {
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_trivalLabel);
            make.left.mas_equalTo(_trivalLabel).mas_offset(5);
            make.right.mas_equalTo(_trivalLabel).mas_equalTo(-5);
            
        }];
        }
        
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    _footedView.imageURL = imageURL;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _footedView.title = title;
}

- (void)setNumberOfGuests:(NSUInteger)numberOfGuests {
    _numberOfGuests = numberOfGuests;
    _footedView.numberOfGuests = numberOfGuests;
}

- (BOOL)showFooter {
    return _footedView.showFooterBar;
}

- (void)setShowFooter:(BOOL)showFooter {
    _footedView.showFooterBar = showFooter;
}

- (void)setShowTrival:(BOOL)showTrival {
    _showTrival = showTrival;
    if (showTrival) {
        _trivalLabel.hidden = NO;
    }else {
        _trivalLabel.hidden = YES;
    }

}
@end
