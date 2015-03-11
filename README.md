# WSFiltersView

To start using the WSPhotoFiltersView, you just need three lines of code: 

    WSPhotoFiltersView *view = [WSPhotoFiltersView getNewPhotoFiltersView];
    [view applyFiltersToRawPhoto:image withImageViewContentMode:contentMode];
    [view loadViewAnimatedOnView:superView withAnimationImage:image];

and all the other stuff is taken care for you. 

There's also a animation transition when loading/dismissing the WSPhotoFiltersView, which I hope would make the interface more intuitive and easier to use.
