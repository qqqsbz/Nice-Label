//
//  NiceViewController.m
//  Radar
//
//  Created by coder on 15/9/8.
//  Copyright (c) 2015年 coder. All rights reserved.
//

#import "NiceViewController.h"
#import "NiceLabel.h"
#import "NiceButton.h"
#import "AroundPlacesViewController.h"
#import "NSString+String.h"
@interface NiceViewController ()<UIAlertViewDelegate,NiceLableDelegate>
{
    UIAlertView     *alertView;
    NiceLabel       *niceLabel;
    NiceLabel       *currentNiceLabel;
    CAShapeLayer    *tag;
   
    CGPoint         currentPoint;
    NiceButton      *locationBtn;
    BOOL            showMenu;
    
    AroundPlacesViewController *placesViewController;
    
}
@end

@implementation NiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = self.view.frame;
    frame.origin.x -= 64;
    self.view.frame = frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPlace:) name:@"kAROUNDPLACE" object:nil];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentPoint = [[touches anyObject] locationInView:self.view];
    
    if (!showMenu) {
        [self addTag];
        [self showMenu];
    } else {
        [self hideMenu];
    }
    showMenu = !showMenu;
    
}

- (void)selectPlace:(NSNotification *)notification
{
    NSString *name = notification.userInfo[@"name"];
    if (name) {
        
        CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:13.f] maxSize:CGSizeMake(100, 30)];
        
        niceLabel = [[NiceLabel alloc] initWithFrame:CGRectMake(currentPoint.x, currentPoint.y, size.width + 60, 30)];
        niceLabel.text      = name;
        niceLabel.textFont  = [UIFont systemFontOfSize:13.f];
        niceLabel.textColor = [UIColor whiteColor];
        niceLabel.delegate  = self;
        
        [self.view addSubview:niceLabel];
        [self hideMenu];
    }
}

#pragma mark -- NiceLabelDelegate
- (void)didLongPressWithNiceLabel:(NiceLabel *)niceLable
{
    if (!alertView) {
        alertView = [[UIAlertView alloc] initWithTitle:@"您要删除当前标签吗" message:@"确认删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
    [alertView show];
    currentNiceLabel = niceLabel;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [currentNiceLabel removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addTag
{
    if (!tag) {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:4 startAngle:0 endAngle:360 clockwise:YES];
        
        tag = [CAShapeLayer layer];
        tag.fillColor   = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.45].CGColor;
        tag.strokeColor = [UIColor clearColor].CGColor;
        tag.path        = path.CGPath;
        [self.view.layer addSublayer:tag];
    }
    tag.hidden   = NO;
    tag.position = currentPoint;
}

- (void)showMenu
{
    if (!locationBtn) {
        locationBtn = [[NiceButton alloc] initWithFrame:CGRectMake(self.view.center.x - 30, self.view.center.y - 40, 60, 80)];
        locationBtn.imageView.image = [UIImage imageNamed:@"icon1"];
        locationBtn.textLabel.text  = @"地点";
        locationBtn.textLabel.textAlignment = NSTextAlignmentCenter;
        locationBtn.textLabel.textColor = [UIColor whiteColor];
        locationBtn.textLabel.font = [UIFont systemFontOfSize:14.f];
        [locationBtn addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:locationBtn];
}

- (void)menuAction:(NiceButton *)sender
{
    if (!placesViewController) {
        placesViewController = [[AroundPlacesViewController alloc] init];
    }
    [self.navigationController pushViewController:placesViewController animated:YES];
}

- (void)hideMenu
{
    tag.hidden = YES;
    [locationBtn removeFromSuperview];
}


@end
