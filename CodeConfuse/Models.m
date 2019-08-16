//
//  Models.m
//  CodeConfuse
//
//  Created by eShow on 2019/8/15.
//  Copyright © 2019 jiaoyingbrother. All rights reserved.
//

#import "Models.h"
#import "CodeAnalyse.h"

@implementation MyRange

- (instancetype)initWithFrom:(NSInteger)frome to:(NSInteger)to {
    self = [super init];
    if (self) {
        self.from = frome;
        self.to = to;
    }
    return self;
}

- (NSInteger)length {
    /**
     从1--2     是   1, 2
     length 为  2 - 1 + 1 = 2
     
     从from到to 是 from, from + 1 , from + 2, ......, to - 2, to - 1, to
     length 为  to - from + 1
     **/
    
    return self.to - self.from + 1;
}

- (NSRange)range {
    return NSMakeRange(self.from, self.length);
}

@end

@interface CodeRootClass ()
@property (nonatomic, copy) NSArray<NSString *> *innerOutPut;
@end
@implementation CodeRootClass

- (NSArray<NSString *> *)outPut {
    return self.content ?: @[];
}

@end

@implementation Interface

- (instancetype)initWithInterfaceStrArray:(NSArray<NSString *> *)strArr {
    self = [super init];
    if (self) {
        NSMutableArray *mutableStrArr = [strArr mutableCopy];
        [CodeAnalyse getDeclareOfInterfaceStrArray:mutableStrArr callBack:^(Declare * _Nonnull declare, MyRange * _Nonnull range) {
            self.declare = declare;
            [mutableStrArr removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range.range]];
        }];
        [CodeAnalyse getPropertiesOfInterfaceStrArray:mutableStrArr callBack:^(NSArray<Property *> * _Nonnull properties, NSArray<MyRange *> * _Nonnull ranges) {
            self.properties = properties;
            NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
            [ranges enumerateObjectsUsingBlock:^(MyRange * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [set addIndexes:[NSIndexSet indexSetWithIndexesInRange:obj.range]];
            }];
            [mutableStrArr removeObjectsAtIndexes:set];
        }];
        self.otherLines = mutableStrArr;
    }
    return self;
}

- (NSArray<NSString *> *)outPut {
    if (!self.innerOutPut) {
        NSArray *declare = self.declare.content;
        NSArray *properties = [self.properties sortedArrayUsingComparator:^NSComparisonResult(Property *obj1, Property *obj2) {
            return obj1.outPut.firstObject.length > obj2.outPut.firstObject.length;
        }];
        NSArray *end = self.otherLines;
        self.innerOutPut = [[declare arrayByAddingObjectsFromArray:properties ?: @[]] arrayByAddingObjectsFromArray:end];
    }
    return self.innerOutPut;
}

@end

@implementation Implementation

- (instancetype)initWithImplementationStrArray:(NSArray<NSString *> *)strArr {
    self = [super init];
    if (self) {
        NSMutableArray *mutableStrArr = [strArr mutableCopy];
        [CodeAnalyse getDeclareOfimplementationStrArray:mutableStrArr callBack:^(Declare * _Nonnull declare, MyRange * _Nonnull range) {
            self.declare = declare;
            [mutableStrArr removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range.range]];
        }];
        [CodeAnalyse getMethodsOfimplementationStrArray:mutableStrArr callBack:^(NSArray<Method *> * _Nonnull methods, NSArray<MyRange *> * _Nonnull ranges) {
            self.methods = methods;
            NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
            [ranges enumerateObjectsUsingBlock:^(MyRange * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [set addIndexes:[NSIndexSet indexSetWithIndexesInRange:obj.range]];
            }];
            [mutableStrArr removeObjectsAtIndexes:set];
        }];
        self.otherLines = mutableStrArr;
    }
    return self;
}

- (NSArray<NSString *> *)outPut {
    if (!self.innerOutPut) {
        NSMutableArray *outPut = [NSMutableArray arrayWithArray:self.declare.outPut ?: @[]];
        
        [[self.methods sortedArrayUsingComparator:^NSComparisonResult(Method *obj1, Method *obj2) {
            return obj2.outPut.firstObject.length > obj2.outPut.firstObject.length;
        }] enumerateObjectsUsingBlock:^(Method * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [outPut addObjectsFromArray:obj.content ?: @[]];
        }];
        [outPut addObjectsFromArray:self.otherLines ?: @[]];
        self.innerOutPut = outPut;
    }
    return self.innerOutPut;
}

@end

@implementation ImplementationClass

- (instancetype)initWithMFileStrArray:(NSArray<NSString *> *)strArray {
    self = [super init];
    if (self) {
        NSMutableArray *mutableStrArr = [[CodeAnalyse deletedMardArrayWithArray:strArray] mutableCopy];
        [CodeAnalyse getImplementationsOfMFileStrArray:mutableStrArr callBack:^(NSArray<Implementation *> * _Nonnull implementations, NSArray<MyRange *> * _Nonnull ranges) {
            self.implementations = implementations;
            NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
            [ranges enumerateObjectsUsingBlock:^(MyRange * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [set addIndexes:[NSIndexSet indexSetWithIndexesInRange:obj.range]];
            }];
            [mutableStrArr removeObjectsAtIndexes:set];
        }];
        [CodeAnalyse getInterfacesOfMFileStrArray:mutableStrArr callBack:^(NSArray<Interface *> * _Nonnull Interface, NSArray<MyRange *> * _Nonnull ranges) {
            self.interfaces = Interface;
            NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
            [ranges enumerateObjectsUsingBlock:^(MyRange * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [set addIndexes:[NSIndexSet indexSetWithIndexesInRange:obj.range]];
            }];
            [mutableStrArr removeObjectsAtIndexes:set];
        }];
        self.otherLines = mutableStrArr;
    }
    return self;
}

- (NSArray<NSString *> *)outPut {
    if (!self.innerOutPut) {
        NSMutableArray *outPut = [NSMutableArray arrayWithArray:self.otherLines ?: @[]];
        ///修改interface 可能影响引用结果
        [self.interfaces enumerateObjectsUsingBlock:^(Interface * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [outPut addObjectsFromArray:obj.outPut];
        }];
        [self.implementations enumerateObjectsUsingBlock:^(Implementation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [outPut addObjectsFromArray:obj.outPut];
        }];
        // 不对implementations 进行排序是因为implementations可能出现方法互相调用的情况
//        [[self.implementations sortedArrayUsingComparator:^NSComparisonResult(Implementation *obj1, Implementation *obj2) {
//            return obj1.outPut.firstObject.length > obj2.outPut.firstObject.length;
//        }] enumerateObjectsUsingBlock:^(Implementation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [outPut addObjectsFromArray:obj.outPut];
//        }];
        self.innerOutPut = outPut;
    }
    return self.innerOutPut;
}


@end
