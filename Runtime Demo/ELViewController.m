//
//  ELViewController.m
//  Runtime Demo
//
//  Created by Alexey Storozhev on 25.02.14.
//  Copyright (c) 2014 e-Legion. All rights reserved.
//

#import "ELViewController.h"
#import "ELSample.h"
#import "utilities.h"


#define CLASS_OBSERVING_TEST 0
#define OBSERVER_TEST 1

#if (OBSERVER_TEST)
#import "Observer.h"
#endif

@implementation ELViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

#if (CLASS_OBSERVING_TEST)
    observeClassPropertyChanges([ELSample class]);
#endif

    ELSample *sample = [ELSample new];

#if (OBSERVER_TEST)
    [Observer observerWithObject:sample];
#endif

    NSLog(@"class: %@", NSStringFromClass([sample class]));

#define TEST_FRAME 1
#define TEST_RANGE 1
#define TEST_IS_VALID 1
#define TEST_VALUES 1

#if (TEST_FRAME)
    NSLog(@"frame: %@", CGRectCreateDictionaryRepresentation([sample frame]));
    [sample setFrame:CGRectMake(1, 2, 3, 4)];
    NSLog(@"frame: %@", CGRectCreateDictionaryRepresentation([sample frame]));
#endif

#if (TEST_RANGE)
    NSLog(@"range: %@", NSStringFromRange([sample range]));
    [sample setRange:NSMakeRange(1, 2)];
    NSLog(@"range: %@", NSStringFromRange([sample range]));
#endif

#if (TEST_IS_VALID)
    NSLog(@"isValid: %d", [sample isValid]);
    [sample setValidCustom:YES];
    NSLog(@"isValid: %d", [sample isValid]);
#endif

#if (TEST_VALUES)
    NSLog(@"values: %@", [sample values]);
    [sample setValues:@[@(5)]];
    NSLog(@"values: %@", [sample values]);
#endif

#undef TEST_FRAME
#undef TEST_RANGE
#undef TEST_IS_VALID
#undef TEST_VALUES

}

@end