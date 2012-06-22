//
//  AQInnerClass.h
//  AQInnerClass
//
//  Created by Jim Dovey on 12-06-22.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//
// Defining Ivars:
//   key = ivar name, as NSString
//   value = NSString containing @encode(type) of value
//
// Example:
//   @{
//       @"index" : _ENCODE(NSUInteger),
//       @"statInfo" : _ENCODE(struct stat)
//   };
//
// Ivar dictionary can be nil to specify no ivars
//

// helper for boxing @encode values
#if __has_feature(__objc_boxed_expressions)
# define _ENCODE(x) @(@encode(x))
#else
# define _ENCODE(x) [NSString stringWithUTF8String: @encode(x)]
#endif

// this will THROW if you specify a selector which isn't already a member of superclass
extern Class AQCreateInnerClass(const char *calleeClassName, const char * calleeSelName, Class superclass, SEL selector, id block, ...) NS_REQUIRES_NIL_TERMINATION;

extern NSString * const AQInnerClassNonexistentSuperclassSelectorException;

// handy variadic macros to add in the first two arguments for you
#define InnerClass(args...) AQCreateInnerClass(class_getName([self class]), sel_getName(_cmd), ## args)
#define CInnerClass(args...) AQCreateInnerClass("C", __FUNCTION__, ## args)

// nesting these things? Then you'll need 'self' and '_cmd' to exist. Here you go:
#define MAKE_OBJC_IMPLICITS(me, cmd) id self = me; SEL _cmd = @selector(cmd)
