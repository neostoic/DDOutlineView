#import <CoreData/CoreData.h>
#import "DDOutlineViewControllerObject.h"

@interface Node : NSManagedObject <DDOutlineViewControllerObject>

#pragma mark - Modeled Properties

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Node *parent;
@property (nonatomic, strong, readonly) NSOrderedSet *children;
@property (nonatomic, strong, readonly) NSMutableOrderedSet *mutableChildren;
@property (nonatomic, strong) NSArray *childrenArray;

#pragma mark - Properties

@property (nonatomic, readonly) BOOL isLeaf;

#pragma mark - Children

- (BOOL)canBeParentOf:(Node *)pNode;
- (BOOL)canBeChildOf:(Node *)pNode;
- (BOOL)isAncestorOf:(Node *)pNode;
- (BOOL)isDescendentOf:(Node *)pNode;
- (NSIndexPath *)indexPathToAncestor:(Node *)pNode;
- (NSIndexPath *)indexPathToDescendent:(Node *)pNode;

@end

@interface Group : Node
@end