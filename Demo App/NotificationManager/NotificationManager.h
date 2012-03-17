//
//  NotificationManager.h
//
//  Created by Nihal Ahmed on 12-03-16.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

#define kDefaultDuration 2.5f
#define kOffset 10.0f
#define kBackgroundColor [UIColor blackColor]
#define kBorderColor [UIColor brownColor]
#define kTextColor [UIColor whiteColor]
#define kFontName @"HelveticaNeue-Bold"
#define kFontSize 15.0f
#define kIconSize 32.0f
#define kPadding 10.0f
#define kCornerRadius 3.0f
#define kBorderWidth 3.0f
#define kMaxWidth 480.0f

typedef enum {
    NotificationStyleSlideIn    = 0,                       
    NotificationStyleFadeIn     = 1
} NotificationStyle;

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface NotificationManager : NSObject {
    NSMutableArray *_queue;
}

+ (NotificationManager *)defaultManager;
- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style;
- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration;
- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style;
- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration;

@end


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
}

- (id)initWithText:(NSString *)text duration:(NSTimeInterval)duration iconName:(NSString *)iconName style:(NotificationStyle)style;
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