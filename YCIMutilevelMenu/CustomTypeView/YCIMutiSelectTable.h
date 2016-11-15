//
//  YCIMutiSelectTable.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/10/8.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCIMenuMutiSelectOption.h"

/*
 可多选列表.
 TopSection:仅支持一项.此项为排他性项.即:topSection和其他任何选项互斥.
 */

@interface YCIMutiSelectTable : UIView<YCIMenuProtocol>

@property (strong, nonatomic) YCIMenuMutiSelectOption *option;

@property (      nonatomic) BOOL defaultSelectedFirstRow;



@end
