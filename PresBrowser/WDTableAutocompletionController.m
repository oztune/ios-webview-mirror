//
//  TableAutocompletionController.m
//  PresBrowser
//
//  Created by alex on 1/24/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import "WDTableAutocompletionController.h"
#import "WDSettings.h"

@interface WDTableAutocompletionController ()
@property (strong, nonatomic) NSArray *cachedHistory;
@end

@implementation WDTableAutocompletionController

@synthesize cachedHistory;

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    }
    return self;
}

- (void)complete{
    self.cachedHistory = [NSMutableArray arrayWithArray:[[WDSettings instance] urlHistory]];
    NSString *filter = self.boundField.text;
    if([filter length] != 0){
        for(int i = 0; i < [cachedHistory count]; i++){
            NSString *url = [self.cachedHistory objectAtIndex:i];
            if([url rangeOfString:filter options:NSCaseInsensitiveSearch].location == NSNotFound ){
                [(NSMutableArray *)self.cachedHistory removeObjectAtIndex:i];
                i--;
            }
        }
    }
    [self.tableView reloadData];
}

-(void)beginCompletion{
    self.view.hidden = YES;
    [self.boundField.superview addSubview:self.view];
}

-(void)endCompletion{
    [[WDSettings instance]pushUrl:self.boundField.text];
    [self.view removeFromSuperview];
    self.view.hidden = YES;
}

- (void)keyboardWasShown:(NSNotification *)notification{
    CGRect keyboard = [[[notification userInfo]
                     objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    float start = self.boundField.frame.origin.y + self.boundField.frame.size.height + 10;
    self.view.frame = CGRectMake(0, start, keyboard.size.width,keyboard.origin.y - start);
    self.cachedHistory = [[WDSettings instance] urlHistory];
    [self.tableView reloadData];
    self.view.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [cachedHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }

    cell.textLabel.text = [self urlFor: indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* url = [self urlFor:indexPath];
    self.boundField.text = url;
    [self.boundField endEditing:NO];
    //[self.boundField resignFirstResponder];
}

- (NSString*) urlFor: (NSIndexPath *)indexPath{
    return [cachedHistory objectAtIndex:[cachedHistory count] - indexPath.row - 1];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
