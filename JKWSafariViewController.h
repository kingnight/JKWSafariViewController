//
//  JKWSafariViewController.h
//  LibSafariViewController
//
//  Created by jinkai on 16/1/25.
//  Copyright © 2016年 jinkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKWSafariViewController;

@protocol JKWSafariViewControllerDelegate <NSObject>
/**
 *  用户点击完成按钮，页面关闭回调函数
 *
 *  @param controller 当前操作的ViewController对象
 */
- (void)JKWSafariViewControllerDidFinish:(JKWSafariViewController *)controller;
/**
 *  页面加载完成或失败回调函数
 *
 *  @param controller          当前操作的ViewController对象
 *  @param didLoadSuccessfully 是否加载成功
 */
- (void)JKWSafariViewController:(JKWSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully;

@end

/**
 *  JKWSafariViewController用于替代SFSafariViewController，支持iOS6+系统，在各个版本上展示一致的用户界面
 */
@interface JKWSafariViewController : UIViewController
/**
 *  tint color 设置
 */
@property (nonatomic,strong) UIColor *tintColor;
/**
 *  状态栏背景色设置
 */
@property (nonatomic,strong) UIColor *statusBarBGColor;
/**
 *  初始化函数
 *
 *  @param URL 请求地址
 *
 *  @return 页面对象
 */
- (instancetype)initWithURL:(NSURL *)URL;
/**
 *  代理
 */
@property(nonatomic, weak) id<JKWSafariViewControllerDelegate> delegate;

@end
