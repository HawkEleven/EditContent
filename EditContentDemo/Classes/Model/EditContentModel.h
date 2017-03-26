//
//  EditContentModel.h
//  EditContentDemo
//
//  Created by Eleven on 17/2/22.
//  Copyright © 2017年 Hawk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EditContentCellType) {
    EditContentCellTypeImage = 0,
    EditContentCellTypeText
    
};

@interface EditContentModel : NSObject

@property (nonatomic, strong) UIImage *img;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *inputStr;
@property (nonatomic, assign) EditContentCellType cellType;

@end

@interface EditContentItemModel : NSObject

@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *inputStr;

@end
