#import "DDDocument.h"
#import "Node.h"

@implementation DDDocument

#pragma mark - Properties

- (NSString *)windowNibName {
	return @"DDDocument";
}

#pragma mark - NSDocument

- (void)windowControllerDidLoadNib:(NSWindowController *)pWindowController {
	[super windowControllerDidLoadNib:pWindowController];
	
	[self.undoManager beginUndoGrouping];
	
	for(NSInteger i = 0; i < 3; ++i) {
		Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
		group.name = [NSString stringWithFormat:@"Group %i", i + 1];
		
		for(NSInteger j = 0; j < 5; ++j) {
			Node *node = [NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:self.managedObjectContext];
			node.name = [NSString stringWithFormat:@"Node %i (%@)", j + 1, group.name];
			node.parent = group;
		}
		
	}
	
	[self.managedObjectContext processPendingChanges];
	[self.undoManager endUndoGrouping];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self.undoManager beginUndoGrouping];
		
		Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
		group.name = @"Extra Group";
		
		[self.managedObjectContext processPendingChanges];
		[self.undoManager endUndoGrouping];
	});
}

@end
