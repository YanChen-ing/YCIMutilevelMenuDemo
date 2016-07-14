//
//  YCIDateRangePicker.m
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/5/27.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "YCIDateRangePicker.h"

#import "YCIPickerView.h"
#import "NSDate+SGBCommon.h"


@interface YCIDateRangePicker ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation YCIDateRangePicker

@synthesize option = _option;

#pragma mark - ------- Life Cycle

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self addSubview:self.tableView];
    
    [self reloadData];
}

- (void)reloadData{
    _tableView.rowHeight = self.option.cellHeight;
    [self.tableView reloadData];
}

#pragma mark - ------- delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *dateCellId = @"dateCell";
    static NSString *infoCellId = @"infoCell";
    
    NSString * cellId = indexPath.row == 1 ? infoCellId : dateCellId;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, cell.bounds.size.height -1, cell.bounds.size.width, 1)];
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        separator.backgroundColor = YCI_SeparatorColor;
        [cell.contentView addSubview:separator];
        
        if (cellId == dateCellId) {
            
            UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(cell.bounds.size.width - 30, 0, 20, cell.bounds.size.height)];
            imageView.contentMode = UIViewContentModeCenter;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            imageView.image = [UIImage imageNamed:@"filter_date"];

            [cell.contentView addSubview:imageView];
        }
    }
    
    if (indexPath.row ==1) {
        [self cell:cell title:@"至" isTips:NO];
    }else{
        
        NSDate *date = indexPath.row == 0 ? self.option.startDate : self.option.endDate;
        
        if (date) {
            [self cell:cell title:[date stringWithFormat:formatStr1] isTips:NO];
        }else{
            [self cell:cell title:@"选择日期" isTips:YES];
        }
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 1) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    YCIPickerView * pickerView = [[YCIPickerView alloc]initWithMode:YCIPickerViewModeDate title:@"选择日期" completion:^(id result, NSUInteger idx, NSError *error) {
        
        if (indexPath.row == 0) {
            weakSelf.option.startDate = result;
        }else{
            weakSelf.option.endDate = result;
        }
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];
    
    [pickerView showInView:[UIApplication sharedApplication].delegate.window];
}

#pragma mark - ------- public


#pragma mark - ------- private
- (void)cell:(UITableViewCell *)cell title:(NSString *)title isTips:(BOOL)isTips{
    
    if (isTips) {
       //灰色提示
        cell.textLabel.textColor = YCI_ColorFromRGB(0xB4B4B4);
    }else{
        cell.textLabel.textColor = YCI_ColorFromRGB(0x222222);
    }
    cell.textLabel.text = title;
}

#pragma mark - ------- setter & getter

- (UITableView *)tableView{
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return _tableView;
}

- (NSMutableDictionary *)infoDic{
    if (!_infoDic) {
        _infoDic = [NSMutableDictionary dictionary];
    }
    return _infoDic;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.tableView.backgroundColor = backgroundColor;
}


@end
