//
//  LiveViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "LiveViewController.h"

@interface LiveViewController ()

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isConnectedToModbus = NO;
    hideUIFlag = NO;
    hideSliderFlag = NO;
    isFullScreen = NO;
    isPlaying = NO;
    redDotFlash = NO;
    _outletPlayButton.enabled = NO;
    deviceRegionDifference = self.view.bounds.size.width - self.view.bounds.size.height;
    if (deviceRegionDifference <= 0) {
        deviceRegionDifference = 0 - deviceRegionDifference;
    }
    [outletBuffering stopAnimating];
    _outletSeekSlider.minimumValue = 0;
    _outletSeekSlider.maximumValue = 1;
    _outletSeekSlider.value = 0;
    _outletSeekSlider.enabled = NO;
    socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    activeCamSerial = -1;
    // Do any additional setup after loading the view.
    queue = dispatch_queue_create("com.dispatch.video", DISPATCH_QUEUE_SERIAL);
    cameraString = @"1";
}

-(void)viewDidAppear:(BOOL)animated{
    UIApplication *app = [UIApplication sharedApplication];
    app.idleTimerDisabled = YES;
    _outletSeekSlider.value = 0;
    _outletSeekSlider.enabled = NO;
    [self initCamera:cameraString.intValue];
    [self.tabBarController.tabBar setUserInteractionEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(enableTabBar) userInfo:nil repeats:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    isPlaying = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    if (hideUIFlag == YES) {
        [self dismissTabBars:NO];
    }
    UIApplication *app = [UIApplication sharedApplication];
    app.idleTimerDisabled = NO;
    [playTimer invalidate];
    playTimer = nil;
    [dotTimer invalidate];
    dotTimer = nil;
    [checkTimer invalidate];
    checkTimer = nil;
    [_video closeAudio];
    _video = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [outletBuffering stopAnimating];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPlay:(id)sender {
//    VMediaPlayer *player = [VMediaPlayer sharedInstance];
    if (isPlaying == YES) {
        isPlaying = NO;
        [_outletPlayButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [dotTimer invalidate];
        [playTimer invalidate];
        dotTimer = nil;
        playTimer = nil;
    } else {
        UIButton *button = (UIButton *)sender;
        button.enabled = NO;
        isPlaying = YES;
        [button setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self playVideoViewWithPath:targetURL seekTime:0];
    }
}

- (IBAction)buttonExpand:(id)sender {
    NSNumber *orientationNumber = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    if (interfaceOrientation == UIInterfaceOrientationPortrait ||
        interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        isFullScreen = YES;
        [_outletVersionLabel setHidden:YES];
        [[UIDevice currentDevice] setValue:orientationNumber forKey:@"orientation"];
        [_outletExpandButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
    } else {
        orientationNumber = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [_outletVersionLabel setHidden:NO];
        [[UIDevice currentDevice] setValue:orientationNumber forKey:@"orientation"];
        [_outletExpandButton setImage:[UIImage imageNamed:@"expand"] forState:UIControlStateNormal];
        
    }
}

- (void)actionLightOn:(id)sender{
    UIButton *button = (UIButton *)sender;
    DDLogDebug(@"light on value: %d", lightValue);
    uint8_t lightStatus[6] = {  (lightValue >> 5 ) & 0x1,
                                (lightValue >> 4 ) & 0x1,
                                (lightValue >> 3 ) & 0x1,
                                (lightValue >> 2 ) & 0x1,
                                (lightValue >> 1 ) & 0x1,
                                 lightValue & 0x1};
    lightStatus[button.tag-100] = !lightStatus[button.tag-100];
    int finalValue=0;
    for (int i=0; i<6; i++) {
        finalValue = finalValue | (lightStatus[i] << (5-i));
    }
    lightValue = finalValue;
    DDLogDebug(@"final light value: %d, %d", finalValue, lightValue);
    [modbusControl writeRegister:4 to:finalValue];
}

- (IBAction)actionSeekTime:(id)sender {
}

- (IBAction)actionBackToMain:(id)sender {
    [[self navigationController]popToRootViewControllerAnimated:YES];
}


- (IBAction)actionOneTap:(id)sender {
    //just invert the flag
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    if (interfaceOrientation != UIDeviceOrientationPortrait && interfaceOrientation != UIDeviceOrientationPortraitUpsideDown) {
        _outletTapGesture.enabled = NO;
        (hideUIFlag == YES) ? (hideUIFlag = NO) : (hideUIFlag = YES);
        [self dismissTabBars:hideUIFlag];
    }

}

- (void)idleHandleFunction{
    [self dismissSeekSlider:YES delay:(0.1) animate:(0.3)];
}

- (void)dismissSeekSlider:(BOOL)localHideSliderFlag delay:(float)delayTime animate:(float)animateTime{
    hideSliderFlag = localHideSliderFlag;
    int side = 1;
    (localHideSliderFlag == NO) ? (side = -1) : (side = 1);
}

- (void)dismissTabBars:(BOOL)localHideUIFlag{
    hideUIFlag = localHideUIFlag;
    int side = 1;//1 is up, 0 is down
    (localHideUIFlag == YES) ? (side = -1) : (side = 1);
    self.tabBarController.tabBar.transformY(-1*side*self.tabBarController.tabBar.bounds.size.height).easeIn.delay(0.1).animate(0.2).animationCompletion = JHAnimationCompletion(){
        _outletTapGesture.enabled = YES;
    };
}

- (void)orientationChange:(UIInterfaceOrientation) orientation{
    [self adjustViewForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)adjustViewForOrientation:(UIInterfaceOrientation) orientation{
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            if (hideUIFlag == NO) {
                if (isPlaying == YES) {
                    [self dismissTabBars:YES];
                    [_outletVersionLabel setHidden:YES];
                }
                [_outletExpandButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
                self.view.backgroundColor = [UIColor blackColor];
                isFullScreen = YES;
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
            if (hideUIFlag == NO) {
                if (isPlaying == YES) {
                    [self dismissTabBars:YES];
                    [_outletVersionLabel setHidden:YES];
                }
                [_outletExpandButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
                self.view.backgroundColor = [UIColor blackColor];
                isFullScreen = YES;
            }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationPortrait:
            [_outletVersionLabel setHidden:NO];
            if (hideUIFlag == YES) {
                [self dismissTabBars:NO];
            }
            if (hideSliderFlag == YES) {
                [self dismissSeekSlider:NO delay:(0.1) animate:(0.5)];
            }
            [_outletExpandButton setImage:[UIImage imageNamed:@"expand"] forState:UIControlStateNormal];
            self.view.backgroundColor = [UIColor whiteColor];
            isFullScreen = NO;
            break;
        default:
            break;
    }
    [self determineResolution];
}



-(void)displayLiveNextFrame:(NSTimer *)timer {
    _outletSeekSlider.value = 1;
    if (![_video stepFrame]) {
        [timer invalidate];
        [dotTimer invalidate];
        [_outletPlayButton setEnabled:YES];
        [_video closeAudio];
        return;
    }
    if (checkTimer != nil) {
        [checkTimer invalidate];
        checkTimer = nil;
    }
//    NSLog(@"%f, %f, %d, %d", _outletLiveView.frame.size.width, _outletLiveView.frame.size.height, _video.outputWidth, _video.outputHeight);

//    [self determineResolution];
//    _video.outputWidth = _outletLiveView.bounds.size.width;
//    _video.outputHeight = _outletLiveView.bounds.size.height;
    dispatch_async(dispatch_get_main_queue(), ^{
        _outletLiveView.backgroundColor = [UIColor colorWithPatternImage:_video.currentImage];
        [_outletPlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        isPlaying = YES;
        [outletBuffering stopAnimating];
        _outletSeekSlider.value = _outletSeekSlider.maximumValue;
        _outletPlayButton.enabled = YES;
        [outletBuffering stopAnimating];
    });
}

- (void)determineResolution{
    float ratio = 1.33f;
    float viewWidth = _outletLiveView.frame.size.width;
    float viewHeight = _outletLiveView.frame.size.width / ratio;
//    NSLog(@"%f, %f, %d, %d", _outletLiveView.frame.size.width, _outletLiveView.frame.size.height, _video.outputWidth, _video.outputHeight);
    if (resolution.intValue > 2) {
        ratio = 1.67f;
        viewHeight = _outletLiveView.frame.size.width / ratio;
    }
    if (self.view.frame.size.height <= _outletLiveView.frame.size.height) {
        viewWidth = viewHeight * ratio;
    }
    [_outletLiveView setFrame:CGRectMake(_outletLiveView.frame.origin.x, _outletLiveView.frame.origin.y, viewWidth, viewHeight)];
    _video.outputWidth = (int) _outletLiveView.frame.size.width;
    _video.outputHeight = (int) _outletLiveView.frame.size.height;
}

- (void)initCamera:(int)cameraSerial{
    PlayerManager* manager = [PlayerManager sharedInstance];
    NSString *string = [NSString stringWithFormat:@"Setup Camera"];
    NSMutableDictionary *dic = manager.dictionarySetting;
    NSMutableDictionary *cameraDic = [dic objectForKey:string];
    NSString *url = [cameraDic objectForKey:@"URL"];
    [outletBuffering startAnimating];
    targetURL = url;
    @try {
        [checkTimer invalidate];
        checkTimer = nil;
        [self playVideoViewWithPath:targetURL seekTime:0];
    }
    @catch (NSException *exception) {
        DDLogDebug(@"set data source failed");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Not Stable" message:@"Please Check Internet Connection and try again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    _outletSeekSlider.enabled = NO;
    _outletSeekSlider.value = 0;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    NSString *string = @"EditCameraSegue";
    passedString = [NSString stringWithFormat:@"Setup Camera %d", (int)cameraTabBar.selectedItem.tag + 1 - 300];
    [self performSegueWithIdentifier:string sender:self];
    return YES;
}

-(void)flashRedDot{
    NSString *string = [[NSString alloc] init];
    (redDotFlash == YES) ? (string = @"flashOn", redDotFlash = NO) : (string = @"flashOff", redDotFlash = YES);
    [_outletRedDot setImage:[UIImage imageNamed:string]];
    if (isConnectedToModbus == YES) {
        [modbusControl readRegister:3 count:5];
    }
}

#pragma delegate

- (void)hostNotResponse:(int)serial command:(NSString *)command{
}

- (void)hostResponse{
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
}

-(void)playVideoViewWithPath:(NSString *)path seekTime:(float)time{
    [outletBuffering startAnimating];
    [_outletPlayButton setEnabled:NO];
    [_outletSeekSlider setEnabled:NO];
    [playTimer invalidate];
    _video = nil;
    localPath = path;
    localTime = time;
    [self isDeviceAlive];
}

- (void)streamNotResponse{
    [self stopVideo];
    _outletOffline.text = @"OFFLINE";
    [_outletRedDot setImage:[UIImage imageNamed:@"flashOff"]];
    [self initCamera:cameraString.intValue];
}

- (void)stopVideo{
    [_video closeAudio];
    _video = nil;
    [playTimer invalidate];
    playTimer = nil;
    [dotTimer invalidate];
    dotTimer = nil;
    [checkTimer invalidate];
    checkTimer = nil;
    [outletBuffering stopAnimating];
}

- (void)isDeviceAlive{
    socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    NSString *category = @"List Stream Parameters";
    NSString *command = [SkyEyeCommandGenerator generateInfoCommandWithName:category];
    [socketManager sendCommand:command toCamera:@"Setup Camera" withTag:SOCKET_READ_TAG_LIST_STREAM_ALIVE];
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(streamNotResponse) userInfo:nil repeats:NO];
}

- (void)updateCameraSettings{
    modbusControl = [ModbusControl sharedInstance];
    modbusControl.delegate = self;
    _outletOffline.text = @"ONLINE";
    [checkTimer invalidate];
    checkTimer = nil;
    BOOL useTCPFlag = NO;
    _video = [[RTSPPlayer alloc] initWithVideo:localPath usesTcp:useTCPFlag];
    if (_video == nil) {
        [self stopVideo];
        return;
    }
    _video.outputWidth = _outletLiveView.bounds.size.width;
    _video.outputHeight = _outletLiveView.bounds.size.height;
    
    lastFrameTime = -1;
    
    // seek to 0.0 seconds
    [_video seekTime:localTime];
    _outletSeekSlider.value = 0;
    _outletSeekSlider.maximumValue = _video.duration;
    _outletSeekSlider.minimumValue = 0;
    
    isPlaying = YES;
    //	float nFrame = 1.0/10;
    // fps
    // nFrame for China: 25 frame per second
    // palFrame: 30 frame per second
    float palFrame = 1.0/30; // PAL Mode
    dotTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(flashRedDot) userInfo:nil repeats:YES];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            while (isPlaying) {
//            [self displayLiveNextFrame:nil];
//            [NSThread sleepForTimeInterval:palFrame];
//        }
//    });
    playTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame
                                                 target:self
                                               selector:@selector(displayLiveNextFrame:)
                                               userInfo:nil
                                                repeats:YES];
    
    isPlaying = NO;
    _outletPlayButton.enabled = YES;
}

#pragma modbus control delegate

- (void)modbusConnectSuccess{
    DDLogDebug(@"Modbus connect success");
    isConnectedToModbus = YES;
    [modbusControl readRegister:3 count:5];
}

- (void)modbusReadSuccess:(NSArray *)dataArray{
    NSNumber *temp = [dataArray objectAtIndex:4];
    NSNumber *light = [dataArray objectAtIndex:1];
    _outletTemperature.text = [NSString stringWithFormat:@"%@ \u2103", temp];
    
    lightValue = light.intValue;
    UIButton *button;
    for (int i=0; i<6; i++) {
        button = (UIButton *)[self.view viewWithTag:i+100];
        uint8_t temp = (lightValue >> (5-i));
        if ((temp & 0x1) == 1) {
            if (i == 0 || i == 1) {
                [button.imageView setImage:[UIImage imageNamed:@"lightBlueOff"]];
            }else if( i == 2 || i == 3){
                [button.imageView setImage:[UIImage imageNamed:@"lightOff"]];
            }else{
                [button.imageView setImage:[UIImage imageNamed:@"flashOff"]];
            }
        }else{
            if (i == 0 || i == 1) {
                [button.imageView setImage:[UIImage imageNamed:@"lightBlueOn"]];
            }else if( i == 2 || i == 3){
                [button.imageView setImage:[UIImage imageNamed:@"lightOn"]];
            }else{
                [button.imageView setImage:[UIImage imageNamed:@"flashOn"]];
            }
        }
    }
}

- (void)modbusWriteSuccess{
    
}

- (void)modbusConnectFail{
    isConnectedToModbus = NO;
    modbusControl.count++;
    if (modbusControl.count < 3) {
        [modbusControl connect];
    }else{
        [_outletTemperature setHidden:YES];
        UIButton *button;
        for (int i=0; i<6; i++) {
            button = (UIButton *)[self.view viewWithTag:i+100];
            [button setHidden:YES];
        }
    }
}

- (void)enableTabBar{
    [self.tabBarController.tabBar setUserInteractionEnabled:YES];
}

@end
