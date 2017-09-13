//
//  MemoryCacheable.h
//  ZOContainer
//
//  Created by zenone on 2017/9/13.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MemoryCacheable <NSObject>

- (void)setObject:(id)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

@end
