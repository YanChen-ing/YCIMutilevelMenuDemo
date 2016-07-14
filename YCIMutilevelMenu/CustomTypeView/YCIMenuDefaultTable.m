//
//  YCIMenuDefaultTable.m
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/7/6.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "YCIMenuDefaultTable.h"

@interface YCIMenuDefaultTable ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation YCIMenuDefaultTable

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    if (!newSuperview) {
        return;
    }
    
    [self addSubview:self.tableView];
    [self sendSubviewToBack:self.tableView];
    
    //set default displaying
    [self refreshViews];
    
}

- (void)reloadData{
    [self setOption:self.option];
    [self refreshViews];
    [self.delegate refreshViewsFrame];
}

- (void)refreshViews{
    [_tableView reloadData];
    [self setSelectedCell];
}

- (void)setSelectedCell{
    
    NSIndexPath *indexPath = _option.selectedIndexPath;
    
    if (self.defaultSelectedFirstRow && !indexPath) {
        
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
    }
    
    YCIMenuOption *selectedOption = _option.options[indexPath.section][indexPath.row];
    
    if (selectedOption) {
        
        if (selectedOption.canShowDetail) {
            //recursive
            [self.delegate addOption:selectedOption];
        }
        
        [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

#pragma mark - ------- UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _option.options.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_option.options[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_option.cellClassName forIndexPath:indexPath];
    
    //bind data
    YCIMenuOption *rowOption = _option.options[indexPath.section][indexPath.row];
    
    if ([cell conformsToProtocol:NSProtocolFromString(@"YCIMenuTableCellProtocol")]) {
        [cell performSelector:@selector(bindDataWithModel:) withObject:rowOption];
    }
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    _option.selectedIndexPath = indexPath;
    
    //show next menu
    YCIMenuOption *selectedOption = _option.options[indexPath.section][indexPath.row];

    if (selectedOption.canShowDetail) {
        [self.delegate option:_option showOption:selectedOption];
        return;
    }
    
    [self.delegate option:_option showOption:nil];
    
}


#pragma mark - ------- setter & getter

- (UITableView *)tableView{
    
    if (!_tableView) {
        
        UITableView *table = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        table.delegate   = self;
        table.dataSource = self;
        table.rowHeight  = _option.cellHeight;
        
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        Class cellClass = NSClassFromString(_option.cellClassName);
        
        NSAssert(cellClass, @"must have cell class for option");
        
        [table registerClass:cellClass forCellReuseIdentifier:_option.cellClassName];
        
        _tableView = table;
        
    }
    return _tableView;
}

- (void)setOption:(YCIMenuOption *)option{
    _option = option;
    
    if (option.hasDefaultTopSection == NO) {
        return;
    }
    
    NSMutableArray *arr = [NSMutableArray arrayWithObject:option.topSection];
    
    if (option.options.count == 0) {
        option.options = arr;
        return;
    }
    
    NSArray *firstSection = option.options[0];
    
    if (firstSection != option.topSection) {

        [arr addObjectsFromArray:option.options];
        option.options = arr;
    }
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.tableView.backgroundColor = backgroundColor;
}

@end
