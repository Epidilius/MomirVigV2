//
//  PageContentViewController.h
//  MomirVigV2
//
//  Created by Joel Cright on 2016-01-01.
//  Copyright © 2016 Joel Cright. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *mCardImageView;
@property (weak, nonatomic) IBOutlet UILabel *mCardNameLabel;

@property NSUInteger mPageIndex;
@property NSString *mTitleText;
@property NSString *mImageFile;


@end
