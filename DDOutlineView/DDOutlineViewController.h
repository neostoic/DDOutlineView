#import <AppKit/AppKit.h>
#import "DDOutlineViewControllerObject.h"


@interface DDOutlineViewController : NSTreeController

#pragma mark - Properties

@property (nonatomic, weak, readonly) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, strong) NSString *draggingPasteboardType;

@end
