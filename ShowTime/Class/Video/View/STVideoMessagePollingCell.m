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
        _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
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
        //        _titleLabel.bounds = self.bounds;
        [self.contentView addSubview:_titleLabel];
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                //                make.centerY.equalTo(self);
                //                make.top.bottom.equalTo(self.contentView).offset(-8);
                make.left.mas_equalTo(self).mas_offset(15);
                make.right.mas_equalTo(self).mas_offset(-12);
                make.bottom.equalTo(self.contentView).offset(-2.5);
                make.top.equalTo(self);
                //                make.height.equalTo(@(rect.size.height));
            }];
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    totalHeight += [self.titleLabel sizeThatFits:size].height;
    totalHeight += 6.5;
    return CGSizeMake(size.width, totalHeight);
}
@end
