#import "TetrisBoard.h"

@interface TetrisBoard ()

@property(readonly) uint16_t width;
@property(readonly) uint16_t height;

///  Blocks represents the blocks of the board that have a "stored" piece in.
///  The value doesn't matter so we're using @YES.
@property NSMutableDictionary *blocks;

@end

@implementation TetrisBoard

- (instancetype)initWithSize:(NSSize)size {
  self = [super init];
  if (self) {
    _width = floor(size.width);
    _height = floor(size.height);

    _blocks = [NSMutableDictionary dictionaryWithCapacity:_width * _height];
  }
  return self;
}

- (NSString *)description {
  NSMutableString *s = [NSMutableString string];

  for (int y = 0; y < self.height; y++) {
    for (int x = 0; x < self.width; x++) {
      [self occupiedPoint:NSMakePoint(x, y)] ? [s appendString:@"*"] : [s appendString:@"-"];
    }
    [s appendString:@"\n"];
  }

  return s;
}

- (void)occupyPoint:(NSPoint)point {
  int x = floor(point.x), y = floor(point.y);

  NSParameterAssert(y < self.height && y >= 0);
  NSParameterAssert(x < self.width && x >= 0);

  self.blocks[[NSValue valueWithPoint:point]] = @YES;
}

- (BOOL)occupiedPoint:(NSPoint)point {
  int x = floor(point.x), y = floor(point.y);

  if (y >= self.height || y < 0) return YES;
  if (x >= self.width || x < 0) return YES;

  return (self.blocks[[NSValue valueWithPoint:point]] != nil);
}

- (uint16_t)clearCompleteRows {
  uint16_t clearedRows = 0;

  // Loop through the rows begining at the bottom and working toward the top
  for (int y = self.height - 1; y > 0; --y) {
    BOOL rowComplete = YES;

    // Loop through the columns of the current row, looking for an unoccupied cell.
    for (int x = 0; x < self.width; ++x) {
      if (! [self occupiedPoint:NSMakePoint(x, y)]) rowComplete = NO;
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
  // replacing the contents of every cell with the cell above it.
  for (int y = row; y >= 0; --y) {
    for (int x = 0; x < self.width; ++x) {
      // p1 == current point, p2 == point above p1
      NSPoint p1 = NSMakePoint(x, y), p2 = NSMakePoint(x, y - 1);

      if (y > 0 && self.blocks[[NSValue valueWithPoint:p2]]) {
        [self.blocks removeObjectForKey:[NSValue valueWithPoint:p2]];
        self.blocks[[NSValue valueWithPoint:p1]] = @YES;
      } else {
        [self.blocks removeObjectForKey:[NSValue valueWithPoint:p1]];
      }
    }
  }
}

@end
