//
//  CodeAnalyse.h
//  CodeConfuse
//
//  Created by eShow on 2019/8/15.
//  Copyright © 2019 jiaoyingbrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Models.h"

NS_ASSUME_NONNULL_BEGIN

@interface CodeAnalyse : NSObject

+ (void)getImplementationsOfMFileStrArray:(NSArray<NSString *> *)strArray
                                 callBack:(void(^)(NSArray<Implementation *> *implementations, NSArray<MyRange *> *ranges))callBack;
+ (void)getMethodsOfimplementationStrArray:(NSArray<NSString *> *)strArray
                                  callBack:(void(^)(NSArray<Method *> *methods, NSArray<MyRange *> *ranges))callBack;
+ (void)getDeclareOfInterfaceStrArray:(NSArray<NSString *> *)strArray
                             callBack:(void(^)(Declare *declare, MyRange *range))callBack;
+ (void)getInterfacesOfMFileStrArray:(NSArray<NSString *> *)strArray
                            callBack:(void(^)(NSArray<Interface *> *Interface, NSArray<MyRange *> *ranges))callBack;
+ (void)getDeclareOfimplementationStrArray:(NSArray<NSString *> *)strArray
                                  callBack:(void(^)(Declare *declare, MyRange *range))callBack;
+ (void)getPropertiesOfInterfaceStrArray:(NSArray<NSString *> *)strArray
                                callBack:(void(^)(NSArray<Property *> *properties, NSArray<MyRange *> *ranges))callBack;
+ (NSArray<NSString *> *)deletedMardArrayWithArray:(NSArray<NSString *> *)array;

@end

NS_ASSUME_NONNULL_END
