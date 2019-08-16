//
//  WKCodeConfuse.m
//  CodeConfuse
//
//  Created by eShow on 2019/8/15.
//  Copyright © 2019 jiaoyingbrother. All rights reserved.
//

#import "WKCodeConfuse.h"
#import "Models.h"

static NSDictionary *filterKey = nil;

#define fileManager [NSFileManager defaultManager]



@implementation WKCodeConfuse

+ (NSString *)fullPathOfSubPath:(NSString *)subPath baseUrl:(NSString *)baseUrl {
    if (!filterKey) {
        filterKey = @{
                      @"Pods" : @"1",
//                      @"IM" : @"1",
                      @"Assets.xcassets" : @"1",
                      @"fastlane" : @"1",
                      @"README.md" : @"1",
                      @"WKTrip.xcodeproj" : @"1",
                      @"WKTrip.xcworkspace" : @"1",
                      @"upload_to_tingyun.log" : @"1",
                      @"Podfile.lock" : @"1",
                      @"Podfile" : @"1",
                      @"Info.plist" : @"1",
//                      @"OCR" : @"1",
                      @"LaunchScreen.storyboard" : @"1",
                      @"WKTrip.entitlements" : @"1",
                      @"loadingGif.gif" : @"1",
                      @"refresh.gif" : @"1"
                      };
    }
    NSString *match = @"^\\..*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", match];
    if ([predicate evaluateWithObject:subPath] || filterKey[subPath]) {
        return nil;
    }
    if (subPath.length) {
        return [baseUrl stringByAppendingFormat:@"/%@", subPath];
    } else {
        return baseUrl;
    }
    
}

+ (NSArray *)contentsOfSubPath:(NSString *)subPath baseUrl:(NSString *)baseUrl {
    
    NSString *url = [self fullPathOfSubPath:subPath baseUrl:baseUrl];
    NSError *error;
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:url error:&error];
    if (error) {
        NSLog(@"%@ - %@", url, error.localizedDescription);
        return nil;
    } else {
        return arr;
    }
}

+ (void)printAllContentOfProjectPath:(NSString *)projectPath {
    NSInteger sum = [self printAllContentOfSubPath:nil baseUrl:projectPath];
    NSLog(@"%ld", sum);
}

+ (NSInteger)printAllContentOfSubPath:(NSString *)subPath baseUrl:(NSString *)baseUrl {
    __block NSInteger sum = 0;
    /// 当前文件夹的路径
    NSString *newBaseUrl = [self fullPathOfSubPath:subPath baseUrl:baseUrl];
    [[self contentsOfSubPath:subPath baseUrl:baseUrl] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /// 当前文件夹下某一项的路径
        NSString *path = [self fullPathOfSubPath:obj baseUrl:newBaseUrl];
        BOOL isDir;
        if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
            if (isDir) {
                sum += [self printAllContentOfSubPath:obj baseUrl:newBaseUrl];
            } else {
                NSLog(@"%@", path);
                sum += 1;
                if ([path hasSuffix:@"h"]) {
                    
                } else if ([path hasSuffix:@"m"]) {
                    [self changeMethodIndexOfFile:path];
                }
            }
        } else {
            NSLog(@"被过滤路径 - %@", [newBaseUrl stringByAppendingFormat:@"/%@", obj]);
        }
    }];
    return sum;
}

+ (void)changeMethodIndexOfFile:(NSString *)path {
//    if ([path hasSuffix:@"Target_OrderDetail.m"]) {
        @autoreleasepool {
            NSString *dataFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            NSArray *dataarr = [dataFile componentsSeparatedByString:@"\n"];
            ImplementationClass *cls = [[ImplementationClass alloc] initWithMFileStrArray:dataarr];
            NSData *data = [[cls.outPut componentsJoinedByString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
            [data writeToFile:path atomically:YES];
        }
//    }
}

@end
