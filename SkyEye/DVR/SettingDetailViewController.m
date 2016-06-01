//
//  SettingDetailViewController.m
//  SkyEye
//
//  Created by Chia-Cheng Hsu on 2016/1/28.
//  Copyright © 2016年 Nuvoton. All rights reserved.
//

#import "SettingDetailViewController.h"

@implementation SettingDetailViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    receivedString = [receivedArray objectAtIndex:0];
    _labelTitle.text = receivedString;
    [_textfield setHidden:YES];
    if ( ![receivedString isEqualToString:@"Resolution"] ) {
        [_segmentControl setHidden:YES];
        if ([receivedString isEqualToString:@"Encode Quality"]) {
            _slider.minimumValue = 1;
            _slider.maximumValue = 15;
            _labelDetailTitle.text = @"Encode Quality can be set between 1(best) to 15.";
        }else if ([receivedString isEqualToString:@"Bit Rate"]) {
            _slider.minimumValue = 1;
            _slider.maximumValue = 30;
            _labelDetailTitle.text = @"Bit Rate can be set between 1 to 30 in Kbps.";
        }else if ([receivedString isEqualToString:@"FPS"]) {
            _slider.minimumValue = 1;
            _slider.maximumValue = 30;
            _labelDetailTitle.text = @"FPS can be set between 1 to 30.";
        }
        _labelValue.text = [NSString stringWithFormat:@"%d", (int)_slider.value];
    } else {
        [_slider setHidden:YES];
        [_segmentControl setTitle:@"QVGA" forSegmentAtIndex:0];
        [_segmentControl setTitle:@"VGA" forSegmentAtIndex:1];
        [_segmentControl setTitle:@"720p" forSegmentAtIndex:2];
        [_segmentControl setTitle:@"1080p" forSegmentAtIndex:3];
        _labelDetailTitle.text = @"Click segments to set video Resolution.";
        _labelValue.text = @"Option";
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)valueChangeSegmentControl:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    if (control.selectedSegmentIndex == 0) {
        
    }else if(control.selectedSegmentIndex == 1){

    }else if(control.selectedSegmentIndex == 2){
    
    }else if(control.selectedSegmentIndex == 3){
        
    }
}

- (IBAction)valueChangeSliderControl:(id)sender {
    _labelValue.text = [NSString stringWithFormat:@"%d", (int)_slider.value];
}

- (void)setupString:(NSString *)string forType:(NSString *)type{
    receivedString = [NSString stringWithString:string];
}

-(void)setupArray:(NSArray *)array forType:(NSString *)type{
    receivedArray = [NSArray arrayWithArray:array];
}



@end
