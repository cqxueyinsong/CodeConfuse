//
//  main.m
//  CodeConfuse
//
//  Created by eShow on 2019/8/15.
//  Copyright © 2019 jiaoyingbrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKCodeConfuse.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc != 2) {
            NSLog(@"请输入路径");
        } else {
            const char *path = argv[1];
            NSString *nsPath = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
            [WKCodeConfuse printAllContentOfProjectPath:nsPath];
        }
    }
    return 0;
}
