//
//  GPJAssistant.m
//  EquityPrice
//
//  Created by study_sun on 14-8-12.
//  Copyright (c) 2014年 GongPingJia. All rights reserved.
//

#import "GPJAssistant.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/xattr.h>
#import <objc/runtime.h>
#import "MBProgressHUD.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "SMFoundation.h"

#define kTagWaitView 10099

@implementation UIView (YOHO)

- (void)alert:(NSString *)message
{
    // 防止网路请求fail的时候，errorDescription也是空
    if ([message length] == 0) {
        message = @"数据异常，请检查网络连接或稍后再试";
    }
    [self alert:message completion:nil];
}


- (void)alert:(NSString *)message completion:(dispatch_block_t)completion
{
    [self hideWait];
    // 为什么不hide其他，因为这个除了wait，其他最多1.5秒，没必要再遍历一遍隐藏
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];

    hud.removeFromSuperViewOnHide = YES;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 60.0f)];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.text = message;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 0;
    hud.customView = textLabel;
    hud.mode = MBProgressHUDModeCustomView;
    
    [self addSubview:hud];
    [hud showAnimated:YES];
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hud hideAnimated:YES];
        if (completion) {
            completion();
        }
    });
}


- (void)alertError:(id)result
{
    NSString *errorMsg = @"操作失败";
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = result;
        if ([[dic objectForKey:@"msg"] isKindOfClass:[NSString class]] && ([[dic objectForKey:@"msg"] length] > 0)) {
            errorMsg = [dic objectForKey:@"msg"];
        }
        [self alert:errorMsg];
    }
    else if ([result isKindOfClass:[NSString class]]) {
        errorMsg = result;
        // 如果是网络错误,但是这个错误其实是asi的错误，所以一直到af的时候还要校验一下，可能都不走这里
        if ([result rangeOfString:@"Error Domain"].length > 0) {
            [self alertNetwork];
            return;
        }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        // 如果不能转为json，则dic会是nil
        if ([dic isKindOfClass:[NSDictionary class]]) {
            if ([[dic objectForKey:@"msg"] isKindOfClass:[NSString class]] && ([[dic objectForKey:@"msg"] length] > 0)) {
                errorMsg = [dic objectForKey:@"msg"];
            }
        }
        [self alert:errorMsg];
    }
    else {
        [self alertNetwork];
    }
}


- (void)alertNetwork
{
    [self alert:@"数据异常，请检查网络连接或稍后再试"];
}


- (void)showWait
{
    [self showWaitWithMessage:@""];
}


- (void)showWaitWithMessage:(NSString *)message
{
    [self hideWait];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
    //    hud.removeFromSuperViewOnHide = YES;
    hud.tag = kTagWaitView;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:14];
    [self addSubview:hud];
    [self bringSubviewToFront:hud];
    [hud showAnimated:YES];
}


- (void)hideWait
{
    [[self viewWithTag:kTagWaitView] removeFromSuperview];
    [MBProgressHUD hideHUDForView:self animated:NO];
}

@end

CGFloat kScreenWidth()
{
    return CGRectGetWidth([UIScreen mainScreen].bounds);
}


CGFloat kScreenHeight()
{
    return CGRectGetHeight([UIScreen mainScreen].bounds);
}

