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
    
    [self.textFieldCMC setHidden:YES];
    
    self.mGrayView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mGrayView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    self.mCardImageView.image = [UIImage imageNamed:self.mImageFile];
    self.mCardNameLabel.text = self.mTitleText;
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.textFieldCMC.inputAccessoryView = numberToolbar;
}

- (IBAction)GenerateNewCard:(id)sender {
    [self.view addSubview:self.mGrayView];
    
    [self.textFieldCMC setHidden:NO];
    
    [self.textFieldCMC becomeFirstResponder];
    self.textFieldCMC.layer.zPosition = 1;
    
    //[[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.textFieldCMC];
}

-(void) SetParent:(ViewController *)aParent {
    self.mParent = aParent;
}

-(void)cancelNumberPad{
    self.textFieldCMC.text = @"";
    [self.textFieldCMC resignFirstResponder];
    [self.textFieldCMC setHidden:YES];
    
    [self.mGrayView removeFromSuperview];
}

-(void)doneWithNumberPad{
    NSString *numberFromTheKeyboard = self.textFieldCMC.text;
    NSInteger cmc = [numberFromTheKeyboard integerValue];
    
    self.textFieldCMC.text = @"";
    [self.textFieldCMC resignFirstResponder];
    [self.textFieldCMC setHidden:YES];
    
    [self.mGrayView removeFromSuperview];
    
    [self.mParent CreateNewCardWithCMC:cmc];
}
@end
