//
//  NiceLabel.m
//  Radar
//
//  Created by coder on 15/9/8.
//  Copyright (c) 2015年 coder. All rights reserved.
//
#define ImageViewWidth  15
#define ImageViewHeight 15
#define Distance        5
#import "NiceLabel.h"
@interface NiceLabel ()
{
    BOOL            isAperture;
    UIButton        *textButton;
    UIImageView     *imageView;
    NiceLabelState  state;
    
    NSMutableArray *shapeLayers;
}
@end

static NSString *kAnimatiomName = @"AnimationName";
static NSString *kGroupAnimation = @"GroupAnimation";
@implementation NiceLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    shapeLayers = [NSMutableArray array];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.bounds) / 2, ImageViewWidth, ImageViewHeight)];
    imageView.image = [UIImage imageNamed:@"location"];
    [self addSubview:imageView];
    
    CGFloat width = Distance + ImageViewWidth;
    textButton = [UIButton buttonWithType:UIButtonTypeCustom];
    textButton.frame = CGRectMake(width, 0, CGRectGetWidth(self.bounds) - width, CGRectGetHeight(self.bounds));
    textButton.layer.masksToBounds = YES;
    textButton.layer.cornerRadius  = 4.f;
    textButton.backgroundColor     = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
    textButton.userInteractionEnabled     = NO;
    textButton.titleLabel.textAlignment   = NSTextAlignmentCenter;
    [self addSubview:textButton];
    state = NiceLabelStateRight;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
}

#pragma mark -- Gesture Operation

//点击手势
- (void)tapAction:(UITapGestureRecognizer *)tapGesture
{
    [self ChangeDirection];
}

//拖动手势
- (void)panAction:(UIPanGestureRecognizer *)panGesture
{
    CGPoint point = [panGesture translationInView:self.superview];
    
    //计算可拖动区域
    CGFloat minXDValue = panGesture.view.center.x + point.x - CGRectGetWidth(self.frame) / 2;
    CGFloat maxXDValue = panGesture.view.center.x + point.x + CGRectGetWidth(self.frame) / 2;
    CGFloat minYDValue = panGesture.view.center.y + point.y - CGRectGetHeight(self.frame) / 2;
    CGFloat maxYDValue = panGesture.view.center.y + point.y - CGRectGetHeight(self.frame) / 2;
    
    CGFloat limitWidth  = CGRectGetWidth(self.superview.bounds);
    CGFloat limitHeight = CGRectGetHeight(self.superview.bounds) - 40;
    CGFloat limitX      = self.superview.frame.origin.x;
    CGFloat limitY      = self.superview.frame.origin.y;
    
    //在可拖动区域 允许拖动
    if ((minXDValue >= limitX && maxXDValue <= limitWidth) && (minYDValue >= limitY && maxYDValue <= limitHeight)) {
        panGesture.view.center = CGPointMake(panGesture.view.center.x + point.x, panGesture.view.center.y + point.y);
    }
    [panGesture setTranslation:CGPointMake(0, 0) inView:self.superview];
}

//长按手势
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress
{
    if ([self.delegate respondsToSelector:@selector(didLongPressWithNiceLabel:)]) {
        NiceLabel *niceLabel = (NiceLabel *)longPress.view;
        [self.delegate didLongPressWithNiceLabel:niceLabel];
    }
}

#pragma mark -- Edit Property
//设置text
- (void)setText:(NSString *)text
{
    _text = text;
    [textButton setTitle:_text forState:UIControlStateNormal];
    CGFloat screenWidth = CGRectGetWidth(self.superview.bounds);
    if (CGRectGetMaxX(self.frame) > screenWidth) {
        
        self.frame = CGRectMake(self.frame.origin.x - CGRectGetWidth(self.bounds) + Distance , self.frame.origin.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        
        textButton.frame = CGRectMake(0, textButton.frame.origin.y, CGRectGetWidth(textButton.frame), CGRectGetHeight(textButton.frame));
        imageView.frame  = CGRectMake(CGRectGetWidth(textButton.frame) + Distance, imageView.frame.origin.y, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
        
        state = NiceLabelStateLeft;
    }
    
    [self addAnimationDuration:0.7f beginTime:.5f];
}

//设置字体p
- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    textButton.titleLabel.font = _textFont;
}

//设置字体颜色
- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [textButton setTitleColor:_textColor forState:UIControlStateNormal];
}

//设置标签的图标
- (void)setImage:(UIImage *)image
{
    _image = image;
    imageView.image = _image;
}

#pragma mark -- Commom Method
//修改方向
- (void)ChangeDirection
{
    if (state == NiceLabelStateRight) {
        
        CGFloat Dvalue = CGRectGetMaxX(self.frame) - CGRectGetWidth(self.bounds);
        if (Dvalue >= CGRectGetWidth(self.bounds) - ImageViewWidth) {
            
            [self stopAnimation];
            
            CGFloat moveX   = Dvalue - CGRectGetWidth(self.bounds);
            CGRect frame    = self.frame;
            frame.origin.x  = moveX + ImageViewWidth;
            self.frame      = frame;
            
            textButton.frame = CGRectMake(0, textButton.frame.origin.y, CGRectGetWidth(textButton.bounds), CGRectGetHeight(textButton.bounds));
            imageView.frame  = CGRectMake(CGRectGetWidth(textButton.frame) + Distance , imageView.frame.origin.y, CGRectGetWidth(imageView.bounds), CGRectGetHeight(imageView.bounds));
            
            state = NiceLabelStateLeft;
        }
        
    } else if (state == NiceLabelStateLeft) {
        
        CGFloat screenWidth = CGRectGetWidth(self.superview.bounds) + ImageViewWidth;
        CGFloat Dvalue = CGRectGetMaxX(self.frame) + CGRectGetWidth(self.bounds);
        
        if (Dvalue <= screenWidth) {
            
            [self stopAnimation];
            
            CGRect frame    = self.frame;
            frame.origin.x  = CGRectGetMaxX(self.frame) - ImageViewWidth;
            self.frame      = frame;
            
            imageView.frame  = CGRectMake(0, imageView.frame.origin.y, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
            textButton.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + Distance, textButton.frame.origin.y, CGRectGetWidth(textButton.frame), CGRectGetHeight(textButton.frame));
            
            state = NiceLabelStateRight;
        }
    }
}


#pragma mark -- Animation
//动画停止执行的delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"TransformScale"] isEqualToString:@"scaleAnimation"]) {
        isAperture = NO;
        [self addApertureAnimationDuration:.6f beginTime:0.5f];
        [self addApertureAnimationDuration:.6f beginTime:1.f];
    } else if ([[anim valueForKey:@"animation"] isEqualToString:@"animation"]) {
        if (!isAperture) {
            [self addAnimationDuration:0.7f beginTime:0.5f];
            isAperture = YES;
        }
    }
}

//添加动画
- (void)addAnimationDuration:(CGFloat)duration beginTime:(CGFloat)beginTime
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue    = [NSNumber numberWithFloat:1.f];
    scaleAnimation.toValue      = [NSNumber numberWithFloat:1.5f];
    scaleAnimation.duration     = duration;
    scaleAnimation.beginTime    = CACurrentMediaTime() + beginTime;
    scaleAnimation.delegate     = self;
    [scaleAnimation setValue:@"scaleAnimation" forKey:@"TransformScale"];
    [imageView.layer addAnimation:scaleAnimation forKey:kAnimatiomName];
}

//添加光晕效果
- (void)addApertureAnimationDuration:(CGFloat)duration beginTime:(CGFloat)beginTime
{
    CGRect frame = CGRectMake(-CGRectGetMidX(imageView.bounds), -CGRectGetMidY(imageView.bounds), CGRectGetWidth(imageView.bounds), CGRectGetHeight(imageView.bounds));
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:CGRectGetWidth(imageView.bounds)];
    
    CGPoint position = [imageView.superview convertPoint:imageView.center fromView:imageView.superview];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor     = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.55f].CGColor;
    shapeLayer.strokeColor   = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth     = 0.f;
    shapeLayer.path          = path.CGPath;
    shapeLayer.position      = position;
    shapeLayer.opacity       = 0.f;
    
    [imageView.superview.layer addSublayer:shapeLayer];
    [shapeLayers addObject:shapeLayer];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue   = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5f, 1.f, 1.f)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1;
    opacityAnimation.toValue   = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation,opacityAnimation];
    animation.duration   = duration;
    animation.beginTime  = CACurrentMediaTime() + beginTime;
    animation.delegate   = self;
    [animation setValue:@"animation" forKey:@"animation"];
    [shapeLayer addAnimation:animation forKey:kGroupAnimation];
    
}
//停止动画 并将光晕移除
- (void)stopAnimation
{
    [imageView.layer removeAnimationForKey:kAnimatiomName];
    for (CAShapeLayer *shapeLayer in shapeLayers) {
        [shapeLayer removeAnimationForKey:kGroupAnimation];
        [shapeLayer removeFromSuperlayer];
    }
    [shapeLayers removeAllObjects];
}
@end
