//
//  AQInnerClassTests.m
//  AQInnerClassTests
//
//  Created by Jim Dovey on 12-06-22.
//  Copyright (c) 2012 Jim Dovey. All rights reserved.
//

#import "AQInnerClassTests.h"
#import <AQInnerClass/AQInnerClass.h>

static int __array[10] = {0,1,2,3,4,5,6,7,8,9};

@implementation AQInnerClassTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    __block BOOL testOneCalled = NO, testTwoCalled = NO;
    Class innerClass = InnerClass([NSArray class], @selector(count), ^NSUInteger(id array){
        testOneCalled = YES;
        return ( sizeof(__array)/sizeof(int) );
    }, @selector(objectAtIndex:), ^id(NSArray * array, NSUInteger index){
        testTwoCalled = YES;
        return ( [NSNumber numberWithInt:__array[index]] );
    }, @selector(objectEnumerator), ^NSEnumerator*(NSArray * array){
        NSLog(@"I can still access my creator by using 'self', see! -- %@", self);
        __block NSUInteger enumeratorIndex = 0;
        Class enumeratorClass = AQCreateInnerClass(class_getName([array class]), sel_getName(@selector(objectEnumerator)), [NSEnumerator class], @selector(nextObject), ^id(id enumerator){
            if ( enumeratorIndex >= [array count] )
                return ( nil );
            return ( [array objectAtIndex: enumeratorIndex++] );
        }, nil);
        
        return ( [[enumeratorClass alloc] init] );
    }, nil);
    
    NSArray * specialArray = [[innerClass alloc] init];
    STAssertEquals([specialArray count], (NSUInteger)10, @"Expected %@ to have a count of 10, but got %lu", specialArray, [specialArray count]);
    STAssertEquals(testOneCalled, YES, @"Expected our custom -count method to be called!");
    
    // we implement the required primitives for NSArray in our inner class, so this should work
    [specialArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber * num = [[NSNumber alloc] initWithUnsignedInteger: idx];
        STAssertEqualObjects(obj, num, @"Expected -objectAtIndex: %lu to return %@, got %@", idx, num, obj);
    }];
    STAssertEquals(testTwoCalled, YES, @"Expected our custom -objectAtIndex: method to be called!");
    
    NSEnumerator * enumerator = [specialArray objectEnumerator];
    id first = [enumerator nextObject];
    STAssertEqualObjects(first, @0, @"Expected first object from enumerator %@ to be %@, but got %@", enumerator, @0, first);
    
    id second = [enumerator nextObject];
    STAssertEqualObjects(second, @1, @"Expected second object from enumerator %@ to be %@, but got %@", enumerator, @1, second);
    
    NSArray * remaining = [enumerator allObjects];
    NSUInteger remainingCount = [remaining count];
    STAssertEquals(remainingCount, (NSUInteger)8, @"Expect to have 8 objects in remaining array from enumerator, but got %lu instead", remainingCount);
    
    [remaining enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber * num = [[NSNumber alloc] initWithUnsignedInteger: idx+2];
        STAssertEqualObjects(obj, num, @"Expected -objectAtIndex: %lu on remainder array to return %@, got %@", idx, num, obj);
    }];
}

@end
