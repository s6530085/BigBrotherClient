//
//  GPJAssistant.h
//  EquityPrice
//
//  Created by study_sun on 14-8-12.
//  Copyright (c) 2014年 GongPingJia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (YOHO)

- (void)alert:(NSString *)message;
// 用于自动提示里面错误信息，如果没有则提示默认错误
- (void)alertError:(id)result;
- (void)alertNetwork;
- (void)showWait;
- (void)hideWait;
- (void)showWaitWithMessage:(NSString *)message;

@end

UIKIT_EXTERN CGFloat kScreenWidth();
UIKIT_EXTERN CGFloat kScreenHeight();
