//
// Created by Alexey Storozhev on 25.02.14.
// Copyright (c) 2014 e-Legion. All rights reserved.
//
#import "utilities.h"
#import <objc/runtime.h>

void observeClassPropertyChanges(Class class)
{
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
    for (unsigned int i=0; i<propertyCount; i++) {
        objc_property_t property = properties[i];
        // code
    }
    free(properties);
}
