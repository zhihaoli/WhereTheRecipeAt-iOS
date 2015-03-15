//
//  RecipePageViewController.h
//  WhereTheRecipeAt
//
//  Created by Bruce Li on 2015-03-15.
//  Copyright (c) 2015 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipePageViewController : UIPageViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *details;
@property (strong, nonatomic) NSArray *ingredients;
@property (strong, nonatomic) NSMutableArray *otherInfo;

@end
