//
//  SettingDetailViewController.h
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/28.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveViewController.h"

@interface SettingDetailViewController : UIViewController{
    NSString *receivedString;
    NSMutableArray *receivedArray;
}
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDetailTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelValue;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
- (IBAction)valueChangeSegmentControl:(id)sender;
- (IBAction)valueChangeSliderControl:(id)sender;
- (void)setupString:(NSString *)string forType:(NSString *)type;
- (void)setupArray:(NSArray *)array forType:(NSString *)type;
@end
