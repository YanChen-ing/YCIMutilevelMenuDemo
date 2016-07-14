//
//  YCILetterIndexHelper.m
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/5/30.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import "YCILetterIndexHelper.h"
#import <UIKit/UIKit.h>

//索引条(最新加入分组的)字符
#define IndexBarNewGroupFlag      @"新"

@interface YCILetterIndexHelper ()
{
    SEL _letterSelector;
}

@property (strong, nonatomic, readwrite) NSMutableArray *marr_index;
@property (strong, nonatomic, readwrite) NSMutableArray *marr_2Dmodels;
@property (strong, nonatomic, readwrite) NSArray *arr_1Dmodels;


@end

@implementation YCILetterIndexHelper

#pragma mark - ------- life Cycle

- (instancetype)initWithObjectIndexLetterSelector:(SEL)selector{
    self = [super init];
    if (self) {
        _letterSelector = selector;
    }
    return self;
}

#pragma mark - ------- public

- (void)updateDataWith1DModelsArray:(NSArray *)arr_1Dmodels{
    //TODO:: 处理nil的问题
//    if (!arr_1Dmodels) {
//        _marr_index = nil;
//        _marr_2Dmodels = nil;
//        _arr_1Dmodels = arr_1Dmodels;
//        return;
//    }
    _arr_1Dmodels = arr_1Dmodels;
    [self sectionTheModels];
}

/**
 *  添加部分新模型
 */
- (void)insertModelsTo2DModels:(NSArray *)arr{
    
    if (_marr_index.count == 0||![_marr_index[0] isEqualToString:IndexBarNewGroupFlag]) {
        //索引
        NSMutableArray *marr = [NSMutableArray arrayWithArray:_marr_index];
        [marr insertObject:IndexBarNewGroupFlag atIndex:0];
        _marr_index = marr;
        
        //数据
        NSMutableArray *models = [NSMutableArray arrayWithArray:arr];
        //        [models addObject:customerInfo];
        
        [_marr_2Dmodels insertObject:models atIndex:0];
        
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    //已经有 新加入分组
    else{
        [_marr_2Dmodels[0] addObjectsFromArray:arr];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

//- (void)deleteModelWithIndexPath:(NSIndexPath *)indexPath{
//
//
//}


#pragma mark - ------- private

/**
 *  给模型分组,生成对应索引数组,数据二维数组
 */
- (void)sectionTheModels
{
    
    //对联系人进行分组和排序
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    NSInteger highSection = [[theCollation sectionTitles] count]; //中文环境下返回的应该是27，是a－z和＃，其他语言则不同
    
    //_indexArray 是右侧索引的数组，也是secitonHeader的标题
    _marr_index = [[NSMutableArray alloc] initWithArray:[theCollation sectionTitles]];
    
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:highSection];
    //初始化27个空数组加入newSectionsArray
    for (NSInteger index = 0; index < highSection; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
    
    //按首字母调整数组
    for (NSObject *p in _arr_1Dmodels) {
        
        //        NSInteger sectionNumber = [theCollation sectionForObject:p collationStringSelector:@selector(yci_firstLetter)];
        NSInteger sectionNumber = [theCollation sectionForObject:p collationStringSelector:_letterSelector];
        NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
        [sectionNames addObject:p];
    }
    
    //移除没有对象的索引
    for (int i = 0; i < newSectionsArray.count; i++) {
        NSMutableArray *sectionNames = newSectionsArray[i];
        if (sectionNames.count == 0) {
            [newSectionsArray removeObjectAtIndex:i];
            [_marr_index removeObjectAtIndex:i];
            i--;
        }
    }
    
    if (self.firstSection) {
        
        [newSectionsArray insertObject:self.firstSection atIndex:0];
        if (self.firstSectionIndexTitle) {
            [_marr_index insertObject:self.firstSectionIndexTitle atIndex:0];
        }else{
            [_marr_index insertObject:@"" atIndex:0];
        }
    }
    
    //_marr_2Dmodels 是联系人数组（确切的说是二维数组）
//    [_marr_2Dmodels 
    _marr_2Dmodels = newSectionsArray;
    
//    [self.tableView reloadData];
}


@end
