//
//  WSPhotoFilterOperation.m
//  Wasup
//
//  Created by Peng Fuyuzhen on 12/7/14.
//  Copyright (c) 2014 Chatty, Inc. All rights reserved.
//

#import "WSPhotoFilterOperation.h"

@implementation WSPhotoFilterOperation
{
    BOOL executing;
    BOOL finished;
}

- (id) init
{
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
    }
    return self;
}

- (BOOL) isAsynchronous
{
    return YES;
}

- (BOOL) isExecuting
{
    return executing;
}

- (BOOL) isFinished
{
    return finished;
}

+ (WSPhotoFilterOperation *) initWithImage: (UIImage *) image filterName: (NSString *) filterName andImageView: (UIImageView *)imageView
{
    WSPhotoFilterOperation *newOperation = [[WSPhotoFilterOperation alloc]init];
    newOperation.image = image;
    newOperation.filterName = filterName;
    newOperation.imageView = imageView;
    return newOperation;
}

- (void) start
{
    // Check for cancellation before start
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // Not cancelled, begin execution
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void) main
{
    @try
    {
        // Do the work
        NSData *imgData = UIImageJPEGRepresentation(self.image, 1);
        CIImage*rawImageData = [[CIImage alloc]initWithData:imgData];

        CIFilter *filter = [CIFilter filterWithName:self.filterName];
        [filter setDefaults];
        [filter setValue:rawImageData forKey:@"inputImage"];
        CIImage *filteredImageData = [filter valueForKey:@"outputImage"];
        
        CGImageRef imageRef = [[CIContext contextWithOptions:nil]
                           createCGImage:filteredImageData
                           fromRect:rawImageData.extent];
        UIImage *output = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:self.image.imageOrientation];
        self.imageView.image = output;
        self.imageView.alpha = 1;
        
        // Done
        [self completeOperation];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error adding filter %@ with exception: %@", self.filterName, exception);
    }
}

- (void) completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
