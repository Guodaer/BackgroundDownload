//
//  AppDelegate.h
//  BackgroundDownload
//
//  Created by xiaoyu on 16/6/1.
//  Copyright © 2016年 Damon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy) void (^backgroundURLSessionCompletionHandler)();

@end

