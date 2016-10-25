//
//  NSObjectAdditions.m
//  Test
//
//  Created by justdoit on 12-12-6.
//  Copyright (c) 2012年 tan. All rights reserved.
//

#import "NSObjectAdditions.h"

@implementation NSObject (NSObjectAdditions)

// called by a non meta class object
// contain the methods statically synthesized by property, contain + and - methods
// but not contain super class's methods
+ (void)printMethods
{
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList([self class], &methodCount);
    char *pStr;
    
    @autoreleasepool {
        NSLog(@"class:%s", class_getName(self));
        
        // instance method
        for(int i = 0; i < methodCount; i++)
        {
            NSMutableString *outputString = [[NSMutableString alloc] initWithFormat:@"Method No #%d:-", i];
            
            pStr = method_copyReturnType(methodList[i]);
            [outputString appendString:[NSString stringWithFormat:@"(%s)", pStr]];
            free(pStr);
            
            NSArray *arguNameArray = [[NSString stringWithCString:sel_getName(method_getName(methodList[i])) encoding:NSUTF8StringEncoding] componentsSeparatedByString:@":"];
            
            int arguCount = method_getNumberOfArguments(methodList[i]);
            
            if (arguCount > 2) {
                for (int j = 2; j < arguCount; j++) {
                    [outputString appendString:[arguNameArray objectAtIndex:j - 2]];
                    
                    pStr = method_copyArgumentType(methodList[i], j);
                    [outputString appendString:[NSString stringWithFormat:@":(%s) ", pStr]];
                    free(pStr);
                }
            }
            else {
                [outputString appendString:[arguNameArray objectAtIndex:0]];
            }
            
            NSLog(@"%@", outputString);
            
            [outputString release];
        }
        
        free(methodList);
        
        // class method
        methodList = class_copyMethodList(object_getClass([self class]), &methodCount);
        
        for(int i = 0; i < methodCount; i++)
        {
            NSMutableString *outputString = [[NSMutableString alloc] initWithFormat:@"Method No #%d:+", i];
            
            pStr = method_copyReturnType(methodList[i]);
            [outputString appendString:[NSString stringWithFormat:@"(%s)", pStr]];
            free(pStr);
            
            NSArray *arguNameArray = [[NSString stringWithCString:sel_getName(method_getName(methodList[i])) encoding:NSUTF8StringEncoding] componentsSeparatedByString:@":"];
            
            int arguCount = method_getNumberOfArguments(methodList[i]);
            
            if (arguCount > 2) {
                for (int j = 2; j < arguCount; j++) {
                    [outputString appendString:[arguNameArray objectAtIndex:j - 2]];
                    
                    pStr = method_copyArgumentType(methodList[i], j);
                    [outputString appendString:[NSString stringWithFormat:@":(%s) ", pStr]];
                    free(pStr);
                }
            }
            else {
                [outputString appendString:[arguNameArray objectAtIndex:0]];
            }
            
            NSLog(@"%@", outputString);
            
            [outputString release];
        }
        
        free(methodList);
    }
}

// include all instance variables (self, super, implicitly add by property), but not support expanding nested types (for example: structure, array, union)
- (void)printVariables
{
    Class class = [self class];
    NSMutableString *outputString = [[NSMutableString alloc] initWithFormat:@"<%s:%p> = {\n", object_getClassName(self), self];
    
    while (class != NULL) {
        unsigned int numberOfIvars = 0;
        Ivar *ivars = class_copyIvarList(class, &numberOfIvars);
        for(Ivar *p = ivars; p < ivars + numberOfIvars; p++){
            Ivar ivar = *p;
            const char *name = ivar_getName(ivar);
            [outputString appendFormat:@"%s(%s) = %@;\n", name, ivar_getTypeEncoding(ivar), [self getIVarDescription:ivar]];
        }
        free(ivars);
        class = class_getSuperclass(class);
    }
    
    [outputString appendString:@"}"];
    
    NSLog(@"%@", outputString);
    
    [outputString release];
}

- (NSString *)getIVarDescription:(Ivar)ivar
{
    const char *type = ivar_getTypeEncoding(ivar);
    char *pValue = (char *)self + ivar_getOffset(ivar);
    
    switch(*type) {
        case '#':
            if (!(*(id *)pValue)) {
                return @"<null_class>";
            }
            else
            {
                return [NSString stringWithFormat:@"<%@>", (*(id *)pValue)];
            }
            break;
        case '@':
            if (!(*(id *)pValue)) {
                return @"<null_object>";
            }
            else
            {
                return [NSString stringWithFormat:@"%@", (*(id *)pValue)];
            }
            break;
        case ':':
            return [NSString stringWithFormat:@"%s", sel_getName(*(SEL *)pValue)];
            break;
        case 'B':
        case 'c':
        case 'C':
        case 'v':
            return [NSString stringWithFormat:@"%d", *((char *)pValue)];
            break;
        case 's':
        case 'S':
            return [NSString stringWithFormat:@"%d", *((short *)pValue)];
            break;
        case 'i':
            return [NSString stringWithFormat:@"%d", *((int *)pValue)];
            break;
        case 'I':
            return [NSString stringWithFormat:@"%u", *((unsigned int *)pValue)];
            break;
        case 'l':
            return [NSString stringWithFormat:@"%ld", *((long *)pValue)];
            break;
        case 'L':
            return [NSString stringWithFormat:@"%lu", *((unsigned long *)pValue)];
            break;
        case 'q':
            return [NSString stringWithFormat:@"%lld", *((long long int *)pValue)];
            break;
        case 'Q':
            return [NSString stringWithFormat:@"%llu", *((unsigned long long int *)pValue)];
            break;
        case 'f':
            return [NSString stringWithFormat:@"%f", *((float *)pValue)];
            break;
        case 'd':
            return [NSString stringWithFormat:@"%f", *((double *)pValue)];
            break;
        case 'D':
            return [NSString stringWithFormat:@"%Lf", *((long double *)pValue)];
            break;
        case '*':
            return [NSString stringWithFormat:@"%s", *((char **)pValue)];
            break;
        case '^':
        case '[':
        case '(':
        case '?':
            return [NSString stringWithFormat:@"%p", pValue];
            break;
        case '{':
        {
            char *pEqualChar = strchr(type, '=');
            if (pEqualChar != NULL) {
                char structType[64] = {0};
                strncpy(structType, type + 1, pEqualChar - (type + 1));
                
                if (strcmp(structType, "CGPoint") == 0 || strcmp(structType, "CGSize") == 0) {
                    return [NSString stringWithFormat:@"{%f, %f}", *((float *)pValue), *((float *)pValue + 1)];
                }
                else if (strcmp(structType, "CGRect") == 0) {
                    return [NSString stringWithFormat:@"{{%f, %f}, {%f, %f}}", *((float *)pValue), *((float *)pValue + 1), *((float *)pValue + 2), *((float *)pValue + 3)];
                }
                else if (strcmp(structType, "NSRange") == 0) {
                    return [NSString stringWithFormat:@"{%u, %u}", *((unsigned int *)pValue), *((unsigned int *)pValue + 1)];
                }
                else if (strcmp(structType, "UIEdgeInsets") == 0) {
                    return [NSString stringWithFormat:@"{%f, %f, %f, %f}", *((float *)pValue), *((float *)pValue + 1), *((float *)pValue + 2), *((float *)pValue + 3)];
                }
                else {
                    return [NSString stringWithFormat:@"%p", pValue];
                }
            }
            break;
        }
        default:
        {
            return [NSString stringWithFormat:@"%p", pValue];
            break;
        }
    }
    
    return nil;
}

+ (void)printPropertysDefine
{
    Class class = [self class];
    NSMutableString *outputString = [[NSMutableString alloc] initWithFormat:@"<%s:%p> = {\n", object_getClassName(self), self];
    
    while (class != NULL) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(class, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            
            [outputString appendFormat:@"%s : %s\n", property_getName(property), property_getAttributes(property)];
        }
        class = class_getSuperclass(class);
    }
    
    [outputString appendString:@"}"];
    
    NSLog(@"%@", outputString);
}

- (void)printPropertys
{
    Class class = [self class];
    NSMutableString *outputString = [[NSMutableString alloc] initWithFormat:@"<%s:%p> = {\n", object_getClassName(self), self];
    
    while (class != NULL) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(class, &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            const char *propertyAttributes = property_getAttributes(property);
            
            const char *ivarName = NULL;
            for (long j = strlen(propertyAttributes) - 1; j >= 0; j--) {
                if (propertyAttributes[j] == ',') {
                    ivarName = propertyAttributes + j + 2;
                    break ;
                }
            }
            
            Ivar ivar = class_getInstanceVariable([self class], ivarName);
            if (ivar) {
                [outputString appendFormat:@"%s(%s) = %@;\n", propertyName, ivar_getTypeEncoding(ivar), [self getIVarDescription:ivar]];
            }
        }
        class = class_getSuperclass(class);
    }
    
    [outputString appendString:@"}"];
    
    NSLog(@"%@", outputString);
}

// parameters and return value must be object types, extended for supporting more than two parameters
- (id)performSelector:(SEL)aSelector withObjects:(NSArray *)objects {
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    
    NSUInteger i = 2;
    for (id object in objects) {
        [invocation setArgument:&object atIndex:i++];
    }
    
    [invocation invoke];
    
    if ([signature methodReturnLength]) {
        id data;
        [invocation getReturnValue:&data];
        return data;
    }
    return nil;
}

// need release or autorelease
- (id)shallowCopy
{
    return object_copy(self, 0);
}

// need release or autorelease
- (id)deepCopy
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [(UIView *)[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
}

// only compare self's instance variables, include all instance variables (self, super, implicitly add by property)
- (BOOL)isEqualTo:(id)object
{
    if (!object)
        return NO;
    
    if (![self isMemberOfClass:[object class]])
        return NO;
    
    if (self == object)
        return YES;
    
    Class class = [self class];
    while (class != [NSObject class]) {
        unsigned int numberOfIvars = 0;
        Ivar *ivars = class_copyIvarList(class, &numberOfIvars);
        for(Ivar *p = ivars; p < ivars + numberOfIvars; p++){
            Ivar ivar = *p;
            const char *type = ivar_getTypeEncoding(ivar);
            switch (type[0])
            {
                case _C_ID:
                {
                    id selfMember = object_getIvar(self, ivar);
                    id otherMember = object_getIvar(object, ivar);
                    
                    if ((!selfMember && otherMember) || (selfMember && !otherMember))
                        return NO;
                    if (selfMember == nil && otherMember == nil)
                        break;
                    if (![selfMember isEqual:otherMember])
                        return NO;
                }
                    break;
                default:
                {
                    NSUInteger typeSize = 0;
                    NSGetSizeAndAlignment(type, &typeSize, NULL);
                    if (memcmp((char *)self + ivar_getOffset(ivar), (char *)object + ivar_getOffset(ivar), typeSize) != 0)
                        return NO;
                }
                    break;
            }
        }
        free(ivars);
        class = class_getSuperclass(class);
    }
    
    return YES;
}

- (Class)metaClass
{
    return objc_getMetaClass(class_getName([self class]));
}

+ (Class)metaClass
{
    return objc_getMetaClass(class_getName([self class]));
}

// total size, include all instance variables (self, super, implicitly add by property). NSGetSizeAndAlignment through @encode() only contain self.
- (NSUInteger)instanceSize
{
    return class_getInstanceSize([self class]);
}

+ (NSUInteger)instanceSize
{
    return class_getInstanceSize([self class]);
}

// support read and write for all types through a c string, return the instance variable address. object_getIvar and object_getInstanceVariable can only get the four bytes value, the set functions also like this
- (void *)instanceVariable:(const char *)name
{
    Ivar ivar = class_getInstanceVariable([self class], name);
    if (ivar) {
        return (char *)self + ivar_getOffset(ivar);
    }
    return NULL;
}

// extend a class's instance variable that doesn't need inherit, i think that when an object deallocated run time calls objc_removeAssociatedObjects to make it dissociative
- (void)setAssociatedObjectWithKey:(void *)key value:(id)value policy:(objc_AssociationPolicy)policy
{
    objc_setAssociatedObject(self, key, value, policy);
}

- (id)getAssociatedObjectWithKey:(void *)key
{
    return objc_getAssociatedObject(self, key);
}

- (void)removeAssociatedObjectWithKey:(void *)key
{
    objc_setAssociatedObject(self, key, nil, 0);
}

// add a method to class object or meta class object
+ (void)addInstanceMethodWithSelector:(SEL)selector imp:(IMP)imp typeEncoding:(char *)typeEncoding
{
    if(!class_addMethod(self, selector, imp, typeEncoding))
    {
        Method origMethod = class_getInstanceMethod(self, selector);
        method_setImplementation(origMethod, imp);
    }
}

+ (void)addInstanceMethodWithSelector:(SEL)selector block:(void(^)(void))block
{
    IMP imp = imp_implementationWithBlock(block);
    if(!class_addMethod(self, selector, imp, "v@:"))
    {
        Method origMethod = class_getInstanceMethod(self, selector);
        method_setImplementation(origMethod, imp);
    }
}

// add a method to meta class object
+ (void)addClassMethodWithSelector:(SEL)selector imp:(IMP)imp typeEncoding:(char *)typeEncoding
{
    if(!class_addMethod(self, selector, imp, typeEncoding))
    {
        Method origMethod = class_getClassMethod(self, selector);
        method_setImplementation(origMethod, imp);
    }
}

+ (void)addClassMethodWithSelector:(SEL)selector block:(void(^)(void))block
{
    IMP imp = imp_implementationWithBlock(block);
    if(!class_addMethod(self, selector, imp, "v@:"))
    {
        Method origMethod = class_getClassMethod(self, selector);
        method_setImplementation(origMethod, imp);
    }
}

// method swizzle, switch implementation within two methods
+ (void)swizzleInstanceMethod:(SEL)selector otherMethod:(SEL)otherSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, selector);
    Method otherMethod = class_getInstanceMethod(class, otherSelector);
    
    if (class_addMethod(class, selector, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod)))
    {
        class_replaceMethod(class, otherSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, otherMethod);
    }
}

+ (void)swizzleClassMethod:(SEL)selector otherMethod:(SEL)otherSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getClassMethod(class, selector);
    Method otherMethod = class_getClassMethod(class, otherSelector);
    
//    if (class_addMethod(class, selector, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod)))
//    {
//        class_replaceMethod(class, otherSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//    }
//    else
//    {
    method_exchangeImplementations(originalMethod, otherMethod);
//    }
}

@end
