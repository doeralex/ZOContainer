//
//  ZOContainer.m
//  ZOContainer
//
//  Created by zenone on 2016/12/22.
//  Copyright © 2016年 zenone. All rights reserved.
//

#import "ZOContainer.h"
#import <objc/runtime.h>
#import "ZOServiceProvider.h"

@interface ZOContainer ()
@property (nonatomic, strong) NSMutableDictionary *services; // 所有服务
@property (nonatomic, strong) NSMutableSet *sharedServiceKeys; // 单例服务的key
@property (nonatomic, strong) NSMutableDictionary *sharedServiceInstances; // 单例服务的实例
@property (nonatomic, strong) NSMutableDictionary *lazyLoadServiceProviders; // 需要延迟加载的服务提供者
@end

@implementation ZOContainer

- (NSMutableSet *)sharedServiceKeys {
    if (_sharedServiceKeys != nil) {
        return _sharedServiceKeys;
    }
    
    _sharedServiceKeys = [NSMutableSet set];
    return _sharedServiceKeys;
}

- (NSMutableDictionary *)sharedServiceInstances {
    if (_sharedServiceInstances != nil) {
        return _sharedServiceInstances;
    }
    
    _sharedServiceInstances = [NSMutableDictionary dictionary];
    return _sharedServiceInstances;
}

- (NSMutableDictionary *)lazyLoadServiceProviders {
    if (_lazyLoadServiceProviders != nil) {
        return _lazyLoadServiceProviders;
    }
    
    _lazyLoadServiceProviders = [NSMutableDictionary dictionary];
    return _lazyLoadServiceProviders;
}

+ (instancetype)defaultContainer {
    static ZOContainer *container = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        container = [ZOContainer new];
        container.services = [NSMutableDictionary dictionary];
    });
    return container;
}

#pragma mark - SERVICE PROVIDER

- (void)loadServiceProvidersWithClasses:(NSArray *)serviceProviderClasses {
    for (Class serviceProviderClass in serviceProviderClasses) {
        [self loadServiceProviderWithClasse:serviceProviderClass];
    }
}

- (void)loadServiceProvidersWithFilePath:(NSString *)filePath{
    NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
    for (NSString *serviceProviderName in array) {
        Class serviceProviderClass = NSClassFromString(serviceProviderName);
        [self loadServiceProviderWithClasse:serviceProviderClass];
    }
}

- (void)loadServiceProviderWithClasse:(Class)serviceProviderClass {
    ZOServiceProvider *serviceProvider = (ZOServiceProvider *)[serviceProviderClass new];
    if (serviceProvider.lazyLoad == YES) {
        for (NSString *key in serviceProvider.serviceKeys) {
            [self.lazyLoadServiceProviders setObject:serviceProvider.serviceKeys[key]
                                              forKey:key];
        }
    } else {
        [serviceProvider registerServices];
    }
}

#pragma mark - REGISTER

- (void)registerService:(Class)service
           withProtocol:(Protocol *)protocol
                context:(Class)context
                 shared:(BOOL)shared
{
    ZOContainerServiceConstructor serviceConstructor = ^id(ZOContainer *container) {
        return [service new];
    };
    NSString *serviceKey = nil;
    if (protocol != Nil) {
        serviceKey = [self serviceKeyWithProtocol:protocol context:context];
    } else {
        serviceKey = NSStringFromClass([service class]);
    }
    [self registerServiceUsingConstructor:serviceConstructor
                                  withKey:serviceKey
                                   shared:shared];
}

- (void)registerService:(Class)service withProtocol:(Protocol *)protocol shared:(BOOL)shared {
    [self registerService:service withProtocol:protocol context:Nil shared:shared];
}

- (void)registerService:(Class)service withProtocol:(Protocol *)protocol {
    [self registerService:service withProtocol:protocol shared:NO];
}

- (void)registerService:(Class)service {
    [self registerService:service withProtocol:Nil];
}

- (void)registerServiceUsingConstructor:(ZOContainerServiceConstructor)constructor
                           withProtocol:(Protocol *)protocol
                                context:(Class)context
                                 shared:(BOOL)shared
{
    NSString *serviceKey = [self serviceKeyWithProtocol:protocol context:context];
    
    [self registerServiceUsingConstructor:constructor
                                  withKey:serviceKey
                                   shared:shared];
}

- (void)registerServiceUsingConstructor:(ZOContainerServiceConstructor)constructor
                                withKey:(NSString *)key
                                 shared:(BOOL)shared {
    if (shared == YES) {
        [self.sharedServiceKeys addObject:key];
    }
    
    [self.services setObject:constructor forKey:key];
}

#pragma mark - MAKE

- (id)makeServiceWithProtocol:(Protocol *)protocol context:(Class)context {
    NSString *serviceKey = [self serviceKeyWithProtocol:protocol context:context];
    return [self makeServiceWithKey:serviceKey];
}

- (id)makeServiceWithProtocol:(Protocol *)protocol {
    return [self makeServiceWithProtocol:protocol context:Nil];
}

- (id)makeService:(Class)service {
    return [self makeServiceWithKey:NSStringFromClass(service)];
}

- (id)makeServiceWithKey:(NSString *)key {
    
    if (_lazyLoadServiceProviders != nil && self.lazyLoadServiceProviders[key] != nil) {
        ZOServiceProvider *serviceProvider = self.lazyLoadServiceProviders[key];
        [serviceProvider registerServices];
        for (NSString *key in serviceProvider.serviceKeys) {
            [self.lazyLoadServiceProviders removeObjectForKey:key];
        }
    }
    
    ZOContainerServiceConstructor serviceConstructor = self.services[key];
    
    if (serviceConstructor == nil) {
        return nil;
    }
    
    id service = nil;
    if ([self.sharedServiceKeys containsObject:key]) {
        service = self.sharedServiceInstances[key];
        if (service == nil) {
            service = [self makeServiceWithConstructor:serviceConstructor];
            [self.sharedServiceInstances setObject:service forKey:key];
        }
    } else {
        service = [self makeServiceWithConstructor:serviceConstructor];
    }
    return service;
}

- (id)makeServiceWithConstructor:(ZOContainerServiceConstructor)serviceConstructor {
    id service = serviceConstructor(self);
    if (service == nil) {
        return nil;
    }
    
    NSSet *dependencies = [self serviceDependenciesForService:[service class]];
    if (dependencies != nil) {
        for (NSString *dependencyName in dependencies) {
            NSString *dependencyTypeName = [self dependencyTypeNameWithPropertyName:dependencyName
                                                                              class:[service class]];
            if ([dependencyTypeName hasPrefix:@"<"] && [dependencyTypeName hasSuffix:@">"]) {
                dependencyTypeName = [dependencyTypeName stringByReplacingOccurrencesOfString:@"<" withString:@""];
                dependencyTypeName = [dependencyTypeName stringByReplacingOccurrencesOfString:@">" withString:@""];
                Protocol *dependencyProtocol = objc_getProtocol([dependencyTypeName UTF8String]);
                id dependency = [self makeServiceWithProtocol:dependencyProtocol];
                [service setValue:dependency forKey:dependencyName];
            } else {
                Class dependencyClass = NSClassFromString(dependencyTypeName);
                id dependency = [self makeService:dependencyClass];
                [service setValue:dependency forKey:dependencyName];
            }
        }
    }
    return service;
}

#pragma mark - DEPENDENCY

- (NSSet *)serviceDependenciesForService:(Class)service {
    if ([service respondsToSelector:NSSelectorFromString(@"serviceDependencies")]) {
        NSSet *serviceDependencies = nil;
#pragma "clang diagnostic push"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        serviceDependencies = [service performSelector:NSSelectorFromString(@"serviceDependencies")];
#pragma ("clang diagnostic pop")
        serviceDependencies = [self superServiceDependenciesForService:service
                                                      withDependencies:serviceDependencies];
        return serviceDependencies;
    } else {
        return nil;
    }
}

- (NSSet *)superServiceDependenciesForService:(Class)service withDependencies:(NSSet *)dependencies {
    Class serviceSuperClass = class_getSuperclass(service);
    if ([serviceSuperClass respondsToSelector:NSSelectorFromString(@"serviceDependencies")]) {
        NSSet *superServiceDependencies = nil;
#pragma "clang diagnostic push"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        superServiceDependencies = [serviceSuperClass performSelector:NSSelectorFromString(@"serviceDependencies")];
#pragma ("clang diagnostic pop")

        NSMutableSet *result = [NSMutableSet setWithSet:dependencies];
        [result unionSet:superServiceDependencies];
        return [self superServiceDependenciesForService:serviceSuperClass
                                withDependencies:result];
    }
    return dependencies;
}

- (NSString *)serviceKeyWithProtocol:(Protocol *)protocol context:(Class)context {
    NSString *serviceKey = NSStringFromProtocol(protocol);
    if (context != Nil) {
        serviceKey = [NSString stringWithFormat:@"%@_%@", serviceKey, NSStringFromClass(context)];
    }
    return serviceKey;
}

- (NSString *)dependencyTypeNameWithPropertyName:(NSString *)propertyName class:(Class)klass{
    objc_property_t property = class_getProperty(klass, (const char *)[propertyName UTF8String]);
    NSAssert(property != NULL, @"Unable to find property declaration '%@' of class '%@'", propertyName, NSStringFromClass(klass));
    
    NSString *propertyAttributes = [NSString stringWithCString: property_getAttributes(property) encoding: NSASCIIStringEncoding];
    NSRange startRange = [propertyAttributes rangeOfString:@"T@\""];
    NSString *startOfTypeName = [propertyAttributes substringFromIndex:startRange.length];
    NSRange endRange = [startOfTypeName rangeOfString:@"\""];
    NSAssert(startRange.location != NSNotFound && endRange.location != NSNotFound ,
             @"Unable to find the type name of property declaration '%@'", propertyName);
    
    NSString *typeName = [startOfTypeName substringToIndex:endRange.location];
    return typeName;
}
@end
