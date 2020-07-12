//
//  MSMSearchViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 15.03.14.
//  Copyright (c) 2014 - 2020 Frank Budszuhn. See LICENSE.
//

#import "MSMSearchViewController.h"

@interface MSMSearchViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSArray *searchResultsPlaces;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation MSMSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    //self.searchController.dimsBackgroundDuringPresentation = NO; // TODO: mal sehen
    self.searchController.searchBar.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //##[self.searchDisplayController.searchBar becomeFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    //##[self.searchDisplayController setActive: NO animated: NO];
    [self.delegate searchDone];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResultsPlaces count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"SearchCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
	}
    
    CLPlacemark *placemark = [self.searchResultsPlaces objectAtIndex:indexPath.row];
    
    cell.textLabel.text = placemark.locality;
    cell.detailTextLabel.text = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //##[self.searchDisplayController setActive: NO animated: YES];
    
    // so, jetzt hin da:
    CLPlacemark *placemark = [self.searchResultsPlaces objectAtIndex: indexPath.row];
    [self.delegate setPlacemark: placemark];    
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    CLGeocoder *gc = [[CLGeocoder alloc] init];
    
    WEAK_SELF(weakSelf);
    [gc geocodeAddressString:searchString completionHandler:^(NSArray *placemarks, NSError *error) {
        
        weakSelf.searchResultsPlaces = placemarks;
        //##[weakSelf.searchDisplayController.searchResultsTableView reloadData];
        
    }];
    
    return NO; // weil asynchrone Suche. Der Block oben lädt die Tabelle neu, wenn er "fertig" ist
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    NSString *searchText = searchBar.text;
    
    if ([searchText length] >= 3)
    {
        CLGeocoder *gc = [[CLGeocoder alloc] init];
        
        WEAK_SELF(weakSelf);
        [gc geocodeAddressString:searchText completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if ([placemarks count] > 0)
            {
                [weakSelf.delegate setPlacemark: [placemarks firstObject]];
            }
        }];
    }
}





@end
