//
//  RecipeObject.h
//  WhereTheRecipeAt
//
//  Created by Bruce Li on 2015-03-14.
//  Copyright (c) 2015 Bruce Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RecipeDetails.h"



@interface RecipeObject : NSObject

@property (strong, nonatomic) NSArray *ingredients;
@property (strong, nonatomic) NSString *recipeId;
@property (strong, nonatomic) NSString *cookingMethod;
@property (strong, nonatomic) NSString *imageFullURL;
@property (strong, nonatomic) NSString *imageThumbURL;
@property (strong, nonatomic) UIImage *imageFull;
@property (strong, nonatomic) UIImage *imageThumb;
@property (strong, nonatomic) NSString *cuisine;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *recipeURL;
@property (strong, nonatomic) RecipeDetails *recipeDetails;

@end
