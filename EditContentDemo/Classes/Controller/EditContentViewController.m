//
//  EditContentViewController.m
//  EditContentDemo
//
//  Created by Eleven on 2017/3/25.
//  Copyright © 2017年 Hawk. All rights reserved.
//

#import "EditContentViewController.h"
#import "EditContentAllView.h"
#import "EditContentModel.h"
#import "ResultPromptView.h"

static CGFloat const kFooterHeight = 45;

@interface EditContentViewController () <UITableViewDataSource, UITableViewDelegate, TZImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<EditContentModel *> *dataArr;
@property (nonatomic, strong) EditContentTableHeader *tableHeader;
@property (nonatomic, strong) UIButton *footerView;
@property (nonatomic, assign) NSInteger responderIndex;
@property (nonatomic, getter=isInsertImg) BOOL insertImg;
@property (nonatomic, copy) NSArray *testUrls;

@end

@implementation EditContentViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self _initSubViews];
    [self _initData];
}

- (void)viewDidLayoutSubviews {
    self.tableHeader.frame = CGRectMake(0, 0, kScreenWidth, 67);
}

#pragma mark - private methods
- (void)_initSubViews {
    self.title = @"图文编辑";
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(_publish)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.footerView];
}

- (void)_initData {
    _testUrls = @[@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg",
                  @"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg",
                  @"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg"];
    EditContentModel *textModel = [[EditContentModel alloc] init];
    textModel.inputStr = @"";
    textModel.cellType = EditContentCellTypeText;
    [self.dataArr addObject:textModel];
    [self.tableView reloadData];
}

- (void)_uploadWithImage:(UIImage *)image index:(NSInteger)index {
    NSLog(@"%zi", index);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        EditContentModel *model = self.dataArr[index];
        // 模拟上传返回的图片路径
        model.imageUrl = _testUrls[arc4random() % 3];
    });
}

- (void)_uploadImages:(NSArray *)photos {
    dispatch_group_t group = dispatch_group_create();
    for (NSInteger i = 0; i < photos.count; i ++) {
        EditContentModel *imgModel = [[EditContentModel alloc] init];
        imgModel.img = photos[i];
        imgModel.cellType = EditContentCellTypeImage;
        if (self.isInsertImg == YES) {
            [self.dataArr insertObject:imgModel atIndex:self.responderIndex + (2 * i + 1)];
        } else {
            [self.dataArr addObject:imgModel];
        }
        dispatch_group_enter(group);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            EditContentModel *model = self.dataArr[[self.dataArr indexOfObject:imgModel]];
            // 模拟上传返回的图片路径
            model.imageUrl = _testUrls[arc4random() % 3];
            dispatch_group_leave(group);
        });
        
        EditContentModel *textModel = [[EditContentModel alloc] init];
        textModel.inputStr = @"";
        textModel.cellType = EditContentCellTypeText;
        if (self.isInsertImg == YES) {
            [self.dataArr insertObject:textModel atIndex:self.responderIndex + (2 * i + 2)];
        } else {
            [self.dataArr addObject:textModel];
        }
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [ResultPromptView showPromptWithMessage:@"上传成功"];
        [self.tableView reloadData];
        self.insertImg = NO;
    });
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditContentModel *model = self.dataArr[indexPath.row];
    if (model.cellType == EditContentCellTypeImage) {
        EditContentImgViewCell *imgCell = [EditContentImgViewCell cellWithTableView:tableView];
        [imgCell setModel:model];
        imgCell.deleteImgBlock = ^() {
            [self.dataArr removeObjectAtIndex:indexPath.row];
            if (indexPath.row != 0) {
                EditContentModel *frontModel = self.dataArr[indexPath.row - 1];
                EditContentModel *lastModel = self.dataArr[indexPath.row];
                NSString *text = nil;
                if (!frontModel.inputStr.length || !lastModel.inputStr.length) {
                    text = [NSString stringWithFormat:@"%@%@", frontModel.inputStr, lastModel.inputStr];
                } else {
                    text = [NSString stringWithFormat:@"%@\n%@", frontModel.inputStr, lastModel.inputStr];
                }
                frontModel.inputStr = text;
                [self.dataArr removeObjectAtIndex:indexPath.row];
            }
            [self.tableView reloadData];
        };
        return imgCell;
    } else {
        EditContentTextViewCell *textCell = [EditContentTextViewCell cellWithTableView:tableView];
        [textCell setModel:model];
        textCell.insertImgBlock = ^() {
            [self _insertImg];
        };
        return textCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditContentModel *model = self.dataArr[indexPath.row];
    if (model.cellType == EditContentCellTypeImage) {
        return 212;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - event response
- (void)_addImg {
    TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
    imagePickerVC.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],
                                                        NSForegroundColorAttributeName:HexColorInt32_t(D6BD99)};
    @weakify(self);
    [imagePickerVC setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        @strongify(self);
        [self _uploadImages:photos];
    }];
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)_insertImg {
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    id firstResponder = [keywindow performSelector:@selector(firstResponder)];
    if ([firstResponder isKindOfClass:[UITextView class]]) {
        // 这里已经判断出来了第一响应者，可以完成相应的操作
        UITextView *textView = (UITextView *)firstResponder;
        EditContentTextViewCell *textCell = (EditContentTextViewCell *)textView.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:textCell];
        self.responderIndex = indexPath.row;
        self.insertImg = YES;
        [self _addImg];
    }
}

- (void)_publish {
    if ((self.dataArr.count == 1 && !self.dataArr[0].inputStr.length) || !self.tableHeader.field.text.length) {
        [ResultPromptView showPromptWithMessage:@"请完善帖子内容"];
        return;
    }
    NSMutableArray *arrM = [NSMutableArray array];
    if (self.dataArr.count % 2 == 0) {
        for (NSInteger i = 0; i < self.dataArr.count / 2; i ++) {
            EditContentItemModel *model = [[EditContentItemModel alloc] init];
            model.imageUrl = self.dataArr[2 * i].imageUrl;
            model.inputStr = self.dataArr[2 * i + 1].inputStr;
            [arrM addObject:model];
        }
    } else {
        for (NSInteger i = 0; i < (self.dataArr.count + 1) / 2; i ++) {
            if (i == 0) {
                EditContentItemModel *model = [[EditContentItemModel alloc] init];
                model.imageUrl = @"";
                model.inputStr = self.dataArr[0].inputStr;
                [arrM addObject:model];
            } else {
                EditContentItemModel *model = [[EditContentItemModel alloc] init];
                model.imageUrl = self.dataArr[2 * i - 1].imageUrl;
                model.inputStr = self.dataArr[2 * i].inputStr;
                [arrM addObject:model];
            }
        }
    }
    NSDictionary *dict = @{@"mEditorDatas" : arrM};
    NSString *mEditorDatas = [dict yy_modelToJSONString];
    NSLog(@"%@", mEditorDatas);
    
    // 模拟网络请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ResultPromptView showPromptWithMessage:@"发布成功"];
    });
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kFooterHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 180;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = HexColorInt32_t(F0F0F0);
        _tableView.tableHeaderView = self.tableHeader;
        
    }
    return _tableView;
}

- (EditContentTableHeader *)tableHeader {
    if (!_tableHeader) {
        _tableHeader = [[[NSBundle mainBundle] loadNibNamed:@"EditContentAllView" owner:self options:nil] objectAtIndex:0];
    }
    return _tableHeader;
}

- (UIButton *)footerView {
    if (!_footerView) {
        _footerView = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight - kFooterHeight, kScreenWidth, kFooterHeight)];
        [_footerView setTitle:@"添加图片" forState:UIControlStateNormal];
        _footerView.backgroundColor = [UIColor lightGrayColor];
        [_footerView addTarget:self action:@selector(_addImg) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footerView;
}

- (NSMutableArray<EditContentModel *> *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}



@end
