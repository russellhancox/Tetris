@import Foundation;

@interface TetrisBoard : NSObject

///  Designated initializer.
///
///  Initializes a new board of the designated width and height.
///  All cells are initialized as empty.
///
- (instancetype)initWithSize:(NSSize)size;

///
///  Marks a cell as occupied.
///
- (void)occupyPoint:(NSPoint)point;

///
///  Returns YES if the requested cell is occupied, otherwise NO.
///
- (BOOL)occupiedPoint:(NSPoint)point;

///
///  Checks for rows that are complete, clear them, move the remaining rows down
///  and return the number of rows that were cleared.
///
- (uint16_t)clearCompleteRows;

@end
