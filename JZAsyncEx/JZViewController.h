//
//  JZViewController.h
//  JZAsyncEx
//
//  Created by jihong zhang on 8/7/14.
//  Copyright (c) 2014 JZ. All rights reserved.
//
/** This is my async exercise
 *  Try to exercise in Async, Async Barrier, and Async group
 *  including NetworkActivityIndicator and handling multi request for it,
 *  and UIActivityIndicator during the image loading waiting
 */
#import <UIKit/UIKit.h>

@interface JZViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSURL *imageURL;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)buttonImage:(id)sender;
- (IBAction)buttonBarrier:(id)sender;
- (IBAction)buttonGroup:(id)sender;

@end
