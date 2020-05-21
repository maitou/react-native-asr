//
//  RecognitionResult.m
//  RNAsr/core
//
//  Created by YangJiang on 2020/5/14.
//

#import "RecognitionResult.h"

@interface RecognitionResult()

@property (nonatomic, copy) NSMutableString *tempRst;

@end

@implementation RecognitionResult

- (BOOL)isError {
    return _errorRst != nil;
}

- (BOOL)isTemp {
    return _tempRst != nil;
}

- (BOOL)isFinal {
    return _finalRst != nil;
}

- (void)addPartRst:(NSString *)part {
    if (!part) {
        return;
    }
    if (!_tempRst) {
        _tempRst = [[NSMutableString alloc]init];
    }
    [_tempRst appendString:part];
}

- (NSString *)getCurrentRst {
    if ([self isError]) {
        return _errorRst;
    }
    if ([self isTemp]) {
        return _tempRst;
    }
    if ([self isFinal]) {
        return _finalRst;
    }
    return _originalRst;
}

@end
