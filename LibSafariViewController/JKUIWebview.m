//
//  JKUIWebview.m
//  LibSafariViewController
//
//  Created by jinkai on 16/1/28.
//  Copyright © 2016年 jinkai. All rights reserved.
//

#import "JKUIWebview.h"
#import "JKWInternalConfig.h"

@interface JKUIWebview () <UIWebViewDelegate>
{
    NSString *_urlString;
    UIBarButtonItem *backItem;
    UIBarButtonItem *forwoardItem;
    UIBarButtonItem *shareItem;
    UIBarButtonItem *safriItem;
    UIToolbar *toolbar;
}
@property (nonatomic ,strong) UIWebView *webView;
@property (nonatomic ,strong) UITextField *inputURLField;
@property (nonatomic ,strong) UIButton *closeBtn;
@property (nonatomic ,strong) UIView *barBackgroundView;
@property (nonatomic ,strong) UIButton *stopReloadBtn;

@end


@implementation JKUIWebview

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

    //刷新停止按钮
    self.stopReloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopReloadBtn setImage:[UIImage imageNamed:@"icon_stop"] forState:UIControlStateNormal];
    self.stopReloadBtn.frame = CGRectMake(self.bounds.size.width-45, yPos, 30, itemHeight);
    [self.stopReloadBtn addTarget:self action:@selector(stopReload) forControlEvents:UIControlEventTouchUpInside];
    [self.barBackgroundView insertSubview:self.stopReloadBtn aboveSubview:self.inputURLField];
    
    [self addSubview:self.barBackgroundView];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, barBackgroundViewHeight+20, self.bounds.size.width, self.bounds.size.height-44)];
    self.webView.delegate = self;
    [self insertSubview:self.webView belowSubview:self.barBackgroundView];
    
    //constraints
//    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.barBackgroundView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
//    [self addConstraint:widthConstraint];
//    
//    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.barBackgroundView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//    [self addConstraint:topConstraint];
//    
//    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
//    [self addConstraint:heightConstraint];
    
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
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [self.webView removeFromSuperview];
    
    [self.barBackgroundView removeFromSuperview];
    self.barBackgroundView =nil;
    
    [toolbar removeFromSuperview];
    toolbar=nil;
    
    if (_delegate && [_delegate respondsToSelector:@selector(uiWebViewDidMissed)]) {
        [_delegate uiWebViewDidMissed];
    }
}

-(void)setStatusBarBGColor:(UIColor *)statusBarBGColor
{
    [self.barBackgroundView setBackgroundColor:statusBarBGColor];
}

#pragma mark - Orientation Change

- (void)handleDidChangeStatusBarOrientationNotification:(NSNotification *)notification;
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    float width = size.width>size.height ? size.width:size.height;
    float height = size.width>size.height ? size.height:size.width;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        self.frame = CGRectMake(0, 0, width, height);
        [self setHorizontalFrame];
    }else {
        self.frame = CGRectMake(0, 0, height, width);
        [self setVerticalFrame];
    }
}

- (void)setVerticalFrame{
    NSLog(@"Vertical");
    self.barBackgroundView.frame = CGRectMake(0, 20, self.bounds.size.width, barBackgroundViewHeight);
    self.inputURLField.frame = CGRectMake(50,yPos,self.bounds.size.width-60,itemHeight);
    self.stopReloadBtn.frame = CGRectMake(self.bounds.size.width-45, yPos, 30, itemHeight);
    toolbar.frame = CGRectMake(0, self.bounds.size.height-44, self.bounds.size.width, 44);
    self.webView.frame = CGRectMake(0, barBackgroundViewHeight+20, self.bounds.size.width, self.bounds.size.height-44);
    [self setNeedsDisplay];
}

- (void)setHorizontalFrame{
    NSLog(@"Horizontal");
    NSInteger systemVer = [[UIDevice currentDevice].systemVersion intValue];
    if (systemVer < 8) {
        self.barBackgroundView.frame = CGRectMake(0, 20, self.bounds.size.width, barBackgroundViewHeight);
    }
    self.inputURLField.frame = CGRectMake(50,yPos,self.bounds.size.width-60,itemHeight);
    self.stopReloadBtn.frame = CGRectMake(self.bounds.size.width-45, yPos, 30, itemHeight);
    toolbar.frame = CGRectMake(0, self.bounds.size.height-44, self.bounds.size.width, 44);
    self.webView.frame = CGRectMake(0, barBackgroundViewHeight+20, self.bounds.size.width, self.bounds.size.height-44);
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
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
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

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    backItem.enabled = self.webView.canGoBack;
    forwoardItem.enabled = self.webView.canGoForward;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    backItem.enabled = self.webView.canGoBack;
    forwoardItem.enabled = self.webView.canGoForward;
    if (_delegate && [_delegate respondsToSelector:@selector(uiWebViewDidFinished)]) {
        [_delegate uiWebViewDidFinished];
    }
    [self.stopReloadBtn setImage:[UIImage imageNamed:@"icon_refresh"] forState:UIControlStateNormal];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%s error %@",__func__,error.debugDescription);
    if (_delegate && [_delegate respondsToSelector:@selector(uiWebViewDidFailedWithError:)]) {
        [_delegate uiWebViewDidFailedWithError:error];
    }
}

@end
