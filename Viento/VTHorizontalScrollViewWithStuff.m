//
//  VTHorizontalScrollViewWithStuff.m
//  Viento
//
//  Created by Radu Dutzan on 12/17/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "VTHorizontalScrollViewWithStuff.h"

@implementation VTHorizontalScrollViewWithStuff

- (void)generateItems
{
    for (int i = 0; i < self.numberOfItems; i++) {
        UIView *item = [[UIView alloc] initWithFrame:CGRectMake((self.itemSize.width + self.itemSpacing) * i, 0, self.itemSize.width, self.itemSize.height)];
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        item.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:1 alpha:1];
        [self addSubview:item];
    }
    
    self.contentSize = CGSizeMake(self.itemSize.width * self.numberOfItems + self.itemSpacing * (self.numberOfItems - 1), self.itemSize.height);
}

@end
