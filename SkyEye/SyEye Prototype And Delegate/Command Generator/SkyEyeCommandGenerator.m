//
//  SkyEyeCommandGenerator.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "SkyEyeCommandGenerator.h"
@implementation SkyEyeCommandGenerator

/**
 *  dictionary content:
 *  key: @"Camera", value: @"Setup Camera %d" while %d is between 1~4
 *  key: @"Category", value: name saved in plist and the dictionary key is "Name"
 *  key: @"Value", value: depents on what value is going to be sent to device
 */
+ (NSString *)generateInfoCommandWithName:(NSString *)string{
    CommandPool *commandPool = [CommandPool sharedInstance];
    NSString *returnString = @"";
    NSString *head = @"GET /cgi-bin/";
    NSString *tail = @" HTTP/1.1\r\n\r\n";
    if ([string isEqualToString:@"Reboot System"]){
        NSDictionary *dic = [commandPool.arraySystemCommandList objectAtIndex:0];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    }else if ([string isEqualToString:@"List Stream Parameters"]) {
        NSDictionary *dic = [commandPool.arrayVideoCommandList objectAtIndex:0];
        NSString *baseCommand = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
        NSString *generatedCommand = [NSString stringWithString:baseCommand];
        NSArray *array = [NSArray arrayWithObjects:head, generatedCommand, tail, nil];
        returnString = [self appendHeaderString:array];
    }else if ([string isEqualToString:@"List Wi-Fi Parameters"]) {
        NSDictionary *dic = [commandPool.arrayConfigCommandList objectAtIndex:0];
        NSString *baseCommand = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
        NSString *generatedCommand = [NSString stringWithString:baseCommand];
        NSArray *array = [NSArray arrayWithObjects:head, generatedCommand, tail, nil];
        returnString = [self appendHeaderString:array];
    }else if ([string isEqualToString:@"Restart Wi-Fi"]){
        NSDictionary *dic = [commandPool.arraySystemCommandList objectAtIndex:1];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    }else if ([string isEqualToString:@"Restart Stream"]){
        NSDictionary *dic = [commandPool.arraySystemCommandList objectAtIndex:2];
        NSString *baseCommand = [dic objectForKey:@"Base Command"];
        NSArray *commandArray = [NSArray arrayWithObjects:head, baseCommand, tail, nil];
        returnString = [self appendHeaderString:commandArray];
    }
    return returnString;
}

+ (NSString *)generateInfoCommandWithName:(NSString *)string parameters:(NSArray *)array{
    CommandPool *commandPool = [CommandPool sharedInstance];
    NSString *returnString = @"";
    NSString *head = @"GET /cgi-bin/";
    NSString *tail = @" HTTP/1.1\r\n\r\n";
    if ([string isEqualToString:@"Update Stream Parameters"]){
        NSDictionary *dic = [commandPool.arrayVideoCommandList objectAtIndex:1];
        NSString *baseCommand = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
        NSString *generatedCommand = [NSString stringWithString:baseCommand];
        NSMutableArray *commandArray = [NSMutableArray arrayWithObjects:head, generatedCommand, nil];
        [commandArray addObjectsFromArray:array];
        [commandArray addObject:tail];
        returnString = [self appendHeaderString:commandArray];
    }else if ([string isEqualToString:@"Update Wi-Fi Parameters"]) {
        NSDictionary *dic = [commandPool.arrayConfigCommandList objectAtIndex:1];
        NSString *baseCommand = [NSString stringWithString:[dic objectForKey:@"Base Command"]];
        NSString *generatedCommand = [NSString stringWithString:baseCommand];
        NSMutableArray *commandArray = [NSMutableArray arrayWithObjects:head, generatedCommand, nil];
        [commandArray addObjectsFromArray:array];
        [commandArray addObject:tail];
        returnString = [self appendHeaderString:commandArray];
    }
    return returnString;
}

+ (NSString *)appendHeaderString:(NSArray *)array{
    NSString *returnString = @"";
    for (NSString *s in array) {
        returnString = [returnString stringByAppendingString:s];
        DDLogDebug(@"append string, %@", s);
    }
    return returnString;
}
@end
