//
//  WSPhotoFiltersView.m
//  Wasup
//
//  Created by Peng Fuyuzhen on 12/4/14.
//  Copyright (c) 2014 Chatty, Inc. All rights reserved.
//

#import "WSPhotoFiltersView.h"
#import "WSPhotoFilterOperation.h"

@implementation WSPhotoFiltersView {
    float scaleFactor;
    float imageViewWidth;
    float imageViewHeight;
    NSInteger startingPageIndex;
    NSMutableArray *scrollViewRects;
    UIViewContentMode contentMode;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        scaleFactor = [UIScreen mainScreen].scale;
        startingPageIndex = 0;

        // Set up title Label
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 40)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        titleLabel.text = @"Apply Filters";
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        // Set up cancel Button
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton addTarget:self action:@selector(dismissViewAnimated) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(8, 22, 80, 40);
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:cancelButton];
        
        // Set up filters
        _filters = @[@"CIPhotoEffectInstant",
                     @"CIPhotoEffectTransfer",
                     @"CIPhotoEffectFade",
                     @"CIPhotoEffectChrome",
                     @"CIPhotoEffectMono"];
        
        _filterTitles = @[@"Normal",
                          @"Instant",
                          @"Transfer",
                          @"Fade",
                          @"Chrome",
                          @"Mono"];
        
        // Set up page control
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        [pageControl setBounds:CGRectMake(0, 0, 100, 30)];
        pageControl.center = CGPointMake(self.center.x, [UIScreen mainScreen].bounds.size.height - 20);
        pageControl.numberOfPages = self.filterTitles.count;
        pageControl.currentPage = 0;
        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1];
        pageControl.enabled = NO;
        [self addSubview:pageControl];
        _pageControl = pageControl;

        // Initialize scroll view
        UIScrollView *scrollView = [self getNewScrollView];
        [self addSubview:scrollView];
        
        [self setScrollView:scrollView withNumberOfPages:self.filterTitles.count];
        _scrollView = scrollView;
        _scrollView.delegate = self;
    }
    return self;
}

+ (WSPhotoFiltersView *) getNewPhotoFiltersView
{
    WSPhotoFiltersView *newView = [[WSPhotoFiltersView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    newView.backgroundColor = [UIColor colorWithRed:18/255.0 green:18/255.0 blue:18/255.0 alpha:1];
    return newView;
}

- (UIScrollView *) getNewScrollView
{
    CGRect screen = [UIScreen mainScreen].bounds;
    float width = screen.size.width *0.74;
    float ratio = screen.size.height / screen.size.width;
    float height = width *ratio;
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    scrollView.center = CGPointMake(screen.size.width /2.0, screen.size.height /2.0);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = YES;
    scrollView.alwaysBounceVertical = NO;
    scrollView.clipsToBounds = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.multipleTouchEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [scrollView addGestureRecognizer:tap];
    self.tap = tap;
    
    return scrollView;
}

- (void) applyFiltersToRawPhoto: (UIImage *) rawPhoto withImageViewContentMode: (UIViewContentMode) imageViewContentMode
{
    contentMode = imageViewContentMode;
    
    // Original photo comes first
    UIImageView *firstImageView = self.imageViews.firstObject;
    firstImageView.contentMode = contentMode;
    firstImageView.image = rawPhoto;
    
    for (int i = 1; i < self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        imageView.contentMode = contentMode;
        imageView.alpha = 0;
    }
    
    // Deploy operations on queue concurrently
    NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
    operationQueue.maxConcurrentOperationCount = self.filters.count;

    for (int i = 0; i < self.filters.count; i++) {
        WSPhotoFilterOperation *operation = [WSPhotoFilterOperation initWithImage:rawPhoto filterName:self.filters[i] andImageView:self.imageViews[i+1]];
        [operationQueue addOperation:operation];
    }
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    self.pageControl.currentPage = 0;
}

- (void) setScrollView:(UIScrollView *)scrollView withNumberOfPages: (NSInteger) pages
{
    float scrollViewWidth = scrollView.frame.size.width;
    float scrollViewHeight = scrollView.frame.size.height;
    imageViewWidth = scrollViewWidth *0.86;
    imageViewHeight = scrollViewHeight *0.86;
    CGPoint center = CGPointMake(scrollViewWidth /2.0, scrollViewHeight /2.0);
    self.imageViews = [[NSMutableArray alloc]init];
    scrollViewRects = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < pages; i++)
    {
        // Add imageView to scroll view
        UIView *container = [[UIView alloc]initWithFrame:CGRectMake(scrollViewWidth *i, 0, scrollViewWidth, scrollViewHeight)];
        [scrollViewRects addObject:NSStringFromCGRect(container.frame)];
        container.backgroundColor = [UIColor clearColor];
        container.clipsToBounds = NO;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewHeight)];
        imageView.center = center;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor clearColor];
        [container addSubview:imageView];
        [self.imageViews addObject:imageView];
        [container addSubview:[self getFilterTitleLabelWithName:self.filterTitles[i] andContainerRect:container.frame]];
        [scrollView addSubview:container];
    }
    // Set scroll view content size
    [scrollView setContentSize:CGSizeMake(scrollViewWidth *pages, scrollViewHeight)];
}

- (UILabel *) getFilterTitleLabelWithName: (NSString *)name andContainerRect: (CGRect) containerRect
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, containerRect.size.height- 10, containerRect.size.width, 20)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    label.text = name;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (void) loadViewAnimatedOnView: (UIView *) view withAnimationImage: (UIImage *)image
{
    [view addSubview:self];
    self.scrollView.userInteractionEnabled = NO;
    
    __block UIImageView *tempImageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    tempImageView.contentMode = contentMode;
    tempImageView.image = image;
    tempImageView.clipsToBounds = YES;
    tempImageView.backgroundColor = self.backgroundColor;
    [view addSubview:tempImageView];
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:4 options:UIViewAnimationOptionCurveEaseInOut animations:^
    {
        tempImageView.bounds = CGRectMake(0, 0, imageViewWidth, imageViewHeight);
        tempImageView.center = self.scrollView.center;
    }
    completion:^(BOOL finished)
    {
        [tempImageView removeFromSuperview];
        tempImageView = nil;
        self.scrollView.userInteractionEnabled = YES;
    }];
    startingPageIndex = self.scrollView.contentOffset.x / (int)self.scrollView.frame.size.width;
}

- (void) dismissViewAnimated
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alpha = 1;
        [self.scrollView scrollRectToVisible:CGRectFromString(scrollViewRects[startingPageIndex]) animated:NO];
    }];
}

- (void) handleTap: (UITapGestureRecognizer *) sender
{
    // prevent multiple taps at the same time
    sender.enabled = NO;
    
    int pageIndex = self.scrollView.contentOffset.x / (int)self.scrollView.frame.size.width;
    UIImageView *imageView = self.imageViews[pageIndex];
    
    // dismiss view animation
    __block UIImageView *tempImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewHeight)];
    tempImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width /2.0, [UIScreen mainScreen].bounds.size.height /2.0);
    tempImageView.contentMode = contentMode;
    tempImageView.image = imageView.image;
    tempImageView.clipsToBounds = YES;
    tempImageView.backgroundColor = self.backgroundColor;
    [self addSubview:tempImageView];
    
    [UIView animateWithDuration:0.24 delay:0 usingSpringWithDamping:1 initialSpringVelocity:4 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        tempImageView.frame = [UIScreen mainScreen].bounds;
    } completion:^(BOOL finished) {
        [self.delegate didChooseFilteredImage:imageView.image];
        
        [UIView animateWithDuration:0.16 delay:0.02 options:UIViewAnimationOptionCurveEaseIn animations:^ {
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [tempImageView removeFromSuperview];
            tempImageView = nil;
            sender.enabled = YES;
            self.alpha = 1;
        }];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page; 
}

@end
