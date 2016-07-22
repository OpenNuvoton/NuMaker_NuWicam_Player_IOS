//
//  PlayerManager.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/1.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "PlayerManager.h"

@implementation PlayerManager

- (id)init{
    if (self == [super init]) {
        if (_cameraAddress == nil) {
            
            [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
            [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
            
            fileLogger = [[DDFileLogger alloc] init]; // File Logger
            fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
            fileLogger.logFileManager.maximumNumberOfLogFiles = 5;
            [DDLog addLogger:fileLogger];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
            NSString *docfilePath = [basePath stringByAppendingPathComponent:@"/SettingsPropertyListLocal.plist"];
            NSString *tempPath = [[NSBundle mainBundle] pathForResource:@"SettingsPropertyList" ofType:@"plist"];
            NSDictionary *tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
            NSDictionary *checkDictinary = [NSDictionary dictionaryWithContentsOfFile:docfilePath];
            if (checkDictinary == nil) {
                [tempDictionary writeToFile:docfilePath atomically:YES];
            }
            path = [NSString stringWithString:docfilePath];
            _dictionarySetting = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            
            NSDictionary *dic = [_dictionarySetting objectForKey:@"Wi-Fi AP Setup"];
            if ([dic objectForKey:@"SSID"] != nil) {
                ssid = [NSString stringWithString:[dic objectForKey:@"SSID"]];
                pass = [NSString stringWithString:[dic objectForKey:@"password"]];
            }
        }
    }
    return self;
}

+ (PlayerManager *)sharedInstance{
    static PlayerManager *playerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerManager = [[self alloc] init];
    });
    return playerManager;
}

- (BOOL)updateSettingPropertyList{
    return [_dictionarySetting writeToFile:path atomically:YES];
}

- (void)resetData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *docfilePath = [basePath stringByAppendingPathComponent:@"/SettingsPropertyListLocal.plist"];
    NSString *tempPath = [[NSBundle mainBundle] pathForResource:@"SettingsPropertyList" ofType:@"plist"];
    NSDictionary *tempDictionary = [NSDictionary dictionaryWithContentsOfFile:tempPath];
    [tempDictionary writeToFile:docfilePath atomically:YES];
    path = [NSString stringWithString:docfilePath];
    _dictionarySetting = [NSMutableDictionary dictionaryWithContentsOfFile:path];
}

- (NSString *)getSSID{
    return [NSString stringWithString:ssid];
}

- (NSString *)getPASS{
    return [NSString stringWithString:pass];
}

- (NSString *)getCurrentLogFilePath{
    NSString *string = [NSString stringWithString:[fileLogger currentLogFileInfo].filePath];
    return string;
}

@end
