//
//  YCIMutiSelectOption.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/10/8.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "YCIMenuOption.h"

@interface YCIMutiSelectOption : YCIMenuOption

/**
 *  选中选项 <NSIndexPath>
 */
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *selectedIndexPaths;


/**
 *  选中选项 模型数组
 */
- (NSMutableArray<YCIMenuOption *> *)selectedOptions;

@end
