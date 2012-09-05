NotificationManager
=========================

NotificationManager can be used to display notifications from any part of your app to the user; similar to the Game Center notifications, but with more features.

Features
--------

- 9 Different styles to choose from
- Can be used with or without an icon
- Custom duration
- Multi-line text
- Customizable look
- Perform an action when notification is tapped
- Adjusts to any device orientation
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

To display a notification, call:

<pre>
    [NotificationManager notifyText:@"This is a notification."
                               icon:@"icon_info.png"
                              style:NotificationStyleSlideInTop
                           duration:2
                             target:nil
                           selector:nil
                    showImmediately:NO];
</pre>

- Pass a `nil` parameter to `icon` to not display an icon
- To perform a selector when the notification is tapped, specify a target and selector
- Notifications are queued and are shown one by one. If you want to skip the queue, pass a `YES` parameter to `showImmediately`

Customization
-------------

To customize the look of the notifications, open the `NotificationManager.h` file and change the defined constants to alter the font, size and colors.