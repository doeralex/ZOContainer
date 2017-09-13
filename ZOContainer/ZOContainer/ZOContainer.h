//
//  ZOContainer.h
//  ZOContainer
//
//  Created by zenone on 2016/12/22.
//  Copyright © 2016年 zenone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZOContainer;

typedef id (^ZOContainerServiceConstructor) (ZOContainer *container);

#define service_dependencies(args, ...) \
    + (NSSet *)serviceDependencies { \
        return [NSSet setWithObjects: args, ## __VA_ARGS__, nil]; \
    }

@interface ZOContainer : NSObject

/**
 默认容器，单例。

 @return 容器实例。
 */
+ (instancetype)defaultContainer;

/**
 加载一组服务提供者
 
 @param serviceProviderClasses 服务提供者数组
 */
- (void)loadServiceProvidersWithClasses:(NSArray *)serviceProviderClasses;

/**
 从文件中加载一组服务提供者
 
 @param filePath 文件的路径
 */
- (void)loadServiceProvidersWithFilePath:(NSString *)filePath;

/**
 向容器注册一个服务。

 @param service 服务类。
 @param protocol 服务关联的协议。
 @param context 服务关联的上下文。
 @param shared 是否共享实例（单例）
 */
- (void)registerService:(Class)service
           withProtocol:(Protocol *)protocol
                context:(Class)context
                 shared:(BOOL)shared;

- (void)registerService:(Class)service withProtocol:(Protocol *)protocol shared:(BOOL)shared;
- (void)registerService:(Class)service withProtocol:(Protocol *)protocol;
- (void)registerService:(Class)service;

/**
 通过 block 向容器注册一个服务，block 的职责是构造服务对象。

 @param constructor 构造服务对象的 block
 @param protocol 服务关联的协议
 @param context 服务关联的上下文
 @param shared 是否共享实例（单例）
 */
- (void)registerServiceUsingConstructor:(ZOContainerServiceConstructor)constructor
                           withProtocol:(Protocol *)protocol
                                context:(Class)context
                                 shared:(BOOL)shared;

/**
 获取服务实例

 @param protocol 服务关联的协议

 @param context 服务关联的上下文 
 @return 服务对象
 */
- (id)makeServiceWithProtocol:(Protocol *)protocol context:(Class)context;
- (id)makeServiceWithProtocol:(Protocol *)protocol;
- (id)makeService:(Class)service;
@end
