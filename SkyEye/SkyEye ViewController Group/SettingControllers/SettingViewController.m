//
//  SettingViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

#pragma UIView Delegate

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pool = [CommandPool sharedInstance];
    [self initSettingArray];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (passedArray == nil) {
        passedArray = [[NSMutableArray alloc]init];
    }
    if (passedString == nil) {
        passedString = [[NSString alloc]init];
    }
    [self.tabBarController.tabBar setHidden:NO];
    [self.tabBarController.tabBar setUserInteractionEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(enableTabBar) userInfo:nil repeats:NO];
}

#pragma TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [_settingCatagoryArray objectAtIndex:section];
    return array.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _settingCatagoryArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *settingItemCellIndentifier = @"SettingItemCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:settingItemCellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingItemCellIndentifier];
    }
    NSString *string = @"";
    NSString *detailString = @"";
    UIImageView *image = (UIImageView *) [cell viewWithTag:SETTING_IMAGE_TAG];
    UILabel *categoryLabel = (UILabel *) [cell viewWithTag:SETTING_CATEGORY_TAG];
    UILabel *settingLabel = (UILabel *) [cell viewWithTag:SETTING_CURRENT_SETTING_TAG];
    if (indexPath.section == VIDEO_SECTION) {
        string = [_settingItemVideoArray objectAtIndex:indexPath.row];
        detailString = [NSString stringWithString:[self determineDetailString:string]];
        image.image = [UIImage imageNamed:@"camera"];
    } else if (indexPath.section == WIRELESS_SECTION){
        string = [_settingItemWirelessArray objectAtIndex:indexPath.row];
        detailString = [NSString stringWithString:[self determineDetailString:string]];
        image.image = [UIImage imageNamed:@"wifi"];
    }else if (indexPath.section == INFO_SECTION){
        string = [_settingItemInfoArray objectAtIndex:indexPath.row];
        detailString = @"";
        image.image = [UIImage imageNamed:@"info"];
    } else{
        string = @"";
        detailString = @"";
    }
    categoryLabel.text = string;
    settingLabel.text = detailString;
    return cell;
}

#pragma custom function

- (NSString *)determineDetailString:(NSString *)string{
    NSString *detailString;
    PlayerManager *manager = [PlayerManager sharedInstance];
    NSDictionary *dic = [manager.dictionarySetting objectForKey:@"Setup Camera"];
    if ([string isEqualToString:@"Setup Camera"]){
        indexOfDetail = @"0";
        NSString *name = [NSString stringWithString:[dic objectForKey:@"Name"]];
        if (name != nil) {
            detailString = name;
        } else {
            detailString = @"Required Setup";
        }
    } else if([string isEqualToString:@"Wi-Fi AP Setup"]){
        NSDictionary *wifiDic = [dic objectForKey:@"Wi-Fi AP Setup"];
        detailString = [[NSString alloc] initWithString:[wifiDic objectForKey:@"SSID"]];
    }
    return detailString;
}

- (void)initSettingArray{
    if (_settingItemVideoArray == nil) {
        _settingItemVideoArray = @[@"Setup Camera"];
    }
    if (_settingItemWirelessArray == nil){
        _settingItemWirelessArray = @[@"Wi-Fi AP Setup"];
    }
    if (_settingItemInfoArray == nil){
        _settingItemInfoArray = @[@"APP Version"];
    }
    if ( _settingCatagoryArray == nil) {
        _settingCatagoryArray = [[NSArray alloc]initWithObjects:_settingItemVideoArray, _settingItemWirelessArray, _settingItemInfoArray, nil];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    detailLabel = [cell viewWithTag:SETTING_CURRENT_SETTING_TAG];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                title = @"Setup Camera";
                break;
            default:
                break;
        }
        passedArray = [[NSMutableArray alloc]initWithObjects:title, nil];
        [self performSegueWithIdentifier:@"TableSettingDetailSegue" sender:self];
    }else if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0: //Wi-Fi AP Setup
                title = @"Wi-Fi AP Setup";
                passedArray = [[NSMutableArray alloc]initWithObjects:title, nil];
                [self performSegueWithIdentifier:@"TableSettingDetailSegue" sender:self];
                break;
            default:
                break;
        }
    }else if(indexPath.section == 2){
        switch (indexPath.row) {
            case 0: //Show APP version
                title = @"APP Version";
                passedArray = [[NSMutableArray alloc]initWithObjects:title, nil];
                [self performSegueWithIdentifier:@"TableSettingDetailSegue" sender:self];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"TableSettingDetailSegue"]) {
        MultipleSettingTableViewController *dest = (MultipleSettingTableViewController *)segue.destinationViewController;
        NSString *category = [NSString stringWithString:[passedArray objectAtIndex:0]];
        dest.delegate = self;
        [dest setupArray:passedArray forCategory:category];
    }else{
        SettingDetailViewController* dest = (SettingDetailViewController *)segue.destinationViewController;
        NSString *category = [NSString stringWithString:[passedArray objectAtIndex:0]];
        [dest setupArray:passedArray forType:category];
    }
}

-(void)updateDetailLabel:(NSString *)string{
    detailLabel.text = [NSString stringWithString:string];
}

- (void)setupCameraString:(NSString *)string{
    cameraString = [NSString stringWithString:string];
}

- (void)enableTabBar{
    [self.tabBarController.tabBar setUserInteractionEnabled:YES];
}

@end
