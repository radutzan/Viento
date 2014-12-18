//
//  VTKeyboardViewController.m
//  Viento
//
//  Created by Radu Dutzan on 12/17/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "VTKeyboardViewController.h"

@interface VTKeyboardViewController ()

@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic) CGPoint cursorPosition;
@property (nonatomic, strong) UIButton *preSelectedButton;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UIView *selectionIndicator;
@property (nonatomic, strong) UILabel *typedTextView;

@end

@implementation VTKeyboardViewController

BOOL _tracking = NO;

- (void)viewDidLoad
{
    self.buttonContainer = [UIView new];
    
    self.selectionIndicator = [UIView new];
    self.selectionIndicator.layer.borderColor = [UIColor whiteColor].CGColor;
    self.selectionIndicator.layer.borderWidth = 2;
    
    self.typedTextView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 590, 120)];
    self.typedTextView.center = CGPointMake(self.typedTextView.center.x, self.view.center.y);
    self.typedTextView.backgroundColor = [UIColor blackColor];
    self.typedTextView.textColor = [UIColor whiteColor];
    self.typedTextView.font = [UIFont systemFontOfSize:54];
    self.typedTextView.text = @"";
    self.typedTextView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.typedTextView.layer.borderWidth = 1;
    self.typedTextView.layer.cornerRadius = 8;
    
    [self createButtonsWithCharacters:@[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"]];
}

- (void)createButtonsWithCharacters:(NSArray *)characters
{
    CGSize buttonSize = CGSizeMake(90, 90);
    self.buttonContainer.frame = CGRectMake(50, 0, buttonSize.width * 6, buttonSize.height * 6);
    CGFloat buttonOriginX = 0;
    CGFloat buttonOriginY = 0;
    
    for (NSString *character in characters) {
        UIButton *characterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        characterButton.frame = CGRectMake(buttonOriginX, buttonOriginY, buttonSize.width, buttonSize.height);
        characterButton.titleLabel.font = [UIFont systemFontOfSize:42];
        [characterButton setTitle:character forState:UIControlStateNormal];
        [characterButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonContainer addSubview:characterButton];
        
        buttonOriginX += buttonSize.width;
        if (buttonOriginX >= self.buttonContainer.bounds.size.width) {
            buttonOriginX = 0;
            buttonOriginY += buttonSize.height;
        }
    }
    
    self.buttonContainer.center = CGPointMake(self.buttonContainer.center.x, self.view.center.y);
    [self.view addSubview:self.buttonContainer];
    
    self.typedTextView.frame = CGRectOffset(self.typedTextView.frame, self.buttonContainer.frame.origin.x + self.buttonContainer.bounds.size.width + 20, 0);
    [self.view addSubview:self.typedTextView];
    
    self.preSelectedButton = self.buttonContainer.subviews[0];
    self.selectedButton = self.buttonContainer.subviews[0];
    
    self.selectionIndicator.frame = CGRectMake(self.buttonContainer.frame.origin.x, self.buttonContainer.frame.origin.y, buttonSize.width, buttonSize.height);
    [self.view addSubview:self.selectionIndicator];
}

- (void)setPreSelectedButton:(UIButton *)preSelectedButton
{
    if ([_preSelectedButton isEqual:preSelectedButton]) return;
    _preSelectedButton = preSelectedButton;
    
    for (UIButton *button in self.buttonContainer.subviews) {
        button.backgroundColor = [UIColor clearColor];
    }
    preSelectedButton.backgroundColor = [UIColor colorWithWhite:1 alpha:.15];
}

- (void)setSelectedButton:(UIButton *)selectedButton
{
    if ([_selectedButton isEqual:selectedButton]) return;
    _selectedButton = selectedButton;
    
    [UIView animateWithDuration:.1 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
        self.selectionIndicator.center = [self.view convertPoint:selectedButton.center fromView:self.buttonContainer];
    } completion:nil];
}

- (void)buttonPressed:(UIButton *)button
{
    // append button title to some label or textview
    self.typedTextView.text = [self.typedTextView.text stringByAppendingString:[button titleForState:UIControlStateNormal]];
}

- (void)handleScrollWillBeginTracking
{
    _tracking = YES;
}

- (void)handleScrollWithOffset:(CGPoint)offset
{
    if (!_tracking) return;
    CGFloat accelerationFactor = 2.4;
    
    CGPoint selectionCenter = CGPointMake(self.selectionIndicator.center.x - offset.x * accelerationFactor, self.selectionIndicator.center.y - offset.y * accelerationFactor);
    selectionCenter.x = MAX(self.buttonContainer.frame.origin.x + self.selectionIndicator.bounds.size.width / 2, selectionCenter.x);
    selectionCenter.x = MIN(self.buttonContainer.frame.origin.x + self.buttonContainer.bounds.size.width - self.selectionIndicator.bounds.size.width / 2, selectionCenter.x);
    selectionCenter.y = MAX(self.buttonContainer.frame.origin.y + self.selectionIndicator.bounds.size.height / 2, selectionCenter.y);
    selectionCenter.y = MIN(self.buttonContainer.frame.origin.y + self.buttonContainer.bounds.size.height - self.selectionIndicator.bounds.size.height / 2, selectionCenter.y);
    self.selectionIndicator.center = selectionCenter;
    
    self.preSelectedButton = (UIButton *)[self.buttonContainer hitTest:[self.buttonContainer convertPoint:selectionCenter fromView:self.view] withEvent:nil];
}

- (void)handleScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    _tracking = NO;
    self.selectedButton = self.preSelectedButton;
    
    // kill scrolling
    scrollView.contentOffset = scrollView.contentOffset;
}

- (void)handleClick
{
    [self.selectedButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
