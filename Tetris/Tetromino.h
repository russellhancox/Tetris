@import Foundation;

@interface Tetromino : NSObject

///  Return the next Tetromino
+ (Tetromino *)nextTetromino;

///  Return a 16-bit unsigned int representing the cells in a 4x4 grid
///  that this Tetromino occupies. Each nibble represents a row.
///
///  e.g. for the T-shaped piece:
///
///     +----+   +----+   +----+   +----+
///     |    |   | x  |   | x  |   | x  |
///     |xxx |   |xx  |   |xxx |   | xx |
///     | x  |   | x  |   |    |   | x  |
///     |    |   |    |   |    |   |    |
///     +----+   +----+   +----+   +----+
///     0x0E40   0x4C40   0x4E00   0x4640
///
- (uint16_t)shape;

///  Rotate this Tetromino and return the new shape as defined above.
- (uint16_t)rotate;

@end
