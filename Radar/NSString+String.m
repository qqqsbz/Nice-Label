//
//  NSString+String.m
//  Radar
//
//  Created by coder on 15/9/8.
//  Copyright (c) 2015年 coder. All rights reserved.
//

#import "NSString+String.h"
@implementation NSString (String)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dic = @{NSFontAttributeName:font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
}
@end
