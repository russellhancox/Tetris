#import "TetrisGame.h"

#import "TetrisBoard.h"
#import "Tetromino.h"

//  The Frames Per Second to play at. This has no real effect on
//  when the blocks fall down, it merely affects how often the tick
//  method is run.
static const uint16_t FPS = 30;

static const float SPEED_START = 1.0;
static const float SPEED_DECRE = 0.005;
static const float SPEED_MIN = 0.4;

static const NSSize fieldSize = {10, 18};

typedef enum { dLeft, dRight, dDown } Direction;

@interface TetrisGame ()

/// The game board
@property TetrisBoard *board;

/// The co-ordinates of the current piece.
@property NSPoint piecePoint;

/// The current piece and next piece
@property Tetromino *currentPiece;
@property Tetromino *nextPiece;

@property float speed;
@property float step;

/// The current number of completed rows
@property uint16_t completedRows;

/// The repeating timer which calls |tick| to maintain FPS.
@property NSTimer *gameTimer;

@end

@implementation TetrisGame

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];

  void (^actionBlock)(int, int) = ^void(int x, int y) {
      float cellWidth = self.bounds.size.width / fieldSize.width;
      float cellHeight = self.bounds.size.height / fieldSize.height;
      NSBezierPath *p = [NSBezierPath bezierPathWithRect:NSMakeRect(x * cellWidth,
                                                                    y * cellHeight,
                                                                    cellWidth - 1,
                                                                    cellHeight - 1)];
      [p fill];
      //[p stroke];
  };


  // Draw the placed pieces
  for (int y = 0; y < fieldSize.height; y++) {
    for (int x = 0; x < fieldSize.width; x++) {
      if ([self.board occupiedPoint:NSMakePoint(x, y)]) actionBlock(x, y);
    }
  }

  // Draw the current piece
  int x = floor(self.piecePoint.x), y = floor(self.piecePoint.y);
  for (int i = 0; i <= 3; i++) {
    uint16_t shape = [self.currentPiece shape] >> (12 - 4 * i);
    if (shape & 0x8) actionBlock(x, y + i);
    if (shape & 0x4) actionBlock(x + 1, y + i);
    if (shape & 0x2) actionBlock(x + 2, y + i);
    if (shape & 0x1) actionBlock(x + 3, y + i);
  }
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
  _board = [[TetrisBoard alloc] initWithSize:fieldSize];

  _speed = SPEED_START;

  [self newPiece];

  _gameTimer = [NSTimer timerWithTimeInterval:(1.0f / FPS)
                                       target:self
                                     selector:@selector(tick)
                                     userInfo:nil
                                      repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:_gameTimer forMode:NSDefaultRunLoopMode];
}

- (void)tick {
  self.step++;
  if (self.step / FPS >= self.speed) {
    self.step = 0;
    self.speed -= SPEED_DECRE;
    if (self.speed < SPEED_MIN) self.speed = SPEED_MIN;
    [self drop];
  }

  [self setNeedsDisplay:YES];
}

- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (void)newPiece {
  if (!self.nextPiece) self.nextPiece = [Tetromino nextTetromino];
  self.currentPiece = self.nextPiece;
  self.piecePoint = NSMakePoint(fieldSize.width / 2 - 2, 0);
  if (![self canMovePieceToPoint:self.piecePoint place:NO]) {
    NSLog(@"YOU LOSE");
    [_gameTimer invalidate];
  }
  self.nextPiece = [Tetromino nextTetromino];
}

- (IBAction)moveUp:(id)sender {
  [self.currentPiece rotate];

  // Check that the new rotation fits. If it doesn't fit because of the edges, try and move
  // it until it does fit. If it doesn't fit for any other reason, or moving doesn't help,
  // undo the rotation.
  NSPoint originalPoint = self.piecePoint;
  while (![self canMovePieceToPoint:self.piecePoint place:NO]) {
    if (self.piecePoint.x < 3) {
      self.piecePoint = NSMakePoint(self.piecePoint.x + 1, self.piecePoint.y);
    } else if (self.piecePoint.x > fieldSize.width - 3) {
      self.piecePoint = NSMakePoint(self.piecePoint.x - 1, self.piecePoint.y);
    } else {
      [self.currentPiece rotateBack];
      self.piecePoint = originalPoint;
      break;
    }
  }
}
- (IBAction)moveLeft:(id)sender  { [self move:dLeft]; }
- (IBAction)moveRight:(id)sender { [self move:dRight]; }
- (IBAction)moveDown:(id)sender  { [self move:dDown]; }

- (void)drop {
  if (![self move:dDown]) {
    [self canMovePieceToPoint:self.piecePoint place:YES];
    self.completedRows += [self.board clearCompleteRows];
    NSLog(@"%d", self.completedRows);
    [self newPiece];
  }
}

- (BOOL)move:(Direction)direction {
  NSPoint newPoint = NSMakePoint(self.piecePoint.x, self.piecePoint.y);

  switch (direction) {
    case dDown: newPoint.y = newPoint.y + 1; break;
    case dLeft: newPoint.x = newPoint.x - 1; break;
    case dRight: newPoint.x = newPoint.x + 1; break;
  }

  if ([self canMovePieceToPoint:newPoint place:NO]) {
    self.piecePoint = newPoint;
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)canMovePieceToPoint:(NSPoint)point place:(BOOL)place {
  int x = floor(point.x), y = floor(point.y);

  int row = 0, col = 0;
  for (int i = 0x8000; i > 0; i = i >> 1) {
    if ([self.currentPiece shape] & i) {
      if (place) {
        [self.board occupyPoint:NSMakePoint(x + col, y + row)];
      } else {
        if ([self.board occupiedPoint:NSMakePoint(x + col, y + row)]) return NO;
      }
    }

    if (++col == 4) {
      col = 0;
      ++row;
    }
  }

  return YES;
}

@end