//
//  NiceLabel.h
//  Radar
//
//  Created by coder on 15/9/8.
//  Copyright (c) 2015年 coder. All rights reserved.
//           

#import <UIKit/UIKit.h>

typedef enum {
    NiceLabelStateLeft,
    NiceLabelStateRight
} NiceLabelState;

@class NiceLabel;
@protocol NiceLableDelegate <NSObject>

- (void)didLongPressWithNiceLabel:(NiceLabel *)niceLable;

@end

@interface NiceLabel : UIView

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor  *textColor;
@property (strong, nonatomic) UIFont   *textFont;
@property (strong, nonatomic) UIImage  *image;
@property (weak,   nonatomic) id<NiceLableDelegate> delegate;

@end
