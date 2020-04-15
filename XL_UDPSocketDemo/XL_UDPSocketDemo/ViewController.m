//
//  ViewController.m
//  XL_UDPSocketDemo
//
//  Created by 李小龙 on 2020/4/15.
//  Copyright © 2020 李小龙. All rights reserved.
//

#import "ViewController.h"
#import "AsyncUdpSocket.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
@interface ViewController ()<AsyncUdpSocketDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self MakeUDP];
}

#pragma mark - udp Socket
-(void)MakeUDP {/**<做udp请求*/
    //实例化
    AsyncUdpSocket *socket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    //启动本地端口
    [socket localPort];
    //发送超时时间
    NSTimeInterval timeout = 1000;
    //发送消息头标志
    NSString *MSG_HEAD_SEND = @"BBBDEV0X01";
    //发送给服务器的内容：头标志、主机名、IP地址、端口、主机类型、所属学校代号、安装教室、设备编号、备注(整个内容包括头标志都是与服务器约定的，自行匹配)
    NSString *request= [NSString stringWithFormat:@"%@@%@@%@@%@@%@@%@@%@@%@@%@",MSG_HEAD_SEND,@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"-"];
    NSLog(@"%@",request);
    NSData *data=[NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding] ];
    //端口（与服务器匹配约定）
    UInt16 port = 8995;
    
    NSError *error;
    
    //发送广播设置
    [socket enableBroadcast:YES error:&error];
    /*
     发送请求
     sendData:发送的内容
     toHost:目标的ip
     port:端口号
     timeOut:请求超时
     */
    BOOL _isOK = [socket sendData:data toHost:@"255.255.255.255" port:port withTimeout:timeout tag:1];
    if (_isOK) {
        NSLog(@"udp请求成功");
    }else{
        NSLog(@"udp请求失败");
    }
    
    [socket bindToPort:port error:&error];
    [socket receiveWithTimeout:-1 tag:0];//启动接收线程 - n?秒超时（-1表示死等）
    
    NSLog(@"开始啦");
}


#pragma mark - Delegate
//接受信息（如果有多个设备会多次调用）
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    
    NSString *result;
    
    result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    NSLog(@"result：%@",result);
    NSLog(@"host：%@",host);
    NSLog(@"收到啦");
    return NO;
}

//接受失败
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    
    NSLog(@"没有收到啊");
}

//发送失败
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    
    NSLog(@"%@",error);
    
    NSLog(@"没有发送啊");
    
}

//开始发送
-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
    NSLog(@"发送啦");
}

//关闭广播
-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
    
    NSLog(@"关闭啦");
}

@end
