//
//  YYMemoryCacheFacade.m
//  ZOContainer
//
//  Created by zenone on 2017/9/13.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import "YYMemoryCacheFacade.h"
#import <YYCache/YYMemoryCache.h>

@interface YYMemoryCacheFacade ()
@property (nonatomic, strong) YYMemoryCache *cache;
@end

@implementation YYMemoryCacheFacade

- (YYMemoryCache *)cache {
    if (_cache != nil) {
        return _cache;
    }
    
    _cache = [YYMemoryCache new];
    return _cache;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [self.cache setObject:object forKey:key];
}

- (id)objectForKey:(NSString *)key {
    return [self.cache objectForKey:key];
}

@end
