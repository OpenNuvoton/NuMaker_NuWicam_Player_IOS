//
//  InfoTableViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/2/23.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerManager.h"
#import "InfoPool.h"
@interface InfoTableViewController : UITableViewController{
    int rowNumber, sectionNumber;
    PlayerManager *playerManager;
    InfoPool *infoPool;
    NSMutableArray *sectionTitle;
    NSMutableArray *deviceInfoArray, *phoneInfoArray;
}

@end
