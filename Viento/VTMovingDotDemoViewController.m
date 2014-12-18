//
//  VTMovingDotDemoViewController.m
//  Viento
//
//  Created by Radu Dutzan on 12/13/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "VTMovingDotDemoViewController.h"

@interface VTMovingDotDemoViewController ()

@property (nonatomic, strong) UIView *controlledDot;

@end

@implementation VTMovingDotDemoViewController

- (void)viewDidLoad
{
    [VTRemoteControl sharedRemoteControl].controlScrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    self.controlledDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.controlledDot.backgroundColor = [UIColor whiteColor];
    self.controlledDot.center = self.view.center;
    self.controlledDot.layer.cornerRadius = 10;
    [self.view addSubview:self.controlledDot];
}

- (void)handleScrollWithOffset:(CGPoint)offset
{
    CGPoint dotCenter = CGPointMake(self.controlledDot.center.x - offset.x, self.controlledDot.center.y - offset.y);
    dotCenter.x = MAX(0, dotCenter.x);
    dotCenter.x = MIN(self.view.bounds.size.width, dotCenter.x);
    dotCenter.y = MAX(0, dotCenter.y);
    dotCenter.y = MIN(self.view.bounds.size.height, dotCenter.y);
    self.controlledDot.center = dotCenter;
}

@end
