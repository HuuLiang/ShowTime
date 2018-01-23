//
//  STHomeCollectionHeaderView.m
//  ShowTime
//
//  Created by Sean Yue on 16/1/25.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STHomeCollectionHeaderView.h"

@interface STHomeCollectionHeaderView ()
{
    UIImageView *_tagImageView;
    UILabel *_titleLabel;
}
@end

@implementation STHomeCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor = [UIColor lightGrayColor];//colorWithHexString:@"#5c4a50"];
        [self addSubview:separator];
        {
            [separator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self);
                make.height.mas_equalTo(0.5);
            }];
        }
        
        _tagImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_section_tag"]];
        [self addSubview:_tagImageView];
        {
            [_tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self);
                make.left.equalTo(self).offset(5);
                make.height.equalTo(self);//.multipliedBy(0.8);
                make.width.equalTo(_tagImageView.mas_height).multipliedBy(145./43.);
            }];
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_tagImageView);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}
@end
