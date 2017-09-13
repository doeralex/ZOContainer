//
//  ViewController.m
//  ZOContainer
//
//  Created by zenone on 2017/9/13.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import "ViewController.h"
#import "MemoryCache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[MemoryCache defaultCache] setObject:@"Beijing" forKey:@"city"];
    NSLog(@"%d - %s:%@", __LINE__, __FUNCTION__, [[MemoryCache defaultCache] objectForKey:@"city"]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
