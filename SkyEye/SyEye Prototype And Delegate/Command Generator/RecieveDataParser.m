//
//  RecieveDataParser.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/3/9.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "RecieveDataParser.h"

@implementation RecieveDataParser
+(NSDictionary *)parseSocketReadData:(NSData *)data withTag:(int)tag{
    NSDictionary *parsedDic;
    NSString *type, *value, *category, *contentLength;
    NSString *dataInString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *dataSplitWithCRLF = [dataInString componentsSeparatedByString:@"\r\n"];
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    if ([[dataSplitWithCRLF objectAtIndex:0] isEqualToString:@"HTTP/1.0 200 OK"]) {
        for (int i=0; i<dataSplitWithCRLF.count; i++) {
            NSString *s = [dataSplitWithCRLF objectAtIndex:i];
            [dataContent addObject:s];
        }
    } else {
        for (int i=0; i<dataSplitWithCRLF.count; i++) {
            NSString *s = [dataSplitWithCRLF objectAtIndex:i];
            [dataContent addObject:s];
        }
    }
    
    NSDictionary *dic;
    for (NSString *s in dataContent) {
        if ([s isEqualToString:@""]) {
            continue;
        }
        NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:d options:kNilOptions error:nil];
    }
    if (dic == nil) {
        parsedDic = [NSDictionary dictionaryWithObjectsAndKeys:@"no data", @"type", nil];
        return parsedDic;
    }
    
    switch (tag) {
        case SOCKET_READ_TAG_LIST_STREAM:
            category = @"List Stream Parameters";
            break;
        case SOCKET_READ_TAG_UPDATE_STREAM:
            category = @"Update Stream Parameters";
            break;
        case SOCKET_READ_TAG_UPDATE_RESOLUTION:
            category = @"Update Resolution";
            break;
        case SOCKET_READ_TAG_UPDATE_BITRATE:
            category = @"Update Bit Rate";
            break;
        case SOCKET_READ_TAG_LIST_WIFI:
            category = @"List Wi-Fi Parameters";
            break;
        case SOCKET_READ_TAG_UPDATE_WIFI:
            category = @"Update Stream Parameters";
            break;
        default:
            break;
    }
    type = @"JSON DATA";
    value = [dic objectForKey:@"value"];
    parsedDic = [NSDictionary dictionaryWithObjectsAndKeys:type, @"type", dic, @"json", category, @"category", nil];
    return parsedDic;
}

+ (NSDictionary *)parseSocketReadDataLength:(NSData *)data withTag:(int)tag{
    NSDictionary *parsedDic;
    NSString *type, *category, *contentLength;
    NSString *dataInString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *dataSplitWithCRLF = [dataInString componentsSeparatedByString:@"\r\n"];
    NSMutableArray *dataContent = [[NSMutableArray alloc] init];
    if ([[dataSplitWithCRLF objectAtIndex:0] isEqualToString:@"HTTP/1.0 200 OK"]) {
        contentLength = [NSString stringWithString:[dataSplitWithCRLF objectAtIndex:4]];
    } else {
        for (int i=0; i<dataSplitWithCRLF.count; i++) {
            NSString *s = [dataSplitWithCRLF objectAtIndex:i];
            [dataContent addObject:s];
        }
    }
    switch (tag) {
        case SOCKET_READ_TAG_LIST_STREAM:
            category = @"List Stream Parameters";
            break;
        case SOCKET_READ_TAG_UPDATE_STREAM:
            category = @"Update Stream Parameters";
            break;
        case SOCKET_READ_TAG_UPDATE_RESOLUTION:
            category = @"Update Resolution";
            break;
        case SOCKET_READ_TAG_UPDATE_BITRATE:
            category = @"Update Bit Rate";
            break;
        case SOCKET_READ_TAG_LIST_WIFI:
            category = @"List Wi-Fi Parameters";
            break;
        case SOCKET_READ_TAG_UPDATE_WIFI:
            category = @"Update Stream Parameters";
            break;
        default:
            break;
    }
    type = @"JSON DATA";
    NSDictionary *dic = @{contentLength: @"Content Length"};
    parsedDic = [NSDictionary dictionaryWithObjectsAndKeys:type, @"type", dic, @"json", category, @"category", nil];
    return parsedDic;
}

@end
