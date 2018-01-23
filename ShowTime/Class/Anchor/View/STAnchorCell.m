//
//  STAnchorCell.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STAnchorCell.h"
#import "STFootedView.h"

@interface STAnchorCell ()
{
    STFootedView *_footedView;
}
@end

@implementation STAnchorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
@end
