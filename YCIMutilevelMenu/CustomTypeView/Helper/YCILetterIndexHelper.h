//
//  YCILetterIndexHelper.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/5/30.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UITableView;

@interface YCILetterIndexHelper : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *marr_index;
@property (strong, nonatomic, readonly) NSMutableArray *marr_2Dmodels;

@property (weak, nonatomic) UITableView *tableView;


@property (strong, nonatomic) NSArray *firstSection;
@property (strong, nonatomic) NSString *firstSectionIndexTitle;

/**
 *  必须用该方法初始化
 *
 *  @param selector 数据数组中,模型对象中返回字符串用以判断索引的Selector
 */
- (instancetype)initWithObjectIndexLetterSelector:(SEL)selector;

- (void)updateDataWith1DModelsArray:(NSArray *)arr_1Dmodels;

/**
 *  添加部分新模型
 */
- (void)insertModelsTo2DModels:(NSArray *)arr;

@end
