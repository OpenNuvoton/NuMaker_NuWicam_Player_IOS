//
//  MultipleSettingTableViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/16.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "MultipleSettingTableViewController.h"

@interface MultipleSettingTableViewController ()

@end

@implementation MultipleSettingTableViewController
@synthesize labelTitle = _labelTitle;
- (void)viewDidLoad {
    [super viewDidLoad];
//    UINib *nib = [UINib nibWithNibName:@"HistoryPicker" bundle:nil];
//    [nib instantiateWithOwner:self options:nil];
    [_historyPicker setHidden:YES];
    sectionOfTable = 1;
    if ([receivedString isEqualToString:@"Setup Camera"]) {
        rowOfTable = 5;
    } else if ([receivedString isEqualToString:@"Wi-Fi AP Setup"]){
        rowOfTable = 4;
    } else if ([receivedString isEqualToString:@"APP Version"]){
        rowOfTable = 2;
    }
    _labelTitle.text = receivedString;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setPicker];
    rebootAnnounce = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    if ([receivedString isEqualToString:@"Setup Camera"]) {
        [self updateHistoryRecord];
    }else if([receivedString isEqualToString:@"Wi-Fi Setup"]){
        [self updateWiFiSettings];
    }
    BOOL update = [[PlayerManager sharedInstance] updateSettingPropertyList];
    DDLogDebug(@"update result: %@", ((update == YES) ? @"Success!" : @"Failed...") );
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self didConnectToHostWithTag:SOCKET_READ_TAG_LIST_STREAM];
    PlayerManager *manager = [PlayerManager sharedInstance];
    if ([receivedString isEqualToString:@"Setup Camera"]) {
        NSDictionary *cameraDic = [manager.dictionarySetting objectForKey:receivedString];
        historyArray = [NSMutableArray arrayWithObject:@"History Records"];
        [historyArray addObjectsFromArray:[cameraDic objectForKey:@"History"]];
    }else{
        [self listWiFiSettings];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChangeSetting:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionOfTable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rowOfTable;
}

- (void)setupString:(NSString *)string forType:(NSString *)type{
    [_labelTitle setText:string];
}

-(void)setupArray:(NSArray *)array forCategory:(NSString *)category{
    receivedArray = [NSArray arrayWithArray:array];
    receivedString = [NSString stringWithString:category];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    UILabel *label = (UILabel *) [cell viewWithTag:10];
    UITextField *textfield = (UITextField *) [cell viewWithTag:11];
    UISegmentedControl *control = (UISegmentedControl *)[cell viewWithTag:12];
    UISlider *slider = (UISlider *)[cell viewWithTag:13];
    UILabel *labelValue = (UILabel *) [cell viewWithTag:14];
    UIButton *button = (UIButton *)[cell viewWithTag:16];
    UILabel *labelVerison = (UILabel *)[cell viewWithTag:17];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    for (int i=10; i<19; i++){
        UIControl *ui = [cell viewWithTag:i];
        [ui setHidden:YES];
    }
    if ( [receivedString isEqualToString:@"Setup Camera"]) {
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSString *key;
        if ([receivedString isEqualToString:@"Setup Camera"]) {
            key = @"0";
        }
        NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
        NSString *cameraName = [NSString stringWithString:[dic objectForKey:@"Name"]];
        NSString *cameraURL = [NSString stringWithString:[dic objectForKey:@"URL"]];
        NSString *cameraResolution = [NSString stringWithString:[dic objectForKey:@"Resolution"]];
        NSString *cameraFPS = [NSString stringWithString:[dic objectForKey:@"Bit Rate"]];
        UIButton *buttonHistory;
        label.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
        switch (indexPath.row) {
            case 0: //name
                [label setHidden:NO];
                [textfield setHidden:NO];
                label.text = @"Name";
                textfieldName = textfield;
                textfieldName.text = cameraName;
                break;
            case 1: //url
                [label setHidden:NO];
                [textfield setHidden:NO];
                label.text = @"URL";
                textfieldURL = textfield;
                textfieldURL.text = cameraURL;
                [textfieldURL setRightViewMode:UITextFieldViewModeAlways];
                buttonHistory = [UIButton buttonWithType:UIButtonTypeInfoLight];
                buttonHistory.contentMode = UIViewContentModeCenter;
                [buttonHistory addTarget:self action:@selector(showHistoryPicker) forControlEvents:UIControlEventTouchDown];
                [buttonHistory setImage:[UIImage imageNamed:@"signature"] forState:UIControlStateNormal];
                textfieldURL.rightView = buttonHistory;
                break;
            case 2: //resolution
                [label setHidden:NO];
                [control setHidden:NO];
                label.text = @"Resolution";
                controlResolution = control;
                [controlResolution setTitle:@"QVGA" forSegmentAtIndex:0];
                [controlResolution setTitle:@"VGA" forSegmentAtIndex:1];
                [controlResolution setTitle:@"360p" forSegmentAtIndex:2];
                [controlResolution removeSegmentAtIndex:3 animated:NO];
                [controlResolution setSelectedSegmentIndex:cameraResolution.intValue];
                break;
            case 3: //fps
                [label setHidden:NO];
                [labelValue setHidden:NO];
                [slider setHidden:NO];
                labelBitRateValue = labelValue;
                label.text = @"BitRate";
                sliderBitRate = slider;
                sliderBitRate.value = (float)cameraFPS.intValue;
                labelBitRateValue.text = [NSString stringWithFormat:@"%d", (int)sliderBitRate.value*1024];
                break;
            case 4:
                rebootButton = button;
                [rebootButton setTitle:@"Restart Stream to take effect." forState:UIControlStateNormal];
                [rebootButton setHidden:NO];
                break;
            default:
                break;
        }
    } else if ( [receivedString isEqualToString:@"Wi-Fi AP Setup"]){
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:@"Setup Camera"];
        NSMutableDictionary *wifiDic = [dic objectForKey:@"Wi-Fi AP Setup"];
        if (wifiDic == nil) {
            NSString *SSID = @"NuWicam";
            NSString *PASS = @"12345678";
            [wifiDic setObject:SSID forKey:@"AP_SSID"];
            [wifiDic setObject:PASS forKey:@"AP_AUTH_KEY"];
        }
        if (indexPath.row == 0) {
            [label setHidden:NO];
            [textfield setHidden:NO];
            label.text = @"SSID";
            textfieldSSID = textfield;
            textfieldSSID.text = [wifiDic objectForKey:@"SSID"];
        } else if(indexPath.row == 1){
            label.text = @"Password";
            [label setHidden:NO];
            [textfield setHidden:NO];
            textfieldPASS = textfield;
            textfieldPASS.text = [wifiDic objectForKey:@"password"];;
            textfieldPASS.secureTextEntry = YES;
        } else if (indexPath.row == 2){
            [button setHidden:NO];
            showPasswordButton = button;
            [showPasswordButton setTitle:@"Show Password" forState:UIControlStateNormal];
        } else if (indexPath.row == 3){
            [button setHidden:NO];
            restartWiFiButton = button;
            [restartWiFiButton setTitle:@"Restart Wi-Fi to take effect." forState:UIControlStateNormal];
        }
        [dic setObject:wifiDic forKey:@"Wi-Fi AP Setup"];
    }else if ( [receivedString isEqualToString:@"APP Version"]){
        if (indexPath.row == 0) {
            [label setHidden:NO];
            [labelVerison setHidden:NO];
            label.text = @"Version";
            labelVerison.text = @"1.1.0";
        }else if (indexPath.row == 1){
            [button setHidden:NO];
            sendReportButton = button;
            [sendReportButton setTitle:@"Send Report" forState:UIControlStateNormal];
        }
    }
    return cell;
}
#pragma value change sending

- (void)rebootButtonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    if ([button isEqual:rebootButton]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restart Required" message:@"The stream will restart, is it okay?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
        alert.tag = 0;
        [alert show];
    }else if([button isEqual:restartWiFiButton]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restart Required" message:@"Wi-Fi will restart, is it okay?" delegate:self cancelButtonTitle:@"Don't restart now" otherButtonTitles:@"Restart", nil];
        alert.tag = 1;
        [alert show];
    }else if([button isEqual:sendReportButton]){
        [self sendMail:nil];
    }else{
        textfieldPASS.secureTextEntry = NO;
    }
}

- (IBAction)sliderValueChange:(id)sender {
    [self.view endEditing:YES];
    UISlider *slider = (UISlider *)sender;
    NSMutableDictionary *dic = [[PlayerManager sharedInstance] dictionarySetting];
    NSMutableDictionary *cameraDic = [dic objectForKey:receivedString];
    slider.value = roundf(slider.value);
    NSString *value = [NSString stringWithFormat:@"%d", (int)slider.value];
    if ([slider isEqual:sliderBitRate]) {
        labelBitRateValue.text = [NSString stringWithFormat:@"%d", (int)sliderBitRate.value*1024];
        [cameraDic setObject:value forKey:@"FPS"];
    }
}

-(void)segmentsValueChange:(id)sender{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    NSString *string;
    if ([control isEqual:controlResolution]) {
        string = [NSString stringWithFormat:@"%d", (int)control.selectedSegmentIndex];
        NSArray *array = @[string];
        [self sendValueWithCategory:@"Update Resolution" withSettings:array];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSMutableDictionary *dic = manager.dictionarySetting;
    NSMutableDictionary *cameraDic = [dic objectForKey:@"Setup Camera"];
    if ([textField isEqual:textfieldName]) {
        NSString *string = [NSString stringWithString:textfieldName.text];
        [cameraDic setObject:string forKey:@"Name"];
    }else if([textField isEqual:textfieldURL]){
        NSString *string = [NSString stringWithString:textfieldURL.text];
        [cameraDic setObject:string forKey:@"URL"];
    }else if([textField isEqual:textfieldSSID]){
        NSString *string = [NSString stringWithString:textfieldSSID.text];
        NSMutableDictionary *wifiDic = [cameraDic objectForKey:@"Wi-Fi AP Setup"];
        [wifiDic setObject:string forKey:@"SSID"];
        [self updateWiFiSettings];
    }else if([textField isEqual:textfieldPASS]){
        NSString *string = [NSString stringWithString:textfieldPASS.text];
        NSMutableDictionary *wifiDic = [cameraDic objectForKey:@"Wi-Fi AP Setup"];
        [wifiDic setObject:string forKey:@"PASS"];
        [self updateWiFiSettings];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    if ([receivedString isEqualToString:@"Setup Camera"]) {
        [self updateHistoryRecord];
    }else{
        [self updateWiFiSettings];
    }
    return NO;
}

- (void)updateWiFiSettingsToTable{
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSDictionary *dic = [manager.dictionarySetting objectForKey:@"Setup Camera"];
    NSDictionary *wifiDic = [dic objectForKey:@"Wi-Fi AP Setup"];
    textfieldSSID.text = [NSString stringWithString:[wifiDic objectForKey:@"SSID"]];
    textfieldPASS.text = [NSString stringWithString:[wifiDic objectForKey:@"password"]];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [_historyPicker setHidden:YES];
}

-(void)sliderTouchUpInside:(id)sender{
    [self.view endEditing:YES];
    UISlider *slider = (UISlider *)sender;
    NSMutableDictionary *dic = [[PlayerManager sharedInstance] dictionarySetting];
    NSMutableDictionary *cameraDic = [dic objectForKey:receivedString];
    NSString *value = [NSString stringWithFormat:@"%d", (int)slider.value];
    if ([slider isEqual:sliderBitRate]) {
        if (sliderBitRate.value == 8) {
            labelBitRateValue.text = [NSString stringWithFormat:@"%d", (int)sliderBitRate.value*1024];
        }else{
            labelBitRateValue.text = [NSString stringWithFormat:@"%d", (int)sliderBitRate.value*1024];
        }
        [cameraDic setObject:value forKey:@"Bit Rate"];
        NSString *bitrate = [NSString stringWithFormat:@"%d", value.intValue*1024];
        NSArray *settingArray = @[bitrate];
        [self sendValueWithCategory:@"Update Bit Rate" withSettings:settingArray];
    }
}

#pragma misc functions

-(void)setString:(NSString *)string{
    receivedString = [NSString stringWithString:string];
}

-(NSDictionary *)getSSID{
    NSArray *interfaces = (__bridge_transfer NSArray *) CNCopySupportedInterfaces();
    DDLogDebug(@"Supported interfaces :%@", interfaces);
    
    NSDictionary *info;
    for (NSString *interfaceName in interfaces) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
        DDLogDebug(@"%@ => %@", interfaceName, info);
        if (info && [info count] ) {
            break;
        }
    }
    return info;
}

-(void)listWiFiSettings{
    NSString *command = [SkyEyeCommandGenerator generateInfoCommandWithName:@"List Wi-Fi Parameters"];
    SocketManager *socketManager = [SocketManager shareInstance];
    [socketManager sendCommand:command toCamera:@"Setup Camera" withTag:SOCKET_READ_TAG_LIST_WIFI];
}

-(void)updateWiFiSettings{
    NSString *localSSID = [NSString stringWithString:textfieldSSID.text];
    NSString *localPASS = [NSString stringWithString:textfieldPASS.text];
    NSString *subCommand = [NSString stringWithFormat:@"&AP_SSID=%@&AP_AUTH_KEY=%@", localSSID, localPASS];
    NSArray *array = @[subCommand];
    SocketManager *socketManager = [SocketManager shareInstance];
    NSString *command = [SkyEyeCommandGenerator generateInfoCommandWithName:@"Update Wi-Fi Parameters" parameters:array];
    [socketManager sendCommand:command toCamera:@"Setup Camera" withTag:SOCKET_READ_TAG_UPDATE_WIFI];
}

-(void)updateHistoryRecord{
    NSString *historyString = [NSString stringWithString:textfieldURL.text];
    if ([historyString isEqualToString:@""]) {
        historyString = @"-";
    }
    NSString *firstHistory = [historyArray objectAtIndex:1];
    if (![firstHistory isEqualToString:historyString]) {
        for (int i=(int)historyArray.count-1; i>1; i--) {
            NSString *from = [historyArray objectAtIndex:i-1];
            [historyArray setObject:from atIndexedSubscript:i];
        }
        [historyArray setObject:historyString atIndexedSubscript:1];
    }
    NSArray *tempArray = [historyArray subarrayWithRange:NSMakeRange(1, 5)];
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSMutableDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
    [dic setObject:tempArray forKey:@"History"];
    NSString *targetURL = [tempArray objectAtIndex:0];
    [dic setObject:targetURL forKey:@"URL"];
}

#pragma touches began delegate

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [_historyPicker setHidden:YES];
    DDLogDebug(@"touches began");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([receivedString isEqualToString:@"Setup Camera"]) {
        [_historyPicker setHidden:YES];
        [self updateHistoryRecord];
    }else{
        [self.view endEditing:YES];
    }
}

-(void)setCameraInCategory:(NSString *)category withAnyValue:(NSString *)value{
    
}

#pragma send value to device

-(void)sendValueWithCategory:(NSString *)category{
    NSString *generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:category]];
    SocketManager *socketManager = [SocketManager shareInstance];
    DDLogDebug(@"command: %@", generatedCommand);
    if ([category isEqualToString:@"Device Mic"]) {
        [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_OTHER];
    }
    [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_SEND_SETTING];
}

-(void)sendValueWithCategory:(NSString *)category withSettings:(NSArray *)settingArray{
    NSString *generatedCommand = @"";
    NSString *stream = @"Update Stream Parameters";
    NSString *wifi = @"Update Wi-Fi Parameters";
    SocketManager *socketManager = [SocketManager shareInstance];
    if ([category isEqualToString:@"Update Stream Parameters"]) {
        generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:category parameters:settingArray]];
        [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_OTHER];
    } else if ([category isEqualToString:@"Update Resolution"]) {
        NSMutableArray *parameters = [[NSMutableArray alloc]init];
        NSString *resolutionSelect = [settingArray objectAtIndex:0];
        if (resolutionSelect.intValue == 0) {
            [parameters addObject:[NSString stringWithFormat:@"&VINWIDTH=320&JPEGENCWIDTH=320"]];
            [parameters addObject:[NSString stringWithFormat:@"&VINHEIGHT=240&JPEGENCHEIGHT=240"]];
        } else if (resolutionSelect.intValue == 1) {
            [parameters addObject:[NSString stringWithFormat:@"&VINWIDTH=640&JPEGENCWIDTH=640"]];
            [parameters addObject:[NSString stringWithFormat:@"&VINHEIGHT=480&JPEGENCHEIGHT=480"]];
        } else if (resolutionSelect.intValue == 2) {
            [parameters addObject:[NSString stringWithFormat:@"&VINWIDTH=640&JPEGENCWIDTH=640"]];
            [parameters addObject:[NSString stringWithFormat:@"&VINHEIGHT=360&JPEGENCHEIGHT=360"]];
        }
        generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:stream parameters:parameters]];
        [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_OTHER];
    } else if ([category isEqualToString:@"Update Bit Rate"]) {
        NSMutableArray *parameters = [[NSMutableArray alloc]init];
        NSString *bitRate = [settingArray objectAtIndex:0];
        [parameters addObject:[NSString stringWithFormat:@"&BITRATE=%@", bitRate]];
        generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:stream parameters:parameters]];
        [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_OTHER];
    } else if ([category isEqualToString:wifi]) {
        NSMutableArray *parameters = [[NSMutableArray alloc]init];
        NSString *ssid = [settingArray objectAtIndex:0];
        NSString *pass = [settingArray objectAtIndex:1];
        [parameters addObject:[NSString stringWithFormat:@"&AP_SSID=%@", ssid]];
        [parameters addObject:[NSString stringWithFormat:@"&AP_AUTH_KEY=%@", pass]];
        generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:category parameters:settingArray]];
        [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_OTHER];
    }
    [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:SOCKET_READ_TAG_SEND_SETTING];
}

-(void)sendRestartCommand:(int)option{
    if (option == 0) {
        NSString *generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:@"Restart Stream"]];
        SocketManager *socketManager = [SocketManager shareInstance];
        DDLogDebug(@"command: %@", generatedCommand);
        [socketManager sendCommand:generatedCommand toCamera:@"Setup Camera" withTag:SOCKET_READ_TAG_INFO_REBOOT];
    }else if (option == 1){
        NSString *generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:@"Restart Wi-Fi"]];
        SocketManager *socketManager = [SocketManager shareInstance];
        DDLogDebug(@"command: %@", generatedCommand);
        [socketManager sendCommand:generatedCommand toCamera:@"Setup Camera" withTag:SOCKET_READ_TAG_INFO_REBOOT];
    }
    
}

#pragma did connect/disconnect

-(void)didConnectToHostWithTag:(int)tag{
    SocketManager *socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    NSString *generatedCommand;
    switch (tag) {
        case SOCKET_READ_TAG_LIST_STREAM:
            generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:@"List Stream Parameters"]];
            break;
        case SOCKET_READ_TAG_LIST_WIFI:
            generatedCommand = [NSString stringWithString:[SkyEyeCommandGenerator generateInfoCommandWithName:@"List Wi-Fi Parameters"]];
            break;
            
        default:
            break;
    }
    [socketManager sendCommand:generatedCommand toCamera:receivedString withTag:tag];
}

-(void)connectHostWithTag:(int)tag{
    SocketManager *socketManager = [SocketManager shareInstance];
    socketManager.delegate = self;
    PlayerManager *playerManager = [PlayerManager sharedInstance];
    NSDictionary *dic = [playerManager.dictionarySetting objectForKey:receivedString];
    NSString *fullURL = [dic objectForKey:@"URL"];
    NSArray *split = [fullURL componentsSeparatedByString:@"/"];
    NSString *splitURL;
    if (split.count == 1) {
        splitURL = [split objectAtIndex:0];
    }else{
        splitURL = [split objectAtIndex:2];
    }
    [socketManager connectHost:splitURL withPort:@"8000" withTag:tag];
}

#pragma socket manager delegate

-(void)updateCameraSettings{
    [self.tableView reloadData];
}

#pragma alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        switch (buttonIndex) {
            case 1:
                [self sendRestartCommand:0];
                break;
            default:
                break;
        }
    } else if (alertView.tag == 1){
        switch (buttonIndex) {
            case 1:
                [self sendRestartCommand:1];
                break;
            default:
                break;
        }
    } else if (alertView.tag == 2){
        
    } else if (alertView.tag == 3){
        
    }
}

#pragma socket manager delegate

-(void)hostNotResponse:(int)serial command:(NSString *)command{
    
}

#pragma button delegate

-(void)showHistoryPicker{
    [self.view endEditing:YES];
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSDictionary *dic = [manager.dictionarySetting objectForKey:receivedString];
    NSArray *history = [dic objectForKey:@"History"];
    NSArray *historyHead = [NSArray arrayWithObject:@"History Records"];
    NSArray *temp = [historyHead arrayByAddingObjectsFromArray:history];
    historyArray = [NSMutableArray arrayWithArray:temp];
    [_historyPicker setHidden:!_historyPicker.hidden];
    [self updateHistoryRecord];
    [_historyPicker reloadComponent:0];
    [_historyPicker selectRow:0 inComponent:0 animated:YES];
}

#pragma picker delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return historyArray.count;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.bounds.size.width, 50)];
    label.text = [historyArray objectAtIndex:(int)row];
    if (row == 0) {
        [label setFont:[UIFont fontWithName:@"Courier" size:25]];
    }else{
        [label setFont:[UIFont fontWithName:@"System" size:17]];
    }
    [label setTextAlignment:NSTextAlignmentCenter];
    label.textColor = UIColorFromRGB(0x007DFF);
    label.adjustsFontSizeToFitWidth = YES;
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSString *dash = @"-";
    NSString *labelString = [historyArray objectAtIndex:row];
    if (row > 0 && ![labelString isEqualToString:dash]) {
        textfieldURL.text = [NSString stringWithString:labelString];
    }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}

-(void)setPicker{
    UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
    CGFloat x, y, w, h;
    if (interfaceOrientation == UIInterfaceOrientationPortrait ||
        interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        x = 0;
        y = 1*self.view.bounds.size.height/2;
        w = self.view.bounds.size.width;
        h = 1.3*self.view.bounds.size.height/3;
    } else {
        x = 0;
        y = self.view.bounds.size.height/2;
        w = self.view.bounds.size.width;
        h = 1.3*self.view.bounds.size.height/3;
    }
    CGRect frame = CGRectMake(x, y, w, h);
    historyFrame = frame;
    if (_historyPicker == nil) {
        _historyPicker = [[UIPickerView alloc]initWithFrame:historyFrame];
    }
    _historyPicker = [[UIPickerView alloc] initWithFrame:historyFrame];
    _historyPicker.backgroundColor = UIColorFromRGB(0xCCE3FF);//UIColorFromRGB(0x006DF0);
    _historyPicker.alpha = 0.95f;
    _historyPicker.dataSource = self;
    _historyPicker.delegate = self;
    [self.view addSubview:_historyPicker];
    [_historyPicker setHidden:YES];
}

- (void)orientationChangeSetting:(UIInterfaceOrientation) orientation{
    [_historyPicker removeFromSuperview];
    _historyPicker = nil;
    [self setPicker];
    [_historyPicker setHidden:YES];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField isEqual:textfieldSSID]) {
        if (range.length + range.location > textField.text.length) {
            return NO;
        }
        NSUInteger newLength = textField.text.length + string.length - range.length;
        return newLength <= 12;
    }else if ([textField isEqual:textfieldPASS]){
        if (range.length + range.location > textField.text.length) {
            return NO;
        }
        NSUInteger newLength = textField.text.length + string.length - range.length;
        return newLength <= 15;
    }
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)sendMail:(id)sender{
    if ([MFMailComposeViewController canSendMail]) {
        mailComposer = [[MFMailComposeViewController alloc]init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"Send Report"];
        [mailComposer setToRecipients:@[@"CCHSU20@nuvoton.com"]];
        [mailComposer setMessageBody:@"" isHTML:NO];
        PlayerManager *manager = [PlayerManager sharedInstance];
        NSString *file = manager.getCurrentLogFilePath;
        NSArray *filePart = [file componentsSeparatedByString:@"."];
        NSString *filename = [filePart objectAtIndex:0];
        NSData *fileData = [NSData dataWithContentsOfFile:file];
        
        NSString *mimeType = @"text/plain";
        [mailComposer addAttachmentData:fileData mimeType:mimeType fileName:filename];
        [self presentViewController:mailComposer animated:YES completion:NULL];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"E-mail not Enable" message:@"Configure your E-mail account first!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result) {
        DDLogDebug(@"Result : %d",result);
    }
    if (error) {
        DDLogDebug(@"Error : %@",error);
    }
    [self dismissModalViewControllerAnimated:YES];
    
}

@end
