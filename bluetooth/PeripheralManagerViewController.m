//
//  PeripheralManagerViewController.m
//  bluetooth
//
//  Created by VeLink on 17/1/12.
//  Copyright © 2017年 VeLink. All rights reserved.
//

#import "PeripheralManagerViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
//#define waiweiName @"TIANXUAN"
#define kPeripheralName @"TIANXUANG's Device" //外围设备名称
#define kServiceUUID @"C4FB2349-72FE-4CA2-94D6-1F3CB16331EE" //服务的UUID
#define kCharacteristicUUID @"6A3E4B28-522D-4B3B-82A9-D5E2004534FC" //特征的UUID
@interface PeripheralManagerViewController ()<CBPeripheralManagerDelegate,CBPeripheralDelegate>
{
    CBPeripheralManager *_manage;
    NSMutableArray *centralM;//订阅此外围设备特征的中心设备
    CBMutableCharacteristic *characteristicM;//特征
    UILabel *label;
}
@end

@implementation PeripheralManagerViewController
-(void)butClickback
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    UIButton *backbut=[UIButton buttonWithType:UIButtonTypeCustom];
    backbut.frame=CGRectMake(10, 100, 80, 40);
    backbut.backgroundColor=[UIColor orangeColor];
    [backbut setTitle:@"返回主页" forState:UIControlStateNormal];
    [backbut addTarget:self action:@selector(butClickback) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backbut];
    
    
    UIButton *but=[UIButton buttonWithType:UIButtonTypeCustom];
    but.frame=CGRectMake(140, 100, 120, 40);
    but.backgroundColor=[UIColor orangeColor];
    [but setTitle:@"启动外围设备" forState:UIControlStateNormal];
    [but addTarget:self action:@selector(butClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    
    UIButton *update=[UIButton buttonWithType:UIButtonTypeCustom];
    update.frame=CGRectMake(270, 100, 60, 40);
    update.backgroundColor=[UIColor orangeColor];
    [update setTitle:@"更新" forState:UIControlStateNormal];
    [update addTarget:self action:@selector(updatebutClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:update];

    
    label=[[UILabel alloc]initWithFrame:CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 400)];
     label.text=@"开始";
//    label.adjustsFontSizeToFitWidth=YES;
    label.numberOfLines=0;
    [self.view addSubview:label];
}
-(void)butClick
{
    _manage=[[CBPeripheralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    
}
-(void)updatebutClick
{
    [self updateCharacteristicValue];
}
#pragma mark - CBPeripheralManager代理方法
//外围设备状态发生变化后调用
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"BLE已打开.");
            [self writeToLog:@"BLE已打开."];
            //添加服务
            [self setupService];
            break;
            
        default:
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.");
            [self writeToLog:@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备."];
            break;
    }
}
//外围设备添加服务后调用
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"向外围设备添加服务失败，错误详情：%@",error.localizedDescription);
        [self writeToLog:[NSString stringWithFormat:@"向外围设备添加服务失败，错误详情：%@",error.localizedDescription]];
        return;
    }
    
    //添加服务后开始广播
    NSDictionary *dic=@{CBAdvertisementDataLocalNameKey:kPeripheralName};//广播设置
    [_manage startAdvertising:dic];//开始广播
    NSLog(@"向外围设备添加了服务并开始广播...");
    [self writeToLog:@"向外围设备添加了服务并开始广播..."];
}
//订阅特征
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"中心设备：%@ 已订阅特征：%@.",central,characteristic);
    [self writeToLog:[NSString stringWithFormat:@"中心设备：%@ 已订阅特征：%@.",central.identifier.UUIDString,characteristic.UUID]];
    //发现中心设备并存储
    if (![self.centralM containsObject:central]) {
        [self.centralM addObject:central];
    }
    /*中心设备订阅成功后外围设备可以更新特征值发送到中心设备,一旦更新特征值将会触发中心设备的代理方法：
     -(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
     */
    
    //    [self updateCharacteristicValue];
}
//取消订阅特征
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"didUnsubscribeFromCharacteristic");
}
-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(CBATTRequest *)request{
    NSLog(@"didReceiveWriteRequests");
}
-(void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict{
    NSLog(@"willRestoreState");
}
#pragma mark -属性
-(NSMutableArray *)centralM{
    if (!centralM) {
        centralM=[NSMutableArray array];
    }
    return centralM;
}

#pragma mark - 私有方法
//创建特征、服务并添加服务到外围设备
-(void)setupService{
    /*1.创建特征*/
    //创建特征的UUID对象
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kCharacteristicUUID];
    //特征值
    //    NSString *valueStr=kPeripheralName;
    //    NSData *value=[valueStr dataUsingEncoding:NSUTF8StringEncoding];
    //创建特征
    /** 参数
     * uuid:特征标识
     * properties:特征的属性，例如：可通知、可写、可读等
     * value:特征值
     * permissions:特征的权限
     */
    CBMutableCharacteristic *characteristicM1=[[CBMutableCharacteristic alloc]initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    characteristicM=characteristicM1;
    //    CBMutableCharacteristic *characteristicM=[[CBMutableCharacteristic alloc]initWithType:characteristicUUID properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
    //    characteristicM.value=value;
    
    /*创建服务并且设置特征*/
    //创建服务UUID对象
    CBUUID *serviceUUID=[CBUUID UUIDWithString:kServiceUUID];
    //创建服务
    CBMutableService *serviceM=[[CBMutableService alloc]initWithType:serviceUUID primary:YES];
    //设置服务的特征
    [serviceM setCharacteristics:@[characteristicM]];
    
    
    /*将服务添加到外围设备*/
    [_manage addService:serviceM];
}
//更新特征值
-(void)updateCharacteristicValue{
    //特征值
    NSString *valueStr=[NSString stringWithFormat:@"%@ --%@",kPeripheralName,[NSDate   date]];
    NSData *value=[valueStr dataUsingEncoding:NSUTF8StringEncoding];
    //更新特征值
    [_manage updateValue:value forCharacteristic:characteristicM onSubscribedCentrals:nil];
    [self writeToLog:[NSString stringWithFormat:@"更新特征值：%@",valueStr]];
}- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)writeToLog:(NSString *)info{
    label.text=[NSString stringWithFormat:@"%@->%@",label.text,info];
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
