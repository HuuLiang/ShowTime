//
//  STVideoMessagePollingCell.m
//  YuePaoBa
//
//  Created by Sean Yue on 16/2/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "STVideoMessagePollingCell.h"

@interface STVideoMessagePollingCell ()

@end

@implementation STVideoMessagePollingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
//                _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _titleLabel.layer.cornerRadius = _titleLabel.font.pointSize/2;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.attributedText = nil;
        
        [_titleLabel aspect_hookSelector:@selector(textRectForBounds:limitedToNumberOfLines:)
                             withOptions:AspectPositionInstead
                              usingBlock:^(id<AspectInfo> aspectInfo,
                                           CGRect bounds,
                                           NSInteger numberOfLines)
         {
             CGRect textRect;
             [[aspectInfo originalInvocation] invoke];
             [[aspectInfo originalInvocation] getReturnValue:&textRect];
             
             textRect = CGRectMake(textRect.origin.x, textRect.origin.y, textRect.size.width+10, textRect.size.height);
             [[aspectInfo originalInvocation] setReturnValue:&textRect];
         } error:nil];
        [self addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
//                make.top.bottom.equalTo(self.contentView).offset(-8);
                make.left.equalTo(self).offset(15);
                make.right.lessThanOrEqualTo(self);
                make.bottom.equalTo(self).offset(0);
                make.top.equalTo(self).offset(0);
//                make.height.equalTo(@(rect.size.height));
            }];
        }
        
//        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.top.equalTo(self);
//            make.bottom.equalTo(_titleLabel.mas_bottom).offset(48);
//        }];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
@end
