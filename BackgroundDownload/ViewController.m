//
//  ViewController.m
//  BackgroundDownload
//
//  Created by xiaoyu on 16/6/1.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import "ViewController.h"
#import "DownloadSession.h"
#import "AppDelegate.h"
@interface ViewController () 
{
    UIProgressView *_progress;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 100, 60, 100);
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor yellowColor];
    [button addTarget:self action:@selector(startdownload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    button1.frame = CGRectMake(120, 100, 60, 100);
    [button1 setTitle:@"stop" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor yellowColor];
    [button1 addTarget:self action:@selector(startdownload1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];

    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.frame = CGRectMake(220, 100, 60, 100);
    [button2 setTitle:@"re" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor yellowColor];
    [button2 addTarget:self action:@selector(startdownload2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];

    _progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progress.progress = 0;
    _progress.frame = CGRectMake(10, 300, CGRectGetWidth(self.view.frame)-20, 10);
    [self.view addSubview:_progress];
    
}
- (void)startdownload2 {
    [[DownloadSession shareInstance] resumeDownload];
    
}
- (void)startdownload1 {
    [[DownloadSession shareInstance] stopDownloadData];

}
- (void)startdownload {
    
    NSString *urlString = @"http://123.57.25.103/mappkg/1/c0103.zip";
    __weak typeof(self) weakSelf = self;

    [[DownloadSession shareInstance] gd_backGroundDownloadWithCategory:1 UrlString:urlString TaskProgress:^(double progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _progress.progress = progress;
        });
        
    } DownloadSuccess:^(NSURLSessionDownloadTask *downloadTask, NSURL *location) {
        
        NSString *fileName = @"hello.zip";
        //沙盒
        NSString *path1 = [NSString stringWithFormat:@"%@/Map",Local_Home_Library_Path];
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL yes;
        if (![manager fileExistsAtPath:path1 isDirectory:&yes]) {
            BOOL b = [manager createDirectoryAtPath:path1 withIntermediateDirectories:YES attributes:nil error:nil];
            NSLog(@"%d",b);
        }
        NSString *savepath = [NSString stringWithFormat:@"%@/%@",path1,fileName];
        [[NSFileManager defaultManager] removeItemAtPath:savepath error:nil];
        //将文件从历史文件夹复制到沙盒
        BOOL b1 = [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:savepath error:nil];
        BOOL b2=[[NSFileManager defaultManager] removeItemAtURL:location error:nil];
        NSLog(@"%d-%d",b1,b2);
        NSLog(@"gd_success");
        AppDelegate *deledate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (deledate.backgroundURLSessionCompletionHandler) {
            void (^handler)() = deledate.backgroundURLSessionCompletionHandler;
            deledate.backgroundURLSessionCompletionHandler = nil;
            handler();
            NSLog(@"后台下载完成");
            dispatch_async(dispatch_get_main_queue(), ^{
                _progress.progress = 1;
            });
            [weakSelf showLocalNotification:YES];
        }

        
    } Error:^(NSError *error) {
        NSLog(@"error -%@",error);
        AppDelegate *deledate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (deledate.backgroundURLSessionCompletionHandler) {
            void (^handler)() = deledate.backgroundURLSessionCompletionHandler;
            deledate.backgroundURLSessionCompletionHandler = nil;
            handler();
            [weakSelf showLocalNotification:NO];
        }
    }];
    
}
- (void)showLocalNotification:(BOOL)downloadSuc {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification!=nil) {
        
        NSDate *now=[NSDate new];
        notification.fireDate=[now dateByAddingTimeInterval:6]; //触发通知的时间
        notification.repeatInterval = 0; //循环次数，kCFCalendarUnitWeekday一周一次
        
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = downloadSuc ? @"后台下载成功啦" : @"下载失败";
        notification.alertAction = @"打开";  //提示框按钮
        notification.hasAction = YES; //是否显示额外的按钮，为no时alertAction消失
        notification.applicationIconBadgeNumber = 1; //设置app图标右上角的数字
        
        //下面设置本地通知发送的消息，这个消息可以接受
        NSDictionary* infoDic = [NSDictionary dictionaryWithObject:@"value" forKey:@"key"];
        notification.userInfo = infoDic;
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
