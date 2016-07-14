//
//  YCILetterIndexTable.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/7/7.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCIMenuLetterIndexOption.h"

@interface YCILetterIndexTable : UIView<YCIMenuProtocol>

@property (strong, nonatomic) YCIMenuLetterIndexOption *option;

@property (nonatomic, weak) id <YCIMenuDelegate> delegate;

@property (      nonatomic) BOOL defaultSelectedFirstRow;

@end
