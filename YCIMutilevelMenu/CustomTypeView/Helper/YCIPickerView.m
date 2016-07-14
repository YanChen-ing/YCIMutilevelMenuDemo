//
//  YCIPickerView.m
//
//
//  Created by CYFly on 16/5/27.
//  Copyright © 2016年 Sogou. All rights reserved.
//

#import "YCIPickerView.h"
#import "NSDate+SGBCommon.h"

#define PickerHeight          216.0f
#define ContainerHeaderHeight 40.0f

static NSInteger const DefaultMinuteInterval = 30;

typedef void(^CompletionBlock)(id result, NSUInteger idx, NSError *error);

@interface YCIPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIButton     *bgView;
@property (strong, nonatomic) UIView       *containerView;

@property (assign, nonatomic) YCIPickerViewMode mode;
@property (copy  , nonatomic) NSString          *title;
@property (copy  , nonatomic) CompletionBlock   finishBlock;
@property (strong, nonatomic) NSArray           *dataSource;
@property (copy  , nonatomic) NSString          *displayKey;
@property (strong, nonatomic) id                chooseObj;
@property (assign, nonatomic) NSUInteger        chooseIndex;

@end

@implementation YCIPickerView

@synthesize currentDate = _currentDate;

#pragma mark - ------ Init

- (void)dealloc {
//    NSLog(@"...YCIPickerView dealloc...");
}

- (instancetype)initWithMode:(YCIPickerViewMode)mode
                       title:(NSString *)title
                  completion:(void (^)(id result, NSUInteger idx, NSError *error))completion {
    
    self = [super init];
    
    if (self) {
        
        [self addSubview:self.bgView];
        [self addSubview:self.containerView];
        
        self.mode        = mode;
        self.title       = title;
        self.finishBlock = completion;
        
        switch (mode) {
            case YCIPickerViewModeDate:
            {
                [self.containerView addSubview:self.datePicker];
                self.datePicker.datePickerMode = UIDatePickerModeDate;
            }
                break;
            case YCIPickerViewModeTime:
            {
                [self.containerView addSubview:self.datePicker];
                self.datePicker.datePickerMode = UIDatePickerModeTime;
                self.minuteInterval = DefaultMinuteInterval;
                [self configureCurrentDate];
            }
                break;
            default:
            {
                [self.containerView addSubview:self.pickerView];
            }
                break;
        }
    }
    
    return self;
}

- (void)dataSource:(NSArray *)dataSource displayKey:(NSString *)key {
    
    self.dataSource = dataSource;
    self.displayKey = key;
    
    if (!dataSource || !dataSource.count) {
        NSAssert(0, @"传入的 dataSource 数组不能为空");
    } else if ((!key || !key.length) && ![dataSource[0] isKindOfClass:[NSString class]]) {
        NSAssert(0, @"未传入参数 displayKey 时，dataSource 必须是 NSString 类型数组");
    }
}

#pragma mark - ------ Life Cycle

- (void)layoutSubviews {
    
    self.bgView.frame        = self.frame;
    self.containerView.frame = CGRectMake(0, self.bounds.size.height - PickerHeight - ContainerHeaderHeight, self.bounds.size.width, PickerHeight + ContainerHeaderHeight);
    
    CGRect pickerFrame       = CGRectMake(0, ContainerHeaderHeight, self.containerView.bounds.size.width, PickerHeight);
    
    if (self.mode == YCIPickerViewModeDate || self.mode == YCIPickerViewModeTime) {
        
        self.datePicker.frame = pickerFrame;
        
    } else {
        
        self.pickerView.frame = pickerFrame;
        [self.pickerView setNeedsLayout];
        
    }
    
    [self layoutContainers];
}

- (void)layoutContainers {
    
    UIColor *btnTitleColor = [UIColor colorWithRed:65/255.0 green:115/255.0 blue:227/255.0 alpha:1];

    UIButton *btn_cancel   = [UIButton buttonWithType:UIButtonTypeSystem];
    btn_cancel.frame       = CGRectMake(10, 5, 100, ContainerHeaderHeight);
    btn_cancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [btn_cancel setTitleColor:btnTitleColor forState:UIControlStateNormal];
    [btn_cancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:btn_cancel];
    
    UILabel *lb_title      = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width-100)/2, 5, 100,ContainerHeaderHeight)];
    lb_title.text          = self.title;
    lb_title.textAlignment = NSTextAlignmentCenter;
    lb_title.textColor     = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1];
    [self.containerView addSubview:lb_title];
    
    UIButton *btn_confirm = [UIButton buttonWithType:UIButtonTypeSystem];
    btn_confirm.frame     = CGRectMake(self.frame.size.width-100-10, 5, 100, ContainerHeaderHeight);
    btn_confirm.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btn_confirm setTitle:@"确定" forState:UIControlStateNormal];
    [btn_confirm setTitleColor:btnTitleColor forState:UIControlStateNormal];
    [btn_confirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:btn_confirm];
}

- (void)showInView:(UIView *)view {
    
    if (self.mode == YCIPickerViewModeSingleLevel && !self.dataSource) {
        NSAssert(0, @"必须先调用 '- (void)dataSource:(NSArray *)dataSource displayKeyName:(NSArray <NSString *> *)keyname' 方法");
    }
    
    [view addSubview:self];
    self.frame = view.bounds;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.5;
    } completion:nil];
}

#pragma mark - ------ Action

- (void)cancel {
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.hidden = YES;
        
        if (self.finishBlock) {
            self.finishBlock = nil;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerViewDidCancel:)]) {
            [self.delegate pickerViewDidCancel:self];
        }
        
        [self removeFromSuperview];
        
    }];
}

- (void)confirm {
    
    if (self.mode == YCIPickerViewModeDate || self.mode == YCIPickerViewModeTime) {
        self.chooseObj = self.datePicker.date;
    }
    
    if (self.finishBlock) {
        
        if (!self.chooseObj) {
            self.chooseObj = self.dataSource[0];
        }
        
        self.finishBlock(self.chooseObj, self.chooseIndex, nil);
        
    }
    
    [self cancel];
}

- (void)reloadData {
    [self.pickerView reloadAllComponents];
}

- (void)reloadLevel:(NSInteger)level {
    [self.pickerView reloadComponent:level];
}


#pragma mark - ------ Private

/** Mode == Time 时 */
- (void)configureCurrentDate {
    NSDateComponents *comps = [self.currentDate dateComponents:NSCalendarUnitHour|NSCalendarUnitMinute];
    NSInteger newMinute     = lround([comps minute]/self.minuteInterval)*self.minuteInterval;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat       = @"HH:mm";
    
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%@:%@", @([comps hour]), @(newMinute)]];
    self.datePicker.date = date;
}


#pragma mark - ------ Setter & Getter

- (UIView *)bgView {
    
    if (!_bgView) {
        _bgView                 = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha           = 0;
        [_bgView addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _bgView;
}

- (UIView *)containerView {
    
    if (!_containerView) {
        _containerView                 = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    
    return _containerView;
}

- (UIPickerView *)pickerView {
    
    if (!_pickerView) {
        _pickerView            = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate   = self;
    }
    
    return _pickerView;
}

- (UIDatePicker *)datePicker {
    
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
    }
    
    return _datePicker;
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    _maximumDate = maximumDate;
    self.datePicker.maximumDate = maximumDate;
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    _minimumDate = minimumDate;
    self.datePicker.minimumDate = minimumDate;
}

- (void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    self.datePicker.date = currentDate;
}

- (NSDate *)currentDate {
    _currentDate = self.datePicker.date;
    return _currentDate;
}

- (void)setMinuteInterval:(NSInteger)minuteInterval {
    _minuteInterval = minuteInterval;
    self.datePicker.minuteInterval = minuteInterval;
}


#pragma mark - ------ Delegate

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    if (self.mode == YCIPickerViewModeSingleLevel) {
        return 1;
    
    } else if (self.mode == YCIPickerViewModeMultiLevel) {
    
        if ([self.delegate respondsToSelector:@selector(numberOfLevelsInPickerView:)]) {
            return [self.delegate numberOfLevelsInPickerView:self];
        }
    
    }
    
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (self.mode == YCIPickerViewModeSingleLevel) {
    
        return self.dataSource.count;
    
    } else if (self.mode == YCIPickerViewModeMultiLevel) {
    
        if ([self.delegate respondsToSelector:@selector(pickerView:numberOfRowsInLevel:)]) {
            return [self.delegate pickerView:self numberOfRowsInLevel:component];
        }
    
    }

    return 0;
}

#pragma mark UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (self.mode == YCIPickerViewModeSingleLevel) {
        
        if (!self.displayKey || [self.dataSource[0] isKindOfClass:[NSString class]]) {
            
            return self.dataSource[row];
            
        } else {

            return [self.dataSource[row] valueForKey:self.displayKey] ;

        }
        
    } else if (self.mode == YCIPickerViewModeMultiLevel) {
        
        if ([self.delegate respondsToSelector:@selector(pickerView:titleForRow:forLevel:)]) {
            
            return [self.delegate pickerView:self titleForRow:row forLevel:component];
            
        }
        
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (self.mode == YCIPickerViewModeSingleLevel) {
        
        self.chooseIndex = row;
        self.chooseObj   = self.dataSource[row];
        
    } else if (self.mode == YCIPickerViewModeMultiLevel) {
        
        if (component == [pickerView numberOfComponents]-1) {
            
            self.chooseIndex = row;
            
        } else {
            
            self.chooseIndex = 0;
            [pickerView selectRow:0 inComponent:component+1 animated:NO];
            
        }
        
        if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inLevel:)]) {
            [self.delegate pickerView:self didSelectRow:row inLevel:component];
        }
        
    }
}

@end
