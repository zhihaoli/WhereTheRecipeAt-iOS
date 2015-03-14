//
//  HomePageTableViewController.m
//  WhereTheRecipeAt
//
//  Created by Bruce Li on 2015-03-13.
//  Copyright (c) 2015 Bruce Li. All rights reserved.
//

#import "HomePageTableViewController.h"
#import "RecipeObject.h"
#import "HomePageCollectionViewController.h"

@interface HomePageTableViewController ()


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSMutableArray *allRecipes;
@property (strong, nonatomic) NSMutableArray *ingredientsList;

@end

@implementation HomePageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allRecipes = [[NSMutableArray alloc]init];
    self.ingredientsList = [[NSMutableArray alloc]init];
    
    NSLog(@"inside view did load");
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.leftBarButtonItem = self.editButtonItem;
}
- (IBAction)addIngredient:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add an ingredient" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        NSLog(@"ADDING! %@", [[alertView textFieldAtIndex:0]text]);
        [self.ingredientsList addObject:[[alertView textFieldAtIndex:0]text]];
        [self.tableView reloadData];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Cancel");
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"GO %@", searchBar.text);
    [searchBar resignFirstResponder];
    [self callRecipesAPIByName];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{

    
    [searchBar setShowsCancelButton:YES animated:YES];
}


-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)callRecipesAPIByName{
    NSMutableString *urlString = [[NSMutableString alloc]init];
    
    NSString *api = @"http://api.pearson.com:80/kitchen-manager/v1/recipes?name-contains=";
    
    [urlString appendString:api];
    
    [urlString appendString:[self.searchBar text]];
    [self callAPIWithURL:urlString];
    
    
}

-(void)callRecipesAPIByIngredient{

    
    //NSURL *url = [NSURL URLWithString:@"http://api.pearson.com:80/kitchen-manager/v1/recipes?ingredients-any=chicken%2Crice"];
    
    NSMutableString *urlString = [[NSMutableString alloc]init];
    
    NSString *api = @"http://api.pearson.com:80/kitchen-manager/v1/recipes?ingredients-any=";
    
    [urlString appendString:api];
    
   
    
    for (int i=0; i< [self.ingredientsList count]; i++){
        NSString* ing =[self.ingredientsList objectAtIndex:i];
     
        [urlString appendString:ing];
        if (i < [self.ingredientsList count]-1){
            [urlString appendString:@"%2C"];
        }
        
    }
    
    NSLog(@"URL STRING IS: %@", urlString);
    
    [self callAPIWithURL:urlString];
    
}

- (void) callAPIWithURL: (NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [request setValue:@"Agent name goes here" forHTTPHeaderField:@"User-Agent"];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self.receivedData = [[NSMutableData alloc] init];
     NSLog(@"in 2");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self.receivedData appendData:data];
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
                 JSONObjectWithData:self.receivedData
                 options:0
                 error:&error];
    
    NSDictionary *results = object;
    [self parseRecipeData:results];
    
    
}

- (void) parseRecipeData: (NSDictionary *) results{
    
    for (id key in [results allKeys]) {
        
        
        if ([key isEqualToString:@"results"]){
            NSArray *resultsArray = [results objectForKey:key];
            
            for (NSDictionary * recipeDict in resultsArray){
                
                 RecipeObject *recipe = [[RecipeObject alloc]init];
                for (id rKey in [recipeDict allKeys] ) {

                    if ([rKey isEqualToString:@"ingredients"]){
                        recipe.ingredients = [recipeDict objectForKey:rKey];
                    }
                    
                    if ([rKey isEqualToString:@"id"]){
                        recipe.recipeId = [recipeDict objectForKey:rKey];
                    }
                    
                    if ([rKey isEqualToString:@"cooking_method"]){
                        recipe.cookingMethod = [recipeDict objectForKey:rKey];
                    }
                    
                    if ([rKey isEqualToString:@"image"]){
                        recipe.imageFullURL = [recipeDict objectForKey:rKey];
                        
                        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: recipe.imageFullURL]];
                        recipe.imageFull = [UIImage imageWithData: imageData];
                    }
                    
                    if ([rKey isEqualToString:@"thumb"]){
                        recipe.imageThumbURL = [recipeDict objectForKey:rKey];
                        
                        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: recipe.imageThumbURL]];
                        
                        recipe.imageThumb = [UIImage imageWithData:imageData];
                    }
                    
                    if ([rKey isEqualToString:@"cusine"]){
                        recipe.cuisine = [recipeDict objectForKey:rKey];
                    }
                    
                    if ([rKey isEqualToString:@"url"]){
                        recipe.recipeURL = [recipeDict objectForKey:rKey];
                    }
                    
                    if ([rKey isEqualToString:@"name"]){
                        recipe.name = [recipeDict objectForKey:rKey];
                    }
                    
                    
                    

                }
                
                [self.allRecipes addObject:recipe];
                
                NSLog(@"recipe is: %@ and requires ingredients: %@", recipe.recipeId, recipe.ingredients);
                
                
            }
            
            
            
            
            
            
        }else{
            NSLog(@"key: %@, value: %@", key, [results objectForKey:key]);
        }
    }
    
    [self performSegueWithIdentifier:@"goToCollection" sender:nil];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
     NSLog(@"in 5 %@", error);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0){
        
    return [self.ingredientsList count];
    }
    if (section == 1) {
        return 1;
    }else{
        return 0;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return @"Ingredients";
    }else{
        return @"Ready to go?";
    }
}



#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"RELOAD FOR searchString is: %@", searchString);
   
//    NSString *scope;
//    
//    NSInteger selectedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
//    if (selectedScopeButtonIndex > 0)
//    {
//        scope = [[APLProduct deviceTypeNames] objectAtIndex:(selectedScopeButtonIndex - 1)];
//    }
//    
//    [self updateFilteredContentForProductName:searchString type:scope];
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString *searchString = [self.searchDisplayController.searchBar text];
    NSLog(@"RELOAD FOR SEARCHSCOPE is: %@", searchString);
    
//    NSString *searchString = [self.searchDisplayController.searchBar text];
//    NSString *scope;
//    
//    if (searchOption > 0)
//    {
//        scope = [[APLProduct deviceTypeNames] objectAtIndex:(searchOption - 1)];
//    }
//    
//    [self updateFilteredContentForProductName:searchString type:scope];
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goToCollection"]){
        NSLog(@"ABOUT TO SEGUE OMG");
        
        HomePageCollectionViewController *collectionView = (HomePageCollectionViewController *)[[segue destinationViewController] topViewController];
        
        
        RecipeObject *obj = [self.allRecipes objectAtIndex:0];
        NSLog(@"all recipes is: %@", obj.name);
        
        
        collectionView.allResults = self.allRecipes;
        
        
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IngredientCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 1){
        
        NSString *search = @"Search!";
        cell.textLabel.text = search;
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setTextColor:[UIColor blueColor]];
    }
    
    if (indexPath.section == 0){
        cell.textLabel.text = [self.ingredientsList objectAtIndex:[indexPath row]];
        
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    }
    

    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        
        if ([self.ingredientsList count] > 0){
            [self callRecipesAPIByIngredient];
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Ingredients!" message:@"Please add some ingredients before you search!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        
        
    }
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    if (indexPath.section == 1) return NO;
    
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.ingredientsList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end