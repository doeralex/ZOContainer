//
//  ZOServiceProvider.h
//  ZOContainer
//
//  Created by zenone on 2017/1/16.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZOContainer.h"

/**
 服务提供者
 */
@interface ZOServiceProvider : NSObject
/**
 是否延迟加载
 */
@property (nonatomic, assign, readonly) BOOL lazyLoad;

/**
 提供的所有服务的key
 */
@property (nonatomic, strong) NSMutableDictionary *serviceKeys;

/**
 提供一个服务。
 
 @param service 服务类。
 @param protocol 服务关联的协议。
 @param context 服务关联的上下文。
 @param shared 是否共享实例
 */
- (void)provideService:(Class)service
           withProtocol:(Protocol *)protocol
                context:(Class)context
                 shared:(BOOL)shared;


- (void)provideService:(Class)service withProtocol:(Protocol *)protocol shared:(BOOL)shared;
- (void)provideService:(Class)service withProtocol:(Protocol *)protocol;
- (void)provideService:(Class)service;

/**
 通过 block 提供一个服务，block 的职责是构造服务对象。
 
 @param constructor 构造服务对象的 block
 @param protocol 服务关联的协议
 @param context 服务关联的上下文
 @param shared 是否共享实例
 */
- (void)provideServiceUsingConstructor:(ZOContainerServiceConstructor)constructor
                           withProtocol:(Protocol *)protocol
                                context:(Class)context
                                 shared:(BOOL)shared;

/**
 提供服务的方法。
 */
- (void)provideServices;

/**
 注册服务的方法，不需要手动调用。
 */
- (void)registerServices;
@end
