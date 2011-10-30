# DDOutlineView

- - -

### Preface:


Mac OS X 10.7 brought ordered relationships to Core Data. Unfortunately Apple didn't update any of their binding enabled controllers ( NSArrayController, NSTreeController ) to support ordered relationships. DDOutlineView is a fully functional example using a subclassed NSTreeController and a standard NSOutlineView with ordered Core Data relationships.

### Requirements:

DDOutlineView is 10.7+ only and requires Xcode 4.2 with LLVM 3.0 compiler to work as it is an **ARC** enabled project.

### Notes:

- Drag & Drop support has been added but it is well tested but does not work "cleanly" with the Pasteboard. You should adjust the drag and drop code as needed.

