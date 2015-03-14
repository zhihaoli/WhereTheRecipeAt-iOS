//
//  RecipeCollectionViewCell.h
//  WhereTheRecipeAt
//
//  Created by Bruce Li on 2015-03-14.
//  Copyright (c) 2015 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeObject.h"

@interface RecipeCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) RecipeObject *recipeData;
@property (strong, nonatomic) UIImage *thumbPhoto;
@property (strong, nonatomic) NSString *recipeName;

@end
