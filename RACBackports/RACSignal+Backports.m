#import "RACSignal+Backports.h"


@implementation RACSignal (Backports)

#pragma mark - Abandoned 3.0 branch backports

// This is a slightly modified version of RAC's -shareWhileActive
// See https://github.com/ReactiveCocoa/ReactiveCocoa/issues/1433
- (RACSignal *)shareWhileActive {
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    lock.name = @"com.github.ReactiveCocoa.shareWhileActive";

    // These should only be used while `lock` is held.
    __block NSUInteger subscriberCount = 0;
    __block RACDisposable *underlyingDisposable = nil;
    __block RACReplaySubject *inflightSubscription = nil;

    return [[RACSignal
             createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                 __block RACSignal*     signal     = nil;
                 __block RACDisposable* disposable = nil;

                 [lock lock];
                 @onExit {
                     [lock unlock];
                     disposable = [signal subscribe:subscriber];
                 };

                 if (subscriberCount++ == 0) {
                     // We're the first subscriber, so create the underlying
                     // subscription.
                     inflightSubscription = [RACReplaySubject subject];
                     underlyingDisposable = [self subscribe:inflightSubscription];
                 }

                 signal = inflightSubscription;

                 return [RACDisposable disposableWithBlock:^{
                     [disposable dispose];

                     [lock lock];
                     @onExit {
                         [lock unlock];
                     };

                     NSCAssert(subscriberCount > 0, @"Mismatched decrement of subscriberCount (%lu)", (unsigned long)subscriberCount);
                     if (--subscriberCount == 0) {
                         // We're the last subscriber, so dispose of the
                         // underlying subscription.
                         [underlyingDisposable dispose];
                         underlyingDisposable = nil;

                         // Also, release the inflightSubscription, since
                         // we won't need its stored values any longer.
                         inflightSubscription = nil;
                     }
                 }];
             }]
            setNameWithFormat:@"[%@] -shareWhileActive", self.name];
}

- (RACSignal *)doDisposed:(void (^)(void))block {
    NSCParameterAssert(block != NULL);

    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        RACCompoundDisposable *disposable = [RACCompoundDisposable compoundDisposable];

        [disposable addDisposable:[RACDisposable disposableWithBlock:block]];
        [disposable addDisposable:[self subscribe:subscriber]];
        
        return disposable;
    }] setNameWithFormat:@"[%@] -doDisposed:", self.name];
}

@end
