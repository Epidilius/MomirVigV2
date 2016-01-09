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
    
    if([self.mImageFile isEqualToString:@"MODO.jpeg"])
        self.mCardImageView.image = [UIImage imageNamed:self.mImageFile];
    else {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:self.mImageFile options:0 error:&error];
        UIImage *image = [UIImage imageWithData: data];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        image = [self imageWithImage:image scaledToSize:CGSizeMake(screenWidth, screenHeight)];
        
        self.mCardImageView.image = image;
    }
    
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

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)GenerateNewCard:(id)sender {
    [self.view addSubview:self.mGrayView];
    
    [self.textFieldCMC setHidden:NO];
    
    [self.textFieldCMC becomeFirstResponder];
    self.textFieldCMC.layer.zPosition = 1;
    
    //[[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.textFieldCMC];
}

- (IBAction)RemoveCard:(id)sender {
    [self.mParent RemoveCardAtPage:self];
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
