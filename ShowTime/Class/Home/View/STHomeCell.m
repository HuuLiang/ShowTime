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
@end
