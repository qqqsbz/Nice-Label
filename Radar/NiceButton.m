//
//  NiceButton.m
//  Radar
//
//  Created by coder on 15/9/8.
//  Copyright (c) 2015年 coder. All rights reserved.
//

#import "NiceButton.h"

@implementation NiceButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.imageView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.textLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *dic = NSDictionaryOfVariableBindings(_imageView,_textLabel);
    NSArray *vlfs = @[
                      @"H:|-0-[_imageView]-0-|",
                      @"H:|-0-[_textLabel]-0-|",
                      @"V:|-0-[_imageView]-5-[_textLabel]-0-|"
                      ];
    for (NSString *vlf in vlfs) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vlf options:0 metrics:nil views:dic]];
    }
}

@end
