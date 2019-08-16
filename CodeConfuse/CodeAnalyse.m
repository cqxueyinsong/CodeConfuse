//
//  CodeAnalyse.m
//  CodeConfuse
//
//  Created by eShow on 2019/8/15.
//  Copyright © 2019 jiaoyingbrother. All rights reserved.
//

#import "CodeAnalyse.h"

@implementation CodeAnalyse

+ (void)getImplementationsOfMFileStrArray:(NSArray<NSString *> *)strArray
                                 callBack:(void (^)(NSArray<Implementation *> * _Nonnull, NSArray<MyRange *> * _Nonnull))callBack {
    NSMutableArray *implememtArr = [NSMutableArray array];
    NSMutableArray *rangeArr = [NSMutableArray array];
    NSInteger tempIndex = NSNotFound;
    for (NSInteger i = 0; i < strArray.count; i ++) {
        if ([strArray[i] hasPrefix:@"@implementation"]) {
            tempIndex = i;
        } else if (tempIndex != NSNotFound && [strArray[i] hasPrefix:@"@end"]) {
            MyRange *range = [[MyRange alloc] initWithFrom:tempIndex to:i];
            Implementation *implement = [[Implementation alloc] initWithImplementationStrArray:[strArray subarrayWithRange:range.range]];
            [implememtArr addObject:implement];
            [rangeArr addObject:range];
            tempIndex = NSNotFound;
        }
    }
    NSAssert(implememtArr.count == rangeArr.count, @"出错了,range 数量需要等于Implementation数量");
    if (callBack) {
        callBack(implememtArr, rangeArr);
    }
}

+ (void)getMethodsOfimplementationStrArray:(NSArray<NSString *> *)strArray
                                  callBack:(void (^)(NSArray<Method *> * _Nonnull, NSArray<MyRange *> * _Nonnull))callBack {
    NSInteger bracketsCountguard = 0;
    BOOL bracketsExist = NO;
    NSInteger eatchBeginIndex = NSNotFound;
    NSInteger eatchEndIndex = NSNotFound;
    NSMutableArray *methods = [NSMutableArray array];
    NSMutableArray *ranges = [NSMutableArray array];
    for (NSInteger i = 0; i < strArray.count; i ++) {
        NSString *line = strArray[i];
        if ([line hasPrefix:@"-("] ||
            [line hasPrefix:@"- ("] ||
            [line hasPrefix:@"+("] ||
            [line hasPrefix:@"+ ("]) {
            NSAssert(bracketsCountguard == 0 && eatchBeginIndex == NSNotFound, @"错误");
            eatchBeginIndex = i;
        }
        NSInteger cStrLength = [strArray[i] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        const char *c = [strArray[i] cStringUsingEncoding:NSUTF8StringEncoding];
        for (NSInteger j = 0; j < cStrLength; j ++) {
            if (c[j] == '{' && eatchBeginIndex != NSNotFound) {
                bracketsExist = YES;
                bracketsCountguard ++;
            } else if (c[j] == '}' && bracketsCountguard > 0) {
//                bracketsCountguard > 0 的判断用来标记屏蔽的方法
                bracketsCountguard --;
            }
        }
        if (eatchBeginIndex != NSNotFound &&
            bracketsExist &&
            bracketsCountguard == 0) {
            eatchEndIndex = i;
            MyRange *range = [[MyRange alloc] initWithFrom:eatchBeginIndex to:eatchEndIndex];
            Method *method = [[Method alloc] init];
            method.content = [strArray subarrayWithRange:range.range];
            [methods addObject:method];
            [ranges addObject:range];
            eatchBeginIndex = NSNotFound;
            eatchEndIndex = NSNotFound;
            bracketsExist = NO;
        }
    }
    if (callBack) {
        callBack(methods, ranges);
    }
}

+ (void)getDeclareOfimplementationStrArray:(NSArray<NSString *> *)strArray
                                  callBack:(void(^)(Declare *declare, MyRange *range))callBack {
    NSInteger beginIndex = NSNotFound;
    NSInteger endIndex = NSNotFound;
    for (NSInteger i = 0; i < strArray.count; i ++) {
        if ([strArray[i] hasPrefix:@"@implementation"]) {
            beginIndex = i;
            endIndex = i;
        }
        if ([strArray[i] hasPrefix:@"-("] ||
            [strArray[i] hasPrefix:@"- ("] ||
            [strArray[i] hasPrefix:@"+("] ||
            [strArray[i] hasPrefix:@"+ ("]) {
            break;
        }
        NSInteger cStrLength = [strArray[i] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        const char *c = [strArray[i] cStringUsingEncoding:NSUTF8StringEncoding];
        for (NSInteger j = 0; j < cStrLength; j ++) {
            if (c[j] == '}') {
                endIndex = i;
            }
        }
    }
    NSAssert(beginIndex != NSNotFound && endIndex != NSNotFound && callBack, @"出错");
    MyRange *range = [[MyRange alloc] initWithFrom:beginIndex to:endIndex];
    Declare *declare = [[Declare alloc] init];
    declare.content = [strArray subarrayWithRange:range.range];
    callBack(declare, range);
}

+ (void)getInterfacesOfMFileStrArray:(NSArray<NSString *> *)strArray
                            callBack:(void(^)(NSArray<Interface *> *Interfaces, NSArray<MyRange *> *ranges))callBack {
    NSMutableArray *interfaceArr = [NSMutableArray array];
    NSMutableArray *rangeArr = [NSMutableArray array];
    NSInteger tempIndex = 0;
    for (NSInteger i = 0; i < strArray.count; i ++) {
        if ([strArray[i] hasPrefix:@"@interface"]) {
            tempIndex = i;
        } else if ([strArray[i] hasPrefix:@"@end"]) {
            MyRange *range = [[MyRange alloc] initWithFrom:tempIndex to:i];
            Interface *interface = [[Interface alloc] initWithInterfaceStrArray:[strArray subarrayWithRange:range.range]];
            [interfaceArr addObject:interface];
            [rangeArr addObject:range];
        }
    }
    NSAssert(interfaceArr.count == rangeArr.count, @"出错了,range 数量需要等于Implementation数量");
    if (callBack) {
        callBack(interfaceArr, rangeArr);
    }
}

+ (void)getDeclareOfInterfaceStrArray:(NSArray<NSString *> *)strArray
                             callBack:(void(^)(Declare *declare, MyRange *range))callBack {
    NSInteger beginIndex = NSNotFound;
    NSInteger endIndex = NSNotFound;
    for (NSInteger i = 0; i < strArray.count; i ++) {
        if ([strArray[i] hasPrefix:@"@interface"]) {
            beginIndex = i;
        }
        if (beginIndex != NSNotFound) {
            NSInteger cStrLength = [strArray[i] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            const char *c = [strArray[i] cStringUsingEncoding:NSUTF8StringEncoding];
            for (NSInteger j = 0; j < cStrLength; j ++) {
                if (c[j] == ':' || c[j] == '}' || c[j] == '>' || c[j] == ')') {
                    endIndex = i;
                }
            }
        }
    }
    NSAssert(beginIndex != NSNotFound && endIndex != NSNotFound && callBack, @"出错");
    MyRange *range = [[MyRange alloc] initWithFrom:beginIndex to:endIndex];
    Declare *declare = [[Declare alloc] init];
    declare.content = [strArray subarrayWithRange:range.range];
    callBack(declare, range);
}

+ (void)getPropertiesOfInterfaceStrArray:(NSArray<NSString *> *)strArray
                                callBack:(void(^)(NSArray<Property *> *properties, NSArray<MyRange *> *ranges))callBack {
    NSInteger eatchBeginIndex = NSNotFound;
    NSInteger eatchEndIndex = NSNotFound;
    NSMutableArray *properties = [NSMutableArray array];
    NSMutableArray *ranges = [NSMutableArray array];
    for (NSInteger i = 0; i < strArray.count; i ++) {
        if ([strArray[i] hasPrefix:@"@property"]) {
            NSAssert(eatchBeginIndex == NSNotFound, @"出错");
            eatchBeginIndex = i;
            NSInteger cStrLength = [strArray[i] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            const char *c = [strArray[i] cStringUsingEncoding:NSUTF8StringEncoding];
            for (NSInteger j = 0; j < cStrLength; j ++) {
                if (c[j] == ';') {
                    eatchEndIndex = i;
                    MyRange *range = [[MyRange alloc] initWithFrom:eatchBeginIndex to:eatchEndIndex];
                    Property *property = [[Property alloc] init];
                    property.content = [strArray subarrayWithRange:range.range];
                    [properties addObject:property];
                    [ranges addObject:range];
                    eatchBeginIndex = NSNotFound;
                    eatchEndIndex = NSNotFound;
                    break;
                }
            }
        }
    }
    NSAssert(properties.count == ranges.count, @"出错");
}

+ (NSArray<NSString *> *)deletedMardArrayWithArray:(NSArray<NSString *> *)array {
    NSMutableArray *tmp = [array mutableCopy];
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < tmp.count; i ++) {
        if ([tmp[i] hasPrefix:@"//"] || [tmp[i] stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0 || [tmp[i] hasPrefix:@"#pragma"]) {
            [set addIndexesInRange:[[MyRange alloc] initWithFrom:i to:i].range];
        }
    }
    [tmp removeObjectsAtIndexes:set];
    [set removeAllIndexes];
    
    NSInteger markBegin = NSNotFound;
    for (NSInteger i = 0; i < tmp.count; i ++) {
        if ([[tmp[i] stringByReplacingOccurrencesOfString:@" " withString:@""] hasPrefix:@"/*"] && markBegin == NSNotFound) {
            markBegin = i;
        }
        if (markBegin != NSNotFound && [tmp[i] hasSuffix:@"*/"]) {
            [set addIndexesInRange:[[MyRange alloc] initWithFrom:markBegin to:i].range];
            markBegin = NSNotFound;
        }
    }
    [tmp removeObjectsAtIndexes:set];
    return [tmp copy];
}

@end
