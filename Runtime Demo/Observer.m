//
// Created by Alexey Storozhev on 25.02.14.
// Copyright (c) 2014 e-Legion. All rights reserved.
//
#import "Observer.h"
#import "utilities.h"

@interface Observer ()
@end


@implementation Observer

- (instancetype)initWithObject:(id)object
{
    if (self) {
        Class pClass = object_setClass(object, [Observer class]);
        objc_setAssociatedObject(object, "realClass", pClass, OBJC_ASSOCIATION_RETAIN);
    }
    return self;
}

+ (instancetype)observerWithObject:(id)object
{
    return [[self alloc] initWithObject:object];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    Class currentClass = [self class];
    Class realClass = objc_getAssociatedObject(self, "realClass");
    object_setClass(self, realClass);

    SEL selector = [anInvocation selector];
    objc_property_t property = class_getPropertyWithSetter(realClass, selector);
    if (NULL != property) {
        NSLog(@"changing %s", property_getName(property));
    }

    [anInvocation invoke];

    object_setClass(self, currentClass);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    Class realClass = objc_getAssociatedObject(self, "realClass");
    NSMethodSignature *signature = [realClass instanceMethodSignatureForSelector:aSelector];
    return signature;
}

@end
