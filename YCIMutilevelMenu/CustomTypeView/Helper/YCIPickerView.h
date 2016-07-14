//
//  YCIPickerView.h
//
//  Created by CYFly on 16/5/27.
//  Copyright © 2016年 Sogou. All rights reserved.
//
//  * 选择控件，包括:传入数据展示、日期、时间 *
//

/*
 *  <-- 使用说明 -->
 *  1.先调用No.1方法创建对象
 *  2.数据准备：
 *    如果mode是YCIPickerViewModeSingleLevel，需调用No.3方法
 *    如果mode是YCIPickerViewModeMultiLevel，需实现 YCIPickerViewMultiLevelDelegate 所有方法
 *    其他mode请忽略这步
 *  3.调用No.2方法用来显示
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YCIPickerViewMode) {
    YCIPickerViewModeSingleLevel,       // 只有一级菜单
    YCIPickerViewModeMultiLevel,        // 多级菜单
    YCIPickerViewModeDate,              // 日期，显示 年月日
    YCIPickerViewModeTime,              // 时间，每半小时间隔
};

@protocol YCIPickerViewMultiLevelDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface YCIPickerView : UIView

#pragma mark - ------ @required

/**
 *  No.1 初始化方法
 *
 *  @param mode       类型
 *  @param title      标题
 *  @param completion 完成回调block（注意self循环引用问题）
 *
 *  @return 初始化好的 YCIPickerView 对象
 */
- (instancetype)initWithMode:(YCIPickerViewMode)mode
                       title:(NSString *)title
                  completion:(void (^)(id _Nullable result, NSUInteger idx, NSError * _Nullable error))completion;

/**
 *  No.2 出现，只有调用此方法后才会显示
 *
 *  @param view 要显示在哪个 view 中，一般在ViewController里传入 self.view 即可
 */
- (void)showInView:(UIView *)view;


#pragma mark - ------ @optional

/**
 *  No.3 只有一级菜单时，调用此方法，传入任意数据数组
 *
 *  @param dataSource [@required] 数据数组（可以是任意对象）
 *  @param key        [@optional] 用来显示的字段名称（如果 dataSource 是 NSString 数组，这里可以传 nil）
 */
- (void)dataSource:(NSArray *)dataSource displayKey:(nullable NSString *)key;

////////////////////////////////////////////////////////////////////////
////////////////////// if mode == Date || Time /////////////////////////
////////////////////////////////////////////////////////////////////////

/** 可设置最小和最大显示范围 */
@property (strong, nonatomic, nullable) NSDate *minimumDate;
@property (strong, nonatomic, nullable) NSDate *maximumDate;
@property (strong, nonatomic, nullable) NSDate *currentDate;

/** 可设置显示时间间隔，最小1，最大30，单位分钟, 必须能被60整除，默认30 */
@property (nonatomic) NSInteger minuteInterval;

////////////////////////////////////////////////////////////////////////
/////////////// if mode == YCIPickerViewModeMultiLevel /////////////////
////////////////////////////////////////////////////////////////////////

/** 如果mode是YCIPickerViewModeMultiLevel需设置delegate */
@property (weak, nonatomic) id<YCIPickerViewMultiLevelDelegate> delegate;

/**
 *  刷新整个PickerView
 */
- (void)reloadData;

/**
 *  刷新PickerView的某一级
 *
 *  @param level 哪一级
 */
- (void)reloadLevel:(NSInteger)level;

@end


#pragma mark - ------ @protocol YCIPickerViewMultiLevelDelegate

@protocol YCIPickerViewMultiLevelDelegate <NSObject>

/**
 *  如果mode是YCIPickerViewModeMultiLevel，需实现以下协议方法
 */
@required

/** YCIPickerView需要有几级选择菜单 */
- (NSInteger)numberOfLevelsInPickerView:(YCIPickerView *)pickerView;

/** 每一级菜单有多少行 */
- (NSInteger)pickerView:(YCIPickerView *)pickerView numberOfRowsInLevel:(NSInteger)level;

/** 每一行显示什么内容 */
- (NSString *)pickerView:(YCIPickerView *)pickerView titleForRow:(NSInteger)row forLevel:(NSInteger)level;

/** 当YCIPickerView被用户选中，会回调此方法 */
- (void)pickerView:(YCIPickerView *)pickerView didSelectRow:(NSInteger)row inLevel:(NSInteger)level;

@optional
- (void)pickerViewDidCancel:(YCIPickerView *)pickerView;

@end

NS_ASSUME_NONNULL_END
