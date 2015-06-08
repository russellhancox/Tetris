#import "Tetromino.h"

typedef enum : NSUInteger {
  ZERO,
  NINETY,
  ONE_EIGHTY,
  TWO_SEVENTY,
} Rotation;

@interface Tetromino ()
@property uint64_t rotations;
@property Rotation currentRotation;

@end

@implementation Tetromino

///  Each of these constants represents one of the standard Tetris shapes,
///  in all 4 of it's rotations. The first 16 bits are rotation 0, the second
///  16 bits are rotation 90 etc.
///  The shapes are:
///
///  ,---,      ,---,  ,---,      ,-------,      ,-------,  ,-----------,  ,-------,
///  | . |      | . |  | . |      | . . . |      | . . . |  | . . . . . |  | . . . |
///  | . |      | . |  | . |      | . . . |  ,---' . ,---'  '---, . ,---'  '---, . '---,
///  | . |  ,---' . |  | . '---,  | . . . |  | . . . |          | . |          | . . . |
///  | . |  | . . . |  | . . . |  '-------'  '-------'          | . |          '-------'
///  '---'  '-------'  '-------'                                '---'
///    I        J          L          O          S                T                Z
///
const uint64_t SHAPES_I = 0x0F00222200F04444;
const uint64_t SHAPES_J = 0x44C08E0064400E20;
const uint64_t SHAPES_L = 0x44600E80C4402E00;
const uint64_t SHAPES_O = 0xCC00CC00CC00CC00;
const uint64_t SHAPES_S = 0x06C08C406C004620;
const uint64_t SHAPES_T = 0x0E404C404E004640;
const uint64_t SHAPES_Z = 0x0C604C80C6002640;

+ (Tetromino *)nextTetromino {
  NSAssert([[NSThread currentThread] isMainThread],
           @"randomTetromino must be called on main thread only");

  ///  Instead of picking the next piece randomly, we fill a 'bag' with 28 pieces,
  ///  4 of each type. We then pick a piece out of this bag at random until the bag
  ///  is empty and then refill it. This is the method most Tetris clones use and is
  ///  probably because picking a piece truly at random can result in a frustrating game.
  static NSMutableArray *piecesBag;
  if (!piecesBag || piecesBag.count < 1) {
#define PIECE(x) [[Tetromino alloc] initWithRotations:SHAPES_##x]
    piecesBag = [@[ PIECE(I), PIECE(I), PIECE(I), PIECE(I),
                    PIECE(J), PIECE(J), PIECE(J), PIECE(J),
                    PIECE(L), PIECE(L), PIECE(L), PIECE(L),
                    PIECE(O), PIECE(O), PIECE(O), PIECE(O),
                    PIECE(S), PIECE(S), PIECE(S), PIECE(S),
                    PIECE(T), PIECE(T), PIECE(T), PIECE(T),
                    PIECE(Z), PIECE(Z), PIECE(Z), PIECE(Z)
    ] mutableCopy];
#undef PIECE
  }

  int pieceNumber = arc4random_uniform((unsigned int)piecesBag.count);
  Tetromino *t = piecesBag[pieceNumber];
  [piecesBag removeObjectAtIndex:pieceNumber];

  return t;
}

- (instancetype)initWithRotations:(uint64_t)rotations {
  self = [super init];
  if (self) {
    _rotations = rotations;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"0x%04hX 0x%04hX 0x%04hX 0x%04hX",
             self.rotationZero, self.rotationNinety,
             self.rotationOneEighty, self.rotationTwoSeventy];
}

- (uint16_t)rotationZero       { return (uint16_t)(self.rotations >> 48); }
- (uint16_t)rotationNinety     { return (uint16_t)(self.rotations >> 32); }
- (uint16_t)rotationOneEighty  { return (uint16_t)(self.rotations >> 16); }
- (uint16_t)rotationTwoSeventy { return (uint16_t)(self.rotations); }

- (uint16_t)shape {
  switch (self.currentRotation) {
    case ZERO: return [self rotationZero];
    case NINETY: return [self rotationNinety];
    case ONE_EIGHTY: return [self rotationOneEighty];
    case TWO_SEVENTY: return [self rotationTwoSeventy];
    default: {
      NSAssert(false, @"self.currentRotation is not valid");
    }
  }
}

- (uint16_t)rotate {
  if (self.currentRotation + 1 > TWO_SEVENTY) {
    self.currentRotation = ZERO;
  } else {
    self.currentRotation++;
  }

  return [self shape];
}

- (uint16_t)rotateBack {
  if (self.currentRotation == ZERO) {
    self.currentRotation = TWO_SEVENTY;
  } else {
    self.currentRotation--;
  }

  return [self shape];
}

@end
