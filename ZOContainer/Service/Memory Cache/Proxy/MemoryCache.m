//
//  MemoryCache.m
//  ZOContainer
//
//  Created by zenone on 2017/9/13.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import "MemoryCache.h"
#import "ZOContainer.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation MemoryCache
#pragma clang diagnostic pop

+ (instancetype)defaultCache {
    static MemoryCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [MemoryCache alloc];
    });
    return cache;
}

- (id)realObject {
    return [[ZOContainer defaultContainer] makeServiceWithProtocol:@protocol(MemoryCacheable)];
}

@end
