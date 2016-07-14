//
//  NSDate+SGBCommon.h
//  mobilebo
//
//  Created by yanchen on 16/6/1.
//  Copyright © 2016年 sogou. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *formatStr1 = @"yyyy-MM-dd";

@interface NSDate (SGBCommon)

/**
 *  获取对应格式的日期字符串
 */
- (NSString *)stringWithFormat:(NSString *)format;

+ (NSDate *)dateFromDateString:(NSString *)str withFormat:(NSString *)format;
- (NSDate *)dateFromFormat:(NSString *)format;

/**
 *  通过return的 NSDateComponents 获取NSDate的 年 月 日 周 时 分 秒 等
 *
 *  @param unitFlags 要获取的时间类型枚举
 *  @示例 NSInteger hour = [[date dateComponents:NSCalendarUnitHour] hour];
 */
- (NSDateComponents *)dateComponents:(NSCalendarUnit)unitFlags;

@end
