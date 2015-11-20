//
//  LovationViewController.m
//  platform
//
//  Created by wujiang on 15/11/4.
//  Copyright © 2015年 wujiang. All rights reserved.
//

#import "LovationViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface LovationViewController () <CLLocationManagerDelegate , UISearchBarDelegate , UISearchDisplayDelegate , UITableViewDelegate , UITableViewDataSource>
@property (nonatomic, retain) NSDictionary * cities;
@property (nonatomic, retain) NSArray * keys;
@property (nonatomic, retain) NSMutableArray * values;
@property (nonatomic, retain) UIView * headerView;
@property (nonatomic, retain) UILabel * headerLocationLabel;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;;
@property (nonatomic, retain) NSArray * filterData;

#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define screenHeight ([UIScreen mainScreen].bounds.size.height)


@property (nonatomic, retain) UITableView * myTableView;

@end

@implementation LovationViewController
{
    UISearchBar * mySearchBar;
}
#pragma mark ---------------
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createNavBtnItem]; // 导航条
    
    
    [self createDataSource]; // 处理数据源
    
    [self createTableView];
    
    [self createHeaderView]; // 创建headView
    
    [self location]; // 定位

   
    
    
}

#pragma mark ---TableView
- (void)createDataSource{
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"citydict" ofType:@"plist"];
    self.cities = [[NSDictionary alloc]
                   initWithContentsOfFile:path];
    
    self.keys = [[self.cities allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    self.values = [[NSMutableArray alloc] init];
    NSArray * arr = [self.cities allValues];
    for(NSArray * array in arr)
    {
        for(int i=0;i<array.count;i++)
        [self.values addObject:[array objectAtIndex:i]];
    }
}
- (void)createTableView
{
    
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,screenWidth , screenHeight) style:UITableViewStylePlain];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.view addSubview:self.myTableView];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.myTableView){
        return [self.keys count];
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.myTableView)
    {
        NSString *key = [self.keys objectAtIndex:section];
        NSArray *citySection = [self.cities objectForKey:key];
        return [citySection count];
    }
    else
    {
        // 谓词搜索
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains [cd] %@",self.searchDisplayController.searchBar.text];
        self.filterData =  [[NSArray alloc] initWithArray:[self.values filteredArrayUsingPredicate:predicate]];
        return self.filterData.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    NSString *key = [self.keys objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    if(tableView == self.myTableView)
    {
        cell.textLabel.text = [[self.cities objectForKey:key] objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = [self.filterData objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == self.myTableView){
        NSString *key = [NSString stringWithFormat:@"   %@",[self.keys objectAtIndex:section]];
        return key;
    }else{
        return nil;
    }
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(tableView == self.myTableView)
    {
        return self.keys;
    }
    else
    {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView == self.myTableView){
        return 15.0;

    }else{
        return 0.01f;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * selectString  = @"";

    if(tableView == self.myTableView)
    {
        NSString *key = [self.keys objectAtIndex:indexPath.section];
        selectString =  [[self.cities objectForKey:key] objectAtIndex:indexPath.row];
    }
    else
    {
        selectString =  [self.filterData objectAtIndex:indexPath.row];
    }
}

#pragma mark -- UI
- (void)location{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter=0.0f;
    [_locationManager startUpdatingLocation];
}
- (void)createHeaderView{
    self.myTableView.backgroundColor = [UIColor whiteColor];
    self.myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.myTableView.sectionIndexColor = [UIColor blackColor];
    
    mySearchBar  = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    mySearchBar.delegate = self;
    mySearchBar.placeholder = @"搜索";

    self.myTableView.tableHeaderView = mySearchBar;
    
    self.headerLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, screenWidth, 50)];
    self.headerLocationLabel.font = [UIFont systemFontOfSize:15];
    self.headerLocationLabel.textColor = [UIColor whiteColor];
    
    
    self.headerLocationLabel.textAlignment = NSTextAlignmentLeft;
    self.headerLocationLabel.text = @"北京";
    [self.headerView addSubview:self.headerLocationLabel];
    
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:mySearchBar contentsController:self];
    
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
}

- (void)createNavBtnItem{
    
    self.title = @"选择城市";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBackActioin)];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.coordinate = [location coordinate];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation: location completionHandler:^(NSArray *array, NSError *error) {
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            if (placemark)
            {
                NSString *city = placemark.administrativeArea;
//                NSString *subLocality = placemark.subLocality;
//                NSString *thoroughfare = placemark.thoroughfare;
                NSLog(@"city -> %@",city);
                [_locationManager stopUpdatingLocation];
            }
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
//    mySearchBar.frame = CGRectMake(0, 0, SCREEN_WIDHT, 44);
    
//    self.myTableView.tableHeaderView = self.headerView;
    
    return YES;
}

#pragma mark ----- ACTION
- (void)goBackActioin{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
