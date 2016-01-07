//
//  ViewController.m
//  MomirVigV2
//
//  Created by Joel Cright on 2016-01-01.
//  Copyright © 2016 Joel Cright. All rights reserved.
//

#import "ViewController.h"

//TODO: Make a C# file and parse the JSON file, then compare it with what I get when I parse the sets here
//TODO: Make the first time run, save, load, and image fetch happen in background with swirly load thing
//TODO: Rename the first time run function to OnStartup or something, and add that check for each set
    //Make the set check its own function thar returns a bool
//TODO: Each other button
//TODO: The menu should have an option to not save data on phone, mention that every image is ~200 mbs
    //If this is checked, on close delete every file in the CardImage directory

@interface ViewController ()

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mPageTitles = [[NSMutableArray alloc] init];
    self.mPageImages = [[NSMutableArray alloc] init];
    
    //Set up homepage
    _mPageTitles = [[NSMutableArray alloc] init];
    _mPageImages = [[NSMutableArray alloc] init];
    [_mPageTitles addObject:@"Momir Vig Avatar"];
    [_mPageImages addObject:@"MODO.jpeg"];
    
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
    
    //TODO: Remove this
    //+[self CreateNewCardWithCMC:3];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) CreateNewCardWithCMC:(NSInteger)aCMC {
    NSString *fileName = [[NSString stringWithFormat:@"%li", (long)aCMC] stringByAppendingString:@".txt"];
    NSString *filePath = [[self.mFilePath stringByAppendingString:self.mCardsPath] stringByAppendingPathComponent:fileName];
    
    NSDictionary* allPossibleCards = [self LoadFileFromPath:filePath];
    
    if(allPossibleCards.count == 1) {
        //TODO: Make popup message saying "No creatures in that CMC" and return
    }
    
    NSArray *cardIDs = [allPossibleCards allKeys];
    
    NSInteger maxNumber = allPossibleCards.count - 1;
    int randNum = arc4random_uniform(maxNumber);
    
    NSString *cardID = [cardIDs objectAtIndex:randNum];
    NSString *cardName = [allPossibleCards objectForKey:cardID];
    
    [self GetImageWithCardID:cardID AndName:cardName];
    //TODO: Make new view page with name and ID
}

-(void) FirstTimeSetup {
    //TODO: Check if each set exists. If it does, continue the loop
    [self CreateFolders];
    
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
                if([dict valueForKey:@"multiverseid"] == nil) {
                    NSLog(@"No multiverseid in set: %@", setCode);
                    continue;
                }
                
                NSString *cardID = [[dict valueForKey:@"multiverseid"] description];
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

-(void) CreateFolders {
    //CREATE FILE
    NSError *error;
    NSString *filePath = [self.mFilePath stringByAppendingString:self.mCardsPath];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
    
    error = nil;
    filePath = [self.mFilePath stringByAppendingString:self.mImagesPath];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
}

-(void) SaveToFile:(NSString*) aToSave WithName:(NSString*) aFileName{
    //CREATE FILE
    
    NSError *error;
    
    NSString *filePath = [self.mFilePath stringByAppendingString:self.mCardsPath];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
    
    
    
    //Reset the error
    error = nil;
    
    filePath = [filePath stringByAppendingPathComponent:aFileName];
    
    // Write to the file
    [aToSave writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSLog(@"string to write:%@",aToSave);
}

-(NSDictionary*) LoadFileFromPath:(NSString*) aPath {
    //Card to card delimiter: |
    //Id to name delimiter: ---
    //Ignore element 0, this is the CMC of the array
    
    NSLog(aPath);
    
    NSError *error = nil;
    
    NSString *content = [NSString stringWithContentsOfFile:aPath encoding:NSUTF8StringEncoding error:&error];
    
    if(error != nil)
        NSLog(@"Error loading card file: %@", error);
    
    NSDictionary* cards;
    
    NSArray *cardArray = [content componentsSeparatedByString:@"|"];
    NSMutableArray *cardIDArray = [[NSMutableArray alloc] init];
    NSMutableArray *cardNameArray = [[NSMutableArray alloc] init];
    
    for(int i = 1; i < cardArray.count; i++) {
        NSArray *cardInfo = [[cardArray objectAtIndex:i] componentsSeparatedByString:@"---"];
        
        if(cardInfo.count != 2) {
            NSLog(@"%@", cardInfo);
            continue;
        }
        
        //ID is element 0, name is 1
        [cardIDArray addObject:[cardInfo objectAtIndex:0]];
        [cardNameArray addObject:[cardInfo objectAtIndex:1]];
    }
    
    if(cardIDArray.count == cardNameArray.count) {
        cards = [NSDictionary dictionaryWithObjects:cardNameArray forKeys:cardIDArray];
    }
    
    return cards;
}

-(void) GetImageWithCardID:(NSString*) aID AndName:(NSString*)aName {
    //Make path for image
    NSString* filePath = [self.mFilePath stringByAppendingPathComponent:self.mImagesPath];
    filePath = [NSString stringWithFormat:@"%@/%@.txt", filePath, aID];
    //BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    //if(fileExists == true)
    //    return nil;
    //TODO: Load image and return it
    
    NSString *urlPath = [self.mURL stringByReplacingOccurrencesOfString:self.mPortionOfURLToReplace withString:aID];
    NSURL *urlToFetchFrom = [NSURL URLWithString:urlPath];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
    dispatch_async(queue, ^{
        NSError *error = nil;
        
        NSData *data = [NSData dataWithContentsOfURL:urlToFetchFrom options:NSDataReadingUncached error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Save image.
            NSError *error = nil;
            [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
            [self ImageHasBeenFetched:filePath WithName:aName];
        });
        
    });
    
}

//TODO: Change that to image path
-(void) ImageHasBeenFetched:(NSString*)aImagePath WithName:(NSString*) aName{
        //TODO: Make a function to add a page
    [_mPageTitles addObject:aName];
    [_mPageImages addObject:aImagePath];
    
    [self createPage];
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

-(void)createPage {
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    //pageContentViewController
    pageContentViewController.mImageFile = [self.mPageImages lastObject];
    pageContentViewController.mTitleText = [self.mPageTitles lastObject];
    pageContentViewController.mPageIndex = self.mPageImages.count;
    
    [pageContentViewController SetParent:self];
}
@end
