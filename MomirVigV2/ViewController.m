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

-(void)viewDidLoad {
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
    self.mFilePath = [[self.mPaths objectAtIndex:0] stringByAppendingPathComponent:@"/Cards"];
    self.mCardsPath = @"/CardData";
    self.mImagesPath = @"/CardImages";
    
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
    
    [self FirstTimeSetup];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) AddPageWithTitle:(NSString*)aTitle AndImageID:(NSString*)aImageID {
    [self.mPageTitles addObject:aTitle];
    
    
    [self DownloadImageWithID:aImageID];
    
    [self.mPageImages addObject:aImageID];
}

-(void) CreateNewCardWithCMC:(NSInteger)aCMC {
    NSString *fileName = [NSString stringWithFormat:@"%li", (long)aCMC];
    NSString *filePath = [[self.mFilePath stringByAppendingString:self.mCardsPath] stringByAppendingPathComponent:fileName];
    
    
    //TODO: Make a C# file and parse the JSON file, then compare it with what I get when I parse the sets here
    
    
    //TODO: Swap size of array for maxNumber here
    NSInteger maxNumber = 350;
    int randNum = arc4random_uniform(maxNumber);
    

    //TODO: Load the file, break it into an array, get a random number between beginning and end of array
    //TODO: If array only contains 1 element, popup a message saying "No creatures in that CMC" and return
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

-(void) FirstTimeSetup {
    //TODO: Check if each set exists. If it does, continue the loop
    
    NSError* err = nil;
    //TODO: Remove this
    NSInteger creatureCount = 0;
    NSInteger creaturesRemoved = 0;
    
    NSString* folderPath = [[NSBundle mainBundle] pathForResource:@"2ED" ofType:@"json"];
    folderPath = [folderPath stringByReplacingOccurrencesOfString:@"2ED.json" withString:@""];
   
    NSArray* listOfFiles = [self GetPathsOfType:@"json" InDirectory:folderPath];
    
    NSMutableArray *cardDataArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 21; i++) {
        NSString *indexToAdd = [NSString stringWithFormat:@"%i", i];
        indexToAdd = [indexToAdd stringByAppendingString:@":|"];
        
        [cardDataArray addObject:indexToAdd];
    }
    
    for(NSString *path in listOfFiles) {
        
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:path ofType:@"json"];
        NSDictionary* allCardData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
        
        NSString *setCode = [allCardData valueForKey:@"code"];
        if([setCode isEqualToString:@"UGL"] || [setCode isEqualToString:@"UNH"])
            continue;
        
        NSLog(setCode);
        
        allCardData = [allCardData valueForKey:@"cards"];
        
        
        for(NSDictionary * dict in allCardData)
        {
            NSString *type = [[dict objectForKey:@"types"] description];
            type = [type stringByReplacingOccurrencesOfString:@" " withString:@""];
            type = [type stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            type = [type stringByReplacingOccurrencesOfString:@"(" withString:@""];
            type = [type stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            NSString *layout = [[dict objectForKey:@"layout"] description];
            
            //NSString *cardName = [dict valueForKey:@"name"];
            
            //NSLog(dict);
            if([type isEqual: @"Creature"] && ![layout isEqual:@"token"]) {
                NSString *cardID = [dict valueForKey:@"id"];
                cardID = [cardID stringByAppendingString:@"---"];
                NSString *name = [dict valueForKey:@"name"];
                NSInteger cmc = [[dict valueForKey:@"cmc"] intValue];
                
                if(cmc == 0 && ([layout isEqual: @"flip"] || [layout isEqual:@"double-faced"])) {
                    NSLog(name);
                    continue;
                }
                
                //TODO: Find out why Im not getting draco
                NSString *currentCards = [cardDataArray objectAtIndex:cmc];
                if([currentCards containsString:name]) {
                    creaturesRemoved++;
                    continue;
                }
                
                NSString *card = [cardID stringByAppendingString:name];
                card = [currentCards stringByAppendingString:card];
                card = [card stringByAppendingString:@"|"];
                
                creatureCount++;    //TODO: This should be ~8000
                
                [cardDataArray replaceObjectAtIndex:cmc withObject:card];
            }
        }
    }
    
    //TODO: Save each element as file
    
    for(int i = 0; i < cardDataArray.count; i++) {
        NSString* fileName = [NSString stringWithFormat:@"%i", i];
        fileName = [fileName stringByAppendingString:@".txt"];
        [self SaveToFile:[cardDataArray objectAtIndex:i] WithName:fileName];
    }
    
    //NSLog(@"Imported Cards: %@", allCardData);
}

-(void) SaveToFile:(NSString*) aToSave WithName:(NSString*) aFileName{
    //CREATE FILE
    
    NSError *error;
    
    // Create file manager
    //NSFileManager *fileMgr = [NSFileManager defaultManager];
        
    NSString *filePath = [[self.mFilePath stringByAppendingString:self.mCardsPath] stringByAppendingPathComponent:aFileName];
    
    NSLog(@"string to write:%@",aToSave);
    // Write to the file
    [aToSave writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

-(NSArray *)GetPathsOfType:(NSString *)aType InDirectory:(NSString *)aDirectoryPath{
    
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:aDirectoryPath];
    
    NSString *filePath;
    
    while ((filePath = [enumerator nextObject]) != nil){
        
        // If we have the right type of file, add it to the list
        // Make sure to prepend the directory path
        if([[filePath pathExtension] isEqualToString:aType]){
            filePath = [filePath stringByReplacingOccurrencesOfString:@".json" withString:@""];
            [filePaths addObject:filePath];//[aDirectoryPath stringByAppendingPathComponent:filePath]];
        }
    }
    
    return filePaths;
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

//TODO: Change this to take in a couple of strings and set the title and image
- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.mPageTitles count] == 0) || (index >= [self.mPageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    //pageContentViewController
    pageContentViewController.mImageFile = self.mPageImages[index];
    pageContentViewController.mTitleText = self.mPageTitles[index];
    pageContentViewController.mPageIndex = index;
    
    [pageContentViewController SetParent:self];
    
    return pageContentViewController;
}
@end
