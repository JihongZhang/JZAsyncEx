//
//  JZViewController.m
//  JZAsyncEx
//
//  Created by jihong zhang on 8/7/14.
//  Copyright (c) 2014 JZ. All rights reserved.
//
#import "JZViewController.h"

@interface JZViewController ()

@end

@implementation JZViewController

-(void)mySetNetworkActivityIndicatorVisible:(BOOL)setVisible{
    static NSInteger numberOfCallsToSetVisible = 0;
    if (setVisible) {
        numberOfCallsToSetVisible++;
    }else{
        numberOfCallsToSetVisible--;
        if( numberOfCallsToSetVisible < 0 ){
            numberOfCallsToSetVisible = 0;
        }
    }
    NSLog(@"numberOfCallsToSetVisible = %i", numberOfCallsToSetVisible);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(numberOfCallsToSetVisible > 0)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.spinner stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

  
- (IBAction)buttonImage:(id)sender {
    [self.spinner startAnimating];
    
    self.imageURL = [NSURL URLWithString:@"http://avatar.csdn.net/2/C/D/1_totogo2010.jpg"];
    /* if URL could be change during the loading time,
     * we need to save the URL before loading, after loading we need to
     * check if the URL has been changed during the loading time
     **! NSURL *imageURL = self.imageURL;
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self mySetNetworkActivityIndicatorVisible:YES];
        NSData *data = [[NSData alloc] initWithContentsOfURL:self.imageURL];
        [self mySetNetworkActivityIndicatorVisible:NO];
        UIImage *image = [[UIImage alloc] initWithData:data];
        
        /* if URL could be change during the loading time, 
         * we need to check if the URL has been changed during the loading time
         **! if(self.imageURL == imageURL){
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            if(data != nil){
                self.imageView.image = image;
                self.imageView.frame = CGRectMake(0,0, image.size.width, image.size.height);
                self.scrollView.contentSize = image.size;
                self.labelInfo.text = [NSString stringWithFormat:@"Image size: %f", image.size.width* image.size.height];
            }
            [self.spinner stopAnimating];
        });
    });
}

- (IBAction)buttonBarrier:(id)sender {
    [self.spinner startAnimating];
    
    self.imageView.image = nil;
    self.labelInfo.text =  @"The total threads sleep time:...";
    
    __block int totalThreadSleepTime = 0;
    
    dispatch_queue_t queue = dispatch_queue_create("MyTestBarrierQ", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3];
        @synchronized(self)  {
            totalThreadSleepTime += 3;
        }
        NSLog(@"Second out: dispatch_async1---sleep3");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        @synchronized(self)  {
            totalThreadSleepTime += 1;
        }
        NSLog(@"First out: dispatch_async2---sleep1");
    });
    dispatch_barrier_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        @synchronized(self)  {
            totalThreadSleepTime += 1;
        }
        NSLog(@"Third out: dispatch_barrier_async---sleep1");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        @synchronized(self)  {
            totalThreadSleepTime += 1;
        }
        NSLog(@"TotalThreadExcuteTime = %d", totalThreadSleepTime);
        NSLog(@"Last out: dispatch_async3---sleep1");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            
            self.imageView.image = nil;
            self.labelInfo.text = [NSString stringWithFormat:@"Threads total sleep time: %d", totalThreadSleepTime];
        });
    });
}

- (IBAction)buttonGroup:(id)sender {
    
    [self.spinner startAnimating];
    
    self.imageView.image = nil;
    self.labelInfo.text =  @"GroupThreads-Total image size:...";

    __block int totalImageSize = 0;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        [self mySetNetworkActivityIndicatorVisible:YES];
        [NSThread sleepForTimeInterval:3]; //simulation URL time delay for getting the image
        //the size can be get by calculate the sub image size in the main thread, here is just simultion sync calculate.
        [self mySetNetworkActivityIndicatorVisible:NO];
        @synchronized(self)  {
            totalImageSize = totalImageSize + 3*3;  
        }
        NSLog(@"Third out: group1---sleep3");
    });
    dispatch_group_async(group, queue, ^{
        [self mySetNetworkActivityIndicatorVisible:YES];
        [NSThread sleepForTimeInterval:2]; //simulation URL time delay for getting the image
        [self mySetNetworkActivityIndicatorVisible:NO];
        @synchronized(self)  {
            totalImageSize = totalImageSize + 2*2;
        }
        NSLog(@"Second out: group2---sleep2");
    });
    dispatch_group_async(group, queue, ^{
        [self mySetNetworkActivityIndicatorVisible:YES];
        [NSThread sleepForTimeInterval:1]; //simulation URL time delay for getting the image
        [self mySetNetworkActivityIndicatorVisible:NO];
        @synchronized(self)  {
            totalImageSize = totalImageSize + 1;
        }
        NSLog(@"First out: group3---sleep1");
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.spinner stopAnimating];
        NSLog(@"UpdateUi");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = nil;
            self.labelInfo.text = [NSString stringWithFormat:@"GroupThreads-Total image size: %d", totalImageSize];
        });
    });
}

@end
