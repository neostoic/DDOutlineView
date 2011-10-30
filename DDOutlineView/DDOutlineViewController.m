
#import "DDOutlineViewController.h"

@interface DDOutlineViewController() <NSOutlineViewDataSource> {
	
}

@property (nonatomic, strong) NSDraggingSession *draggingSession;
@property (nonatomic, strong) NSArray *draggingItems;
@property (nonatomic, strong) NSArray *draggingObjects;


@end
@implementation DDOutlineViewController

#pragma mark - Properties

@synthesize outlineView;
@synthesize draggingSession;
@synthesize draggingItems;
@synthesize draggingObjects;
@synthesize draggingPasteboardType;

- (void)setContent:(id)pContent {
	[super setContent:pContent];
}
- (void)setDraggingPasteboardType:(NSString *)pValue {
	NSMutableArray *types = [self.outlineView.registeredDraggedTypes mutableCopy];
	if(draggingPasteboardType != nil) {
		[types removeObject:draggingPasteboardType];
	}
	draggingPasteboardType = pValue;
	if(draggingPasteboardType != nil) {
		[types addObject:draggingPasteboardType];
	}
	[self.outlineView registerForDraggedTypes:types];
}

#pragma mark - Nib

- (void)awakeFromNib {
	[super awakeFromNib];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
	Class entityClass = NSClassFromString(entity.managedObjectClassName);
	if(![entityClass conformsToProtocol:@protocol(DDOutlineViewControllerObject)]) {
		[NSException raise:@"Invalid Entity" format:@"Entity with class: %@ does not conform to protocol %@", entity.managedObjectClassName, NSStringFromProtocol(@protocol(DDOutlineViewControllerObject))];
		return;
	}
	
	// setup some properties
	[self setFetchPredicate:[NSPredicate predicateWithFormat:@"parent == nil"]];
	[self setLeafKeyPath:@"isLeaf"];
	
	self.draggingPasteboardType = [NSString stringWithFormat:@"outlineviewcontroller.%@", self.entityName];
	self.outlineView.dataSource = self;
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)pOutlineView numberOfChildrenOfItem:(NSTreeNode *)pItem {
	return 0;
}
- (NSTreeNode *)outlineView:(NSOutlineView *)pOutlineView child:(NSInteger)pChildIndex ofItem:(id)pItem {
	return nil;
}
- (BOOL)outlineView:(NSOutlineView *)pOutlineView isItemExpandable:(NSTreeNode *)pItem {
	return NO;
}

- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)pOutlineView pasteboardWriterForItem:(NSTreeNode *)pItem {
	return [[NSPasteboardItem alloc] initWithPasteboardPropertyList:[NSNumber numberWithBool:YES] ofType:self.draggingPasteboardType];
}
- (void)outlineView:(NSOutlineView *)pOutlineView draggingSession:(NSDraggingSession *)pDraggingSession willBeginAtPoint:(NSPoint)pScreenPoint forItems:(NSArray *)pDraggedItems {
	self.draggingSession = pDraggingSession;
	self.draggingItems = [pDraggedItems copy];
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:self.draggingItems.count];
	for(NSTreeNode *draggedItem in draggingItems) {
		[objects addObject:draggedItem.representedObject];
	}
	self.draggingObjects = objects;
}
- (void)outlineView:(NSOutlineView *)pOutlineView draggingSession:(NSDraggingSession *)pDraggingSession endedAtPoint:(NSPoint)pScreenPoint operation:(NSDragOperation)pOperation {
	self.draggingItems = nil;
	self.draggingSession = nil;
	self.draggingObjects = nil;
}
- (NSDragOperation)outlineView:(NSOutlineView *)pOutlineView validateDrop:(id <NSDraggingInfo>)pDraggingInfo proposedItem:(NSTreeNode *)pItem proposedChildIndex:(NSInteger)pIndex {
	id <DDOutlineViewControllerObject> object = (id <DDOutlineViewControllerObject>)pItem.representedObject;
	
	id draggingSource = [pDraggingInfo draggingSource];
	
	// our own outline view
	if(draggingSource == self.outlineView) {
		// validate all objects we're dragging can be a child of proposed object
		for(id <DDOutlineViewControllerObject> draggingObject in self.draggingObjects) {
			if(![draggingObject canBeChildOf:object] &&
			   ![object canBeParentOf:draggingObject]) {
				return NSDragOperationNone;
			}
		}
		return NSDragOperationMove;
	}
	// another outline view controlled by DDOutlineViewController
	else if([draggingSource isKindOfClass:[NSOutlineView class]] && [[draggingSource dataSource] isKindOfClass:[DDOutlineViewController class]]) {
		DDOutlineViewController *otherOutlineViewController = (DDOutlineViewController *)[(NSOutlineView *)draggingSource dataSource];
		
		// validate all objects we're dragging can be a child of proposed object
		for(id <DDOutlineViewControllerObject> draggingObject in otherOutlineViewController.draggingObjects) {
			if(![draggingObject canBeChildOf:object] &&
			   ![object canBeParentOf:draggingObject]) {
				return NSDragOperationNone;
			}
		}
		return NSDragOperationCopy;
	}
	// someone else
	else {
		return NSDragOperationNone;
	}
	
	return NSDragOperationNone;
	
}
- (BOOL)outlineView:(NSOutlineView *)pOutlineView acceptDrop:(id <NSDraggingInfo>)pDraggingInfo item:(NSTreeNode *)pItem childIndex:(NSInteger)pIndex {
//	id <DDOutlineViewControllerObject> object = (id <DDOutlineViewControllerObject>)((pItem == nil) ? root.representedObject :  pItem.representedObject);
	NSInteger index = (pIndex == NSOutlineViewDropOnItemIndex) ? 0 : pIndex;
	
	id draggingSource = [pDraggingInfo draggingSource];
	
	// our own outline view
	if(draggingSource == self.outlineView) {
		if(pItem == nil) {
			[self moveNodes:self.draggingItems toIndexPath:[NSIndexPath indexPathWithIndex:index]];
		} else {
			[self moveNodes:self.draggingItems toIndexPath:[pItem.indexPath indexPathByAddingIndex:index]];
		}
		return YES;
	}
	// another outline view controlled by DDOutlineViewController
	else if([draggingSource isKindOfClass:[NSOutlineView class]] && [[draggingSource dataSource] isKindOfClass:[DDOutlineViewController class]]) {
//		DDOutlineViewController *otherOutlineViewController = (DDOutlineViewController *)[(NSOutlineView *)draggingSource dataSource];
//		@TODO - Custom logic required to copy NSManaged objects
	}
	
	return NO;
}

#pragma mark - Dealloc

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
