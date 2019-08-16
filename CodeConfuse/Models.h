//
//  Models.h
//  CodeConfuse
//
//  Created by eShow on 2019/8/15.
//  Copyright © 2019 jiaoyingbrother. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyRange : NSObject
@property (nonatomic, assign) NSInteger from;
@property (nonatomic, assign) NSInteger to;
@property (nonatomic, readonly) NSInteger length;
@property (nonatomic, readonly) NSRange range;

- (instancetype)initWithFrom:(NSInteger)frome to:(NSInteger)to;

@end

@interface CodeRootClass : NSObject
@property (nonatomic, copy) NSArray<NSString *> *content;
@property (nonatomic, copy, nullable) NSArray<NSString *> *otherLines;
@property (nonatomic, readonly) NSArray<NSString *> *outPut;
@end

typedef CodeRootClass Property;
typedef CodeRootClass Method;
// @interface AClass : BClass <CProtocol>{ EClass * FVariable }
typedef CodeRootClass Declare;
typedef CodeRootClass TheProtocol;

@interface Interface : CodeRootClass
@property (nonatomic, strong) Declare *declare;
@property (nonatomic, strong) NSArray<Property *> *properties;
- (instancetype)initWithInterfaceStrArray:(NSArray<NSString *> *)strArr;
@end

@interface Implementation : CodeRootClass
@property (nonatomic, strong) Declare *declare;
@property (nonatomic, copy) NSArray<Method *> *methods;
- (instancetype)initWithImplementationStrArray:(NSArray<NSString *> *)strArr;
@end

@interface ImplementationClass : CodeRootClass
@property (nonatomic, copy) NSArray<Interface *> *interfaces;
@property (nonatomic, copy) NSArray<Implementation *> *implementations;
- (instancetype)initWithMFileStrArray:(NSArray<NSString *> *)strArray;

@end

NS_ASSUME_NONNULL_END
