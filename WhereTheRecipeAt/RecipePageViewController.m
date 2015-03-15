//
//  RecipePageViewController.m
//  WhereTheRecipeAt
//
//  Created by Bruce Li on 2015-03-15.
//  Copyright (c) 2015 Bruce Li. All rights reserved.
//

#import "RecipePageViewController.h"
#import "RecipeViewController.h"

@interface RecipePageViewController ()

@end

@implementation RecipePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    //[self setUpPageViews];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageViewController.dataSource = self;
    [[self.pageViewController view] setFrame:[[self view] bounds]];
    
    RecipeViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [[self view] addSubview:[self.pageViewController view]];
    [self.pageViewController didMoveToParentViewController:self];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)setUpPageViews
{
    //navigation style
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    
    
    RecipeViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((RecipeViewController *) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)){
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((RecipeViewController *) viewController).pageIndex;
    index++;
    if (index == [self.details count]){
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (RecipeViewController *)viewControllerAtIndex:(NSUInteger) index{
    
    if (([self.details count] == 0) || (index >= [self.details count])){
        return nil;
    }
    
    RecipeViewController *rVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RecipeViewController"];
  
    rVC.detail = self.details[index];

    rVC.pageIndex = index;
    
    return rVC;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return [self.details count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
