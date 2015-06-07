@import Foundation;

@interface TetrisBoard : NSObject

///  Designated initializer.
///
///  Initializes a new board of the designated width and height.
///  All cells are initialized as empty.
///
- (instancetype)initWithWidth:(uint16_t)width height:(uint16_t)height;

///
///  Marks a cell as occupied.
///  Both parameters must be within the bounds of the board.
///
- (void)occupyRow:(uint16_t)y column:(uint16_t)x;

///
///  Returns YES if the requested cell is occupied, otherwise NO.
///  Both parameters must be within the bounds of the board.
///
- (BOOL)occupiedRow:(uint16_t)y column:(uint16_t)x;

///
///  Checks for rows that are complete, clear them, move the remaining rows down
///  and return the number of rows that were cleared.
///
- (uint16_t)clearCompleteRows;

@end
