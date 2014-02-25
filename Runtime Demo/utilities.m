//
// Created by Alexey Storozhev on 25.02.14.
// Copyright (c) 2014 e-Legion. All rights reserved.
//
#import "utilities.h"

static NSString *setterNameForPropertyWithName(NSString *propertyName)
{
    NSString *firstLetter = [[propertyName substringToIndex:1] uppercaseString];
    NSString *remainingSetterName = [propertyName substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingSetterName];
}

NSString *property_getSetterName(objc_property_t property)
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

objc_property_t class_getPropertyWithSetter(Class class, SEL selector)
{
    // TODO cache values

    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertiesCount);

    NSString *selectorName = NSStringFromSelector(selector);

    for (unsigned int i=0; i<propertiesCount; i++) {
        objc_property_t property = properties[i];
        NSString *setterName = property_getSetterName(property);

        if ([setterName isEqualToString:selectorName]) {
            return property;
        }
    }

    return NULL;
}

void observeClassPropertyChanges(Class class)
{
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);

    for (unsigned int i=0; i<propertyCount; i++) {
        objc_property_t property = properties[i];

        NSString *setterName = property_getSetterName(property);
        SEL setterSelector = NSSelectorFromString(setterName);

        Method method = class_getInstanceMethod(class, setterSelector);
        IMP originalImp = method_getImplementation(method);

#define IMP_BLOCK_WITH_ARG_TYPE(argumentType)\
    ^id(id self, argumentType arg) {\
        NSLog(@"changing %s", property_getName(property));\
        ((void(*)(id, SEL, argumentType))originalImp)(self, setterSelector, arg);\
        return nil;\
    };

        // 0 - self, 1 - _cmd
        char *argumentEncoding = method_copyArgumentType(method, 2);

#define IS_ENCODED_TYPE(type)\
    (0 == strcmp(argumentEncoding, @encode(type)))

        id block = nil;

#define CHECK_TYPE(type)\
    if (nil == block && IS_ENCODED_TYPE(type)) {\
        block = IMP_BLOCK_WITH_ARG_TYPE(type);\
    }

        CHECK_TYPE(id)
        CHECK_TYPE(NSUInteger)
        CHECK_TYPE(NSInteger)
        CHECK_TYPE(CGFloat)
        CHECK_TYPE(double)
        CHECK_TYPE(BOOL)
        CHECK_TYPE(CGRect)
        CHECK_TYPE(CGSize)
        CHECK_TYPE(CGPoint)
        CHECK_TYPE(NSRange)

        if (nil != block) {
            IMP newImp = imp_implementationWithBlock(block);

            method_setImplementation(method, newImp);
        } else {
            NSLog(@"unknown type encoding: %s", argumentEncoding);
        }
    }
    free(properties);
}

