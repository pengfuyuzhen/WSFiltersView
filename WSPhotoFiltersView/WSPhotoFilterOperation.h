//
//  WSPhotoFilterOperation.h
//  Wasup
//
//  Created by Peng Fuyuzhen on 12/7/14.
//  Copyright (c) 2014 Chatty, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WSPhotoFilterOperation : NSOperation

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) UIImageView *imageView;

+ (WSPhotoFilterOperation *) initWithImage: (UIImage *) image filterName: (NSString *) filterName andImageView: (UIImageView *)imageView;
@end
