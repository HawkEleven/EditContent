//
//  EditContent.h
//  EditContentDemo
//
//  Created by Eleven on 2017/3/25.
//  Copyright © 2017年 Hawk. All rights reserved.
//

#ifndef EditContent_h
#define EditContent_h

#define HexColorInt32_t(rgbValue) \
[UIColor colorWithRed:((float)((0x##rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((0x##rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(0x##rgbValue & 0x0000FF))/255.0  alpha:1]


///  获取屏幕宽度
static inline CGFloat _getScreenWidth () {
    static CGFloat _screenWidth = 0;
    if (_screenWidth > 0) return _screenWidth;
    _screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    return _screenWidth;
}

///  获取屏幕高度
static inline CGFloat _getScreenHeight () {
    static CGFloat _screenHeight = 0;
    if (_screenHeight > 0) return _screenHeight;
    _screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    return _screenHeight;
}


#define kScreenHeight     _getScreenHeight()
#define kScreenWidth      _getScreenWidth()

#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil;


#endif /* EditContent_h */
