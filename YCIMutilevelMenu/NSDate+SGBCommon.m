//
//  NSDate+SGBCommon.m
//  mobilebo
//
//  Created by yanchen on 16/6/1.
//  Copyright © 2016年 sogou. All rights reserved.
//

#import "NSDate+SGBCommon.h"

@implementation NSDate (SGBCommon)

/**
 *  获取对应格式的日期字符串
 */
- (NSString *)stringWithFormat:(NSString *)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateFromDateString:(NSString *)str withFormat:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:str];
}

- (NSDate *)dateFromFormat:(NSString *)format{
    NSString *str = [self stringWithFormat:format];
    return [NSDate dateFromDateString:str withFormat:format];
}

/** 通过return的NSDateComponents 获取NSDate的 年 月 日 周 时 分 秒 等 */
- (NSDateComponents *)dateComponents:(NSCalendarUnit)unitFlags {
    NSCalendar    *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];

    return comps;
}

@end
