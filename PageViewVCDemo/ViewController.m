//
//  ViewController.m
//  PageViewVCDemo
//
//  Created by 杜文亮 on 2017/10/25.
//  Copyright © 2017年 杜文亮. All rights reserved.
//

#define DRandomColor  [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0f];


#import "ViewController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = DRandomColor;
}

-(void)dealloc
{
    NSLog(@"子控制器释放");
}

@end
