import metal.Token
namespace Metal

/-! # Metal lexer

Kernel-reducible lexer for the route's kernel headers and bodies, after the
TypeScript lexer's style (proofs/host/ts/Lexer.lean): characters are
classified by code point with `Nat.beq`/`Nat.ble`, scanners come in
take/drop pairs, the token stream is produced lazily, and a lexical error
ends the stream with an `err` token.

Translation phases as in C++ [lex.phases]: `splice` deletes every
backslash–newline pair (phase 2); the main loop then forms preprocessing
tokens (phase 3), comments acting as whitespace, and recognizes a
directive at a `#` that is the first token of its line: `#define` (object-
or function-like, `(` immediately after the name) and `#pragma`, each
lexed to the end of its line. Any other directive, `#` elsewhere, and
constructs outside the route's subset (character literals, string
prefixes, octal and hexadecimal-floating literals, digraphs, `...`, `.*`,
`->*`, non-ASCII outside comments) are lexical errors, so the lexer never
gives a valid C++ text a different meaning. Inside a directive line `#`
and `##` are `punct` tokens, which the preprocessor rejects in macro bodies. -/

/-! ## Character classes -/

def isDigit (n : Nat) : Bool := Nat.ble 48 n && Nat.ble n 57

/-- `[A-Za-z_]`, lower case tested first. -/
def isIdStart (n : Nat) : Bool :=
  bif Nat.ble 97 n then Nat.ble n 122
  else bif Nat.ble 65 n then Nat.ble n 90 || Nat.beq n 95 else false

/-- `[A-Za-z0-9_]`. -/
def isIdPart (n : Nat) : Bool :=
  bif Nat.ble 97 n then Nat.ble n 122
  else bif Nat.ble 65 n then Nat.ble n 90 || Nat.beq n 95 else isDigit n

/-- Space, tab, line feed, vertical tab, form feed, carriage return. -/
def isBlank (n : Nat) : Bool := Nat.beq n 32 || (Nat.ble 9 n && Nat.ble n 13)

def charsBeq : List Char → List Char → Bool
  | a :: as, b :: bs => Nat.beq a.toNat b.toNat && charsBeq as bs
  | [], [] => true
  | _, _ => false

/-! ## Phase 2: line splicing -/

/-- Deletes each backslash immediately followed by a line feed. -/
def splice : List Char → List Char
  | c :: d :: ds => bif Nat.beq c.toNat 92 && Nat.beq d.toNat 10 then splice ds else c :: splice (d :: ds)
  | cs => cs
termination_by structural x => x

theorem splice_length_le : ∀ cs : List Char, (splice cs).length ≤ cs.length
  | [] => by simp [splice]
  | [c] => by simp [splice]
  | c :: d :: ds => by
    have h1 := splice_length_le ds
    have h2 := splice_length_le (d :: ds)
    simp only [splice]
    cases Nat.beq c.toNat 92 && Nat.beq d.toNat 10 <;> simp only [Bool.cond_true, Bool.cond_false, List.length_cons] at h2 ⊢ <;> omega

/-! ## Scanners -/

def wordTake : List Char → List Char
  | c :: cs => bif isIdPart c.toNat then c :: wordTake cs else []
  | [] => []

def wordDrop : List Char → List Char
  | c :: cs => bif isIdPart c.toNat then wordDrop cs else c :: cs
  | [] => []

def blankDrop : List Char → List Char
  | c :: cs => bif isBlank c.toNat then blankDrop cs else c :: cs
  | [] => []

/-- Characters of a pp-number after its first: digits, letters, `_`, `.`,
and a sign after `e`, `E`, `p` or `P` ([lex.ppnumber]). -/
def isNumPart (n : Nat) : Bool := isIdPart n || Nat.beq n 46
def isExpChar (n : Nat) : Bool := Nat.beq n 101 || Nat.beq n 69 || Nat.beq n 112 || Nat.beq n 80
def isSign (n : Nat) : Bool := Nat.beq n 43 || Nat.beq n 45

def numTake : List Char → List Char
  | c :: d :: ds =>
    bif isNumPart c.toNat then
      (bif isExpChar c.toNat && isSign d.toNat then c :: d :: numTake ds else c :: numTake (d :: ds))
    else []
  | [c] => bif isNumPart c.toNat then [c] else []
  | [] => []
termination_by structural x => x

def numDrop : List Char → List Char
  | c :: d :: ds =>
    bif isNumPart c.toNat then
      (bif isExpChar c.toNat && isSign d.toNat then numDrop ds else numDrop (d :: ds))
    else c :: d :: ds
  | [c] => bif isNumPart c.toNat then [] else [c]
  | [] => []
termination_by structural x => x

/-- Input from the line feed ending a `//` comment. -/
def lineComment : List Char → List Char
  | c :: cs => bif Nat.beq c.toNat 10 then c :: cs else lineComment cs
  | [] => []

/-- Input after the `*/` closing a block comment. -/
def blockDrop : List Char → Option (List Char)
  | c :: d :: ds => bif Nat.beq c.toNat 42 && Nat.beq d.toNat 47 then some ds else blockDrop (d :: ds)
  | _ => none
termination_by structural x => x

/-! ## Directive lines

A directive extends to the first line feed outside a block comment (which
phase 3 has already replaced by a space). The scan tracks comments and
string literals one character at a time. -/

inductive LineSt where
  | code | slash | block | blockStar | lineComment | str | strEsc

def LineSt.next : LineSt → Nat → LineSt
  | .code, n => bif Nat.beq n 47 then .slash else bif Nat.beq n 34 then .str else .code
  | .slash, n =>
    bif Nat.beq n 42 then .block else bif Nat.beq n 47 then .lineComment
    else bif Nat.beq n 34 then .str else .code
  | .block, n => bif Nat.beq n 42 then .blockStar else .block
  | .blockStar, n => bif Nat.beq n 47 then .code else bif Nat.beq n 42 then .blockStar else .block
  | .lineComment, _ => .lineComment
  | .str, n => bif Nat.beq n 92 then .strEsc else bif Nat.beq n 34 then .code else .str
  | .strEsc, _ => .str

/-- Whether a line feed in this state ends the directive. -/
def LineSt.ends : LineSt → Bool
  | .block | .blockStar => false
  | _ => true

def lineTake : LineSt → List Char → List Char
  | s, c :: cs => let n := c.toNat; bif Nat.beq n 10 && s.ends then [] else c :: lineTake (s.next n) cs
  | _, [] => []

/-- Input from the line feed ending the directive. -/
def lineDrop : LineSt → List Char → List Char
  | s, c :: cs => let n := c.toNat; bif Nat.beq n 10 && s.ends then c :: cs else lineDrop (s.next n) cs
  | _, [] => []

/-! ## Literals -/

def hexDigit (n : Nat) : Option Nat :=
  bif isDigit n then some (n - 48)
  else bif Nat.ble 97 n && Nat.ble n 102 then some (n - 87)
  else bif Nat.ble 65 n && Nat.ble n 70 then some (n - 55)
  else none

def isU (n : Nat) : Bool := Nat.beq n 117 || Nat.beq n 85
def isL (n : Nat) : Bool := Nat.beq n 108 || Nat.beq n 76

/-- Integer suffix: none, `u`/`U`, `l`/`L`, or one of each in either order. -/
def intTok (v : Nat) (hex : Bool) : List Char → Option Tok
  | [] => some (.int v false false hex)
  | [a] =>
    let x := a.toNat
    bif isU x then some (.int v true false hex) else bif isL x then some (.int v false true hex) else none
  | [a, b] =>
    let x := a.toNat
    let y := b.toNat
    bif (isU x && isL y) || (isL x && isU y) then some (.int v true true hex) else none
  | _ => none

/-- Hexadecimal digits after `0x`: value `v`, digit count `nd`. -/
def hexNum (v nd : Nat) : List Char → Option Tok
  | c :: cs =>
    match hexDigit c.toNat with
    | some d => hexNum (v * 16 + d) (nd + 1) cs
    | none => bif Nat.beq nd 0 then none else intTok v true (c :: cs)
  | [] => bif Nat.beq nd 0 then none else some (.int v false false true)

/-- Floating suffix: none (`double`) or `f`/`F`. -/
def floatTok (m : Nat) (e : Int) : List Char → Option Tok
  | [] => some (.float m e false)
  | [c] => let x := c.toNat; bif Nat.beq x 102 || Nat.beq x 70 then some (.float m e true) else none
  | _ => none

/-- Decimal exponent `±x` less the fraction digit count `fd`. -/
def expOf (neg : Bool) (x fd : Nat) : Int := bif neg then Int.negOfNat (x + fd) else Int.subNatNat x fd

/-- Exponent digits: sign `neg`, value `x`, digit count `nx`. -/
def expNum (m fd : Nat) (neg : Bool) (x nx : Nat) : List Char → Option Tok
  | c :: cs =>
    let n := c.toNat
    bif isDigit n then expNum m fd neg (x * 10 + (n - 48)) (nx + 1) cs
    else bif Nat.beq nx 0 then none else floatTok m (expOf neg x fd) (c :: cs)
  | [] => bif Nat.beq nx 0 then none else floatTok m (expOf neg x fd) []

def expSign (m fd : Nat) : List Char → Option Tok
  | c :: cs =>
    let n := c.toNat
    bif Nat.beq n 43 then expNum m fd false 0 0 cs
    else bif Nat.beq n 45 then expNum m fd true 0 0 cs
    else expNum m fd false 0 0 (c :: cs)
  | [] => none

/-- Fraction digits: mantissa so far `m`, fraction digit count `fd`. -/
def fracNum (m fd : Nat) : List Char → Option Tok
  | c :: cs =>
    let n := c.toNat
    bif isDigit n then fracNum (m * 10 + (n - 48)) (fd + 1) cs
    else bif Nat.beq n 101 || Nat.beq n 69 then expSign m fd cs
    else floatTok m (Int.negOfNat fd) (c :: cs)
  | [] => some (.float m (Int.negOfNat fd) false)

/-- Decimal digits: value `v`, digit count `nd`, whether the first is `0`
(a longer integer starting with `0` is octal, which the subset rejects). -/
def decNum (v nd : Nat) (zero : Bool) : List Char → Option Tok
  | c :: cs =>
    let n := c.toNat
    bif isDigit n then decNum (v * 10 + (n - 48)) (nd + 1) zero cs
    else bif Nat.beq n 46 then fracNum v 0 cs
    else bif Nat.beq n 101 || Nat.beq n 69 then expSign v 0 cs
    else bif zero && Nat.blt 1 nd then none else intTok v false (c :: cs)
  | [] => bif zero && Nat.blt 1 nd then none else some (.int v false false false)

def startsZero : List Char → Bool
  | c :: _ => Nat.beq c.toNat 48
  | [] => false

/-- The literal a pp-number spells, if it is in the subset. -/
def numTok (cs : List Char) : Option Tok :=
  match cs with
  | c :: d :: r =>
    bif Nat.beq c.toNat 48 && (Nat.beq d.toNat 120 || Nat.beq d.toNat 88) then hexNum 0 0 r
    else decNum 0 0 (startsZero cs) cs
  | _ => decNum 0 0 (startsZero cs) cs

/-- Simple escape sequences; numeric escapes are outside the subset. -/
def escape (n : Nat) : Option Nat :=
  bif Nat.beq n 110 then some 10
  else bif Nat.beq n 116 then some 9
  else bif Nat.beq n 114 then some 13
  else bif Nat.beq n 92 || Nat.beq n 34 || Nat.beq n 39 || Nat.beq n 63 then some n
  else bif Nat.beq n 97 then some 7
  else bif Nat.beq n 98 then some 8
  else bif Nat.beq n 102 then some 12
  else bif Nat.beq n 118 then some 11
  else none

/-- String body after the opening quote, escapes resolved, and the input
after the closing quote. -/
def strBody : List Char → Option (List Char × List Char)
  | [] => none
  | c :: cs =>
    let n := c.toNat
    bif Nat.beq n 34 then some ([], cs)
    else bif Nat.beq n 10 then none
    else bif Nat.beq n 92 then
      match cs with
      | d :: ds =>
        match escape d.toNat with
        | some e => (strBody ds).map fun r => (Char.ofNat e :: r.1, r.2)
        | none => none
      | [] => none
    else (strBody cs).map fun r => (c :: r.1, r.2)
termination_by structural x => x

/-! ## Tokens

`K` continues lexing after a token: whether the input is at the start of
a line (only blanks and comments since the last line feed), and the input. -/

abbrev K := Bool → List Char → List Tok

def emit (k : K) (t : Tok) (cs : List Char) : List Tok := t :: k false cs

/-- An identifier; one immediately followed by `"` would be a string prefix
or user-defined literal, outside the subset. -/
def lexWord (k : K) (cs : List Char) : List Tok :=
  match wordDrop cs with
  | c :: r => bif Nat.beq c.toNat 34 then [.err cs] else emit k (.ident (wordTake cs)) (c :: r)
  | [] => emit k (.ident (wordTake cs)) []

def lexNumber (k : K) (cs : List Char) : List Tok :=
  match numTok (numTake cs) with
  | some t => emit k t (numDrop cs)
  | none => [.err cs]

/-- After the opening quote. -/
def lexString (k : K) (cs : List Char) : List Tok :=
  match strBody cs with
  | some (s, r) =>
    match r with
    | c :: _ => bif isIdStart c.toNat then [.err cs] else emit k (.str s) r
    | [] => emit k (.str s) r
  | none => [.err cs]

/-- After `/`: a comment (whitespace, keeping the line-start flag) or `/`, `/=`. -/
def lexSlash (k : K) (bol : Bool) (cs : List Char) : List Tok :=
  match cs with
  | c :: r =>
    let n := c.toNat
    bif Nat.beq n 47 then k bol (lineComment r)
    else bif Nat.beq n 42 then
      match blockDrop r with
      | some r' => k bol r'
      | none => [.err cs]
    else bif Nat.beq n 61 then emit k (.punct ['/', '=']) r
    else emit k (.punct ['/']) cs
  | [] => emit k (.punct ['/']) []

/-- `a`, or `a` followed by the character with code `d1` (`t1`) or `d2` (`t2`). -/
def opAlt (k : K) (a : Char) (d1 : Nat) (t1 : Tok) (d2 : Nat) (t2 : Tok) : List Char → List Tok
  | c :: r =>
    let m := c.toNat
    bif Nat.beq m d1 then emit k t1 r else bif Nat.beq m d2 then emit k t2 r else emit k (.punct [a]) (c :: r)
  | [] => emit k (.punct [a]) []

/-- After `-`: `--`, `-=`, `->`, `-`; `->*` is outside the subset. -/
def opMinus (k : K) : List Char → List Tok
  | c :: r =>
    let m := c.toNat
    bif Nat.beq m 45 then emit k (.punct ['-', '-']) r
    else bif Nat.beq m 61 then emit k (.punct ['-', '=']) r
    else bif Nat.beq m 62 then
      match r with
      | d :: _ => bif Nat.beq d.toNat 42 then [.err (c :: r)] else emit k (.punct ['-', '>']) r
      | [] => emit k (.punct ['-', '>']) r
    else emit k (.punct ['-']) (c :: r)
  | [] => emit k (.punct ['-']) []

/-- After `<`: `<<=`, `<<`, `<=`, `<`. `<:` and `<%` are digraphs, outside the
subset, except that `<::` not followed by `:` or `>` is `<` then `::`. -/
def opLt (k : K) : List Char → List Tok
  | c :: r =>
    let m := c.toNat
    bif Nat.beq m 60 then
      match r with
      | d :: r' => bif Nat.beq d.toNat 61 then emit k (.punct ['<', '<', '=']) r' else emit k (.punct ['<', '<']) r
      | [] => emit k (.punct ['<', '<']) r
    else bif Nat.beq m 61 then emit k (.punct ['<', '=']) r
    else bif Nat.beq m 58 then
      match r with
      | d :: e :: _ =>
        bif Nat.beq d.toNat 58 && !(Nat.beq e.toNat 58 || Nat.beq e.toNat 62) then emit k (.punct ['<']) (c :: r)
        else [.err (c :: r)]
      | [d] => bif Nat.beq d.toNat 58 then emit k (.punct ['<']) (c :: r) else [.err (c :: r)]
      | [] => [.err (c :: r)]
    else bif Nat.beq m 37 then [.err (c :: r)]
    else emit k (.punct ['<']) (c :: r)
  | [] => emit k (.punct ['<']) []

/-- After `>`: `>>=`, `>>`, `>=`, `>`. -/
def opGt (k : K) : List Char → List Tok
  | c :: r =>
    let m := c.toNat
    bif Nat.beq m 62 then
      match r with
      | d :: r' => bif Nat.beq d.toNat 61 then emit k (.punct ['>', '>', '=']) r' else emit k (.punct ['>', '>']) r
      | [] => emit k (.punct ['>', '>']) r
    else bif Nat.beq m 61 then emit k (.punct ['>', '=']) r
    else emit k (.punct ['>']) (c :: r)
  | [] => emit k (.punct ['>']) []

/-- After `:`: `::`, `:`; `:>` is a digraph. -/
def opColon (k : K) : List Char → List Tok
  | c :: r =>
    let m := c.toNat
    bif Nat.beq m 58 then emit k (.punct [':', ':']) r
    else bif Nat.beq m 62 then [.err (c :: r)]
    else emit k (.punct [':']) (c :: r)
  | [] => emit k (.punct [':']) []

/-- After `%`: `%=`, `%`; `%>` and `%:` are digraphs. -/
def opPercent (k : K) : List Char → List Tok
  | c :: r =>
    let m := c.toNat
    bif Nat.beq m 61 then emit k (.punct ['%', '=']) r
    else bif Nat.beq m 62 || Nat.beq m 58 then [.err (c :: r)]
    else emit k (.punct ['%']) (c :: r)
  | [] => emit k (.punct ['%']) []

/-- After `.` (not starting a number): `.`; `.*` and `...` are outside the subset. -/
def opDot (k : K) : List Char → List Tok
  | c :: r =>
    let m := c.toNat
    bif Nat.beq m 42 then [.err (c :: r)]
    else bif Nat.beq m 46 then
      match r with
      | d :: _ => bif Nat.beq d.toNat 46 then [.err (c :: r)] else emit k (.punct ['.']) (c :: r)
      | [] => emit k (.punct ['.']) (c :: r)
    else emit k (.punct ['.']) (c :: r)
  | [] => emit k (.punct ['.']) []

/-- Longest-match operator or punctuation starting with `c` (code `n`). -/
def lexPunct (k : K) (n : Nat) (c : Char) (cs : List Char) : List Tok :=
  bif Nat.beq n 40 || Nat.beq n 41 || Nat.beq n 59 || Nat.beq n 44 || Nat.beq n 91 || Nat.beq n 93
    || Nat.beq n 123 || Nat.beq n 125 || Nat.beq n 63 || Nat.beq n 126 then emit k (.punct [c]) cs
  else bif Nat.beq n 61 then opAlt k c 61 (.punct ['=', '=']) 61 (.punct ['=', '=']) cs
  else bif Nat.beq n 42 then opAlt k c 61 (.punct ['*', '=']) 61 (.punct ['*', '=']) cs
  else bif Nat.beq n 43 then opAlt k c 43 (.punct ['+', '+']) 61 (.punct ['+', '=']) cs
  else bif Nat.beq n 60 then opLt k cs
  else bif Nat.beq n 62 then opGt k cs
  else bif Nat.beq n 45 then opMinus k cs
  else bif Nat.beq n 46 then opDot k cs
  else bif Nat.beq n 58 then opColon k cs
  else bif Nat.beq n 38 then opAlt k c 38 (.punct ['&', '&']) 61 (.punct ['&', '=']) cs
  else bif Nat.beq n 124 then opAlt k c 124 (.punct ['|', '|']) 61 (.punct ['|', '=']) cs
  else bif Nat.beq n 33 then opAlt k c 61 (.punct ['!', '=']) 61 (.punct ['!', '=']) cs
  else bif Nat.beq n 94 then opAlt k c 61 (.punct ['^', '=']) 61 (.punct ['^', '=']) cs
  else bif Nat.beq n 37 then opPercent k cs
  else [.err (c :: cs)]

def startsNumber (n : Nat) : List Char → Bool
  | d :: _ => isDigit n || (Nat.beq n 46 && isDigit d.toNat)
  | [] => isDigit n

/-- A token other than `#` starting with `c` (code `n`). -/
def lexCommon (k : K) (bol : Bool) (n : Nat) (c : Char) (cs : List Char) : List Tok :=
  bif isIdStart n then lexWord k (c :: cs)
  else bif startsNumber n cs then lexNumber k (c :: cs)
  else bif Nat.beq n 47 then lexSlash k bol cs
  else bif Nat.beq n 34 then lexString k cs
  else lexPunct k n c cs

/-! ## Directive lines -/

/-- `#` or `##` inside a directive line. -/
def lexHash (k : K) : List Char → List Tok
  | c :: r => bif Nat.beq c.toNat 35 then emit k (.punct ['#', '#']) r else emit k (.punct ['#']) (c :: r)
  | [] => emit k (.punct ['#']) []

def flatStep (k : K) (bol : Bool) : List Char → List Tok
  | [] => []
  | c :: cs =>
    let n := c.toNat
    bif isBlank n then k bol cs
    else bif Nat.beq n 35 then lexHash k cs
    else lexCommon k bol n c cs

def flatAux : Nat → K
  | 0, _, cs => [.err cs]
  | fuel + 1, bol, cs => flatStep (flatAux fuel) bol cs

/-- Tokens of one directive line (no directives inside). Each step consumes
a character, so `length + 1` fuel suffices. -/
def lexFlat (cs : List Char) : List Tok := flatAux (cs.length + 1) false cs

def noErr : List Tok → Bool
  | .err _ :: _ => false
  | _ :: ts => noErr ts
  | [] => true

/-- Parameter list after `(`: names separated by `,`, then `)`. -/
def paramList : List Tok → Option (List (List Char) × List Tok)
  | .ident a :: .punct p :: r =>
    bif charsBeq p [')'] then some ([a], r)
    else bif charsBeq p [','] then (paramList r).map fun q => (a :: q.1, q.2)
    else none
  | _ => none
termination_by structural x => x

def paramsOf : List Tok → Option (List (List Char) × List Tok)
  | .punct p :: r => bif charsBeq p [')'] then some ([], r) else none
  | ts => paramList ts

def defineName : List Char := ['d', 'e', 'f', 'i', 'n', 'e']
def pragmaName : List Char := ['p', 'r', 'a', 'g', 'm', 'a']

/-- `#define` after the directive name and blanks. -/
def defineTok (cs : List Char) : Option Tok :=
  match cs with
  | c :: _ =>
    bif isIdStart c.toNat then
      match wordDrop cs with
      | '(' :: ps =>
        match paramsOf (lexFlat ps) with
        | some (params, body) => bif noErr body then some (.defineFunction (wordTake cs) params body) else none
        | none => none
      | r => let body := lexFlat r; bif noErr body then some (.defineObject (wordTake cs) body) else none
    else none
  | [] => none

/-- The directive on the line after `#`. -/
def directiveTok (line : List Char) : Option Tok :=
  let l := blankDrop line
  let w := wordTake l
  let r := wordDrop l
  bif charsBeq w pragmaName then (let ts := lexFlat r; bif noErr ts then some (.pragma ts) else none)
  else bif charsBeq w defineName then defineTok (blankDrop r)
  else none

/-- After a `#` that starts a line. -/
def lexDirective (k : K) (cs : List Char) : List Tok :=
  match directiveTok (lineTake .code cs) with
  | some t => emit k t (lineDrop .code cs)
  | none => [.err ('#' :: cs)]

/-! ## Main loop -/

def mainStep (k : K) (bol : Bool) : List Char → List Tok
  | [] => []
  | c :: cs =>
    let n := c.toNat
    bif Nat.beq n 10 then k true cs
    else bif isBlank n then k bol cs
    else bif Nat.beq n 35 then (bif bol then lexDirective k cs else [.err (c :: cs)])
    else lexCommon k bol n c cs

def mainAux : Nat → K
  | 0, _, cs => [.err cs]
  | fuel + 1, bol, cs => mainStep (mainAux fuel) bol cs

/-- Each step consumes a character and splicing never lengthens the input
(`splice_length_le`), so `length + 1` fuel suffices. -/
def lex (cs : List Char) : List Tok := mainAux (cs.length + 1) true (splice cs)

end Metal
