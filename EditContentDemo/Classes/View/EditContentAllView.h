//
//  EditContentAllView.h
//  EditContentDemo
//
//  Created by Eleven on 17/2/22.
//  Copyright © 2017年 Hawk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditContentModel;

@interface EditContentTableHeader : UIView

@property (weak, nonatomic) IBOutlet UITextField *field;

@end

@interface EditContentImgViewCell : UITableViewCell

@property (nonatomic, strong) EditContentModel *model;
@property (nonatomic, copy) void (^deleteImgBlock)(void);

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end


@interface EditContentTextViewCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (nonatomic, strong) EditContentModel *model;
@property (nonatomic, copy) void (^deleteTextBlock)(void);
@property (nonatomic, copy) void (^insertImgBlock)(void);


+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end

