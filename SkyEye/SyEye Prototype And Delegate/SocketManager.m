//
//  SocketManager.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/27.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "SocketManager.h"

@implementation SocketManager
@synthesize hostURL = _hostURL;
@synthesize hostPort = _hostPort;

+ (id)shareInstance {
    static SocketManager* socketManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socketManager = [[self alloc] init];
    });
    return socketManager;
}

- (id) init{
    if (self = [super init]) {
        _isConnected = NO;
        serial = 0;
        connectTry = 0;
        tagLocal = 0;
        indexLocal = 0;
        connectedSocket = [[NSMutableArray alloc] initWithCapacity:1];
        socketQueue = dispatch_queue_create("socketQueue", NULL);
        socket = [[GCDAsyncSocket alloc]init];
        socketSwap = [[GCDAsyncSocket alloc]init];
        [socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
        [socketSwap setDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)sendAudioData{
//    NSLog(@"socket manager, send audio data, %@", commandToBeSentInData);
    [socket writeData:commandToBeSentInData withTimeout:-1 tag:tagLocal];
}

- (void)sendData{
    NSData *data = [commandToBeSent dataUsingEncoding:NSUTF8StringEncoding];
    [socket readDataWithTimeout:-1 tag:tagLocal];
    if (tagLocal >= SOCKET_READ_TAG_CAMERA_OFFSET && tagLocal <= SOCKET_READ_TAG_CAMERA_1) {
        [socket writeData:data withTimeout:-1 tag:tagLocal+SOCKET_READ_TAG_CAMERA_OFFSET];
    }else{
        [socket writeData:data withTimeout:-1 tag:tagLocal];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    _isConnected = YES;
    _hostURL = [[NSString alloc] initWithString:host];
    _hostPort = [[NSString alloc] initWithFormat:@"%d", port];
    NSLog(@"Did connected to Host: %@ at port: %@", _hostURL, _hostPort);
    [self sendData];
}

- (BOOL)connectHost:(NSString *)hostURL withPort:(NSString *)hostPort withTag:(int)tag{
    BOOL ret = NO;
    if (socket == nil) {
        socket = [[GCDAsyncSocket alloc]init];
        [socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    if (_isConnected == YES && ![socket.connectedHost isEqualToString:hostURL]) {
        [socket disconnect];
    }
    _hostURL = hostURL;
    _hostPort = hostPort;
    NSLog(@"address: %@, port: %@", _hostURL, _hostPort);
    ret = [socket connectToHost:_hostURL onPort:_hostPort.intValue withTimeout:3 error:nil];
    return ret;
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"error code: %ld", (long)err.code);
    _isConnected = NO;
    if (err.code >=4 && err.code < 7) {
        [_delegate hostNotResponse:tagLocal command:commandToBeSent];
    }else if (err.code == 61){
        [self connectHost:localURL withPort:@"8000" withTag:tagLocal];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
//    NSLog(@"did write data: %@", commandToBeSent);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"===tag: %ld", (long)tag);
    NSLog(@"%@", string);
    PlayerManager *manager = [PlayerManager sharedInstance];
    if (tag == SOCKET_READ_TAG_CAMERA_1) {
        NSArray *arrayData = [string componentsSeparatedByString:@"\r\n"];
        NSMutableArray *dataContentArray = [[NSMutableArray alloc]init];
        NSMutableArray *fileList = [[NSMutableArray alloc]init];
        NSString *searchPatternAVI = @".avi";
        NSString *searchPatternMP4 = @".mp4";
        NSRange range;
        NSString *httpHearder = [arrayData objectAtIndex:0];
        if (arrayData.count > 8 && [httpHearder isEqualToString:@"HTTP/1.1 200 OK"]) {
            for (int i=8; i<arrayData.count; i++) {
                [dataContentArray addObject:[arrayData objectAtIndex:i]];
            }
        } else {
            for (NSString *s in arrayData) {
                [dataContentArray addObject:s];
            }
        }
        BOOL isDataFlag = NO;
        for (NSString *s in dataContentArray) {
            NSArray *split = [s componentsSeparatedByString:@"\n"];
            if (split.count == 0) {
                break;
            }else{
                for (NSString *ss in split) {
                    range = [ss rangeOfString:searchPatternAVI];
                    if (![ss isEqualToString:@""]) {
                        isDataFlag = YES;
                    }
                    if (range.location != NSNotFound) {
                        NSArray *deleteNextLine = [ss componentsSeparatedByString:@"\n"];
                        [fileList addObject:[deleteNextLine objectAtIndex:0]];
                    }
                    range = [ss rangeOfString:searchPatternMP4];
                    if (![ss isEqualToString:@""]) {
                        isDataFlag = YES;
                    }
                    if (range.location != NSNotFound) {
                        NSArray *deleteNextLine = [ss componentsSeparatedByString:@"\n"];
                        [fileList addObject:[deleteNextLine objectAtIndex:0]];
                    }
                }
            }
        }
        if (!isDataFlag) {
            [socket readDataWithTimeout:-1 tag:tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_UPDATE_STREAM){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"value"]];
            NSLog(@"update stream result: %@", value);
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_UPDATE_RESOLUTION){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"value"]];
            [cameraDic setValue:value forKey:@"Resolution"];
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_UPDATE_BITRATE){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"value"]];
            [cameraDic setValue:value forKey:@"Resolution"];
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_LIST_WIFI){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSMutableDictionary *wifiDic = [cameraDic objectForKey:@"Wi-Fi AP Setup"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"AP_SSID"]];
            NSString *subValue;
            if (value.length > 18) {
                subValue = [value substringWithRange:NSMakeRange(0, value.length-18)];
            }else{
                subValue = value;
            }
            [wifiDic setValue:subValue forKey:@"SSID"];
            value = [NSString stringWithString:[json objectForKey:@"AP_AUTH_KEY"]];
            [wifiDic setValue:value forKey:@"password"];
            [_delegate updateWiFiSettingsToTable];
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_UPDATE_WIFI){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"value"]];
            [cameraDic setValue:value forKey:@"Resolution"];
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }else if(tag == SOCKET_READ_TAG_LIST_STREAM_ALIVE || tag == SOCKET_READ_TAG_LIST_STREAM){
        NSDictionary *parsedDic = [NSDictionary dictionaryWithDictionary:[RecieveDataParser parseSocketReadData:data withTag:(int)tag]];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSMutableDictionary *cameraDic = [manager.dictionarySetting objectForKey:cameraSerialLocal];
        NSString *dataType = [parsedDic objectForKey:@"type"];
        if ([dataType isEqualToString:@"JSON DATA"]) {
            NSDictionary *json = [parsedDic objectForKey:@"json"];
            NSString *value = [NSString stringWithString:[json objectForKey:@"BITRATE"]];
            if (value.intValue > 0) {
                [cameraDic setObject:value forKey:@"Bit Rate"];
                if (tag == SOCKET_READ_TAG_LIST_STREAM_ALIVE) {
                    [_delegate updateCameraSettings];
                }
            }
            value = [NSString stringWithString:[json objectForKey:@"VINWIDTH"]];
            if (value.intValue == 640) {
                [cameraDic setObject:@"1" forKey:@"Resolution"];
            }else{
                [cameraDic setObject:@"0" forKey:@"Resolution"];
            }
        } else if ([dataType isEqualToString:@"no data"]){
            [socket readDataWithTimeout:-1 tag:(int)tag];
            return;
        }
    }
}

-(BOOL)sendCommand:(NSString *)commandString toCamera:(NSString *)cameraSerial withTag:(int)tag {
    commandToBeSent = [NSString stringWithString:commandString];
    cameraSerialLocal = [NSString stringWithString:cameraSerial];
    tagLocal = tag;
    
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:cameraSerial];
    NSString *fullURL = [dic objectForKey:@"URL"];
    NSArray *split = [fullURL componentsSeparatedByString:@"/"];
    NSString *splitURL;
    if (split.count == 1) {
        splitURL = [split objectAtIndex:0];
    }else{
        splitURL = [split objectAtIndex:2];
    }
    localURL = splitURL;
    if (_isConnected == NO || ![socket.connectedHost isEqualToString:_hostURL]){
        NSLog(@"connect to host; send command set");
        return [self connectHost:splitURL withPort:@"80" withTag:tag];
    }else{
        [self sendData];
        return YES;
    }
}

-(void)setTag:(int)value commandCategory:(NSString *)string{
    commandName = string;
    tagLocal = value;
}

@end
