//
//  ViewController.m
//  LibSafariViewController
//
//  Created by jinkai on 16/1/25.
//  Copyright © 2016年 jinkai. All rights reserved.
//

#import "ViewController.h"
#import "JKWSafariViewController.h"

@interface ViewController ()

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
    JKWSafariViewController *controller = [[JKWSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/sou-gou-shu-ru-fa-dai-biao/id917670924?mt=8"]];
    
    [self.view.window.rootViewController presentViewController:controller animated:YES completion:nil];
}
- (IBAction)openNormal:(UIButton *)sender {
    JKWSafariViewController *controller = [[JKWSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    controller.tintColor = [UIColor redColor];
    controller.statusBarBGColor = [UIColor greenColor];
    [self.view.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

@end
