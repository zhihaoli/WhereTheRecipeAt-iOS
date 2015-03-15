//
//  HomePageCollectionViewController.m
//  WhereTheRecipeAt
//
//  Created by Bruce Li on 2015-03-14.
//  Copyright (c) 2015 Bruce Li. All rights reserved.
//

#import "HomePageCollectionViewController.h"
#import "RecipeCollectionViewCell.h"
#import "RecipePageViewController.h"

@interface HomePageCollectionViewController ()

@property (strong, nonatomic) NSMutableData * receivedRecipeData;
@property (strong, nonatomic) NSMutableArray *directions;

@end

@implementation HomePageCollectionViewController

static NSString * const reuseIdentifier = @"RecipeCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.directions = [[NSMutableArray alloc]init];
    
    
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
     
    
    NSLog(@"transfered data count: %d", [self.allResults count]);
    
    RecipeObject *obj = [self.allResults objectAtIndex:0];
    
    NSLog(@"recipe is: %@",obj.name);
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(250, 250)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated{
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.allResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecipeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecipeCell" forIndexPath:indexPath];
    
    // Configure the cell
    
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    RecipeObject *recipe = [self.allResults objectAtIndex:indexPath.row];

    UIImageView *recipeImage = (UIImageView *)[cell viewWithTag:1];
    UILabel *recipeLabel = (UILabel *)[cell viewWithTag:2];
    
    
    if (recipe.imageThumb == nil){
        recipeImage.image = [UIImage imageNamed:@"noImg"];
    }else{
        recipeImage.image = recipe.imageThumb;
    }
    
    recipeLabel.text = recipe.name;
    

    
    
    
    NSLog(@"DISPLAYING CELL %@", recipe.name);
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goToRecipe"]){
        NSLog(@"ABOUT TO SEGUE TO RECIPE OMG");
        
        RecipePageViewController *pageView = (RecipePageViewController *)[[segue destinationViewController] topViewController];
        
        pageView.details = self.directions;
        
    }
}

-(void) recipeDetailsParser:(NSDictionary *) results{
    
    NSLog(@"recipe results: %@", results);
    
    for (id key in [results allKeys]){
        if ([key isEqualToString:@"directions"]){
            
            self.directions = [results objectForKey:key];
            
            
            break;
        }
    }
    
    [self performSegueWithIdentifier:@"goToRecipe" sender:nil];
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"DID SELECT ITEM!");
    
    RecipeObject *object = [self.allResults objectAtIndex:[indexPath row]];
    
    //[self.directions addObject:object.ingredients];
    
    [self callAPIWithURL:object.recipeURL];
    
    
}


#pragma NSURLConnection Delegates


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self.receivedRecipeData = [[NSMutableData alloc] init];
    NSLog(@"in 2");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self.receivedRecipeData appendData:data];
    NSLog(@"in 2");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    NSLog(@"in 3");
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    NSLog(@"in 4");
    // You can parse the stuff in your instance variable now
    
    //NSLog(@"response is: %@", response);
    
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:self.receivedRecipeData
                 options:0
                 error:&error];
    
    NSDictionary *results = object;
    
    [self recipeDetailsParser:results];
}


- (void) callAPIWithURL: (NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request setValue:@"Agent name goes here" forHTTPHeaderField:@"User-Agent"];
    [NSURLConnection connectionWithRequest:request delegate:self];
}


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
