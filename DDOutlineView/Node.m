#import "Node.h"

@implementation Node

#pragma mark - Modeled Properties

@dynamic identifier;
@dynamic name;
@dynamic parent;
@dynamic children;
@dynamic mutableChildren;
@dynamic childrenArray;

- (void)setIdentifier:(NSString *)pValue {
	
}
- (NSMutableOrderedSet *)mutableChildren {
	return [self mutableOrderedSetValueForKey:@"children"];
}

- (NSArray *)childrenArray {
	return self.children.array;
}
- (void)setChildrenArray:(NSArray *)pValue {
	[self willChangeValueForKey:@"children"];
	[self setPrimitiveValue:[NSOrderedSet orderedSetWithArray:pValue] forKey:@"children"];
	[self didChangeValueForKey:@"children"];
}

#pragma mark - Properties

@dynamic isLeaf;

- (BOOL)isLeaf {
	return self.children.count == 0;
}

#pragma mark - Initialization

- (id)initWithEntity:(NSEntityDescription *)pEntity insertIntoManagedObjectContext:(NSManagedObjectContext *)pContext {
	if((self = [super initWithEntity:pEntity insertIntoManagedObjectContext:pContext])) {
		[self willChangeValueForKey:@"identifier"];
		[self setPrimitiveValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:@"identifier"];
		[self didChangeValueForKey:@"identifier"];
	}
	return self;
}

#pragma mark - KVO/KVC

- (void)willChangeValueForKey:(NSString *)pKey {
	if([pKey isEqualToString:@"children"]) {
		[super willChangeValueForKey:@"isLeaf"];
		[super willChangeValueForKey:@"childrenArray"];
	}
	[super willChangeValueForKey:pKey];
}
- (void)didChangeValueForKey:(NSString *)pKey {
	[super didChangeValueForKey:pKey];
	if([pKey isEqualToString:@"children"]) {
		[super didChangeValueForKey:@"childrenArray"];
		[super didChangeValueForKey:@"isLeaf"];
	}
}
- (void)willChange:(NSKeyValueChange)pChangeKind valuesAtIndexes:(NSIndexSet *)pIndexes forKey:(NSString *)pKey {
	if([pKey isEqualToString:@"children"]) {
		[super willChangeValueForKey:@"isLeaf"];
		[super willChange:pChangeKind valuesAtIndexes:pIndexes forKey:@"childrenArray"];
	}
	[super willChange:pChangeKind valuesAtIndexes:pIndexes forKey:pKey];
}
- (void)didChange:(NSKeyValueChange)pChangeKind valuesAtIndexes:(NSIndexSet *)pIndexes forKey:(NSString *)pKey {
	[super didChange:pChangeKind valuesAtIndexes:pIndexes forKey:pKey];
	if([pKey isEqualToString:@"children"]) {
		[super didChange:pChangeKind valuesAtIndexes:pIndexes forKey:@"childrenArray"];
		[super didChangeValueForKey:@"isLeaf"];
	}
}

#pragma mark - Children

- (BOOL)canBeParentOf:(Node *)pNode {
	return NO;
}
- (BOOL)canBeChildOf:(Node *)pNode {
	return YES;
}
- (BOOL)isAncestorOf:(Node *)pNode {
	if(pNode == nil) {
		return NO;
	}
	Node *parent = pNode.parent;
	while(parent != nil) {
		if(parent == self) {
			return YES;
		}
		parent = parent.parent;
	}
	return NO;
}
- (BOOL)isDescendentOf:(Node *)pNode {
	if(pNode == nil) {
		return YES;
	}
	return [pNode isAncestorOf:self];
}
- (NSIndexPath *)indexPathToAncestor:(Node *)pNode {
	if(![self isDescendentOf:pNode]) {
		return nil;
	}
	
	NSIndexPath *indexPath = nil;
	
	Node *node = self;
	Node *parent = self.parent;
	do {
		NSInteger index = [parent.children indexOfObject:node];
		
		if(indexPath == nil) {
			indexPath = [NSIndexPath indexPathWithIndex:index];
		} else {
			indexPath = [indexPath indexPathByAddingIndex:index];
		}
		
		node = parent;
		parent = parent.parent;
		
	} while(node != pNode);
	
	return indexPath;
	
}
- (NSIndexPath *)indexPathToDescendent:(Node *)pNode {
	if(![self isAncestorOf:pNode]) {
		return nil;
	}
	
	NSIndexPath *indexPath = [pNode indexPathToAncestor:self];
	NSIndexPath *reversedIndexPath = [NSIndexPath indexPathWithIndex:[indexPath indexAtPosition:indexPath.length - 1]];
	for(NSInteger i = indexPath.length - 2; i >= 0; --i) {
		reversedIndexPath = [reversedIndexPath indexPathByAddingIndex:[indexPath indexAtPosition:i]];
	}
	
	return reversedIndexPath;
}

@end

@implementation Group

#pragma mark - Properties

- (BOOL)isLeaf {
	return NO;
}

#pragma mark - Children

- (BOOL)canBeParentOf:(Node *)pNode {
	return (pNode != nil && pNode != self && ![pNode isAncestorOf:self]);
}
- (BOOL)canBeChildOf:(Node *)pNode {
	return (pNode == nil || (pNode != self && [pNode isKindOfClass:[Group class]] && ![pNode isDescendentOf:self]));
}

@end