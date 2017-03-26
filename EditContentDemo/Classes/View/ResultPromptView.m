//
//  ResultPromptView.m
//  EditContentDemo
//
//  Created by Eleven on 17/1/10.
//  Copyright © 2017年 Hawk. All rights reserved.
//

#import "ResultPromptView.h"

@implementation ResultPromptView

+ (void)showPromptWithMessage:(NSString *)message {
    CGFloat width = 200;
    CGFloat height = 41;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 165 + 64, width, height)];
    [window addSubview:label];
    label.centerX = window.centerX;
//    label.sd_layout.centerXIs(window.centerX).topSpaceToView(window, Fit(165) + 64).widthIs(width);

    label.text = message;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.layer.cornerRadius = 5;
    label.layer.masksToBounds = YES;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    });
}

@end
