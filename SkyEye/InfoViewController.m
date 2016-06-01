//
//  InfoViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize infoCatagoryArray = _infoCatagoryArray;
@synthesize infoItemAudioArray = _infoItemAudioArray;
@synthesize infoItemVideoArray = _infoItemVideoArray;
@synthesize infoItemWirelessArray = _infoItemWirelessArray;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initInfoArray];
    CommandPool *pool = [CommandPool sharedInstance];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [_infoCatagoryArray objectAtIndex:section];
    return array.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _infoCatagoryArray.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *settingCatagoryCellIdentifier = @"InfoCatagoryCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:settingCatagoryCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingCatagoryCellIdentifier];
    }
    NSString *string = [[NSString alloc]init];
    if (section == VIDEO_SECTION) {
        string = @"Video Stream";
    } else if (section == AUDIO_SECTION){
        string = @"Audio Stream";
    } else if (section == WIRELESS_SECTION){
        string = @"Wireless Setup";
    }
    UIImageView *sectionImage = (UIImageView *) [cell viewWithTag:INFO_SECTION_IMAGE_TAG];
    [sectionImage setImage:[UIImage imageNamed:@"snapshot"]];
    UILabel *sectionLabel = (UILabel *) [cell viewWithTag:INFO_SECTION_LABEL_TAG];
    [sectionLabel setText:string];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *settingItemCellIndentifier = @"InfoItemCellIdentifier";
    InfoItemCellPrototype *cell = [tableView dequeueReusableCellWithIdentifier:settingItemCellIndentifier];
    if (cell == nil) {
        cell = [[InfoItemCellPrototype alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingItemCellIndentifier];
    }
    NSString *string = [[NSString alloc]init];
    if (indexPath.section == VIDEO_SECTION) {
        string = [_infoItemVideoArray objectAtIndex:indexPath.row];
    } else if (indexPath.section == AUDIO_SECTION){
        string = [_infoItemAudioArray objectAtIndex:indexPath.row];
    } else if (indexPath.section == WIRELESS_SECTION){
        string = [_infoItemWirelessArray objectAtIndex:indexPath.row];
    }
    UILabel *sectionLabel = (UILabel *) [cell viewWithTag:INFO_ITEM_LABEL_TAG];
    sectionLabel.text = string;
    UILabel *settingLabel = (UILabel *) [cell viewWithTag:INFO_CURRENT_SETTING_TAG];
    NSString *detailString = @"YEEEEEEEEEE";
    settingLabel.text = detailString;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}

- (void)initInfoArray{
    if (_infoItemVideoArray == nil) {
        _infoItemVideoArray = [[NSArray alloc] initWithObjects:@"Resolution", @"Encode Quality", @"Bit Rate", @"FPS", nil];
    }
    if (_infoItemAudioArray == nil) {
        _infoItemAudioArray = [[NSArray alloc] initWithObjects:@"Device Mic Mute", @"Phone Mic Mute", nil];
    }
    if (_infoItemWirelessArray == nil){
        _infoItemWirelessArray = [[NSArray alloc] initWithObjects:@"Wi-Fi AP Setup", nil];
    }
    if ( _infoCatagoryArray == nil) {
        _infoCatagoryArray = [[NSArray alloc]initWithObjects:_infoItemVideoArray, _infoItemAudioArray, _infoItemWirelessArray, nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
