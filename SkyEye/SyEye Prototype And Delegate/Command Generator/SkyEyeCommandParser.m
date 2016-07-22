//
//  SkyEyeCommandParser.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/4.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "SkyEyeCommandParser.h"

@implementation SkyEyeCommandParser
- (id)init{
    if (self = [super init]) {
        dictionaryCommandList = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)addCommand:(NSString *)name content:(NSArray *)content{
    /**
     *  The command is combined in 3 parts: "GET" + "command content" + "HTTP/1.1\r\n\r\n"
     */
    NSString *httpGETHead = @"GET ";
    NSString *httpVersionTail = @" HTTP/1.1\r\n\r\n";
    NSString *commandContent = [[NSString alloc] init];
    commandContent = [self commandParser:content];
    NSString *fullCommand = [NSString stringWithFormat:@"%@%@%@", httpGETHead, commandContent, httpVersionTail];
    [dictionaryCommandList setObject:fullCommand forKey:name];
}

- (NSString *)commandParser:(NSArray *)commandArray{
    NSString *parsedCommandString = [[NSString alloc] init];
    for (NSArray *commandArray in commandArray) {
        NSString *command = (NSString *)[commandArray objectAtIndex:0];
        [parsedCommandString stringByAppendingString:command];
        command = (NSString *)[commandArray objectAtIndex:1];
        [parsedCommandString stringByAppendingString:command];
    }
    DDLogDebug(@"==command string parsed result: %@", parsedCommandString);
    return parsedCommandString;
}

- (NSArray *)dataParser:(NSData *)data{
    NSArray *parsedDataArray = [[NSArray alloc] init];
    
    return parsedDataArray;
}

+ (id) shareInstance{
    static SkyEyeCommandParser* parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[self alloc] init];
    });
    return parser;
}

- (NSDictionary *)getCommandList{
    NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:dictionaryCommandList];
    return dictionary;
}



@end
