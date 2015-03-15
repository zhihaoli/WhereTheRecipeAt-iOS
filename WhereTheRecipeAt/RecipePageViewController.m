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
    [self setUpData];
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

-(void) setUpData{

    //the text for each page of the tutorial
    self.details = @[@"Control your classroom with SmarTEST. Swipe to learn more!", @"Create and Manage Your Courses", @"Easily bring in your tests from your favorite service", @"Upload your class roster and manage your teams", @"Set up your classroom the way you like it", @"Take full control over the release of your questions", @"Tap on a team to bring up the list of group members", @"Statistics views show the results in a way that makes it easy to see trends", @"View your results team by team", @"When you're done, you can export your results as an Excel file"];
    
    self.titles = @[@"", @"Tip: Tapping edit allows you to rearrange and delete courses", @"Tip: Use the lock icon to control student access to tests", @"Tip: You can import your class list from a file or manually add or modify them by tapping edit then +", @"Tip: Once you have uploaded a classroom map, you can drag each teams' reporting flag to the correct location", @"Tip: You can control when to release the Application (open ended) Questions, and then lock them when you are done", @"Tip: The list will have a random team member highlighted so you can call on them to explain their choices", @"Tip: You can scroll down to see more detailed information about how teams have answered each question", @"Tip: Tapping on a circle will also bring up that question if you need a reminder", @"If you want to see this again, tap the Tutorial button at the bottom once you've create a course!"];
    
    

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
    if (index == [self.titles count]){
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (RecipeViewController *)viewControllerAtIndex:(NSUInteger) index{
    
    if (([self.titles count] == 0) || (index >= [self.titles count])){
        return nil;
    }
    
    RecipeViewController *rVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RecipeViewController"];
    rVC.title = self.titles[index];
    rVC.detail = self.details[index];

    rVC.pageIndex = index;
    
    return rVC;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return [self.titles count];
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
