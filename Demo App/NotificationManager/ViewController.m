//
//  ViewController.m
//  NotificationManager
//
//  Created by Nihal Ahmed on 12-03-17.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(0, 0, 100, 40)];
    [btn setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    [btn addTarget:self action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
    [btn setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [btn setTitle:@"Notify" forState:UIControlStateNormal];
    [self.view addSubview:btn];
}

- (void)show {
    [[NotificationManager defaultManager] notifyText:@"This is a notification." withStyle:NotificationStyleSlideIn];
    [[NotificationManager defaultManager] notifyText:@"This is a notification with an icon." withIcon:@"icon_info.png" withStyle:NotificationStyleSlideIn];
    [[NotificationManager defaultManager] notifyText:@"Multi-line text works too!\nThis is the second line." withIcon:@"icon_checkmark.png" withStyle:NotificationStyleSlideIn];
    [[NotificationManager defaultManager] notifyText:@"You can choose to fade-in notifications..." withIcon:@"icon_checkmark.png" withStyle:NotificationStyleFadeIn];
    [[NotificationManager defaultManager] notifyText:@"...and set their duration as well." withIcon:@"icon_checkmark.png" withStyle:NotificationStyleFadeIn];
    [[NotificationManager defaultManager] notifyText:@"Notifications work in any orientation.\nYou have 5 seconds to rotate your device." withIcon:@"icon_checkmark.png" withStyle:NotificationStyleSlideIn forDuration:5];
    [[NotificationManager defaultManager] notifyText:@"You can also force a notification to any orientation" withStyle:NotificationStyleFadeIn forceOrientation:UIInterfaceOrientationLandscapeLeft];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end