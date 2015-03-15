//
//  HomePageCollectionViewController.h
//  WhereTheRecipeAt
//
//  Created by Bruce Li on 2015-03-14.
//  Copyright (c) 2015 Bruce Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeObject.h"

@interface HomePageCollectionViewController : UICollectionViewController <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) NSArray *allResults;

@end
