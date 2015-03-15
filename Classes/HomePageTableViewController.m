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
#import <AFNetworking/AFNetworking.h>
#import <Parse/Parse.h>

@interface HomePageTableViewController ()


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSMutableArray *allRecipes;
@property (strong, nonatomic) NSMutableArray *ingredientsList;
@property (strong, nonatomic) NSString *bestTagIngredient;


@end

@implementation HomePageTableViewController

UIAlertView * scanAlert;
UIAlertView *searchAlert;


- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.allRecipes = [[NSMutableArray alloc]init];
    self.ingredientsList = [[NSMutableArray alloc]init];
    
    NSLog(@"inside view did load");
    
    //[self callAPIWithURL:@"https://opendata.socrata.com/api/views/u5i2-8j3f/rows.json?accessType=DOWNLOAD"];
    
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    testObject[@"foo"] = @"bar";
//    [testObject saveInBackground];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

-(void) parseFoodDictionary:(NSDictionary *) results{
    
    NSMutableArray *alphabetArray = [[NSMutableArray alloc]init];
    NSMutableArray *theAlphabet = [[NSMutableArray alloc]init];
    
    for (id key in [results allKeys]) {
        
        
        
        
        if ([key isEqualToString:@"data"]){
            NSArray *dataArray = [results objectForKey:key];
            
            NSMutableArray *letterArray = [[NSMutableArray alloc]init];
            
            NSString *prevFirstLetter = @"";
            
            for (NSArray * data in dataArray){
                
                NSString *food = [data objectAtIndex:8];
                food = [food lowercaseString];
                NSString *firstLetter = [food substringToIndex:1];
                
                
                if (![firstLetter isEqualToString:prevFirstLetter]){
                    [theAlphabet addObject:firstLetter];
                    prevFirstLetter = firstLetter;
                    [alphabetArray addObject:letterArray];
                    letterArray = [[NSMutableArray alloc]init];
                }
                [letterArray addObject:food];
                
            }
            
        }
    }
    NSLog(@"full data is: %@", alphabetArray);
    
    
 
}

- (IBAction)addIngredient:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add an ingredient" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if (buttonIndex == 1 && [alertView.title isEqualToString:@"Add an ingredient"]){
        NSLog(@"ADDING! %@", [[alertView textFieldAtIndex:0]text]);
        [self.ingredientsList addObject:[[alertView textFieldAtIndex:0]text]];
        [self.tableView reloadData];
    }else if (buttonIndex == 1){
        NSLog(@"ADDING THE BEST TAG: %@", self.bestTagIngredient);
        [self.ingredientsList addObject:self.bestTagIngredient];
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
    
    
    searchAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Retreiving Recipes!"] message:@"Busy running some super crazy awesome algorithms, please be patient :)" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [searchAlert show];
    
    
    
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
    
    [urlString appendString:@"&limit=5"];
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
    
    searchAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Retrieving Recipes"] message:@"Busy running some super crazy awesome algorithms, please be patient :)" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [searchAlert show];
    
    //[self parseFoodDictionary:results];
    
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
    
    [searchAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    [self performSegueWithIdentifier:@"goToCollection" sender:nil];

}


-(void) parseImageRecogData: (NSDictionary *) recogData{
    
    BOOL found1Tag = NO;
 
          NSMutableArray *goodTags = [[NSMutableArray alloc]init];
    NSString *bestTag;

    
    int tagCount = 0;
    for (id key in [recogData allKeys]) {
        if ([key isEqualToString:@"results"]){
            
            NSMutableArray *firstLevelArr = [[NSMutableArray alloc]init];
            firstLevelArr = [recogData objectForKey:key];
        
            
            for (id tKey in [[firstLevelArr objectAtIndex:0] allKeys]){
                
            
                if ([tKey isEqualToString:@"tags"] ){
                    NSMutableArray *tagsArray = [[NSMutableArray alloc]init];
            
                    tagsArray = [[firstLevelArr objectAtIndex:0] objectForKey:tKey];
              
                    
                    for (NSDictionary * tagDict in tagsArray){
                
                        int confidence = (int)[tagDict objectForKey:@"confidence"];
                
                        if ( confidence > 30 && tagCount <5){
                            if (![self checkIfTagIsAFood:[tagDict objectForKey:@"tag"]]){
                        
                                NSLog(@"%@ is a bad tag!", [tagDict objectForKey:@"tag"]);
                        
                            }else{
                                [goodTags addObject:[tagDict objectForKey:@"tag"]];
                            }
                            
                            tagCount++;
                }
                
                
                
                
                
            }
                
                    if ([goodTags count] > 0){
                        bestTag = [goodTags objectAtIndex:0];
                        found1Tag = YES;
                
                    }else{
                        found1Tag = NO;
                   
                        bestTag = @"... actually I'm not sure what that was, maybe enter it manually?";
                    }
            
        }}
        }
    }
    
    
    [scanAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    self.bestTagIngredient = bestTag;
    NSLog(@"the best tag is %@", bestTag);
    NSLog(@"top tags: %@", goodTags);
    
    if (found1Tag){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You took a picture of a(n) %@", bestTag] message:@"" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yup!", nil];
        [alert show];
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Sorry, I couldn't figure out what that was; go easy on me, I've only been doing this for like a day"] message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    
   
    
}


-(BOOL) checkIfTagIsAFood:(NSString *) tag{
    
    
    NSString *firstLetterTag = [tag substringToIndex:1];
    
    PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"FoodDictionary_%@", firstLetterTag]];
    [query whereKey:@"foodName" equalTo:tag];
    NSArray *result = [query findObjects];
    
    NSLog(@"querying tag: %@", tag);
    
    if ([result count] == 0){
        NSLog(@"NO!");
        return NO;
    }else{
        NSLog(@"YES!");
        return YES;
    }
    

    
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0){
        
    return [self.ingredientsList count];
    }
    if (section == 1 || section == 2) {
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
    }
    
    if (section == 1){
        return @"Search recipes by Ingredients!";
    }else{
        return @"Scan your Ingredients!";
    }
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
    
    if (indexPath.section == 2){
        
        NSString *search = @"Scan Your Food!";
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
            
            searchAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Retrieving Recipes!"] message:@"Busy running some super crazy awesome algorithms, please be patient :)" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [searchAlert show];
            
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Ingredients!" message:@"Please add some ingredients before you search!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        
        
        
    }
    
    if (indexPath.section == 2){
        [self switchToCamera]; 
    }
    
}

- (void) switchToCamera{
    UIImagePickerController *camerapicker = [[UIImagePickerController alloc]init];
    camerapicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    camerapicker.delegate = self;
    [self presentViewController:camerapicker animated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
 
    UIImage* cameraImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    
    // NSURL *strImageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    
    
    
    
    [self storeImageToParse:cameraImage];
    
    
    scanAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Scanning the picture!"] message:@"Busy running some super crazy awesome algorithms, please be patient :)" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [scanAlert show];
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

-(void) storeImageToParse:(UIImage *) image{
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    PFObject *imageStore = [PFObject objectWithClassName:@"ImagesForRecognition"];
    imageStore[@"cameraImage"] = [PFFile fileWithData:imageData];
    [imageStore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFQuery *queryImage = [PFQuery queryWithClassName:@"ImagesForRecognition"];
        [queryImage orderByDescending:@"createdAt"];
        PFObject *storedImage = [queryImage getFirstObject];
        
        PFFile *imageFile = storedImage[@"cameraImage"];
        
        AFHTTPRequestOperationManager *taggingManager = [AFHTTPRequestOperationManager manager];
        [taggingManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [taggingManager.requestSerializer setAuthorizationHeaderFieldWithUsername: @"acc_1adda715b59e697" password: @"c8e39f2f43b7097205c013e23034eef3"];
        [taggingManager GET:@"http://api.imagga.com/v1/tagging" parameters:@{@"url":imageFile.url}
                    success:^(AFHTTPRequestOperation *taggingOperation, id taggingResponseObject) {
                        NSLog(@"Tagging Response: %@", taggingResponseObject);
                        
                        
                      
                        
//                        NSError *error = nil;
//                        id object = [NSJSONSerialization
//                                     JSONObjectWithData:taggingResponseObject
//                                     options:0
//                                     error:&error];
                        
                        NSDictionary *recogData = taggingResponseObject;
                        
                        [self parseImageRecogData:recogData];
                        
                        
                        
                        
                    } failure:^(AFHTTPRequestOperation *taggingOperation, NSError *taggingError) {
                        NSLog(@"Tagging Error: %@", taggingError);
                    }];
        
        }
    ];

}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    if (indexPath.section == 0) return YES;
    
    return NO;
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
