//
//  ViewController.h
//  MomirVigV2
//
//  Created by Joel Cright on 2016-01-01.
//  Copyright © 2016 Joel Cright. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface ViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *mPageViewController;
@property (strong, nonatomic) NSMutableArray *mViewControllerArray;

@property (strong, nonatomic) NSMutableArray *mPageTitles;
@property (strong, nonatomic) NSMutableArray *mPageImages;

@property (strong, nonatomic) NSArray *mPaths;
@property (strong, nonatomic) NSString *mFilePath;

@property (strong, nonatomic) NSString *mURL;
@property (strong, nonatomic) NSString *mPortionOfURLToReplace;


@end

