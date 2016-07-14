//
//  YCIMenuOption.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/6/30.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YCIMenuDefinement.h"

static NSString *const optionClassNameKey = @"optionClassName";

/**
 *  选项模型
 */
@interface YCIMenuOption : NSObject

@property (      nonatomic) YCIMenuType type;

@property (      nonatomic) BOOL showLoading;     /**< 需要网络请求*/

@property (      nonatomic) BOOL canShowDetail;

@property (      nonatomic) BOOL autoBackgroundColor;     /**< 自动设置背景色*/

@property (copy  , nonatomic) NSString *title;
@property (copy  , nonatomic) NSString *sid;

/** 标题的拼音,用于索引分段*/
@property (strong, nonatomic) NSString *titlePinyin;

@property (copy  , nonatomic) NSString *menuClassName;
@property (copy  , nonatomic) NSString *cellClassName;
@property (      nonatomic) NSInteger cellHeight;

/*======= 详情(下级)列表信息 =====*/
@property (copy  , nonatomic) NSArray     *options;
@property (copy  , nonatomic) NSIndexPath *selectedIndexPath;


@property (strong, nonatomic) id info;           /**< 保存自定义页面的数据*/

@property (readonly,nonatomic) BOOL hasDefaultTopSection;
@property (strong, nonatomic) NSArray  *topSection;

/**
 *  根据选项展开的视图类型,返回对应的选项模型
 */
+ (instancetype)menuOptionWithMenuType:(YCIMenuType)type;

+ (instancetype)menuOptionWithJsonFile:(NSString *)file;
+ (instancetype)menuOptionWithDictionary:(NSDictionary *)config;

/** 选中选项链,A->B->C*/
- (NSArray *)selectedOptionLink;

/** 清除用户操作信息,递归清除路径下所有option操作信息 */
- (void)clearUserOperation;
///** ?含有详细(下级)数据 */
//- (BOOL)hasRightDetailData;

@end
