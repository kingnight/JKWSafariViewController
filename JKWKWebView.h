//
//  JKWKWebView.h
//  LibSafariViewController
//
//  Created by jinkai on 16/1/25.
//  Copyright © 2016年 jinkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JKWKWebViewDelegate <NSObject>

- (void)wkWebViewDidMissed;
- (void)wkWebViewDidFinished;
- (void)wkWebViewDidFailedWithError:(NSError *)error;
@end


@interface JKWKWebView : UIView

@property (nonatomic,weak) id<JKWKWebViewDelegate> delegate;

@property (nonatomic,strong) UIViewController *currentViewController;

@property (nonatomic,strong) UIColor *statusBarBGColor;

- (instancetype)initWithFrame:(CGRect)frame andURLString:(NSString *)urlString;
@end
