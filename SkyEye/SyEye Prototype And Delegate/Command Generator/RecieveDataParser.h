//
//  RecieveDataParser.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/3/9.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerManager.h"
@interface RecieveDataParser : NSObject{
    PlayerManager *playerManager;
}
/**
 *  parse socket read data buffer
 *
 *  @param data pure nsdata from buffer
 *  @param tag  socket read/write tag, defined in SocketManager.h
 *
 *  @return NSDictionary content: 
 *          "key" <=> "value"
 *           type <=> return data type in NSString (e.g. ACK, JSON DATA, etc.)
 *           json <=> json data stored in NSDictionary
 */
+ (NSDictionary *)parseSocketReadData:(NSData *)data withTag:(int)tag;
+ (NSDictionary *)parseSocketReadDataLength:(NSData *)data withTag:(int)tag;

@end
