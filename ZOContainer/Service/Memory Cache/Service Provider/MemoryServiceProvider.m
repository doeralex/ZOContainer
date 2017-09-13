//
//  MemoryServiceProvider.m
//  ZOContainer
//
//  Created by zenone on 2017/9/13.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import "MemoryServiceProvider.h"
#import "MemoryCacheable.h"
#import "YYMemoryCacheFacade.h"
#import "TMMemoryCacheFacade.h"

@implementation MemoryServiceProvider
- (void)provideServices {
    [self provideServiceUsingConstructor:^id(ZOContainer *container) {
        return [TMMemoryCacheFacade new];
//        return [YYMemoryCacheFacade new];
    } withProtocol:@protocol(MemoryCacheable) context:Nil shared:YES];
}
@end
