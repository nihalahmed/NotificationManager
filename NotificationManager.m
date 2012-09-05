//
//  NotificationManager.m
//
//  Created by Nihal Ahmed on 12-03-16.
//  Copyright (c) 2012 NABZ Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "NotificationManager.h"

#pragma mark - Notification Window

@interface NotificationWindow : UIWindow
@end

@implementation NotificationWindow

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == [self.subviews objectAtIndex:0]) {
        return nil;
    }
    else {
        return hitView;   
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return YES;
}

@end

#pragma mark - Notification View Controller

@interface NotificationViewController : UIViewController

@end

@implementation NotificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    CGRect frame;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    }
    else {
        frame = [[UIScreen mainScreen] bounds];
    }
    [self.view setFrame:frame];
    [self setWantsFullScreenLayout:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == [[UIApplication sharedApplication] statusBarOrientation]);
}

@end

#pragma mark - Notification

@interface Notification : UIView

- (id)initWithText:(NSString *)text icon:(NSString *)icon style:(NotificationStyle)style duration:(NSTimeInterval)duration target:(id)target selector:(SEL)selector;
- (void)show;
- (NSMutableArray *)splitString:(NSString*)str maxWidth:(CGFloat)width forFont:(UIFont *)font;

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIWindow *oldWindow;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIViewController *modalViewController;
@property (nonatomic, assign) UILabel *textLabel;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, assign) NotificationStyle style;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) NSMutableArray *lines;

@end

@implementation Notification

@synthesize delegate, oldWindow, window, modalViewController;
@synthesize text = _text;
@synthesize icon = _icon;
@synthesize style = _style;
@synthesize duration = _duration;
@synthesize target = _targer;
@synthesize selector = _selector;
@synthesize textLabel = _textLabel;
@synthesize lines = _lines;

//Initialize notification object
- (id)initWithText:(NSString *)text icon:(NSString *)icon style:(NotificationStyle)style duration:(NSTimeInterval)duration target:(id)target selector:(SEL)selector
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setText:text];
        [self setIcon:icon];
        [self setStyle:style];
        [self setDuration:duration];
        [self setTarget:target];
        [self setSelector:selector];
    }
    return self;
}

//Prepare notification object with given parameters
- (void)prepareNotification
{
    CGSize size = [[self performSelector:@selector(calculateSize)] CGSizeValue];
    [self setFrame:CGRectMake(0, 0, size.width, size.height)];
    [self setUserInteractionEnabled:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    if(self.style == NotificationStyleStatusBar) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.layer setShadowRadius:1];
    [self.layer setShadowOpacity:1];
    [self.layer setMasksToBounds:NO];
    [self.layer setShadowOffset:CGSizeMake(0, 1)];
    
    //Notification background
    UIView *background = [[UIView alloc] initWithFrame:self.bounds];
    [background setBackgroundColor:kNotificationBackgroundColor];
    if(self.style != NotificationStyleStatusBar) {
        [background.layer setCornerRadius:kNotificationCornerRadius];
        [background.layer setBorderWidth:kNotificationBorderWidth];
        [background.layer setBorderColor:[kNotificationBorderColor CGColor]];
    }
    [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:background];
    [background release];
    
    //If icon specified, add it to the notification
    if(self.icon != nil) {
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kNotificationPadding, self.bounds.size.height/2 - kNotificationIconSize/2, kNotificationIconSize, kNotificationIconSize)];
        if(self.style == NotificationStyleStatusBar) {
            [iconView setFrame:CGRectMake(2, 2, 16, 16)];
        }
        [iconView setContentMode:UIViewContentModeScaleAspectFit];
        [iconView setImage:[UIImage imageNamed:self.icon]];
        [iconView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        [self addSubview:iconView];
        [iconView release];
    }
    
    //Setup notification text
    UILabel *textLabel = [[UILabel alloc] init];
    if(self.icon != nil) {
        [textLabel setFrame:CGRectMake(kNotificationIconSize + (kNotificationPadding * 1.5), 0.0f, self.bounds.size.width - kNotificationIconSize - (kNotificationPadding * 2.5), self.bounds.size.height)];
        if(self.style == NotificationStyleStatusBar) {
            [textLabel setFrame:CGRectMake(20, 0.0f, self.bounds.size.width - 22, self.bounds.size.height)];
        }
    }
    else {
        [textLabel setFrame:CGRectMake(kNotificationPadding, 0.0f, self.bounds.size.width - (kNotificationPadding * 2), self.bounds.size.height)];
        if(self.style == NotificationStyleStatusBar) {
            [textLabel setFrame:CGRectMake(2, 0.0f, self.bounds.size.width - 4, self.bounds.size.height)];
        }
    }
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setTextColor:kNotificationTextColor];
    [textLabel setText:self.text];
    [textLabel setTextAlignment:UITextAlignmentCenter];
    [textLabel setFont:[UIFont fontWithName:kNotificationFontName size:kNotificationFontSize]];
    if(self.style == NotificationStyleStatusBar) {
        [textLabel setTextAlignment:UITextAlignmentLeft];
        [textLabel setFont:[UIFont fontWithName:kNotificationFontName size:12]];
    }
    [textLabel setNumberOfLines:0];
    [textLabel setLineBreakMode:UILineBreakModeWordWrap];
    [textLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:textLabel];
    [textLabel release];
    [self setTextLabel:textLabel];
    
    if(self.target != nil && self.selector != nil) {
        [self.window setUserInteractionEnabled:YES];
        [self setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notificationTapped)];
        [tapGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
    
    switch (_style) {
        case NotificationStyleFadeInBottom: {
            [self setCenter:CGPointMake(self.modalViewController.view.bounds.size.width/2, self.modalViewController.view.bounds.size.height - self.bounds.size.height/2 - kNotificationOffset)];
            [self setAlpha:0];
            break;
        }
        case NotificationStyleFadeInCenter: {
            [self setCenter:CGPointMake(self.modalViewController.view.bounds.size.width/2, self.modalViewController.view.bounds.size.height/2)];
            [self setAlpha:0];
            break;
        }
        case NotificationStyleFadeInTop: {
            [self setCenter:CGPointMake(self.modalViewController.view.bounds.size.width/2, self.bounds.size.height/2 + kNotificationOffset)];
            [self setAlpha:0];
            break;
        }
        case NotificationStyleSlideInBottom: {
            [self setCenter:CGPointMake(self.modalViewController.view.bounds.size.width/2, self.modalViewController.view.bounds.size.height + self.bounds.size.height/2)];
            break;
        }
        case NotificationStyleSlideInTop: {
            [self setCenter:CGPointMake(self.modalViewController.view.bounds.size.width/2, -self.bounds.size.height/2)];
            break;
        }
        case NotificationStyleZoomInBottom: {
            [self setCenter:CGPointMake(self.modalViewController.view.bounds.size.width/2, self.modalViewController.view.bounds.size.height - self.bounds.size.height/2 - kNotificationOffset)];
            [self setAlpha:0];
            [self setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
            break;
        }
        case NotificationStyleZoomInCenter: {
            [self setCenter:CGPointMake(self.modalViewController.view.bounds.size.width/2, self.modalViewController.view.bounds.size.height/2)];
            [self setAlpha:0];
            [self setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
            break;
        }
        case NotificationStyleZoomInTop: {
            [self setCenter:CGPointMake(self.modalViewController.view.bounds.size.width/2, self.bounds.size.height/2 + kNotificationOffset)];
            [self setAlpha:0];
            [self setTransform:CGAffineTransformMakeScale(0.1, 0.1)];
            break;
        }
        case NotificationStyleStatusBar: {
            [self setCenter:CGPointMake(self.modalViewController.view.bounds.size.width/2, -self.bounds.size.height/2)];
            if(self.icon != nil) {
                [self setLines:[self splitString:self.text maxWidth:self.frame.size.width - 20 forFont:self.textLabel.font]];
            }
            else {
                [self setLines:[self splitString:self.text maxWidth:self.frame.size.width - 2 forFont:self.textLabel.font]];                
            }
            [self.textLabel setText:[self.lines objectAtIndex:0]];
            [self.lines removeObjectAtIndex:0];
            break;
        }
    }
}

//Show notification
- (void)show
{
    [self setModalViewController:[[[NotificationViewController alloc] init] autorelease]];
    
    NotificationWindow *aWindow = [[NotificationWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [aWindow setWindowLevel:UIWindowLevelStatusBar];
    [aWindow setBackgroundColor:[UIColor clearColor]];
    [aWindow setUserInteractionEnabled:NO];
    [aWindow addSubview:self.modalViewController.view];
    [self setWindow:aWindow];
    [aWindow release];
    
    [self setOldWindow:[[UIApplication sharedApplication] keyWindow]];
    [self.modalViewController.view addSubview:self];
    [self.window makeKeyAndVisible];
    
    [self performSelector:@selector(prepareNotification)];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(notificationDidShow)];
    switch (_style) {
        case NotificationStyleFadeInBottom: {
            [self setAlpha:1];
            break;
        }
        case NotificationStyleFadeInCenter: {
            [self setAlpha:1];
            break;
        }
        case NotificationStyleFadeInTop: {
            [self setAlpha:1];
            break;
        }
        case NotificationStyleSlideInBottom: {
            [self setTransform:CGAffineTransformMakeTranslation(0, -(self.bounds.size.height + kNotificationOffset))];
            break;
        }
        case NotificationStyleSlideInTop: {
            [self setTransform:CGAffineTransformMakeTranslation(0, self.bounds.size.height + kNotificationOffset)];
            break;
        }
        case NotificationStyleZoomInBottom: {
            [self setAlpha:1];
            [self setTransform:CGAffineTransformIdentity];
            break;
        }
        case NotificationStyleZoomInCenter: {
            [self setAlpha:1];
            [self setTransform:CGAffineTransformIdentity];
            break;
        }
        case NotificationStyleZoomInTop: {
            [self setAlpha:1];
            [self setTransform:CGAffineTransformIdentity];
            break;
        }
        case NotificationStyleStatusBar: {
            [self setTransform:CGAffineTransformMakeTranslation(0, self.bounds.size.height)];
            break;
        }
    }
    [UIView commitAnimations];    
}

//Callback when notification shows
- (void)notificationDidShow
{
    if(self.style == NotificationStyleStatusBar && self.lines.count > 0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelay:self.duration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(statusBarNotificationShowNextLine)];
        [self.textLabel setAlpha:0];
        [UIView commitAnimations];
    }
    else {
        [self performSelector:@selector(hide) withObject:nil afterDelay:self.duration];
    }
}

//Hide notification
- (void)hide
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(notificationDidHide)];
    switch (_style) {
        case NotificationStyleFadeInBottom: {
            [self setAlpha:0];
            break;
        }
        case NotificationStyleFadeInCenter: {
            [self setAlpha:0];
            break;
        }
        case NotificationStyleFadeInTop: {
            [self setAlpha:0];
            break;
        }
        case NotificationStyleSlideInBottom: {
            [self setTransform:CGAffineTransformIdentity];
            break;
        }
        case NotificationStyleSlideInTop: {
            [self setTransform:CGAffineTransformIdentity];
            break;
        }
        case NotificationStyleZoomInBottom: {
            [self setAlpha:0];
            break;
        }
        case NotificationStyleZoomInCenter: {
            [self setAlpha:0];
            break;
        }
        case NotificationStyleZoomInTop: {
            [self setAlpha:0];
            break;
        }
        case NotificationStyleStatusBar: {
            [self setTransform:CGAffineTransformIdentity];
            break;
        }
    }
    [UIView commitAnimations];
}

//Callback when notification hides
- (void)notificationDidHide
{
    [self.oldWindow makeKeyWindow];
    if([self.delegate respondsToSelector:@selector(notificationDidHide:)]) {
        [self.delegate performSelector:@selector(notificationDidHide:) withObject:self];
    }
    [self removeFromSuperview];
}

//Called when notification is tapped
- (void)notificationTapped
{
    if([self.target respondsToSelector:self.selector]) {
        [self.target performSelector:self.selector];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self notificationDidHide];
}

//Show the next line for NotificationStyleStatusBar
- (void)statusBarNotificationShowNextLine
{
    [self.textLabel setText:[self.lines objectAtIndex:0]];
    [self.lines removeObjectAtIndex:0];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(notificationDidShow)];
    [self.textLabel setAlpha:1];
    [UIView commitAnimations];
}

//Get notification size for current orientation
- (NSValue *)calculateSize
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float reserved = (kNotificationOffset * 2) + (kNotificationPadding * 2);
    if(self.icon) {
        reserved += kNotificationIconSize + kNotificationPadding/2;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        if(self.style == NotificationStyleStatusBar) {
            return [NSValue valueWithCGSize:CGSizeMake(screenSize.height, 20)];
        }
        
        float landscapeWidth = fmin(screenSize.height, kNotificationMaxWidth);
        CGSize landscapeSize = [self.text sizeWithFont:[UIFont fontWithName:kNotificationFontName size:kNotificationFontSize]
                                     constrainedToSize:CGSizeMake(landscapeWidth - reserved, CGFLOAT_MAX)];
        return [NSValue valueWithCGSize:CGSizeMake(landscapeSize.width - (kNotificationOffset * 2) + reserved, landscapeSize.height + kNotificationPadding * 2)];
    }
    else {
        if(self.style == NotificationStyleStatusBar) {
            return [NSValue valueWithCGSize:CGSizeMake(screenSize.width, 20)];
        }
        
        float portraitWidth = fmin(screenSize.width, kNotificationMaxWidth);
        CGSize portraitSize = [self.text sizeWithFont:[UIFont fontWithName:kNotificationFontName size:kNotificationFontSize]
                                    constrainedToSize:CGSizeMake(portraitWidth - reserved, CGFLOAT_MAX)];
        return [NSValue valueWithCGSize:CGSizeMake(portraitSize.width - (kNotificationOffset * 2) + reserved, portraitSize.height + kNotificationPadding * 2)];
    }
}

//Get array of lines for NotificationStyleStatusBar
- (NSMutableArray *)splitString:(NSString *)str maxWidth:(CGFloat)width forFont:(UIFont *)font
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
    NSArray *lineArray = [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for(NSString *string in lineArray) {
        NSArray *wordArray = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *line = @"";
        NSString *lineWithNext = @"";
        
        for (int i = 0; i < [wordArray count]; i++) {
            if (line.length == 0) { line = [wordArray objectAtIndex:i]; }
            
            if (i+1 < [wordArray count]) {
                lineWithNext = [[NSArray arrayWithObjects:line, [wordArray objectAtIndex:i+1], nil] componentsJoinedByString:@" "];
                if (((int)[lineWithNext sizeWithFont:font].width) <= width) {
                    line = lineWithNext;
                } else {
                    [tempArray addObject:line];
                    line = @"";
                }
            } else {
                [tempArray addObject:line];
            }
        }
    }
    return tempArray;
}

- (void)dealloc
{
    [oldWindow release];
    [window release];
    [modalViewController release];
    [_text release];
    [_icon release];
    [_lines release];
    [super dealloc];
}

@end

#pragma mark - Notification Delegate Protocol

@protocol NotificationManagerDelegate <NSObject> 

- (void)notificationDidHide:(UIView *)notification;

@end

#pragma mark - Notification Manager

@interface NotificationManager () {
    NSMutableArray *_queue;
}

+ (NotificationManager *)sharedManager;
- (void)notifyText:(NSString *)text icon:(NSString *)icon style:(NotificationStyle)style duration:(NSTimeInterval)duration target:(id)target selector:(SEL)selector showImmediately:(BOOL)showImmediately;

@end

@implementation NotificationManager

static NotificationManager *sharedManager = nil;

+ (NotificationManager *)sharedManager
{
    if(sharedManager == nil) {
        sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

- (id)init
{
    if (self = [super init]) {
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;    
}

- (id)retain
{
    return self;    
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
}

- (id)autorelease
{
    return self;
}

- (void)dealloc
{
    [_queue release];
    [super dealloc];
}

//Class method to create new notification object with given parameters
+ (void)notifyText:(NSString *)text icon:(NSString *)icon style:(NotificationStyle)style duration:(NSTimeInterval)duration target:(id)target selector:(SEL)selector showImmediately:(BOOL)showImmediately
{
    [[NotificationManager sharedManager] notifyText:text icon:icon style:style duration:duration target:target selector:selector showImmediately:showImmediately];
}

//Create new notification object with given parameters
- (void)notifyText:(NSString *)text icon:(NSString *)icon style:(NotificationStyle)style duration:(NSTimeInterval)duration target:(id)target selector:(SEL)selector showImmediately:(BOOL)showImmediately
{
    if(text == nil || text.length == 0) {
        return;
    }
    
    //Create notification object and add it to the queue
    Notification *notification = [[Notification alloc] initWithText:text icon:icon style:style duration:duration target:target selector:selector];
    if(showImmediately) {
        [notification show];
    }
    else {
        [notification setDelegate:self];
        [_queue addObject:notification];
        
        //If queue empty, then show notification immediately
        if(_queue.count == 1) {
            [notification show];
        }
    }
    [notification release];
}

//Callback recieved when a notification hides
- (void)notificationDidHide:(Notification *)notification
{
    //Remove notification from queue
    [_queue removeObject:notification];
    
    //If queue not empty, show next notification
    if(_queue.count > 0) {
        [(Notification *)[_queue objectAtIndex:0] performSelector:@selector(show) withObject:nil afterDelay:0.5];
    }
}

@end
