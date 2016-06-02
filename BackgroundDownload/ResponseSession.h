//
//  ResponseSession.h
//  BackgroundDownload
//
//  Created by xiaoyu on 16/6/1.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM (NSInteger, DownloadStatus) {
    XZDownloadSuccuss, // 下载成功
    XZDownloadBackgroudSuccuss, // 下载成功
    XZDownloading, // 下载中
    XZDownloadFail, // 下载失败
    XZDownloadResume, // 重启
    XZDownloadCancle, // 取消
    XZDownloadPause // 暂停
};

@interface ResponseSession : NSObject

@property (nonatomic, strong)NSString *identifier;
@property (nonatomic, assign)DownloadStatus downloadStatus;
@property (nonatomic, strong)id targert;
@property (nonatomic, strong)NSString *action;
@property (nonatomic, assign) double progress;
@property (nonatomic, strong)NSString *downloadUrl;
@property (nonatomic, strong)NSURL *downloadSaveFileUrl;
@property (nonatomic, strong)NSData *downloadData;
@property (nonatomic, strong)NSString *downloadResult;

@end
