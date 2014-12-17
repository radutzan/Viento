//
//  VTVerticalListViewController.m
//  Viento
//
//  Created by Radu Dutzan on 12/13/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "VTVerticalListViewController.h"

@interface VTVerticalListViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation VTVerticalListViewController

CGFloat _datConstant = 0;
CGFloat _rowHeight = 100;

- (void)viewDidLoad
{
    _datConstant = (self.view.bounds.size.height - _rowHeight) / 2;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(500, 0, self.view.bounds.size.width - 520, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.contentInset = UIEdgeInsetsMake(_datConstant, 0, 0, 0);
    [self.view addSubview:self.tableView];
    
    CGRect selectedRowFrame = CGRectMake(self.tableView.frame.origin.x, _datConstant, self.tableView.bounds.size.width, _rowHeight);
    CGFloat selectionBorderWidth = 4;
    
    CALayer *selectionIndicator = [CALayer layer];
    selectionIndicator.frame = CGRectInset(selectedRowFrame, -selectionBorderWidth, -selectionBorderWidth);
    selectionIndicator.borderColor = [UIColor whiteColor].CGColor;
    selectionIndicator.borderWidth = selectionBorderWidth;
    selectionIndicator.backgroundColor = [UIColor colorWithWhite:1 alpha:.15].CGColor;
    [self.view.layer addSublayer:selectionIndicator];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGSize scrollSize = CGSizeMake(10, self.tableView.contentSize.height + _datConstant);
    [[VTRemoteControl sharedRemoteControl] setSpecialScrollSize:scrollSize];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld. Test cell!", indexPath.row + 1];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:32];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.separatorInset = UIEdgeInsetsZero;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _rowHeight;
}

- (void)handleScrollWithOffset:(CGPoint)offset
{
    self.tableView.contentOffset = CGPointMake(0, [VTRemoteControl sharedRemoteControl].controlScrollView.contentOffset.y - _datConstant);
}

- (void)handleScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat integer = 0;
    CGFloat fraction = modf(targetContentOffset->y / _rowHeight, &integer);
    targetContentOffset->y = (fraction >= 0.5) ? (integer + 1) * _rowHeight : integer * _rowHeight;
}

@end
