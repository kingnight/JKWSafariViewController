# JKWSafariViewController

a replace of SFSafariViewController,support iOS6+



## Problem

SFSafariViewController is a handy class provides a standard interface for browsing the web, but only used from iOS9+. JKWSafariViewController make a standard interface for different iOS version ,  support iOS6+



## Feature

- provides a standard interface for browsing the web
- support landscape and portrait  orientation  change
- support iPhone and iPad
- support In-App App Store



## Usage

``` objective-c
#import "JKWSafariViewController.h"

JKWSafariViewController *controller = [[JKWSafariViewController alloc]initWithURL:[NSURL 		URLWithString:@"http://www.baidu.com"]];
controller.tintColor = [UIColor redColor];//optinal 
controller.statusBarBGColor = [UIColor greenColor];//optinal, avialable in iOS8 and below
[self presentViewController:controller animated:YES completion:nil];
```



## Requirements

- UIKit.framework
- StoreKit.framework
- WebKit.framework
- Xcode 7+
- Base SDK iOS 9.0+

