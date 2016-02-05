//
//  TCSSingleton.m
//  TCSiCore
//
//  Created by Andrey Ilskiy on 25/08/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSSingleton.h"
#include <string.h>
#include <objc/runtime.h>

static void swizzleMethods(Class selfClass, Class singletonClass, SEL originalSelector, SEL backupSelector);

static Method class_getCurrentClassMethod(Class class, SEL name);

@implementation TCSSingleton

static NSMutableDictionary* _children;

static Class recursionClass = NULL;

+ (void)initialize //thread-safe
{
    if (!_children) {
        _children = [[NSMutableDictionary alloc] init];
    }
    [_children setObject:[[self alloc] init] forKey:NSStringFromClass(self.class)];
}

+ (instancetype)alloc
{
    id child = [self instance];
    return child ? child : [self allocWithZone:nil];
}

- (instancetype)init
{
    Class cls = self.class;
    Class singletonClass = [TCSSingleton class];

    NSObject *result = _children[NSStringFromClass(cls)];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL const backupSelector = @selector(initBackup_tcs_);
#pragma clang diagnostic pop


    if (result == nil && cls != singletonClass)
    {
        Class superclass = recursionClass ? class_getSuperclass(recursionClass) : self.superclass;
        while (result == nil && superclass != singletonClass)
        {
            result = _children[NSStringFromClass(superclass)];
            if (result == nil)
            {
                superclass = class_getSuperclass(superclass);
            }
        }

        if (result)
        {
            SEL selector = backupSelector;

            if (superclass == singletonClass)
            {
                superclass = [NSObject class];
                selector = @selector(init);
            }

            id (*imp_func)(id, SEL) = (void *)method_getImplementation(class_getInstanceMethod(superclass, selector));

            recursionClass = superclass;
            self = imp_func(self, backupSelector);
            result = self;
        }
    }

    if (result == nil)
    {
        self = [super init];
        result = self;
        if (result && ![super isMemberOfClass:[NSObject class]] && ![self isMemberOfClass:singletonClass])
        {
            swizzleMethods(self.class, [TCSSingleton class], @selector(init), backupSelector);
        }

    }

    if (recursionClass)
    {
        recursionClass = NULL;
    }

    return (__typeof(self))result;
}

+ (instancetype)instance
{
    return [_children objectForKey:NSStringFromClass(self.class)];
}

+ (instancetype)defaultInstance
{
    return [self instance];
}

+ (instancetype)sharedInstance
{
    return [self instance];
}

+ (instancetype)singleton
{
    return [self instance];
}

+ (instancetype)new
{
    return [self instance];
}

+ (instancetype)copyWithZone:(NSZone *)zone
{
    return [self instance];
}

+ (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    return [self instance];
}

@end


#pragma mark -
#pragma mark - Utility Functions

void swizzleMethods(Class selfClass, Class singletonClass, SEL originalSelector, SEL backupSelector) {
    unsigned int classesCount = 2;
    Method *swizzledMethods = calloc(classesCount, sizeof(Method));
    {
        Class classes[2] = {selfClass, singletonClass};
        
        for (unsigned int i = 0; i < classesCount; i++) {
            swizzledMethods[i] = class_getCurrentClassMethod(classes[i], originalSelector);
        }
    }
    Method selfMethod = swizzledMethods[0];
    Method singletonMethod = swizzledMethods[1];
    
    free(swizzledMethods);
    swizzledMethods = NULL;
    
    IMP singletonMethodIMP = method_getImplementation(singletonMethod);
    const char * const singletonMethodTypeEncoding = method_getTypeEncoding(singletonMethod);
    IMP originalMethodIMP = method_getImplementation(selfMethod);
    if (selfMethod) {
        class_replaceMethod(selfClass, originalSelector, singletonMethodIMP, singletonMethodTypeEncoding);
        if (backupSelector != nil) {
            class_addMethod(selfClass, backupSelector, originalMethodIMP, method_getTypeEncoding(selfMethod));
        }
    }
}

Method class_getCurrentClassMethod(Class class, SEL name) {
    Method *methodList = NULL;
    unsigned int methodListCount = 0;
    
    methodList = class_copyMethodList(class, &methodListCount);
    assert(methodListCount > 0);
    unsigned int j = 0;
    for (; name != method_getName(methodList[j]) && j < methodListCount; j++);
    
    Method result = NULL;
    if (j < methodListCount) {
        result = methodList[j];
    }
    
    free(methodList);
    methodList = NULL;
    methodListCount = 0;
    
    return result;
}
