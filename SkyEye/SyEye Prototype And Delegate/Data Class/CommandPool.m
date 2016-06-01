//
//  CommandPool.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/15.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "CommandPool.h"

@implementation CommandPool
@synthesize arrayVideoCommandList = _arrayVideoCommandList;
@synthesize arraySystemCommandList = _arraySystemCommandList;
@synthesize arrayConfigCommandList = _arrayConfigCommandList;

- (id) init{
    if (self = [super init]) {
        [self parsePropertyList];
    }
    return self;
}

+(CommandPool *)sharedInstance{
    static CommandPool *commandPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        commandPool = [[self alloc] init];
    });
    return commandPool;
}

- (void)parsePropertyList{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"VideoCommandPropertyList" ofType:@"plist"];
    _arrayVideoCommandList = [NSArray arrayWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"ConfigCommandPropertyList" ofType:@"plist"];
    _arrayConfigCommandList = [NSArray arrayWithContentsOfFile:path];
    
    path = [[NSBundle mainBundle] pathForResource:@"SystemCommandPropertyList" ofType:@"plist"];
    _arraySystemCommandList = [NSArray arrayWithContentsOfFile:path];
}

@end
