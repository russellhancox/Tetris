#import "TetrisBoard.h"

@interface TetrisBoard ()

@property(readonly) uint16_t width;
@property(readonly) uint16_t height;

///  Empty row is a mutable array containing @NO objects representing empty cells on
///  the board, with one object per column. This is used to initialize the board and
///  to replace the top row when another row is removed due to being complete.
@property NSMutableArray *emptyRow;

///  Blocks represents the blocks of the board that have a "stored" piece in.
///  It's actually a mutable array of mutable arrays, one for each row, with
///  index 0 being the top of the board and index self.height-1 being the bottom.
///  Each subarray goes from left to right.
@property NSMutableArray *blocks;

@end

@implementation TetrisBoard

- (instancetype)initWithWidth:(uint16_t)width height:(uint16_t)height {
  self = [super init];
  if (self) {
    _width = width;
    _height = height;

    _emptyRow = [NSMutableArray arrayWithCapacity:width];
    for (int x = 0; x < width; x++) {
      [_emptyRow addObject:@NO];
    }

    _blocks = [NSMutableArray arrayWithCapacity:height];
    for (int y = 0; y < height; y++) {
      [_blocks addObject:[_emptyRow mutableCopy]];
    }
  }
  return self;
}

- (NSString *)description {
  NSMutableString *s = [NSMutableString string];

  for (int y = 0; y < self.height; y++) {
    for (int x = 0; x < self.width; x++) {
      [self occupiedRow:y column:x] ? [s appendString:@"*"] : [s appendString:@"-"];
    }
    [s appendString:@"\n"];
  }

  return s;
}

- (void)occupyRow:(uint16_t)y column:(uint16_t)x {
  NSParameterAssert(y < self.height && y >= 0);
  NSParameterAssert(x < self.width && x >= 0);

  self.blocks[y][x] = @YES;
}

- (BOOL)occupiedRow:(uint16_t)y column:(uint16_t)x {
  NSParameterAssert(y < self.height && y >= 0);
  NSParameterAssert(x < self.width && x >= 0);

  return [self.blocks[y][x] boolValue];
}

- (uint16_t)clearCompleteRows {
  uint16_t clearedRows = 0;

  // Loop through the rows begining at the bottom and working toward the top
  for (int y = self.height - 1; y > 0; --y) {
    BOOL rowComplete = YES;

    // Loop through the columns of the current row, looking for an unoccupied cell.
    for (int x = 0; x < self.width; ++x) {
      if (! [self occupiedRow:y column:x]) rowComplete = NO;
    }

    // The current row is complete, remove it and then re-check the same line
    // as it will now have different contents..
    if (rowComplete) {
      [self removeLine:y];
      y++;  // recheck this line
      clearedRows++;
    }
  }

  return clearedRows;
}

- (void)removeLine:(int16_t)row {
  NSParameterAssert(row < self.height && row >= 0);

  // Loop through the lines beginning at the cleared row and working upwards,
  // replacing the contents of every cell with the cell above it. If the row is
  // the top of the board, instead replace the whole row with self.emptyRow.
  for (int y = row; y >= 0; --y) {
    if (y == 0) {
      self.blocks[y] = [self.emptyRow mutableCopy];
    } else {
      for (int x = 0; x < self.width; ++x) {
        self.blocks[y][x] = self.blocks[y-1][x];
      }
    }
  }
}

@end
