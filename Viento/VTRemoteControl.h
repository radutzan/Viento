//
//  VTRemoteControl.h
//  Viento
//
//  Created by Radu Dutzan on 12/12/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VTExternalViewController;

@interface VTRemoteControl : UIViewController

@property (nonatomic) VTExternalViewController *externalScreenController;

+ (VTRemoteControl *)sharedRemoteControl;

- (void)setSpecialScrollSize:(CGSize)size;
- (void)resetScrollSize;

@property (nonatomic, strong) UIScrollView *controlScrollView;

@end

