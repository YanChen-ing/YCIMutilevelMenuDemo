//
//  YCIMutiSelectOption.m
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/10/8.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "YCIMutiSelectOption.h"

@implementation YCIMutiSelectOption

- (NSMutableArray<NSIndexPath *> *)selectedIndexPaths{
    
    if (!_selectedIndexPaths) {
        _selectedIndexPaths = [NSMutableArray array];
    }
    return _selectedIndexPaths;
}

- (NSMutableArray<YCIMenuOption *> *)selectedOptions{
    
    NSMutableArray *mArr = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in _selectedIndexPaths) {
        
        NSInteger section = [indexPath indexAtPosition:0];
        NSInteger row     = [indexPath indexAtPosition:1];
        
        NSArray *sectionArr = self.options[section];
        
        YCIMenuOption *option = sectionArr[row];
        
        [mArr addObject:option];
        
    }
    
    return mArr;
}

@end
