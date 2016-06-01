//
//  SkyEyeCommandParser.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/4.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkyEyeCommandParser : NSObject{
    NSMutableDictionary *dictionaryCommandList;
    NSArray *arrayCommandName, *arrayCommandContent;
}
/**
 *  commandParser, used to parse command
 *
 *  @param: Data coming data from socket
 *
 *  @return: An 2 object Array stores "data type" at index 0, "data content" at index 1
 */
+ (SkyEyeCommandParser *)shareInstance;
- (id)init;
- (void)addCommand:(NSString *)name content:(NSArray *)content;
- (NSString *)commandParser:(NSArray *)content;
- (NSDictionary *)getCommandList;
@end
