.LISTADDR #2999;

LDM LISTADDR R11;
LD  R11 R10; 
INC R11;
DEC R10;

$LOOP:
CPR R11 R13; -- PREVIOUS INDEX OF MIN ELEMENT

PSH R11; -- STARTING ADDRESS
PSH R10; -- LENGTH
JSR MIN;
POP R14; -- INDEX OF MIN ELEMENT
LD  R13 R15;
LD  R14 R16;
CMP R15 R16;
BNQ SWAP1;

$NEXT:
INC R11;
DEC R10;
BEQ END;
BRA LOOP;

$SWAP1:
PSH R13;
PSH R14;
JSR SWAP;
BRA NEXT;

$END:
END;

-----------------------------
-- SUBROUTINE TO SWAP TWO LIST ELEMENTS
-- PARAMETERS: 
-- 1: INDEX OF FIRST ELEMENT
-- 2: INDEX OF SECOND ELEMENT
$SWAP:
POP R1; -- INDEX OF SECOND ELEMENT
POP R0; -- INDEX OF FIRST ELEMENT
-- add your code here <----------------
-- do the swap of R1 and R0
-- you may use R2 and R3 

RTN;
-----------------------------------
-- SUBROUTINE TO FIND THE MIN OF A LIST
-- PARAMETERS:
-- 1: STARTING ADDRESS
-- 2: LENGTH
-- RETURNS:
-- 1: INDEX OF MIN ELEMENT

$MIN:
POP R1; -- LENGTH
POP R0; -- STARTING ADDRESS

CPR R0 R4;
ZRO R29;
INC R29;

$START:
LD  R4 R2;
LDX R0 I1 R3;
CMP R2 R3;
BGT S1; -- NEXT ELEMENT
ADD R0 R29 R4;
CPR R3 R2;

$S1:
INC R29;
DEC R1;
BEQ FIN; -- FINISH
BRA START;

$FIN:
PSH R4;
RTN;