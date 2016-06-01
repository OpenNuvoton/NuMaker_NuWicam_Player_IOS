//
//  PlayerManager.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/1.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingPool.h"

#ifndef USE_DFU_RTSP_PLAYER
#define USE_DFU_RTSP_PLAYER
#endif

enum{
    SOCKET_READ_TAG_SEND_SETTING            = 5,
    SOCKET_READ_TAG_SET_PLUGIN              = 6,
    
    SOCKET_READ_TAG_CAMERA_OFFSET           = 10,
    SOCKET_READ_TAG_CAMERA_1                = 11,
    SOCKET_READ_TAG_OTHER                   = 12,
    
    SOCKET_READ_TAG_INFO_REBOOT             = 20,
    
    SOCKET_READ_TAG_UPDATE_RESOLUTION       = 30,
    SOCKET_READ_TAG_UPDATE_BITRATE          = 31,
    SOCKET_READ_TAG_LIST_STREAM             = 32,
    SOCKET_READ_TAG_UPDATE_STREAM           = 33,
    SOCKET_READ_TAG_LIST_WIFI               = 34,
    SOCKET_READ_TAG_UPDATE_WIFI             = 35,
    SOCKET_READ_TAG_LIST_STREAM_ALIVE       = 36,

};

@interface PlayerManager : NSObject{
    NSString *path;
    NSString *ssid, *pass;
}

@property (strong, nonatomic) NSMutableDictionary *cameraAddress;
@property (strong, nonatomic) NSMutableDictionary *dictionarySetting;

- (id)init;

+ (PlayerManager *)sharedInstance;

- (BOOL)updateSettingPropertyList;
- (void)resetData;
- (NSString *)getSSID;
- (NSString *)getPASS;
@end
