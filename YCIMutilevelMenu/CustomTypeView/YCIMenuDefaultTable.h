//
//  YCIMenuDefaultTable.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/7/6.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCIMenuOption.h"

@interface YCIMenuDefaultTable : UIView<YCIMenuProtocol>

@property (strong, nonatomic) YCIMenuOption *option;

@property (nonatomic, weak) id <YCIMenuDelegate> delegate;

@property (      nonatomic) BOOL defaultSelectedFirstRow;


@end
