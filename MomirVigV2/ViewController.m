//
//  ViewController.m
//  MomirVigV2
//
//  Created by Joel Cright on 2016-01-01.
//  Copyright © 2016 Joel Cright. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mPageTitles = [[NSMutableArray alloc] init];
    self.mPageImages = [[NSMutableArray alloc] init];
    
    //Set up homepage
    _mPageTitles = @[@"Momir Vig Avatar"];
    _mPageImages = @[@"MODO.jpeg"];
    
    self.mURL = @"http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=ABCDEF&type=card";
    self.mPortionOfURLToReplace = @"ABCDEF";
    
    // Create path.
    self.mPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.mFilePath = [[self.mPaths objectAtIndex:0] stringByAppendingPathComponent:@"Cards/Images"];
    
    // Create page view controller
    self.mPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.mPageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    _mViewControllerArray = @[startingViewController];
    [self.mPageViewController setViewControllers:_mViewControllerArray direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.mPageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_mPageViewController];
    [self.view addSubview:_mPageViewController.view];
    [self.mPageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) AddPageWithTitle:(NSString*)aTitle AndImageID:(NSString*)aImageID {
    [self.mPageTitles addObject:aTitle];
    
    
    [self DownloadImageWithID:aImageID];
    
    [self.mPageImages addObject:aImageID];
}

-(void) DownloadImageWithID:(NSString*) aID {
    
    //Make path for image
    NSString* filePath = [[self.mPaths objectAtIndex:0] stringByAppendingPathComponent:self.mFilePath];
    filePath = [NSString stringWithFormat:@"%@,%@", filePath, aID];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if(fileExists) return;
    
    NSString* url = [self.mURL stringByReplacingOccurrencesOfString:self.mPortionOfURLToReplace withString:aID];
    
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    UIImage *image = [UIImage imageWithData: imageData];
    
    // Save image.
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    //return image;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).mPageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).mPageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.mPageTitles count]) {
                return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.mPageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

//TODO: Change this to take in a JSON object. Have another function to decipher it and get back the title and image
- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.mPageTitles count] == 0) || (index >= [self.mPageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.mImageFile = self.mPageImages[index];
    pageContentViewController.mTitleText = self.mPageTitles[index];
    pageContentViewController.mPageIndex = index;
    
    return pageContentViewController;
}
@end
