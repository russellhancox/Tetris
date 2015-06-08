#import "TetrisGame.h"

#import "TetrisBoard.h"
#import "Tetromino.h"

//  The Frames Per Second to play at. This has no real effect on
//  when the blocks fall down, it merely affects how often the tick
//  method is run.
static const uint16_t FPS = 2;

static const float SPEED_START = 0.6;
static const float SPEED_DECRE = 0.005;
static const float SPEED_MIN = 0.1;

typedef enum : NSUInteger {
  DOWN,
  LEFT,
  RIGHT,
} DIR;

@interface TetrisGame ()

/// The game board
@property TetrisBoard *board;

/// The co-ordinates of the current piece.
@property NSPoint piecePoint;

/// The current piece and next piece
@property Tetromino *currentPiece;
@property Tetromino *nextPiece;

@property uint64_t ticks;
@property float step;

/// The current number of completed rows
@property uint16_t completedRows;

/// The repeating timer which calls |tick| to maintain FPS.
@property NSTimer *gameTimer;


@property uint16_t height;
@property uint16_t width;

@end

@implementation TetrisGame

- (instancetype)initWithWidth:(uint16_t)width height:(uint16_t)height {
  self = [super init];
  if (self) {
    _width = width;
    _height = height;

    _step = SPEED_START * 100;

    _board = [[TetrisBoard alloc] initWithWidth:width height:height];

    [self newPiece];

    _gameTimer = [NSTimer timerWithTimeInterval:(1.0f / FPS)
                                         target:self
                                       selector:@selector(tick)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_gameTimer forMode:NSDefaultRunLoopMode];
  }
  return self;
}

- (void)tick {
  [self drop];
}

- (void)newPiece {
  if (!self.nextPiece) self.nextPiece = [Tetromino nextTetromino];
  self.currentPiece = self.nextPiece;
  self.piecePoint = NSMakePoint(self.width / 2 - 2, 0);
  if (![self canMovePieceToRow:self.piecePoint.y column:self.piecePoint.x]) {
    NSLog(@"YOU LOSE");
    [_gameTimer invalidate];
  }
  self.nextPiece = [Tetromino nextTetromino];
}

- (void)drop {
  if (![self move:DOWN]) {
    [self placePiece];
    NSLog(@"%@", self.board);
    [self newPiece];
  }
}

- (BOOL)move:(DIR)direction {
  NSPoint newPoint = NSMakePoint(self.piecePoint.x, self.piecePoint.y);

  switch (direction) {
    case DOWN: newPoint.y = newPoint.y + 1; break;
    case LEFT: newPoint.x = newPoint.x - 1; break;
    case RIGHT: newPoint.x = newPoint.x + 1; break;
  }

  if ([self canMovePieceToRow:newPoint.y column:newPoint.x]) {
    self.piecePoint = newPoint;
    return YES;
  } else {
    return NO;
  }
}

- (void)placePiece {
  uint16_t shape = [self.currentPiece shape];

  for (int i = 0; i < 3; i++) {
    uint16_t sshape = shape >> (12 - 4 * i);
    if (sshape & 0x8) [self.board occupyRow:self.piecePoint.y + i column:self.piecePoint.x + 1];
    if (sshape & 0x4) [self.board occupyRow:self.piecePoint.y + i column:self.piecePoint.x + 2];
    if (sshape & 0x2) [self.board occupyRow:self.piecePoint.y + i column:self.piecePoint.x + 3];
    if (sshape & 0x1) [self.board occupyRow:self.piecePoint.y + i column:self.piecePoint.x + 4];
  }

  self.completedRows += [self.board clearCompleteRows];
}

- (BOOL)canMovePieceToRow:(uint16_t)y column:(uint16_t)x {
  if (x < 0 || x >= self.width - 1 || y < 0 || y >= self.height - 1) return NO;

  uint16_t shape = [self.currentPiece shape];

  for (int i = 0; i < 3; i++) {
    uint16_t sshape = shape >> (12 - 4 * i);
    if (sshape & 0x8 && [self.board occupiedRow:y + i column:x + 1]) return NO;
    if (sshape & 0x4 && [self.board occupiedRow:y + i column:x + 2]) return NO;
    if (sshape & 0x2 && [self.board occupiedRow:y + i column:x + 3]) return NO;
    if (sshape & 0x1 && [self.board occupiedRow:y + i column:x + 4]) return NO;
  }

  return YES;
}


@end