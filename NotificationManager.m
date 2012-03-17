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
    [self notifyText:text withIcon:nil withStyle:style forDuration:kDefaultDuration];
}

- (void)notifyText:(NSString *)text withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration {
    [self notifyText:text withIcon:nil withStyle:style forDuration:duration];    
}

- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style {
    [self notifyText:text withIcon:iconName withStyle:style forDuration:kDefaultDuration];
}

- (void)notifyText:(NSString *)text withIcon:(NSString *)iconName withStyle:(NotificationStyle)style forDuration:(NSTimeInterval)duration {
    if(text == nil || [text length] == 0) {
        return;
    }
    
    Notification *notification = [[Notification alloc] initWithText:text duration:duration iconName:iconName style:style];
    [notification setDelegate:self];
    [_queue addObject:notification];
    [notification release];
    
    if([_queue count] == 1) {
        [notification show];
    }
}

- (void)notificationDidHide:(Notification *)notification {
    [_queue removeObject:notification];
    if([_queue count] > 0) {
        [(Notification *)[_queue objectAtIndex:0] show];
    }
}

@end


#pragma mark - Notification Class

@implementation Notification

@synthesize delegate;

- (id)initWithText:(NSString *)text duration:(NSTimeInterval)duration iconName:(NSString *)iconName style:(NotificationStyle)style {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _notificationDuration = duration;
        _style = style;
        
        [self setSizesForText:text andIcon:(iconName != nil)];
        [self setFrame:CGRectMake(0, 0, [self getSizeForCurrentOrientation].width, [self getSizeForCurrentOrientation].height)];
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [self.layer setShadowRadius:1];
        [self.layer setShadowOpacity:1];
        [self.layer setMasksToBounds:NO];
        [self.layer setShadowOffset:CGSizeMake(0, 1)];
        
        UIView *background = [[UIView alloc] initWithFrame:self.bounds];
        [background setBackgroundColor:kBackgroundColor];
        [background.layer setCornerRadius:kCornerRadius];
        [background.layer setBorderColor:[kBorderColor CGColor]];
        [background.layer setBorderWidth:kBorderWidth];
        [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:background];
        [background release];
        
        if(iconName != nil) {
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPadding, self.bounds.size.height/2 - kIconSize/2, kIconSize, kIconSize)];
            [iconView setContentMode:UIViewContentModeScaleAspectFit];
            [iconView setImage:[UIImage imageNamed:iconName]];
            [iconView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
            [self addSubview:iconView];
            [iconView release];
        }
        
        UILabel *textLabel = [[UILabel alloc] init];
        if(iconName != nil) {
            [textLabel setFrame:CGRectMake(kIconSize + (kPadding * 1.5), 0.0f, self.bounds.size.width - kIconSize - (kPadding * 2.5), self.bounds.size.height)];
        }
        else {
            [textLabel setFrame:CGRectMake(kPadding, 0.0f, self.bounds.size.width - (kPadding * 2), self.bounds.size.height)];
        }
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setTextColor:kTextColor];
        [textLabel setText:text];
        [textLabel setTextAlignment:UITextAlignmentCenter];
        [textLabel setFont:[UIFont fontWithName:kFontName size:kFontSize]];
        [textLabel setNumberOfLines:0];
        [textLabel setLineBreakMode:UILineBreakModeWordWrap];
        [textLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:textLabel];
        [textLabel release];        
    }
    return self;
}

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

- (void)notificationDidHide {
    [delegate notificationDidHide:self];
    [self removeFromSuperview];
}

- (void)initPositionAndRotation {
    [self calculatePositionAndRotation];
    switch (_style) {
        case NotificationStyleSlideIn: [self setCenter:_centerBegin]; break;
        case NotificationStyleFadeIn: [self setCenter:_centerEnd]; [self setAlpha:0]; break;
    }
    [self setTransform:CGAffineTransformMakeRotation(_angle)];
}

- (void)updatePositionAndRotation {
    [self setTransform:CGAffineTransformIdentity];
    [self calculatePositionAndRotation];
    [self setCenter:_centerEnd];
    [self setTransform:CGAffineTransformMakeRotation(_angle)];
}

- (void)calculatePositionAndRotation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            [self setFrame:CGRectMake(0, 0, _portraitSize.width, _portraitSize.height)];
            _centerBegin = CGPointMake([self screenCenter].x, [[UIScreen mainScreen] bounds].size.height + kOffset + [self statusBarOffset] + self.bounds.size.height/2);
            _centerEnd = CGPointMake([self screenCenter].x, [[UIScreen mainScreen] bounds].size.height - kOffset - [self statusBarOffset] - self.bounds.size.height/2);
            _angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [self setFrame:CGRectMake(0, 0, _landscapeSize.width, _landscapeSize.height)];
            _centerBegin = CGPointMake(- kOffset - [self statusBarOffset] - self.frame.size.height/2, [self screenCenter].y);
            _centerEnd = CGPointMake(kOffset + [self statusBarOffset] + self.frame.size.height/2, [self screenCenter].y);
            _angle = - M_PI / 2.0f;
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self setFrame:CGRectMake(0, 0, _landscapeSize.width, _landscapeSize.height)];
            _centerBegin = CGPointMake([[UIScreen mainScreen] bounds].size.width + kOffset + [self statusBarOffset] + self.bounds.size.height/2, [self screenCenter].y);
            _centerEnd = CGPointMake([[UIScreen mainScreen] bounds].size.width - kOffset - [self statusBarOffset] - self.bounds.size.height/2, [self screenCenter].y);
            _angle = M_PI / 2.0f;
            break;
        default:
            [self setFrame:CGRectMake(0, 0, _portraitSize.width, _portraitSize.height)];
            _centerBegin = CGPointMake([self screenCenter].x, - kOffset - [self statusBarOffset] - self.bounds.size.height/2);
            _centerEnd = CGPointMake([self screenCenter].x, kOffset + [self statusBarOffset] + self.bounds.size.height/2);
            _angle = 0.0;
            break;
    }
    [self.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:kCornerRadius].CGPath];
}

- (void)setSizesForText:(NSString *)text andIcon:(BOOL)hasIcon {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float reserved = (kOffset * 2) + (kPadding * 2);
    if(hasIcon) {
        reserved += kIconSize + kPadding/2;
    }
    float portraitWidth = fmin(screenSize.width, kMaxWidth);
    float landscapeWidth = fmin(screenSize.height, kMaxWidth);
    
    CGSize portraitSize = [text sizeWithFont:[UIFont fontWithName:kFontName size:kFontSize]
                           constrainedToSize:CGSizeMake(portraitWidth - reserved, CGFLOAT_MAX)];
    _portraitSize = CGSizeMake(portraitWidth - (kOffset * 2), portraitSize.height + kIconSize);
    
    CGSize landscapeSize = [text sizeWithFont:[UIFont fontWithName:kFontName size:kFontSize]
                            constrainedToSize:CGSizeMake(landscapeWidth - reserved, CGFLOAT_MAX)];
    _landscapeSize = CGSizeMake(landscapeWidth - (kOffset * 2), landscapeSize.height + kIconSize);
}

- (CGPoint)screenCenter {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGPoint center = CGPointMake(screenSize.width/2, screenSize.height/2);
    return center;
}

- (CGSize)getSizeForCurrentOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        return _landscapeSize;
    }
    else {
        return _portraitSize;        
    }
}

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
    [super dealloc];
}

@end