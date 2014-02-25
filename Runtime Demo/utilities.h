//
// Created by Alexey Storozhev on 25.02.14.
// Copyright (c) 2014 e-Legion. All rights reserved.
//

#import <objc/runtime.h>

NSString *property_getSetterName(objc_property_t property);
objc_property_t class_getPropertyWithSetter(Class class, SEL selector);
void observeClassPropertyChanges(Class class);
