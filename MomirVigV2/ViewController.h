//
//  ViewController.h
//  MomirVigV2
//
//  Created by Joel Cright on 2016-01-01.
//  Copyright © 2016 Joel Cright. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@class PageContentViewController;

@interface ViewController : UIViewController <UIPageViewControllerDataSource>

-(void) CreateNewCardWithCMC:(NSInteger) aCMC;
-(void) RemoveCardAtPage:(PageContentViewController*) aPage;

-(bool) DoAllSetsExist;

@property (strong, nonatomic) UIPageViewController *mPageViewController;
@property (strong, nonatomic) NSMutableArray *mViewControllerArray;
@property (strong, nonatomic) NSMutableArray *mFirstViewControllerArray;
@property (strong, nonatomic) NSMutableArray *mIndicesRemoved;

@property (strong, nonatomic) NSMutableArray *mPageTitles;
@property (strong, nonatomic) NSMutableArray *mPageImages;
@property (strong, nonatomic) UIView *mGrayView;

@property (strong, nonatomic) NSArray *mPaths;
@property (strong, nonatomic) NSString *mFilePath;
@property (strong, nonatomic) NSString *mSetCheckPath;
@property (strong, nonatomic) NSString *mCardsPath;
@property (strong, nonatomic) NSString *mImagesPath;

@property (strong, nonatomic) NSString *mURL;
@property (strong, nonatomic) NSString *mPortionOfURLToReplace;


@end
