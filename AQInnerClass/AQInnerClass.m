//
//  AQInnerClass.m
//  AQInnerClass
//
//  Created by Jim Dovey on 12-06-22.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import "AQInnerClass.h"

NSString * const AQInnerClassNonexistentSuperclassSelectorException = @"NonexistentSuperclassSelector";

Class AQCreateInnerClass(const char *calleeClassName, const char * calleeSelName, Class superclass, SEL selector, id block, ...)
{
    Class innerClass = Nil;
    Class metaClass = Nil;
    
    NSString * className = [NSString stringWithFormat: @"%s_%s_%s_subclass_%lu", calleeClassName, calleeSelName, class_getName(superclass), time(NULL)];
    
    va_list args;
    va_start(args, block);
    
    @try
    {
        // create the inner class object
        innerClass = objc_allocateClassPair(superclass, [className UTF8String], 0);
        metaClass = object_getClass(innerClass);
        
        do
        {
            BOOL isClassMethod = NO;
            Method superMethod = class_getInstanceMethod(superclass, selector);
            if ( superMethod == NULL )
            {
                superMethod = class_getClassMethod(superclass, selector);
                if ( superMethod == NULL )
                {
                    [NSException raise: AQInnerClassNonexistentSuperclassSelectorException format: @"Selector %@ is not implemented as either an instance or class method of %@", NSStringFromSelector(selector), NSStringFromClass(superclass)];
                }
                
                isClassMethod = YES;
            }
            
            IMP imp = imp_implementationWithBlock(block);
            if ( imp == NULL )
            {
                [NSException raise:NSInternalInconsistencyException format:@"Failed to allocate IMP from a block!"];
            }
            
            if ( isClassMethod )
            {
                class_addMethod(metaClass, selector, imp, method_getTypeEncoding(superMethod));
            }
            else
            {
                class_addMethod(innerClass, selector, imp, method_getTypeEncoding(superMethod));
            }
            
            // get the next selector/block pair
            selector = va_arg(args, SEL);
            if ( selector == NULL )
                break;
            block = va_arg(args, id);
            if ( block == nil )
                break;
            
        } while (1);
    }
    @catch (id e)
    {
        // not going to use this class any more, so kill it
        if ( innerClass != Nil )
            objc_disposeClassPair(innerClass);
        @throw;
    }
    @finally
    {
        // properly let go of the arg list, even if we throw
        va_end(args);
    }
    
    // get the class ready for use
    objc_registerClassPair(innerClass);
    
    return ( innerClass );
}
