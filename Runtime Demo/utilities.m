//
// Created by Alexey Storozhev on 25.02.14.
// Copyright (c) 2014 e-Legion. All rights reserved.
//
#import "utilities.h"
#import <objc/runtime.h>

static NSString *setterNameForPropertyWithName(NSString *propertyName)
{
    NSString *firstLetter = [[propertyName substringToIndex:1] uppercaseString];
    NSString *remainingSetterName = [propertyName substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingSetterName];
}

static NSString *property_getSetterName(objc_property_t property)
{
    char *setterAttributeValue = property_copyAttributeValue(property, "S");

    if (NULL != setterAttributeValue) {
        NSString *setterName = [NSString stringWithUTF8String:setterAttributeValue];
        
        // do not forget!
        free(setterAttributeValue);

        return setterName;
    }

    const char *propertyName = property_getName(property);
    return setterNameForPropertyWithName([NSString stringWithUTF8String:propertyName]);
}

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
