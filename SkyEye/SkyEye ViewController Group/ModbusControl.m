//
//  ModbusControl.m
//  NuWicam
//
//  Created by Chia-Cheng Hsu on 6/16/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

#import "ModbusControl.h"

@implementation ModbusControl

+ (ModbusControl *)sharedInstance{
    static ModbusControl *modbusControl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modbusControl = [[self alloc] init];
    });
    return modbusControl;
}

- (ModbusControl *) init{
    if (self == [super init]) {
        modbus = [[ObjectiveLibModbus alloc] initWithTCP:@"192.168.100.1" port:502 device:1];
        [modbus connect:^{
            [_delegate modbusConnectSuccess];
        } failure:^(NSError *error){
            NSLog(@"Modbus connect Error: %@", error.localizedDescription);
        }];
    }
    return self;
}

- (void)writeRegister:(int)address to:(int)value{
    [modbus writeRegister:address to:value success:^{
        [_delegate modbusWriteSuccess];
    }failure: ^(NSError *error){
        NSLog(@"Modbus write Error: %@", error.localizedDescription);
    }];
}

- (void)readRegister:(int)startAddress count:(int)count{
    [modbus readRegistersFrom:startAddress count:count success:^(NSArray *array){
//        NSLog(@"modbus: %@", array);
        [_delegate modbusReadSuccess:[NSArray arrayWithArray:array]];
    }failure: ^(NSError *error){
        NSLog(@"Modbus read error: %@", error.localizedDescription);
    }];
}

- (void)readBit:(int)startAddress count:(int)count{
    [modbus readBitsFrom:startAddress count:count success:^(NSArray *array){
//        NSLog(@"Modbus read bit: %@", array);
    }failure: ^(NSError *error){
        NSLog(@"Modbus read bit error: %@", error.localizedDescription);
    }];
}

@end
