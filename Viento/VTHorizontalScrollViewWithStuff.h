//
//  VTHorizontalScrollViewWithStuff.h
//  Viento
//
//  Created by Radu Dutzan on 12/17/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTHorizontalScrollViewWithStuff : UIScrollView

// i wanted to make a collection view, but then i didn't.

@property (nonatomic) NSUInteger numberOfItems;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat itemSpacing;

- (void)generateItems;

@end
