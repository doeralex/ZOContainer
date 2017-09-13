//
//  TMMemoryCacheFacade.m
//  ZOContainer
//
//  Created by zenone on 2017/9/13.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import "TMMemoryCacheFacade.h"
#import <TMCache/TMMemoryCache.h>

@interface TMMemoryCacheFacade ()
@property (nonatomic, strong) TMMemoryCache *cache;
@end

@implementation TMMemoryCacheFacade
- (TMMemoryCache *)cache {
    if (_cache != nil) {
        return _cache;
    }
    
    _cache = [TMMemoryCache new];
    return _cache;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [self.cache setObject:object forKey:key];
}

- (id)objectForKey:(NSString *)key {
    return [self.cache objectForKey:key];
}

@end
