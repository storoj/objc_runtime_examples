//
// Created by Alexey Storozhev on 25.02.14.
// Copyright (c) 2014 e-Legion. All rights reserved.
//

#import <objc/runtime.h>

NSString *property_getSetterName(objc_property_t property);
objc_property_t class_getPropertyWithSetter(Class class, SEL selector);
void observeClassPropertyChanges(Class class);
void observeClassPropertyChanges2(Class class);
NSString *NSStringFromUIControlEvents(UIControlEvents events);

#define METHOD_SWIZZLE1_DECLARATION(type)\
    void method_swizzle1_##type (Method method, void(^before)(id, SEL, type), void(^after)(id, SEL, type))

METHOD_SWIZZLE1_DECLARATION(id);
