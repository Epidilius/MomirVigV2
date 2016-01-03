//
//  PageContentViewController.m
//  MomirVigV2
//
//  Created by Joel Cright on 2016-01-01.
//  Copyright © 2016 Joel Cright. All rights reserved.
//

#import "PageContentViewController.h"

@implementation PageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mCardImageView.image = [UIImage imageNamed:self.mImageFile];
    self.mCardNameLabel.text = self.mTitleText;
}

@end
