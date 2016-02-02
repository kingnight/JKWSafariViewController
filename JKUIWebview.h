//
//  JKUIWebview.h
//  LibSafariViewController
//
//  Created by jinkai on 16/1/28.
//  Copyright © 2016年 jinkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JKUIWebviewDelegate <NSObject>

- (void)uiWebViewDidMissed;
- (void)uiWebViewDidFinished;
- (void)uiWebViewDidFailedWithError:(NSError *)error;
@end


@interface JKUIWebview : UIView

@property (nonatomic,weak) id<JKUIWebviewDelegate> delegate;

@property (nonatomic,strong) UIViewController *currentViewController;

@property (nonatomic,strong) UIColor *statusBarBGColor;

- (instancetype)initWithFrame:(CGRect)frame andURLString:(NSString *)urlString;

@end
