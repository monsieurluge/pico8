# Cheat Sheet

pico-8 v0.1.11g

Online Manual: [link](https://www.lexaloffle.com/pico-8.php?page=manual)

## Colors

```
0=BLACK
1=DARK BLUE
2=DARK PURPLE
3=DARK GREEN
4=BROWN
5=DARK RED
6=ORANGE
7=LIGHT GREY
8=DARK GREY
9=LIGHT BLUE
10=LIGHT PURPLE
11=LIGHT GREEN
12=LIGHT BROWN
13=LIGHT RED
14=YELLOW
15=WHITE
```

## Command Line

```
HELP
SAVE <FILENAME>.P8
LOAD <FILENAME>.P8/("NAME")
RUN
SPLORE
IMPORT X.PNG
EXPORT X.BIN/X.HTML
LS()/DIR
CD
CLS
SHUTDOWN
REBOOT
P/ENTER
FOLDER
MKDIR<DIR_NAME>
```

## Controls

PLAYER 1: LEFT, RIGHT, UP, DOWN, Z, X (OR C, V) (OR N,M)
PLAYER 2: S, F, E, D, LSHIFT, A (OR TAB, Q)
PAUSE: P/ENTER

```
BTN([I],[P])
BTN_P([I],[P])
```

## Functions

```
FUNCTION ADD(A,B)
  RETURN A+B
END
```

## If Statement

```
IF (X==33) THEN
  PRINT("WELL DONE")
ELSEIF (X>33) THEN
  PRINT("PLEASE TRY AGAIN")
ELSE
  BREAK
END
```

## Loops

### Count up

```
FOR I=1,10 DO
  PRINT(I)
END
```

### Count down

```
FOR A=10,0,-2 DO
  PRINT(A)
END
```

### Array

```
FOR S IN ALL (SHIPS) DO
  PRINT(S.NAME)
END
```

### Table

```
FOR K,V IN PAIRS(M) DO
  PRINT("K:"..K..", V:"..V)
END
```

### Repeat block

```
REPEAT
  PRINT("LOOP")
UNTIL <CONDITION>
```

### While block

```
WHILE <CONDITION> DO
  PRINT("LOOP")
END
```

## Map

```
MGET(X,Y)
MSET(X,Y,VALUE)
MAP(CEL_X,CEL_Y,SCR_X,SCR_Y,CELL_W,CELL_H,[LAYER])
```

## Math

```
AND
OR
NOT
BAND(X,Y)
BOR(X,Y)
BXOR(X,Y)
BNOT(X)

SHL(X,N)
SHR(X,N)
LSHR(X,N)

COS(X)
SIN(X)
ATAN2(DY,DX)

FLR(X)
CEIL(X)
ABS(X)
SGN(X)
MAX(A,B)
MIN(A,B)
MID(A,B,C)

SQRT(X)
RND([X])
SRND(X)
```

## Operators

```
+ - * / ^ % =
+= -= *= /= ^= %=
< > <= >= == != ~=
#LIST
"A".."B"
```

## Palette

```
PAL(C0,C1,[P])
PALT(COLOR,TRANSPARENT)
```

## Pixels

```
PGET(X,Y)
PSET(X,Y,[COLOR])
```

## Screen

Size: 128x128 pixels

```
CAMERA([X,Y])
COLOR([COLOR])
CLIP([X,Y,W,H])
```

## Shapes

```
LINE(X0,Y0,X1,Y1,[COLOR])
RECT(X0,Y0,X1,Y1,[COLOR])
RECTF(X0,Y0,X1,Y1,[COLOR])
CIRC(X,Y,R,[COLOR])
CIRCF(X,Y,R,[COLOR])
```

## Shortcuts

### Command Line

```
CHANGE MODE: ESC
FULLSCREEN: ALT+ENTER/F11

RELOAD AND RUN: CTRL+R
SAVE: CTRL+S

SCREENSHOT: F6
CART IMAGE: F7

VIDEO - START: F8
VIDEO - SAVE: F9
```

### Editor

```
UNDO: CTRL+Z
REDO: CTRL+Y

SEARCH: CTRL+F
SEARCH NEXT: CTRL+G

NEXT FUNCTION: ALT+UP/DOWN
PREVIOUS FUNCTION: ALT+UP
```

## Sound

```
SFX(N,[CHANNEL,[OFFSET,[LENGTH]]])
MUSIC([N,[FADE,MASK]])
```

## Special Callbacks

```
_INIT()
_UPDATE()
_UPDATE60()
_DRAW()
```

## Sprites

```
SPR(SPRITE_NUM,X,Y,[W,H],[FLIP_X],[FLIP_Y])
SSPR(SX,SY,SW,SH,DX,DY,[DW,DH],[FLIP_X],[FLIP_Y])
SGET(X,Y)
SSET(X,Y,[COLOR])
```

### Flags

```
FGET(SPRITE_NUM,[FLAG_NUM])
FSET(SPRITE_NUM,[FLAG_NUM],VALUE)
```

## String Manipulation

### casting

```
"123.45"+0
TOSTR(123.45)
TONUM("123.45")
```

### concatenation

```"HELLO"..4```

### length

```#STRING```

## Tables

```
T={A="X",B=1}
ADD(T,V)
DEL(T,V)
COUNT(T)
N={6,8,42,13}
PRINT(N[1]) -- 6
```

## Variables and Types

```
A=NIL
X=23
LOCAL X="TEXT"
T={NAME="JOE",AGE=23}
```
