//
//  ZOServiceProvider.m
//  ZOContainer
//
//  Created by zenone on 2017/1/16.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import "ZOServiceProvider.h"

typedef void (^ServiceRegisterAcion)();

@interface ZOServiceProvider ()
@property (nonatomic, strong) NSMutableArray *serviceRegisterActions;
@end

@implementation ZOServiceProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self provideServices];
    }
    return self;
}

- (NSMutableArray *)serviceRegisterActions {
    if (_serviceRegisterActions != nil) {
        return _serviceRegisterActions;
    }
    
    _serviceRegisterActions = [NSMutableArray array];
    return _serviceRegisterActions;
}

- (NSMutableDictionary *)serviceKeys {
    if (_serviceKeys != nil) {
        return _serviceKeys;
    }
    
    _serviceKeys = [NSMutableDictionary dictionary];
    return _serviceKeys;
}

- (void)provideService:(Class)service
          withProtocol:(Protocol *)protocol
               context:(Class)context
                shared:(BOOL)shared
{
    ServiceRegisterAcion action = ^{
        [[ZOContainer defaultContainer] registerService:service
                                           withProtocol:protocol
                                                context:context
                                                 shared:shared];
    };
    NSString *serviceKey = nil;
    if (protocol != nil) {
        serviceKey = [self serviceKeyWithProtocol:protocol context:context];
    } else {
        serviceKey = NSStringFromClass(service);
    }
    [self provideServiceWithKey:serviceKey registerAction:action];
}

- (void)provideService:(Class)service withProtocol:(Protocol *)protocol shared:(BOOL)shared {
    [self provideService:service withProtocol:protocol context:Nil shared:shared];
}

- (void)provideService:(Class)service withProtocol:(Protocol *)protocol {
    [self provideService:service withProtocol:protocol shared:NO];
}

- (void)provideService:(Class)service {
    [self provideService:service withProtocol:Nil];
}

- (void)provideServiceUsingConstructor:(ZOContainerServiceConstructor)constructor
                          withProtocol:(Protocol *)protocol
                               context:(Class)context
                                shared:(BOOL)shared
{
    ServiceRegisterAcion action = ^{
        [[ZOContainer defaultContainer] registerServiceUsingConstructor:constructor
                                                           withProtocol:protocol
                                                                context:context
                                                                 shared:shared];
    };
    NSString *serviceKey = [self serviceKeyWithProtocol:protocol context:context];
    [self provideServiceWithKey:serviceKey registerAction:action];
}

- (void)provideServiceWithKey:(NSString *)key
               registerAction:(ServiceRegisterAcion)action
{
    [self.serviceKeys setObject:self forKey:key];
    [self.serviceRegisterActions addObject:action];
}

- (void)provideServices {}

- (void)registerServices {
    if (_serviceRegisterActions != nil) {
        for (ServiceRegisterAcion action in self.serviceRegisterActions) {
            action();
        }
    }
}

- (NSString *)serviceKeyWithProtocol:(Protocol *)protocol context:(Class)context {
    NSString *serviceKey = NSStringFromProtocol(protocol);
    if (context != Nil) {
        serviceKey = [NSString stringWithFormat:@"%@_%@", serviceKey, NSStringFromClass(context)];
    }
    return serviceKey;
}
@end
