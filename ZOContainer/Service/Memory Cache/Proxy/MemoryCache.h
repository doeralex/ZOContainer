//
//  MemoryCache.h
//  ZOContainer
//
//  Created by zenone on 2017/9/13.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import "ZOServiceProxy.h"
#import "MemoryCacheable.h"

@interface MemoryCache : ZOServiceProxy <MemoryCacheable>

+ (instancetype)defaultCache;

@end
