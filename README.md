NotificationManager
=========================

NotificationManager is a stand-alone class that can be used to display notifications to the user similar to the Game Center notifications, but with more features.

Features
--------

- Adjusts to any device orientation
- Customizable duration and several other parameters
- Supports custom icon
- Multi-line text
- 2 different styles: Slide-In and Fade-In
- Supported on iPhone and iPad with iOS 3.2 onwards

Installation
------------

1. Add the `QuartzCore` Framework to your Xcode project

2. Add the following files to your Xcode project (make sure to select Copy Items in the dialog):
 - NotificationManager.h  
 - NotificationManager.m

3. Import the `NotificationManager.h` file

Usage
-----

Display a text-only notification:

<pre>
    [[NotificationManager defaultManager] notifyText:@"This is a notification."
                                           withStyle:NotificationStyleSlideIn];
</pre>

Display a notification with specified icon:

<pre>
    [[NotificationManager defaultManager] notifyText:@"This is a notification with an icon."
                                            withIcon:@"icon_info.png"
                                           withStyle:NotificationStyleSlideIn];
</pre>

Display notification using Fade-In style:

<pre>
    [[NotificationManager defaultManager] notifyText:@"This is a fade-in notification."
                                           withStyle:NotificationStyleFadeIn];
</pre>

Display notification with custom duration:

<pre>
    [[NotificationManager defaultManager] notifyText:@"This notification is taking too long."
                                           withStyle:NotificationStyleFadeIn
                                         forDuration:5];
</pre>

Separate your text with `/n` to use multi-line notifications:

<pre>
    [[NotificationManager defaultManager] notifyText:@"This is the first line./nThis is the second line"
                                           withStyle:NotificationStyleSlideIn];
</pre>

Force a notification to any orientation:

<pre>
    [[NotificationManager defaultManager] notifyText:@"This notification is for Landscape (Left) orientation"
                                           withStyle:NotificationStyleFadeIn 
                                    forceOrientation:UIInterfaceOrientationLandscapeLeft];
</pre>

Customization
-------------

To customize the look of the notifications, open the `NotificationManager.h` file and change the defined constants to alter the font, size and colors.