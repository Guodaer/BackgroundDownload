//
//  DownloadSession.h
//  BackgroundDownload
//
//  Created by xiaoyu on 16/6/1.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseSession.h"

#define Local_Home_Library_Path ([NSString stringWithFormat:@"%@/Library/Caches",NSHomeDirectory()])
/**
 *  下载的是music？app？。。。。。
 */
typedef NS_ENUM(NSInteger,GDDownload_Category) {
    GDDownload_Music,
    GDDownload_App,
    GDDownload_Map,
    GDDownload_Append
};

typedef void(^GDTask_Success)(NSURLSessionDownloadTask *downloadTask,NSURL *location);

typedef void(^GDTask_Error)(NSError *error);

typedef void(^GDTask_Progress)(double progress);

@interface DownloadSession : NSObject

+ (instancetype) shareInstance;
/**
 *  Damon牌后台下载接口，封装的NSURLSession
 *
 *  @param category    这是跟我达哥的需求定义的属性，不用刻意去掉
 *  @param downloadUrl 下载链接地址
 *  @param progress    进度
 *  @param success     下载成功 block
 *  @param error       下载失败 block
 */
- (void)gd_backGroundDownloadWithCategory:(GDDownload_Category)category UrlString:(NSString *)downloadUrl TaskProgress:(GDTask_Progress)progress DownloadSuccess:(GDTask_Success)success Error:(GDTask_Error)error;

/**
 *  开始任务
 */
- (void)startDownloadData:(NSString *)urlString;
/**
 *  继续下载
 */
- (void)resumeDownload;
/**
 *  停止下载
 */
- (void)stopDownloadData;



@end
