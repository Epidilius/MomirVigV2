//
//  PageContentViewController.h
//  MomirVigV2
//
//  Created by Joel Cright on 2016-01-01.
//  Copyright © 2016 Joel Cright. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@class ViewController;

@interface PageContentViewController : UIViewController

@property (strong, nonatomic) UIView *mGrayView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCMC;
- (IBAction)GenerateNewCard:(id)sender;
- (void)TapCard;
- (IBAction)RemoveCard:(id)sender;

@property (strong, nonatomic) ViewController* mParent;
-(void) SetParent:(ViewController*) aParent;

@property (weak, nonatomic) IBOutlet UIImageView *mCardImageView;
@property (weak, nonatomic) IBOutlet UILabel *mCardNameLabel;

@property NSUInteger mPageIndex;
@property NSString *mTitleText;
@property NSString *mImageFile;


@end
