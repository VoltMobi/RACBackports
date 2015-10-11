#import <ReactiveCocoa/ReactiveCocoa.h>


@interface RACSignal (Backports)

- (RACSignal *)shareWhileActive;
- (RACSignal *)doDisposed:(void (^)(void))block;

@end
