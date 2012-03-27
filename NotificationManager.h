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
#define kNotificationBorderColor [UIColor brownColor]
#define kNotificationTextColor [UIColor whiteColor]
#define kNotificationFontName @"HelveticaNeue-Bold"
#define kNotificationFontSize 15.0f
#define kNotificationIconSize 32.0f
#define kNotificationPadding 10.0f
#define kNotificationCornerRadius 3.0f
#define kNotificationBorderWidth 3.0f
#define kNotificationMaxWidth 480.0f

//Notification style types
typedef enum {
    NotificationStyleSlideIn    = 0,                       
    NotificationStyleFadeIn     = 1
} NotificationStyle;

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


//Notification Manager singleton
@interface NotificationManager : NSObject {
    NSMutableArray *_queue;
}

+ (NotificationManager *)defaultManager;
- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style;
- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style forceOrientation:(UIInterfaceOrientation)orientation;
- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration;
- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration forceOrientation:(UIInterfaceOrientation)orientation;
- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style;
- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style forceOrientation:(UIInterfaceOrientation)orientation;
- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration;
- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration forceOrientation:(UIInterfaceOrientation)orientation;

@end


//Notification message class
@class Notification;

@protocol NotificationManagerDelegate <NSObject> 

- (void)notificationDidHide:(Notification *)notification;

@end

@interface Notification : UIView {
    id <NotificationManagerDelegate> delegate;
    CGPoint _centerBegin, _centerEnd;
    CGSize _portraitSize, _landscapeSize;
    float _angle;
    NotificationStyle _style;
    NSTimeInterval _notificationDuration;
    UIInterfaceOrientation _orientation;
}

- (id)initWithText:(NSString *)text duration:(NSTimeInterval)duration iconName:(NSString *)iconName style:(NotificationStyle)style orientation:(UIInterfaceOrientation)orientation;
- (void)show;
- (void)initPositionAndRotation;
- (void)updatePositionAndRotation;
- (void)calculatePositionAndRotation;
- (void)setSizesForText:(NSString *)text andIcon:(BOOL)hasIcon;
- (CGSize)getSizeForCurrentOrientation;
- (CGPoint)screenCenter;
- (float)statusBarOffset;

@property (nonatomic, retain) id delegate;

@end