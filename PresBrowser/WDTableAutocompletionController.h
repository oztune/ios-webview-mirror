//
//  TableAutocompletionController.h
//  PresBrowser
//
//  Created by alex on 1/24/14.
//  Copyright (c) 2014 Oz Michaeli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDTableAutocompletionController : UITableViewController
@property (strong, nonatomic) IBOutlet UITextField *boundField;
- (IBAction)beginCompletion;
- (IBAction)endCompletion;
- (IBAction)complete;

- (void)keyboardWasShown:(NSNotification *)notification;
@end