//
// Created by Alexey Storozhev on 25.02.14.
// Copyright (c) 2014 e-Legion. All rights reserved.
//
#import "utilities.h"
#import <objc/message.h>

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

        char *readonlyFlag = property_copyAttributeValue(property, "R");
        if (NULL != readonlyFlag) {
            free(readonlyFlag);
            continue;
        }

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

#undef CHECK_TYPE
#undef IS_ENCODED_TYPE
#undef IMP_BLOCK_WITH_ARG_TYPE

        if (nil != block) {
            IMP newImp = imp_implementationWithBlock(block);

            method_setImplementation(method, newImp);
        } else {
            NSLog(@"unknown type encoding: %s", argumentEncoding);
        }

        free(argumentEncoding);
    }
    free(properties);
}

void observeClassPropertyChanges2(Class class)
{
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(class, &propertyCount);

    NSMutableSet *capturedSelectorsSet = [NSMutableSet set];

    for (unsigned int i=0; i<propertyCount; i++) {
        objc_property_t property = properties[i];

        char *readonlyFlag = property_copyAttributeValue(property, "R");
        if (NULL != readonlyFlag) {
            free(readonlyFlag);
            continue;
        }

        NSString *setterName = property_getSetterName(property);
        SEL setterSelector = NSSelectorFromString(setterName);

        [capturedSelectorsSet addObject:setterName];

        Method method = class_getInstanceMethod(class, setterSelector);

        IMP originalImp = method_setImplementation(method, _objc_msgForward);

        NSString *internalSetterName = [setterName stringByAppendingString:@"_internal"];
        SEL internalSelector = NSSelectorFromString(internalSetterName);
        char const *types = method_getTypeEncoding(method);
        class_addMethod(class, internalSelector, originalImp, types);
    }
    free(properties);

    Method forwardInvocationMethod = class_getInstanceMethod(class, @selector(forwardInvocation:));
    IMP originalForwardInvocationImp = method_getImplementation(forwardInvocationMethod);
    void(^block)(id, NSInvocation *) = ^void(id self, NSInvocation *invocation) {
        NSString *selectorName = NSStringFromSelector([invocation selector]);

        if ([capturedSelectorsSet containsObject:selectorName]) {
            NSString *internalSelectorName = [selectorName stringByAppendingString:@"_internal"];
            [invocation setSelector:NSSelectorFromString(internalSelectorName)];
            [invocation invoke];
        } else {
            ((void(*)(id, SEL, NSInvocation *))originalForwardInvocationImp)(self, @selector(forwardInvocation:), invocation);
        }
    };

    method_setImplementation(forwardInvocationMethod, imp_implementationWithBlock(block));
}

#define METHOD_SWIZZLE1_IMPL(type)\
METHOD_SWIZZLE1_DECLARATION(type)\
{\
    SEL selector = method_getName(method);\
\
    IMP originalImp = method_getImplementation(method);\
\
    id(^newImpBlock)(id, type) = ^(id self, type arg) {\
        if (before) {\
            before(self, selector, arg);\
        }\
\
        id result = ((id(*)(id, SEL, type))originalImp)(self, selector, arg);\
\
        if (after) {\
            after(self, selector, arg);\
        }\
        return result;\
    };\
\
    IMP newImp = imp_implementationWithBlock(newImpBlock);\
\
    method_setImplementation(method, newImp);\
}

METHOD_SWIZZLE1_IMPL(id)