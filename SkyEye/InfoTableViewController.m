//
//  InfoTableViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "InfoTableViewController.h"

@implementation InfoTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    playerManager = [PlayerManager sharedInstance];
    sectionNumber = 2;
    rowNumber = (int) playerManager.dictionaryInfo.count;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *infoCategoryCellIdentifier = @"InfoCatagoryCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCategoryCellIdentifier];
    UIImageView *sectionImage = (UIImageView *)[cell viewWithTag:200];
    UILabel *sectionLabel = (UILabel *)[cell viewWithTag:201];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoCategoryCellIdentifier];
    }
    sectionLabel.text = @"Device Information";
    return cell;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *infoItemCellIdentifier = @"InfoItemCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoItemCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoItemCellIdentifier];
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sectionNumber;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return rowNumber;
}

-(void)initArrays{
    [sectionTitle addObject:@"Device Information"];
    [sectionTitle addObject:@"Phone Information"];
    
}

@end
