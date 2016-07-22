//
//  Constants.m
//  NuWicam
//
//  Created by Chia-Cheng Hsu on 7/22/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "DDLog.h"
int ddLogLevel =
#ifdef DEBUG
LOG_LEVEL_DEBUG;
#else
LOG_LEVEL_ERROR;
#endif