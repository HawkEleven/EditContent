//
//  EditContentAllView.m
//  EditContentDemo
//
//  Created by Eleven on 17/2/22.
//  Copyright © 2017年 Hawk. All rights reserved.
//

#import "EditContentAllView.h"
#import "EditContentModel.h"
#import "UIImageView+WebCache.h"


@implementation EditContentTableHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    view.backgroundColor = HexColorInt32_t(F0F0F0);
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    line.backgroundColor = HexColorInt32_t(D1D6DA);
    [view addSubview:line];
    
    UIButton *rightBtn = [[UIButton alloc] init];
    [view addSubview:rightBtn];
    rightBtn.sd_layout.rightSpaceToView(view, 10).centerYEqualToView(view).widthIs(40).heightIs(30);
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [rightBtn addTarget:self action:@selector(_dismissKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    
    _field.inputAccessoryView = view;
}

- (void)_dismissKeyBoard {
    [_field resignFirstResponder];
}

@end



@implementation EditContentImgViewCell
{
    __weak IBOutlet UIImageView *_imgView;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString * ID = @"EditContentImgViewCell";
    EditContentImgViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EditContentAllView" owner:nil options:nil] objectAtIndex:1];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - event response
- (IBAction)_deleteImg:(id)sender {
    if (self.deleteImgBlock) {
        self.deleteImgBlock();
    }
}


- (void)setModel:(EditContentModel *)model {
    _model = model;
    [_imgView sd_setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:model.img];
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.clipsToBounds = YES;
}

@end



@implementation EditContentTextViewCell
{
    __weak IBOutlet UILabel *_placeholderLabel;
}

#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    view.backgroundColor = HexColorInt32_t(F0F0F0);
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    line.backgroundColor = HexColorInt32_t(D1D6DA);
    [view addSubview:line];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    [view addSubview:leftBtn];
    leftBtn.sd_layout.leftSpaceToView(view, 10).centerYEqualToView(view).widthIs(40).heightIs(30);
    [leftBtn setTitle:@"图片" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [leftBtn addTarget:self action:@selector(_insertImg) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [[UIButton alloc] init];
    [view addSubview:rightBtn];
    rightBtn.sd_layout.rightSpaceToView(view, 10).centerYEqualToView(view).widthIs(40).heightIs(30);
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_dismissKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    
    _inputTextView.inputAccessoryView = view;

    @weakify(self);
    [_inputTextView.rac_textSignal subscribeNext:^(id x) {
        @strongify(self);
        self.model.inputStr = x;
        self->_placeholderLabel.hidden = [x length] > 0;
        
        // textView高度自适应
        CGRect bounds = _inputTextView.bounds;
        
        // 计算 text view 的高度
        CGSize maxSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
        CGSize newSize = [_inputTextView sizeThatFits:maxSize];
        bounds.size = newSize;
        _inputTextView.bounds = bounds;
        
        // 让 table view 重新计算高度
        UITableView *tableView = [self tableView];
        [tableView beginUpdates];
        [tableView endUpdates];
    }];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString * ID = @"EditContentTextViewCell";
    EditContentTextViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EditContentAllView" owner:nil options:nil] objectAtIndex:2];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - private methods
- (UITableView *)tableView {
    UIView *tableView = self.superview;
    
    while (![tableView isKindOfClass:[UITableView class]] && tableView) {
        tableView = tableView.superview;
    }
    
    return (UITableView *)tableView;
}

- (void)_insertImg {
    NSLog(@"_insertImg");
    BLOCK_SAFE_RUN(self.insertImgBlock);
}

- (void)_dismissKeyBoard {
    [_inputTextView resignFirstResponder];
}

#pragma mark - event response
- (IBAction)_deleteText:(id)sender {
    BLOCK_SAFE_RUN(self.deleteTextBlock)
}


#pragma mark - setter
- (void)setModel:(EditContentModel *)model {
    _model = model;
    _inputTextView.text = model.inputStr;
    _placeholderLabel.hidden = [model.inputStr length] > 0;
}

@end

