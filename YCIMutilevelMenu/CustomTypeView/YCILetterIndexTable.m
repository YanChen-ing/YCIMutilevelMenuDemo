//
//  YCILetterIndexTable.m
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/7/7.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "YCILetterIndexTable.h"
#import "YCILetterIndexHelper.h"

#define YCI_SectionTextColor       YCI_ColorFromRGB(0xB4B4B4)
#define YCI_SectionBgColor         YCI_ColorFromRGB(0xFAFAFA)

#define YCI_IndexPannelTextColor   YCI_ColorFromRGB(0x4779E3)
#define YCI_IndexPannelBgColor     YCI_ColorFromRGB(0xE7F0FE)


@interface YCILetterIndexTable ()<UITableViewDelegate,UITableViewDataSource>
{
    NSTimer *_indexPannelTimer;
}

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) YCILetterIndexHelper *indexHelper;
@property (strong, nonatomic) UILabel  *lb_indexPannel;

@end

@implementation YCILetterIndexTable

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
    
    if (_option.options.count == 0) {
        return;
    }
    
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

#pragma mark Index

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
//    if (_option.hasDefaultTopSection && section == 0) {
//        return 0;
//    }
    
    if (_option.hasDefaultTopSection && section == 0) {
        return 0;
    }
    
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
//    if (_option.hasDefaultTopSection && section == 0) {
//        return nil;
//    }
    
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 40, 23)];
    lb.font = [UIFont systemFontOfSize:11];
    lb.textColor = YCI_SectionTextColor;
    
    lb.text = [_option.marr_index objectAtIndex:section];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 23)];
    background.backgroundColor = YCI_SectionBgColor;
    [background addSubview:lb];
    
    return background;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
//    if (_option.hasDefaultTopSection) {
//        
//        NSString *topSectionIndexTitle = _option.topSectionIndexTitle;
//        if (!topSectionIndexTitle) {
//            topSectionIndexTitle = @"";
//        }
//        NSMutableArray *indexArr = [NSMutableArray arrayWithObject:topSectionIndexTitle];
//        [indexArr addObjectsFromArray:_option.marr_index];
//        
//        return indexArr;
//    }
    
    return _option.marr_index;
}

//索引列点击事件
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (title.length > 0) {
        
        [self showIndexPannelWithString:title];
    }
    
    return index;
}

#pragma mark - ------- logic
- (void)showIndexPannelWithString:(NSString *)str{
    [self.superview addSubview:self.lb_indexPannel];
    
    self.lb_indexPannel.text = str;
    
    [_indexPannelTimer invalidate];
    
    _indexPannelTimer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(hideIndexPannel) userInfo:nil repeats:NO];
    
    
}

- (void)hideIndexPannel{
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.lb_indexPannel.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.lb_indexPannel.alpha = 1.0f;
        [self.lb_indexPannel removeFromSuperview];
    }];
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

- (YCILetterIndexHelper *)indexHelper{
    
    if (!_indexHelper) {
        _indexHelper = [[YCILetterIndexHelper alloc] initWithObjectIndexLetterSelector:@selector(titlePinyin)];
    }
    return _indexHelper;
}

- (UILabel *)lb_indexPannel{
    
    if (!_lb_indexPannel) {
        _lb_indexPannel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        
        CGPoint center = self.superview.center;
        center.y = CGRectGetMidY(self.superview.bounds) *0.9;
        _lb_indexPannel.center = center;
        
        _lb_indexPannel.textAlignment = NSTextAlignmentCenter;
        _lb_indexPannel.font = [UIFont systemFontOfSize:15];
        
        _lb_indexPannel.textColor = YCI_IndexPannelTextColor;
        _lb_indexPannel.backgroundColor = YCI_IndexPannelBgColor;
        
        
        _lb_indexPannel.layer.masksToBounds = YES;
        _lb_indexPannel.layer.cornerRadius  = 4;
    }
    return _lb_indexPannel;
}


- (void)setOption:(YCIMenuLetterIndexOption *)option{
    _option = option;
    
    if (option.hasSectionModels) {
        return;
    }
    
    NSMutableArray *marr_2Dmodels = [NSMutableArray array];
    NSMutableArray *marr_index    = [NSMutableArray array];
    
    if (option.hasDefaultTopSection) {
    
        //set top section
        [marr_2Dmodels addObject:option.topSection];
        
        NSString *indexTitle = option.topSectionIndexTitle;
        if (!indexTitle) {
            indexTitle = @"";
        }
        [marr_index insertObject:indexTitle atIndex:0];
    }
    
    //set options
    if (!option.hasSectionModels) {
        
        __block NSArray *options;
        
        [option.options enumerateObjectsUsingBlock:^(NSArray *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj != _option.topSection) {
                options = obj;
                *stop = YES;
            }
            
        }];
        
        if (options) {
            [self.indexHelper updateDataWith1DModelsArray:options];
            [marr_2Dmodels addObjectsFromArray:self.indexHelper.marr_2Dmodels];
            [marr_index addObjectsFromArray:self.indexHelper.marr_index];
            
            option.hasSectionModels = YES;
            
        }
    }
    
    option.options    = marr_2Dmodels;
    option.marr_index = marr_index;
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.tableView.backgroundColor = backgroundColor;
}


@end
