//
//  ViewController.m
//  LibSafariViewController
//
//  Created by jinkai on 16/1/25.
//  Copyright © 2016年 jinkai. All rights reserved.
//

#import "ViewController.h"
#import "JKWSafariViewController.h"

@interface ViewController () <JKWSafariViewControllerDelegate>
{
    JKWSafariViewController *controller;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openAppStoreLink:(UIButton *)sender {
    controller = [[JKWSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/sou-gou-shu-ru-fa-dai-biao/id917670924?mt=8"]];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
    
    [self performSelector:@selector(closeViewController) withObject:nil afterDelay:5.0f];
}
- (IBAction)openNormal:(UIButton *)sender {
    controller = [[JKWSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    controller.delegate = self;
    controller.tintColor = [UIColor redColor];
    controller.statusBarBGColor = [UIColor greenColor];
    [self presentViewController:controller animated:YES completion:nil];
    
    [self performSelector:@selector(closeViewController) withObject:nil afterDelay:5.0f];
}

#pragma mark - JKWSafariViewControllerDelegate

- (void)JKWSafariViewControllerDidFinish:(JKWSafariViewController *)controller{
    NSLog(@"%s",__FUNCTION__);
}

- (void)JKWSafariViewController:(JKWSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully{
    NSLog(@"%s,load=%d",__FUNCTION__,didLoadSuccessfully);
}

- (void)closeViewController{
    [controller closeJKWSafariViewController];
}


@end
