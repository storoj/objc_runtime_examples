//
// Created by Alexey Storozhev on 25.02.14.
// Copyright (c) 2014 e-Legion. All rights reserved.
//

@interface ELSample : NSObject

@property (nonatomic, strong) NSArray *values;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign, getter=isValid, setter=setValidCustom:) BOOL valid;

@end
