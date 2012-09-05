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
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(0, 0, 100, 40)];
    [btn setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
    [btn addTarget:self action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
    [btn setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [btn setTitle:@"Notify" forState:UIControlStateNormal];
    [self.view addSubview:btn];
}

- (void)show {
    [NotificationManager notifyText:@"This is a notification." icon:nil style:NotificationStyleSlideInTop duration:2 target:nil selector:nil showImmediately:NO];
    
    [NotificationManager notifyText:@"This is a notification with an icon." icon:@"icon_info.png" style:NotificationStyleSlideInBottom duration:2 target:nil selector:nil showImmediately:NO];
    
    [NotificationManager notifyText:@"Multi-line text works too!\nThis is the second line." icon:@"icon_checkmark.png" style:NotificationStyleFadeInTop duration:2 target:nil selector:nil showImmediately:NO];
    
    [NotificationManager notifyText:@"Choose from 9 different styles." icon:@"icon_checkmark.png" style:NotificationStyleFadeInCenter duration:2 target:nil selector:nil showImmediately:NO];
    
    [NotificationManager notifyText:@"Notifications can also intercept touches.\nTap this one to close it!" icon:@"icon_checkmark.png" style:NotificationStyleFadeInBottom duration:5 target:self selector:@selector(tap) showImmediately:NO];    
    
    [NotificationManager notifyText:@"Notifications work in any orientation.\nRotate your device and see for yourself." icon:@"icon_checkmark.png" style:NotificationStyleFadeInCenter duration:5 target:nil selector:nil showImmediately:NO];
    
    [NotificationManager notifyText:@"Visit github.com/nihalahmed/NotificationManager for more information." icon:@"icon_info.png" style:NotificationStyleStatusBar duration:2 target:nil selector:nil showImmediately:NO];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end