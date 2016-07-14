//
//  YCIMenuDefinement.h
//  YCIMutilevelMenuDemo
//
//  Created by yanchen on 16/6/30.
//  Copyright © 2016年 yanchen. All rights reserved.
//

#ifndef YCIMenuDefinement_h
#define YCIMenuDefinement_h

#define  YCI_ColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define YCI_SeparatorColor       YCI_ColorFromRGB(0xEEEEEE)
#define YCI_TextColor            YCI_ColorFromRGB(0x000000)
#define YCI_TextSelectedColor    YCI_ColorFromRGB(0x4779E3)

//#define YCI_CellMinHeight   44
//#define YCI_FontSize        16
#define YCI_animateDuration 0.3

//#define YCI_MaxLevel    5

/**
 *  每级子菜单类型
 */
typedef NS_ENUM(NSUInteger, YCIMenuType) {

    YCIMenuTypeDefault,
    /** 默认样式,需要请求网络数据*/
    YCIMenuTypeDefaultRequest,
    /** 日期区间选择 */
    YCIMenuTypeDateRange,
    /** 字母索引列表 */
    YCIMenuTypeLetterIndexTable,
    
};

#import "YCIMenuOption.h"
@class YCIMenuOption;
@protocol YCIMenuTableCellProtocol <NSObject>

- (void)bindDataWithModel:(YCIMenuOption *)model;

@end

@protocol YCIMenuDelegate <NSObject>
@required
- (void)option:(YCIMenuOption *)highOption showOption:(YCIMenuOption *)lowOption;
- (void)addOption:(YCIMenuOption *)option;
- (void)refreshViewsFrame;

@end

@protocol YCIMenuProtocol <NSObject>

@required

@property (strong, nonatomic) YCIMenuOption *option;

- (void)reloadData;

@end

#endif /* YCIMenuDefinement_h */
