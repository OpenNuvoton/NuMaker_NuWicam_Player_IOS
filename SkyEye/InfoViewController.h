//
//  InfoViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/22.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoItemCellPrototype.h"
#import "CommandPool.h"
enum{
    VIDEO_SECTION = 0,
    AUDIO_SECTION,
    WIRELESS_SECTION,

    INFO_SECTION_IMAGE_TAG = 200,
    INFO_SECTION_LABEL_TAG,
    INFO_ITEM_LABEL_TAG,
    INFO_CURRENT_SETTING_TAG
};
@interface InfoViewController : UITableViewController{
}
@property (nonatomic, strong) NSArray *infoCatagoryArray;
@property (nonatomic, strong) NSArray *infoItemVideoArray;
@property (nonatomic, strong) NSArray *infoItemAudioArray;
@property (nonatomic, strong) NSArray *infoItemWirelessArray;

@end
