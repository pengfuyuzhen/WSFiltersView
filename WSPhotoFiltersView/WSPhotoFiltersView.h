//
//  WSPhotoFiltersView.h
//  Wasup
//
//  Created by Peng Fuyuzhen on 12/4/14.
//  Copyright (c) 2014 Chatty, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSPhotoFiltersViewDelegate <NSObject>
/*
 Called after users taps to select a filtered image. 
 This method should be used to update the original image view with the filteredImage.
 */
- (void) didChooseFilteredImage: (UIImage *) filteredImage;
@end

@interface WSPhotoFiltersView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) NSArray *filters;
@property (nonatomic, readonly) NSArray *filterTitles;
@property (nonatomic, strong)   UIScrollView *scrollView;
@property (nonatomic, strong)   UIPageControl *pageControl;
@property (nonatomic, strong)   NSMutableArray *imageViews;
@property (nonatomic, strong)   UITapGestureRecognizer *tap;
@property (nonatomic, weak)     id<WSPhotoFiltersViewDelegate>delegate;

+ (WSPhotoFiltersView *) getNewPhotoFiltersView;
- (void) applyFiltersToRawPhoto: (UIImage *) rawPhoto withImageViewContentMode: (UIViewContentMode) contentMode;
- (void) loadViewAnimatedOnView: (UIView *) view withAnimationImage: (UIImage *)image;
- (void) dismissViewAnimated;

@end
