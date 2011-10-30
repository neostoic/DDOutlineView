#import <Foundation/Foundation.h>

@protocol DDOutlineViewControllerObject <NSObject>

@required

- (BOOL)isLeaf;

- (NSOrderedSet *)children;
- (id <DDOutlineViewControllerObject>)parent;
- (BOOL)canBeParentOf:(id <DDOutlineViewControllerObject>)pObject;
- (BOOL)canBeChildOf:(id <DDOutlineViewControllerObject>)pObject;
- (NSIndexPath *)indexPathToAncestor:(id <DDOutlineViewControllerObject>)pObject;
- (NSIndexPath *)indexPathToDescendent:(id <DDOutlineViewControllerObject>)pObject;

@end
