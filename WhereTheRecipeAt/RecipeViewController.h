//
//  RecipeViewController.h
//  WhereTheRecipeAt
//
//  Created by Bruce Li on 2015-03-15.
//  Copyright (c) 2015 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;


@property NSString *detail;


@property NSUInteger pageIndex;

@end
