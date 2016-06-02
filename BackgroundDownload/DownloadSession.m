//
//  DownloadSession.m
//  BackgroundDownload
//
//  Created by xiaoyu on 16/6/1.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import "DownloadSession.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>
@interface DownloadSession ()<NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>
{
    NSData *_resumeData;
}
@property (nonatomic, strong) NSURLSession *backgroundSession;

@property (nonatomic, strong) NSURLSessionDownloadTask *backgroundSessionTask;

//成功
@property (nonatomic, copy) void(^GDTask_Success)(NSURLSessionDownloadTask *downloadTask,NSURL *location);

//失败
@property (nonatomic, copy) void(^GDTask_Error)(NSError *error);

//progress
@property (nonatomic, copy) void(^GDTask_Progress)(double progress);

@end

@implementation DownloadSession
+ (instancetype)shareInstance {
    static DownloadSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [[self alloc] init];
    });
    return session;
}
- (void)gd_backGroundDownloadWithCategory:(GDDownload_Category)category UrlString:(NSString *)downloadUrl TaskProgress:(GDTask_Progress)progress DownloadSuccess:(GDTask_Success)success Error:(GDTask_Error)error{

    self.GDTask_Success = success;
    self.GDTask_Progress = progress;
    self.GDTask_Error = error;
    [self startDownloadData:downloadUrl];
    
}
- (NSURLSession *)getBackgroundSession:(NSString *)identifier {
    NSURLSession *backgroundSession = nil;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"background-NSURLSession-%@",identifier]];
    config.HTTPMaximumConnectionsPerHost = 5;//限制连接到特定主机的数量
    backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    return backgroundSession;
}

- (NSURLSession *)backgroundSession{
    if (!_backgroundSession) {
        self.backgroundSession = [self getBackgroundSession:[[NSProcessInfo processInfo] globallyUniqueString]];
    }
    return _backgroundSession;
}
- (void)startDownloadData:(NSString *)urlString {
//
//    NSString *urlString = @"http://123.57.25.103/mappkg/1/c0301.zip";
    
//    NSString *urlString = @"http://123.57.25.103/mappkg/1/c0103.zip";
    NSURL *url = [NSURL URLWithString:urlString];
    self.backgroundSessionTask = [self.backgroundSession downloadTaskWithURL:url];
    [self.backgroundSessionTask resume];
    
}
- (void)resumeDownload {
    
    if (_resumeData) {
        self.backgroundSessionTask = [self.backgroundSession downloadTaskWithResumeData:_resumeData];
        [self.backgroundSessionTask resume];
        _resumeData = nil;
    }
}
- (void)stopDownloadData{
    
    if (self.backgroundSessionTask) {
        [self.backgroundSessionTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            _resumeData = resumeData;
            
            [[self backgroundSession] finishTasksAndInvalidate];
            self.backgroundSession = nil;
            self.backgroundSessionTask = nil;
        }];
    }
    
}
#pragma mark - NSURLSessionDownloadDelegate 代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{

    if (self.GDTask_Success) {
        self.GDTask_Success(downloadTask,location);
    }
    
#if 0

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
    
    AppDelegate *deledate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (deledate.backgroundURLSessionCompletionHandler) {
        void (^handler)() = deledate.backgroundURLSessionCompletionHandler;
        deledate.backgroundURLSessionCompletionHandler = nil;
        handler();
        NSLog(@"后台下载完成");
//        if (self.Download_Progress) {
//            self.Download_Progress(1);
//        }
        if (self.GDTask_Progress) {
            self.GDTask_Progress(1);
        }

        [self showLocalNotification:YES];
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Finish" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
        
        
    }
#endif
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{

    double progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
    if (self.GDTask_Progress) {
        self.GDTask_Progress(progress);
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
//成功或失败都会调用一下的
    if (error) {
        if (self.GDTask_Error) {
            self.GDTask_Error(error);
        }
    }
}

/*
 当不再需要连接时，可以调用Session的invalidateAndCancel直接关闭，或者调用finishTasksAndInvalidate等待当前Task结束后关闭。这时Delegate会收到URLSession:didBecomeInvalidWithError:这个事件
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
//    NSLog(@"didBecomeInvalidWithError");
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
//    NSLog(@"URLSessionDidFinishEventsForBackgroundURLSession");
}




- (unsigned long long)fileSizeForPath:(NSString *)path {
    
    signed long long fileSize = 0;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:path]) {
        
        NSError *error = nil;
        
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        
        if (!error && fileDict) {
            
            fileSize = [fileDict fileSize];
        }
    }
    
    return fileSize;
}


@end


