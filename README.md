# UITableView形式的图文编辑
#### 导语

> 本方案使用**UITableview**实现简单的图文混编效果，数据存储采用**Json**字符串。
 
## 一、背景

近期做项目，需要图文编辑功能，就上网搜索了一些资料，发现主流的方式有三种：
**UIView+UITextView+ImageView**、**UIWebview**、**CoreText**，数据存储方面主要采用**Html**和**Json**。

由于项目的特殊需求：批量插入图片，且每张图片下面自带文本输入框，还可以删除图片。因此自己用UITableView来实现此功能：**图片一个cell，文本一个cell**（因为考虑到后期的排序，故没将图片和文本放到一个cell里面处理）。

![图文编辑.gif](http://upload-images.jianshu.io/upload_images/1338824-80651d8eb7329822.gif?imageMogr2/auto-orient/strip)

## 二、具体实现

### 插入图片

这里存在两种情况：

1）在末尾依次插入图片和对应的输入框；

2）从中间插入图片和输入框。

代码如下：

```objc
	EditContentModel *imgModel = [[EditContentModel alloc] init];
	imgModel.img = photos[i];
	imgModel.cellType = EditContentCellTypeImage;
	if (self.isInsertImg == YES) {
	    [self.dataArr insertObject:imgModel atIndex:self.responderIndex + (2 * i + 1)];
	} else {
	    [self.dataArr addObject:imgModel];
	}
	[self _uploadWithImage:photos[i] index:[self.dataArr indexOfObject:imgModel]];
	    
	EditContentModel *textModel = [[EditContentModel alloc] init];
	textModel.inputStr = @"";
	textModel.cellType = EditContentCellTypeText;
	if (self.isInsertImg == YES) {
	    [self.dataArr insertObject:textModel atIndex:self.responderIndex + (2 * i + 2)];
	} else {
	    [self.dataArr addObject:textModel];
	}
```
### 文本输入

输入文本时动态改变textview的高度，达到自适应效果（这里使用的是RAC，也可以用代理实现）：

```objc
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
```
### 图片删除

删除图片时，将相邻的两个文本cell合并为一个，并处理相应的数据源：

```objc
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
```

### 数据存储

数据上传时，将一个图片和一个文本的数据作为一个整体进行处理：

```objc
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
```

至此，基本功能已经完成，若大家有排序这种需求可以在此基础上进行拓展添加。
