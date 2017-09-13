//
//  ZOFacade.m
//  ZOContainer
//
//  Created by zenone on 2017/2/4.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import "ZOServiceProxy.h"

@implementation ZOServiceProxy

#pragma mark - 类方法转发

// 类方法的转发实现原理参考 https://stackoverflow.com/questions/11551086/forwardinvocation-for-class-methods
+ (void)forwardInvocation:(NSInvocation *)invocation
{
    NSAssert([self respondsToSelector:@selector(realObjectClass)], @"realObjectClass method must be implemented");
    [invocation invokeWithTarget:[self realObjectClass]];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSAssert([self respondsToSelector:@selector(realObjectClass)], @"realObjectClass method must be implemented");
    NSMethodSignature *signature = [[self realObjectClass] methodSignatureForSelector:sel];
    return signature;
    return nil;
}

#pragma mark - 实例方法转发
- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSAssert(self.realObject != nil, @"proxy's realObject can't be nil!");
    [invocation invokeWithTarget:self.realObject];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    NSAssert(self.realObject != nil, @"proxy's realObject can't be nil!");
    NSMethodSignature *signature = [self.realObject methodSignatureForSelector:sel];
    return signature;
}

@end
