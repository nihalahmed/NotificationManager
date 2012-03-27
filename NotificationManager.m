//
//  NotificationManager.m
//
//  Created by Nihal Ahmed on 12-03-16.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

#import "NotificationManager.h"


#pragma mark - Notification Manager Singleton

@implementation NotificationManager

static NotificationManager *defaultManager = nil;

+ (NotificationManager *)defaultManager {
    if(defaultManager == nil) {
        defaultManager = [[super allocWithZone:NULL] init];
    }
    return defaultManager;
}

- (id)init {
    if (self = [super init]) {
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self defaultManager] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;    
}

- (id)retain {
    return self;    
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (oneway void)release {
}

- (id)autorelease {
    return self;
}

- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style {
    [self notifyText:text withIcon:nil withStyle:style forDuration:kNotificationDefaultDuration forceOrientation:-1];
}

- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style forceOrientation:(UIInterfaceOrientation)orientation {
    [self notifyText:text withIcon:nil withStyle:style forDuration:kNotificationDefaultDuration forceOrientation:orientation];    
}

- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration {
    [self notifyText:text withIcon:nil withStyle:style forDuration:duration forceOrientation:-1];   
}

- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration forceOrientation:(UIInterfaceOrientation)orientation {
    [self notifyText:text withIcon:nil withStyle:style forDuration:duration forceOrientation:orientation];
}

- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style {
    [self notifyText:text withIcon:iconName withStyle:style forDuration:kNotificationDefaultDuration forceOrientation:-1];
}

- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style forceOrientation:(UIInterfaceOrientation)orientation {
    [self notifyText:text withIcon:iconName withStyle:style forDuration:kNotificationDefaultDuration forceOrientation:orientation];    
}

- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration {
    [self notifyText:text withIcon:iconName withStyle:style forDuration:duration forceOrientation:-1];
}

//Create new notification object with given parameters
- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration forceOrientation:(UIInterfaceOrientation)orientation {
    if(text == nil || [text length] == 0) {
        return;
    }
    
    //Create notification object and add it to the queue
    Notification *notification = [[Notification alloc] initWithText:text duration:duration iconName:iconName style:style orientation:orientation];
    [notification setDelegate:self];
    [_queue addObject:notification];
    [notification release];
    
    //If queue empty, then show notification immediately
    if([_queue count] == 1) {
        [notification show];
    }
}

//Callback recieved when a notification hides
- (void)notificationDidHide:(Notification *)notification {
    //Remove notification from queue
    [_queue removeObject:notification];
    
    //If queue not empty, show next notification
    if([_queue count] > 0) {
        [(Notification *)[_queue objectAtIndex:0] show];
    }
}

@end


#pragma mark - Notification Class

@implementation Notification

@synthesize delegate;

//Initialize notification object with given parameters
- (id)initWithText:(NSString *)text duration:(NSTimeInterval)duration iconName:(NSString *)iconName style:(NotificationStyle)style orientation:(UIInterfaceOrientation)orientation {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _notificationDuration = duration;
        _style = style;
        _orientation = orientation;
        
        [self setUserInteractionEnabled:NO];
        [self setSizesForText:text andIcon:(iconName != nil)];
        [self setFrame:CGRectMake(0, 0, [self getSizeForCurrentOrientation].width, [self getSizeForCurrentOrientation].height)];
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [self.layer setShadowRadius:1];
        [self.layer setShadowOpacity:1];
        [self.layer setMasksToBounds:NO];
        [self.layer setShadowOffset:CGSizeMake(0, 1)];
        
        //Notification background
        UIView *background = [[UIView alloc] initWithFrame:self.bounds];
        [background setBackgroundColor:kNotificationBackgroundColor];
        [background.layer setCornerRadius:kNotificationCornerRadius];
        [background.layer setBorderColor:[kNotificationBorderColor CGColor]];
        [background.layer setBorderWidth:kNotificationBorderWidth];
        [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:background];
        [background release];
        
        //If icon specified, add it to the notification
        if(iconName != nil) {
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kNotificationPadding, self.bounds.size.height/2 - kNotificationIconSize/2, kNotificationIconSize, kNotificationIconSize)];
            [iconView setContentMode:UIViewContentModeScaleAspectFit];
            [iconView setImage:[UIImage imageNamed:iconName]];
            [iconView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
            [self addSubview:iconView];
            [iconView release];
        }
        
        //Setup notification text
        UILabel *textLabel = [[UILabel alloc] init];
        if(iconName != nil) {
            [textLabel setFrame:CGRectMake(kNotificationIconSize + (kNotificationPadding * 1.5), 0.0f, self.bounds.size.width - kNotificationIconSize - (kNotificationPadding * 2.5), self.bounds.size.height)];
        }
        else {
            [textLabel setFrame:CGRectMake(kNotificationPadding, 0.0f, self.bounds.size.width - (kNotificationPadding * 2), self.bounds.size.height)];
        }
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:kNotificationTextColor];
        [textLabel setText:text];
        [textLabel setTextAlignment:UITextAlignmentCenter];
        [textLabel setFont:[UIFont fontWithName:kNotificationFontName size:kNotificationFontSize]];
        [textLabel setNumberOfLines:0];
        [textLabel setLineBreakMode:UILineBreakModeWordWrap];
        [textLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:textLabel];
        [textLabel release];        
    }
    return self;
}

//Show notification
- (void)show {
    [self initPositionAndRotation];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePositionAndRotation)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    switch (_style) {
        case NotificationStyleSlideIn: [self setCenter:_centerEnd]; break;
        case NotificationStyleFadeIn: [self setAlpha:1]; break;
    }
    [UIView commitAnimations];
    [self performSelector:@selector(hide) withObject:nil afterDelay:_notificationDuration];
}

//Hide notification
- (void)hide {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(notificationDidHide)];
    switch (_style) {
        case NotificationStyleSlideIn: [self setCenter:_centerBegin]; break;
        case NotificationStyleFadeIn: [self setAlpha:0]; break;
    }
    [UIView commitAnimations];
}

//Callback when notification hides
- (void)notificationDidHide {
    [delegate notificationDidHide:self];
    [self removeFromSuperview];
}

//Set initial notification message position and rotation
- (void)initPositionAndRotation {
    [self calculatePositionAndRotation];
    switch (_style) {
        case NotificationStyleSlideIn: [self setCenter:_centerBegin]; break;
        case NotificationStyleFadeIn: [self setCenter:_centerEnd]; [self setAlpha:0]; break;
    }
    [self setTransform:CGAffineTransformMakeRotation(_angle)];
}

//Update notification message position and rotation in response to orientation changes
- (void)updatePositionAndRotation {
    [self setTransform:CGAffineTransformIdentity];
    [self calculatePositionAndRotation];
    [self setCenter:_centerEnd];
    [self setTransform:CGAffineTransformMakeRotation(_angle)];
}

//Calculate new notification message position and rotation in response to orientation changes
- (void)calculatePositionAndRotation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(_orientation != -1) {
        orientation = _orientation;
    }
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            [self setFrame:CGRectMake(0, 0, _portraitSize.width, _portraitSize.height)];
            _centerBegin = CGPointMake([self screenCenter].x, [[UIScreen mainScreen] bounds].size.height + kNotificationOffset + [self statusBarOffset] + self.bounds.size.height/2);
            _centerEnd = CGPointMake([self screenCenter].x, [[UIScreen mainScreen] bounds].size.height - kNotificationOffset - [self statusBarOffset] - self.bounds.size.height/2);
            _angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [self setFrame:CGRectMake(0, 0, _landscapeSize.width, _landscapeSize.height)];
            _centerBegin = CGPointMake(- kNotificationOffset - [self statusBarOffset] - self.frame.size.height/2, [self screenCenter].y);
            _centerEnd = CGPointMake(kNotificationOffset + [self statusBarOffset] + self.frame.size.height/2, [self screenCenter].y);
            _angle = - M_PI / 2.0f;
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self setFrame:CGRectMake(0, 0, _landscapeSize.width, _landscapeSize.height)];
            _centerBegin = CGPointMake([[UIScreen mainScreen] bounds].size.width + kNotificationOffset + [self statusBarOffset] + self.bounds.size.height/2, [self screenCenter].y);
            _centerEnd = CGPointMake([[UIScreen mainScreen] bounds].size.width - kNotificationOffset - [self statusBarOffset] - self.bounds.size.height/2, [self screenCenter].y);
            _angle = M_PI / 2.0f;
            break;
        default:
            [self setFrame:CGRectMake(0, 0, _portraitSize.width, _portraitSize.height)];
            _centerBegin = CGPointMake([self screenCenter].x, - kNotificationOffset - [self statusBarOffset] - self.bounds.size.height/2);
            _centerEnd = CGPointMake([self screenCenter].x, kNotificationOffset + [self statusBarOffset] + self.bounds.size.height/2);
            _angle = 0.0;
            break;
    }
    [self.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:kNotificationCornerRadius].CGPath];
}

//Set notification message sizes for portrait and landscape orientation
- (void)setSizesForText:(NSString *)text andIcon:(BOOL)hasIcon {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float reserved = (kNotificationOffset * 2) + (kNotificationPadding * 2);
    if(hasIcon) {
        reserved += kNotificationIconSize + kNotificationPadding/2;
    }
    float portraitWidth = fmin(screenSize.width, kNotificationMaxWidth);
    float landscapeWidth = fmin(screenSize.height, kNotificationMaxWidth);
    
    CGSize portraitSize = [text sizeWithFont:[UIFont fontWithName:kNotificationFontName size:kNotificationFontSize]
                           constrainedToSize:CGSizeMake(portraitWidth - reserved, CGFLOAT_MAX)];
    _portraitSize = CGSizeMake(portraitSize.width - (kNotificationOffset * 2) + reserved, portraitSize.height + kNotificationIconSize);
    
    CGSize landscapeSize = [text sizeWithFont:[UIFont fontWithName:kNotificationFontName size:kNotificationFontSize]
                            constrainedToSize:CGSizeMake(landscapeWidth - reserved, CGFLOAT_MAX)];
    _landscapeSize = CGSizeMake(landscapeSize.width - (kNotificationOffset * 2) + reserved, landscapeSize.height + kNotificationIconSize);
}

//Get center point of screen
- (CGPoint)screenCenter {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGPoint center = CGPointMake(screenSize.width/2, screenSize.height/2);
    return center;
}

//Get notification message size for current orientation
- (CGSize)getSizeForCurrentOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return _landscapeSize;
    }
    else {
        return _portraitSize;        
    }
}

//Get status bar height for orientation
- (float)statusBarOffset {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return [[UIApplication sharedApplication] statusBarFrame].size.width;
    }
    else {
        return [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [delegate release];
    [super dealloc];
}

@end