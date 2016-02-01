//
//  JKWSafariViewController.m
//  LibSafariViewController
//
//  Created by jinkai on 16/1/25.
//  Copyright © 2016年 jinkai. All rights reserved.
//

#import "JKWSafariViewController.h"
#import <StoreKit/StoreKit.h>
#import "JKWInternalConfig.h"
#import "JKWKWebView.h"
#import "JKUIWebview.h"
#import <SafariServices/SafariServices.h>

@import SafariServices;

#define APPSTORE_HOST @"itunes.apple.com"

typedef NS_ENUM(NSInteger,JKWSafariViewUseType) {
    JKWSafariViewAppstore = 1,
    JKWSafariViewSF,
    JKWSafariViewWKWebview,
    JKWSafariViewUIWebview
};

@interface JKWSafariViewController () <SFSafariViewControllerDelegate,SKStoreProductViewControllerDelegate,JKWKWebViewDelegate,JKUIWebviewDelegate>
{
    JKWKWebView *WKwebview;
    JKUIWebview *jkuiwebview;
    JKWSafariViewUseType useType;
    SFSafariViewController *safariVC;
    UIColor *oldTintColor;
    UIColor *newTintColor;
    UIColor *statusBarBackgroudColor;
    BOOL viewLoad;
    SKStoreProductViewController *sKStoreProductViewController;
}

@property (nonatomic,assign) NSInteger systemVer;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) NSString *urlStr;
@property (nonatomic,assign) BOOL isAppleStoreLink;
@end

@implementation JKWSafariViewController 

- (instancetype)initWithURL:(NSURL *)URL{
    if ([super init]) {
        if ([URL.host isEqualToString:APPSTORE_HOST]) {
            self.isAppleStoreLink = YES;
            
        }
        else
            self.isAppleStoreLink = NO;
        
        _systemVer = [[UIDevice currentDevice].systemVersion intValue];
        self.url = URL;
        viewLoad = NO;
    }
    return self;
}

#pragma mark - life recycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSInteger width = self.view.frame.size.width;
    NSInteger height = self.view.frame.size.height;
    
    //In-App App Store
    //SKStoreProductViewController 支持iOS6+
    if (self.isAppleStoreLink) {
        useType = JKWSafariViewAppstore;
        if (newTintColor) {
        [[UINavigationBar appearance] setTintColor:newTintColor];
        }
        NSString *appId = [self appIdInURL:self.url];
        [self showAppInApp:appId];
        viewLoad = YES;
        return;
    }
    //使用SFSafariViewController 支持iOS9+
    if (_systemVer>=9) {
        useType = JKWSafariViewSF;
        return;
    }
    //使用WKWebview 支持iOS8+
    if (_systemVer>=8) {
        useType = JKWSafariViewWKWebview;
        WKwebview = [[JKWKWebView alloc]initWithFrame:CGRectMake(0, 0, width, height) andURLString:[self.url absoluteString]];
        WKwebview.currentViewController = self;
        WKwebview.delegate = self;
        if (newTintColor) {
            WKwebview.tintColor = newTintColor;
        }
        if (statusBarBackgroudColor) {
            [WKwebview setStatusBarBGColor:statusBarBackgroudColor];
        }
        [self.view addSubview:WKwebview];
        viewLoad = YES;
        return;
    }

    //使用UIWebView
    jkuiwebview = [[JKUIWebview alloc]initWithFrame:CGRectMake(0, 0, width, height) andURLString:[self.url absoluteString]];
    jkuiwebview.delegate = self;
    jkuiwebview.currentViewController =self;
    if (newTintColor) {
        jkuiwebview.tintColor = newTintColor;
    }
    if (statusBarBackgroudColor) {
        [jkuiwebview setStatusBarBGColor:statusBarBackgroudColor];
    }
    [self.view addSubview:jkuiwebview];
    useType = JKWSafariViewUIWebview;
    viewLoad = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!viewLoad && _systemVer>=9 && !self.isAppleStoreLink) {
        safariVC = [[SFSafariViewController alloc]initWithURL:self.url entersReaderIfAvailable:NO];
        safariVC.delegate = self;
        if (newTintColor) {
            [safariVC.view setTintColor:newTintColor];
        }
        
        [self presentViewController:safariVC animated:YES completion:nil];
        viewLoad = YES;
        return;
    }
}

- (void)dealloc{
    WKwebview = nil;
    jkuiwebview = nil;
    safariVC = nil;
    oldTintColor = nil;
    newTintColor = nil;
    statusBarBackgroudColor = nil;
    viewLoad = NO;
    sKStoreProductViewController = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)setTintColor:(UIColor *)tintColor{
    oldTintColor = [[UINavigationBar appearance] tintColor];
    newTintColor = tintColor;
}

- (void)setStatusBarBGColor:(UIColor *)statusBarBGColor
{
    statusBarBackgroudColor = statusBarBGColor;
}

- (void)restoreSystemColor{
    [[UINavigationBar appearance] setTintColor:oldTintColor];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - private method

- (NSString *)appIdInURL:(NSURL *)appStoreURL {
    NSString * appId = nil;
    NSRange range = [appStoreURL.absoluteString rangeOfString:@"/id"];
    if (range.length!=0) {
        appId = [[appStoreURL.absoluteString componentsSeparatedByString:@"/id"] lastObject];
        NSRange range2 = [appStoreURL.absoluteString rangeOfString:@"?"];
        if (range2.length!=0)
            appId = [[appId componentsSeparatedByString:@"?"] firstObject];
    }
    
    return appId;
}

- (void)dismissRootViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//custom close
- (void)closeJKWSafariViewController{
    if (useType == JKWSafariViewAppstore) {
        if (sKStoreProductViewController) {
            [sKStoreProductViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (useType == JKWSafariViewSF) {
        if (safariVC) {
            [safariVC dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (useType == JKWSafariViewWKWebview) {
        if (WKwebview) {
            [WKwebview removeFromSuperview];
        }
    }
    if (useType == JKWSafariViewUIWebview) {
        if (jkuiwebview) {
            [jkuiwebview removeFromSuperview];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewControllerDidFinish:)]) {
        [_delegate JKWSafariViewControllerDidFinish:self];
    }
    
    [self dismissRootViewController];
}

#pragma mark - AppStore
- (void)showAppInApp:(NSString *)_appId {
    Class isAllow = NSClassFromString(@"SKStoreProductViewController");
    if (isAllow != nil) {
        sKStoreProductViewController = [[SKStoreProductViewController alloc] init];
        sKStoreProductViewController.delegate = self;
        
        [sKStoreProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: _appId}
                                      completionBlock:^(BOOL result, NSError *error) {
                                         if (result) {
                                                //避免UI阻塞
                                            }
                                         else{
                                             NSLog(@"%@",error);
                                         }
                                    }];
        [self presentViewController:sKStoreProductViewController animated:YES completion:nil];
    }
    else{
        //低于iOS6没有这个类
        NSString *string = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/id%@?mt=8",_appId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate
//对视图消失的处理
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    if (viewController) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }
    [self dismissRootViewController];
    if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewControllerDidFinish:)]) {
        [_delegate JKWSafariViewControllerDidFinish:self];
    }
}

#pragma mark - SFSafariViewController delegate methods
-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    // Load finished
    if (didLoadSuccessfully) {
        if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewController:didCompleteInitialLoad:)]) {
            [_delegate JKWSafariViewController:self didCompleteInitialLoad:YES];
        }
    }
    else{
        if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewController:didCompleteInitialLoad:)]) {
            [_delegate JKWSafariViewController:self didCompleteInitialLoad:NO];
        }
    }
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self dismissRootViewController];
    if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewControllerDidFinish:)]) {
        [_delegate JKWSafariViewControllerDidFinish:self];
    }
}

#pragma mark - JKWKWebViewDelegate

- (void)wkWebViewDidMissed
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewControllerDidFinish:)]) {
        [_delegate JKWSafariViewControllerDidFinish:self];
    }
}

- (void)wkWebViewDidFinished{
    if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewController:didCompleteInitialLoad:)]) {
        [_delegate JKWSafariViewController:self didCompleteInitialLoad:YES];
    }
}

- (void)wkWebViewDidFailedWithError:(NSError *)error{
    if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewController:didCompleteInitialLoad:)]) {
        [_delegate JKWSafariViewController:self didCompleteInitialLoad:NO];
    }
}

#pragma mark - JKUIWebviewDelegate

- (void)uiWebViewDidMissed{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewControllerDidFinish:)]) {
        [_delegate JKWSafariViewControllerDidFinish:self];
    }
}

- (void)uiWebViewDidFinished{
    if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewController:didCompleteInitialLoad:)]) {
        [_delegate JKWSafariViewController:self didCompleteInitialLoad:YES];
    }
}

- (void)uiWebViewDidFailedWithError:(NSError *)error{
    if (_delegate && [_delegate respondsToSelector:@selector(JKWSafariViewController:didCompleteInitialLoad:)]) {
        [_delegate JKWSafariViewController:self didCompleteInitialLoad:NO];
    }
}

@end
