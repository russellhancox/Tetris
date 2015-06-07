#import "TetrisGame.h"

#import "TetrisBoard.h"
#import "Tetromino.h"

//  The Frames Per Second to play at. This has no real effect on
//  when the blocks fall down, it merely affects how often the tick
//  method is run.
static const uint16_t FPS = 30;

static const float SPEED_START = 0.6;
static const float SPEED_DECRE = 0.005;
static const float SPEED_MIN = 0.1;

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

/// The current score and number of completed rows
@property uint16_t score;
@property uint16_t completedRows;

/// The repeating timer which calls |tick| to maintain FPS.
@property NSTimer *gameTimer;

@end

@implementation TetrisGame

- (instancetype)initWithWidth:(uint16_t)width height:(uint16_t)height {
  self = [super init];
  if (self) {
    _board = [[TetrisBoard alloc] initWithWidth:width height:height];
    _currentPiece = [Tetromino nextTetromino];
    _nextPiece = [Tetromino nextTetromino];

    _gameTimer = [NSTimer timerWithTimeInterval:(1 / FPS)
                                         target:self
                                       selector:@selector(tick)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_gameTimer forMode:NSDefaultRunLoopMode];
  }
  return self;
}

- (void)tick {
  self.ticks++;
  if (self.ticks > self.step) {
    self.ticks = self.ticks - self.step;
    [self drop];
  }
}

- (void)newPiece {
  self.currentPiece = self.nextPiece;
  self.piecePoint = NSMakePoint(arc4random_uniform(self.width - 4), 0);
}

- (void)drop {}
- (void)move {}
- (void)placePiece {}


@end