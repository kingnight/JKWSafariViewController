//
//  JKWKWebView.m
//  LibSafariViewController
//
//  Created by jinkai on 16/1/25.
//  Copyright © 2016年 jinkai. All rights reserved.
//

#import "JKWKWebView.h"
#import <WebKit/WebKit.h>
#import "JKWInternalConfig.h"

@interface JKWKWebView () <WKNavigationDelegate>{
    NSString *_urlString;
    UIBarButtonItem *backItem;
    UIBarButtonItem *forwoardItem;
    UIBarButtonItem *shareItem;
    UIBarButtonItem *safriItem;
    UIToolbar *toolbar;
}
@property (nonatomic ,strong) WKWebView *webView;
@property (nonatomic ,strong) UIProgressView *progressView;
@property (nonatomic ,strong) UITextField *inputURLField;
@property (nonatomic ,strong) UIButton *closeBtn;
@property (nonatomic ,strong) UIView *barBackgroundView;
@property (nonatomic ,strong) UIButton *stopReloadBtn;
@end


/**
 适配iOS8+ 使用UIAlertController弹出错误提示
 
 - returns: WKWebview对象
 */
@implementation JKWKWebView

- (instancetype)initWithFrame:(CGRect)frame andURLString:(NSString *)urlString{
    self = [super initWithFrame:frame];
    if (self) {
        _urlString =(NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)[urlString copy],
                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                         NULL,
                                                                                         kCFStringEncodingUTF8));
        
        [self initAllUIComponents];
    }
    return self;
}

#pragma mark - UI Layout
- (void)initAllUIComponents{
    //view
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    
    self.barBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, self.bounds.size.width, barBackgroundViewHeight)];
    [self.barBackgroundView setBackgroundColor:UIColorFromRGB(0xF9F9F9)];
    
    //完成按钮
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeBtn addTarget:self action:@selector(closeWebView) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.closeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.closeBtn.frame = CGRectMake(0, yPos, 50, itemHeight);
    [self.barBackgroundView addSubview:self.closeBtn];
    
    //地址栏
    self.inputURLField = [[UITextField alloc]initWithFrame:CGRectMake(50,yPos,self.bounds.size.width-60,itemHeight)];
    self.inputURLField.userInteractionEnabled = NO;
    self.inputURLField.text = _urlString;
    [self.inputURLField setBackgroundColor:UIColorFromRGB(0xEBECEE)];
    [self.inputURLField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.inputURLField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.inputURLField.layer.cornerRadius = 6.0f;
    [self.barBackgroundView addSubview:self.inputURLField];
    
    
    //进度条
    self.progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setProgressTintColor:[UIColor redColor]];
    self.progressView.frame = CGRectMake(0, 43, self.bounds.size.width, 1);
    [self.barBackgroundView addSubview:self.progressView];
    
    //刷新停止按钮
    self.stopReloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopReloadBtn setImage:[UIImage imageNamed:@"icon_stop"] forState:UIControlStateNormal];
    self.stopReloadBtn.frame = CGRectMake(self.bounds.size.width-45, yPos, 30, itemHeight);
    [self.stopReloadBtn addTarget:self action:@selector(stopReload) forControlEvents:UIControlEventTouchUpInside];
    [self.barBackgroundView insertSubview:self.stopReloadBtn aboveSubview:self.inputURLField];
    
    [self addSubview:self.barBackgroundView];
    
    //webview
    //    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, barBackgroundViewHeight+20, self.bounds.size.width, self.bounds.size.height-44)];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    self.webView.navigationDelegate = self;
    [self insertSubview:self.webView belowSubview:self.barBackgroundView];
    
    //constraints
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.barBackgroundView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [self addConstraint:widthConstraint];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.barBackgroundView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self addConstraint:topConstraint];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self addConstraint:heightConstraint];
    
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    
    toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, self.bounds.size.height-44, self.bounds.size.width, 44);
    backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    forwoardItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_forward"] style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    
    shareItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    safriItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(openSafri)];
    
    [toolbar setItems:[NSArray arrayWithObjects:backItem,flexible,forwoardItem,flexible,shareItem,flexible,safriItem,nil]];
    
    [self addSubview:toolbar];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidChangeStatusBarOrientationNotification:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [self.webView loadRequest:request];
}

- (void)closeWebView{
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView stopLoading];
    self.webView.navigationDelegate =nil;
    self.webView =nil;
    
    [self.barBackgroundView removeFromSuperview];
    self.barBackgroundView =nil;
    
    [toolbar removeFromSuperview];
    toolbar=nil;
    
    [self removeFromSuperview];
    
    if (_delegate && [_delegate respondsToSelector:@selector(wkWebViewDidMissed)]) {
        [_delegate wkWebViewDidMissed];
    }
}

-(void)setStatusBarBGColor:(UIColor *)statusBarBGColor
{
    [self.barBackgroundView setBackgroundColor:statusBarBGColor];
}

#pragma mark - Orientation Change
- (void)handleDidChangeStatusBarOrientationNotification:(NSNotification *)notification;
{
    // Do something interesting
    NSLog(@"The orientation is %@", [notification.userInfo objectForKey: UIApplicationStatusBarOrientationUserInfoKey]);
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        [self setVerticalFrame];
    }
    else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight){
        [self setHorizontalFrame];
    }
}

- (void)setVerticalFrame{
    NSLog(@"Vertical");
    self.barBackgroundView.frame = CGRectMake(0, 20, self.bounds.size.width, barBackgroundViewHeight);
    self.inputURLField.frame = CGRectMake(50,yPos,self.bounds.size.width-60,itemHeight);
    self.progressView.frame = CGRectMake(0, 43, self.bounds.size.width, 1);
    self.stopReloadBtn.frame = CGRectMake(self.bounds.size.width-45, yPos, 30, itemHeight);
    toolbar.frame = CGRectMake(0, self.bounds.size.height-44, self.bounds.size.width, 44);
    [self setNeedsDisplay];
}

- (void)setHorizontalFrame{
    NSLog(@"Horizontal");
    self.barBackgroundView.frame = CGRectMake(0, 0, self.bounds.size.width, barBackgroundViewHeight);
    self.inputURLField.frame = CGRectMake(50,yPos,self.bounds.size.width-60,itemHeight);
    self.progressView.frame = CGRectMake(0, 43, self.bounds.size.width, 1);
    self.stopReloadBtn.frame = CGRectMake(self.bounds.size.width-45, yPos, 30, itemHeight);
    toolbar.frame = CGRectMake(0, self.bounds.size.height-44, self.bounds.size.width, 44);
    [self setNeedsDisplay];

}

#pragma mark - Webview Action
- (void)goBack{
    [self.webView goBack];
}

- (void)goForward{
    [self.webView goForward];
}

- (void)stopReload{
    if (self.webView.loading) {
        [self.webView stopLoading];
        [self.stopReloadBtn setImage:[UIImage imageNamed:@"icon_refresh"] forState:UIControlStateNormal];
    }
    else
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.webView.URL]];
        [self.stopReloadBtn setImage:[UIImage imageNamed:@"icon_stop"] forState:UIControlStateNormal];
    }
}

- (void)shareAction{
    if (self.currentViewController) {
        NSString *url = _urlString;
        NSArray *arrayOfItems = [NSArray arrayWithObjects:url, nil];
        UIActivityViewController *activityController = [[UIActivityViewController alloc]initWithActivityItems:arrayOfItems applicationActivities:nil];
        [self.currentViewController presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)openSafri{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_urlString]];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"loading"]) {
        backItem.enabled = self.webView.canGoBack;
        forwoardItem.enabled = self.webView.canGoForward;
        
        //        self.backButton.enabled = self.webView.canGoBack;
        //        self.forwardButton.enabled = self.webView.canGoForward;
        //        self.stopReloadButton.image = self.webView.loading ? [UIImage imageNamed:@"icon_stop"] : [UIImage imageNamed:@"icon_refresh"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:self.webView.loading];
        //
        if (!self.webView.loading) {
            self.inputURLField.text = self.webView.URL.absoluteString;
        }
        
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        self.progressView.hidden = self.webView.estimatedProgress == 1;
        self.progressView.progress = self.webView.estimatedProgress;
        
        if (self.webView.estimatedProgress==1) {
            [self.stopReloadBtn setImage:[UIImage imageNamed:@"icon_refresh"] forState:UIControlStateNormal];
        }
    }
    
}

#pragma mark Webview Navigation Delegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self.progressView setProgress:0.0f animated:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(wkWebViewDidFinished)]) {
        [_delegate wkWebViewDidFinished];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.currentViewController) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self.currentViewController presentViewController:alertController animated:YES completion:nil];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(wkWebViewDidFailedWithError:)]) {
        [_delegate wkWebViewDidFailedWithError:error];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%@",navigationAction.request.URL);
    //    if ([navigationAction.request.URL.absoluteString containsString:@"&extlink=1"]) {
    //        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    //        decisionHandler(WKNavigationActionPolicyCancel);
    //    } else {
    decisionHandler(WKNavigationActionPolicyAllow);
    
    //    }
}

@end
