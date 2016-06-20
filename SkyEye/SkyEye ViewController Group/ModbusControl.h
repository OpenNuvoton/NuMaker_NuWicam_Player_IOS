//
//  ModbusControl.h
//  NuWicam
//
//  Created by Chia-Cheng Hsu on 6/16/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveLibModbus.h"
@class ModbusControl;

@protocol ModbusControlDelegate <NSObject>
- (void) modbusConnectSuccess;
- (void) modbusWriteSuccess;
- (void) modbusReadSuccess:(NSArray *)dataArray;
- (void) modbusConnectFail;
@end

@interface ModbusControl : NSObject <ModbusControlDelegate>{
    ObjectiveLibModbus *modbus;
}

+ (ModbusControl *) sharedInstance;
@property (strong, nonatomic) id <ModbusControlDelegate> delegate;

- (void) writeRegister:(int)address to:(int)value;
- (void) readRegister:(int)startAddress count:(int)count;
- (void) readBit:(int)startAddress count:(int)count;
- (void) disconnect;
- (void) connect;
@end
