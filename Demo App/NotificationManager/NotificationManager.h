//
//  NotificationManager.h
//
//  Created by Nihal Ahmed on 12-03-16.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

//Notification appearance option
#define kNotificationDefaultDuration 2.5f
#define kNotificationOffset 10.0f
#define kNotificationBackgroundColor [UIColor blackColor]
#define kNotificationBorderColor [UIColor clearColor]
#define kNotificationTextColor [UIColor whiteColor]
#define kNotificationFontName @"HelveticaNeue-Bold"
#define kNotificationFontSize 14.0f
#define kNotificationIconSize 24.0f
#define kNotificationPadding 10.0f
#define kNotificationCornerRadius 3.0f
#define kNotificationBorderWidth 3.0f
#define kNotificationMaxWidth 480.0f

//Notification style types
typedef enum {
    NotificationStyleFadeInBottom,
    NotificationStyleFadeInCenter,
    NotificationStyleFadeInTop,
    NotificationStyleSlideInBottom,
    NotificationStyleSlideInTop,
    NotificationStyleZoomInBottom,
    NotificationStyleZoomInCenter,
    NotificationStyleZoomInTop,
    NotificationStyleStatusBar
} NotificationStyle;

//Notification Manager Singleton
@interface NotificationManager : NSObject

+ (void)notifyText:(NSString *)text icon:(NSString *)icon style:(NotificationStyle)style duration:(NSTimeInterval)duration target:(id)target selector:(SEL)selector showImmediately:(BOOL)showImmediately;

@end
