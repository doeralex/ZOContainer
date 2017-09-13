//
//  ZOFacade.h
//  ZOContainer
//
//  Created by zenone on 2017/2/4.
//  Copyright © 2017年 zenone. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZOClassMethodServiceProtocol <NSObject>

@optional
/**
 实体对象的类型
 */
+ (Class)realObjectClass;


@end

/**
 服务代理
 */
@interface ZOServiceProxy : NSProxy <ZOClassMethodServiceProtocol> {
    id _realObject;
}
/**
 实体对象
 */
@property (nonatomic, strong) id realObject;

@end
