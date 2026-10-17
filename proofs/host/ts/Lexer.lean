import host.ts.Syntax
namespace Host.Ts

/-! Kernel-reducible TypeScript lexer. Each character is classified by its
code point once; the token stream is produced lazily (no `Option` wrapper),
so the parser forces it one token at a time and a lexical error appears as
a trailing `err` token. Regular-expression literals are not supported: `/`
is always division. -/

inductive Kw where
  | break_ | case_ | catch_ | class_ | const_ | continue_ | debugger_ | default_
  | delete_ | do_ | else_ | enum_ | export_ | extends_ | false_ | finally_
  | for_ | function_ | if_ | import_ | in_ | instanceof_ | new_ | null_
  | return_ | super_ | switch_ | this_ | throw_ | true_ | try_ | typeof_
  | var_ | void_ | while_ | with_ | let_ | static_ | yield_ | await_
  | async_ | get_ | set_ | of_ | as_ | from_ | type_ | interface_
  | declare_ | readonly_ | private_ | public_ | protected_ | abstract_ | override_ | satisfies_
  | is_ | keyof_ | infer_ | asserts_ | implements_ | namespace_ | module_ | using_
  | constructor_ | accessor_ | unique_ | global_

/-- Reserved words cannot be identifiers; the rest are contextual. -/
def Kw.reserved : Kw → Bool
  | .break_ => true
  | .case_ => true
  | .catch_ => true
  | .class_ => true
  | .const_ => true
  | .continue_ => true
  | .debugger_ => true
  | .default_ => true
  | .delete_ => true
  | .do_ => true
  | .else_ => true
  | .enum_ => true
  | .export_ => true
  | .extends_ => true
  | .false_ => true
  | .finally_ => true
  | .for_ => true
  | .function_ => true
  | .if_ => true
  | .import_ => true
  | .in_ => true
  | .instanceof_ => true
  | .new_ => true
  | .null_ => true
  | .return_ => true
  | .super_ => true
  | .switch_ => true
  | .this_ => true
  | .throw_ => true
  | .true_ => true
  | .try_ => true
  | .typeof_ => true
  | .var_ => true
  | .void_ => true
  | .while_ => true
  | .with_ => true
  | _ => false

def kwOf : List Char → Option Kw
  | ['b','r','e','a','k'] => some .break_
  | ['c','a','s','e'] => some .case_
  | ['c','a','t','c','h'] => some .catch_
  | ['c','l','a','s','s'] => some .class_
  | ['c','o','n','s','t'] => some .const_
  | ['c','o','n','t','i','n','u','e'] => some .continue_
  | ['d','e','b','u','g','g','e','r'] => some .debugger_
  | ['d','e','f','a','u','l','t'] => some .default_
  | ['d','e','l','e','t','e'] => some .delete_
  | ['d','o'] => some .do_
  | ['e','l','s','e'] => some .else_
  | ['e','n','u','m'] => some .enum_
  | ['e','x','p','o','r','t'] => some .export_
  | ['e','x','t','e','n','d','s'] => some .extends_
  | ['f','a','l','s','e'] => some .false_
  | ['f','i','n','a','l','l','y'] => some .finally_
  | ['f','o','r'] => some .for_
  | ['f','u','n','c','t','i','o','n'] => some .function_
  | ['i','f'] => some .if_
  | ['i','m','p','o','r','t'] => some .import_
  | ['i','n'] => some .in_
  | ['i','n','s','t','a','n','c','e','o','f'] => some .instanceof_
  | ['n','e','w'] => some .new_
  | ['n','u','l','l'] => some .null_
  | ['r','e','t','u','r','n'] => some .return_
  | ['s','u','p','e','r'] => some .super_
  | ['s','w','i','t','c','h'] => some .switch_
  | ['t','h','i','s'] => some .this_
  | ['t','h','r','o','w'] => some .throw_
  | ['t','r','u','e'] => some .true_
  | ['t','r','y'] => some .try_
  | ['t','y','p','e','o','f'] => some .typeof_
  | ['v','a','r'] => some .var_
  | ['v','o','i','d'] => some .void_
  | ['w','h','i','l','e'] => some .while_
  | ['w','i','t','h'] => some .with_
  | ['l','e','t'] => some .let_
  | ['s','t','a','t','i','c'] => some .static_
  | ['y','i','e','l','d'] => some .yield_
  | ['a','w','a','i','t'] => some .await_
  | ['a','s','y','n','c'] => some .async_
  | ['g','e','t'] => some .get_
  | ['s','e','t'] => some .set_
  | ['o','f'] => some .of_
  | ['a','s'] => some .as_
  | ['f','r','o','m'] => some .from_
  | ['t','y','p','e'] => some .type_
  | ['i','n','t','e','r','f','a','c','e'] => some .interface_
  | ['d','e','c','l','a','r','e'] => some .declare_
  | ['r','e','a','d','o','n','l','y'] => some .readonly_
  | ['p','r','i','v','a','t','e'] => some .private_
  | ['p','u','b','l','i','c'] => some .public_
  | ['p','r','o','t','e','c','t','e','d'] => some .protected_
  | ['a','b','s','t','r','a','c','t'] => some .abstract_
  | ['o','v','e','r','r','i','d','e'] => some .override_
  | ['s','a','t','i','s','f','i','e','s'] => some .satisfies_
  | ['i','s'] => some .is_
  | ['k','e','y','o','f'] => some .keyof_
  | ['i','n','f','e','r'] => some .infer_
  | ['a','s','s','e','r','t','s'] => some .asserts_
  | ['i','m','p','l','e','m','e','n','t','s'] => some .implements_
  | ['n','a','m','e','s','p','a','c','e'] => some .namespace_
  | ['m','o','d','u','l','e'] => some .module_
  | ['u','s','i','n','g'] => some .using_
  | ['c','o','n','s','t','r','u','c','t','o','r'] => some .constructor_
  | ['a','c','c','e','s','s','o','r'] => some .accessor_
  | ['u','n','i','q','u','e'] => some .unique_
  | ['g','l','o','b','a','l'] => some .global_
  | _ => none

inductive P where
  | lp | rp | lb | rb | lc | rc | semi | comma | dot | dots | colon | q | qdot
  | arrow | bang | tilde | inc | dec | at

inductive Tok where
  /-- Identifier or keyword; `k` classifies keywords, keeping the name. -/
  | id (n : Name) (k : Option Kw)
  | priv (n : Name)
  | num (raw : List Char) | big (raw : List Char) | str (raw : List Char)
  /-- Template pieces: whole `` `a` ``, head `` `a${ ``, middle `}b${`, tail `` }c` ``. -/
  | tFull (raw : List Char) | tHead (raw : List Char) | tMid (raw : List Char) | tTail (raw : List Char)
  | p (x : P)
  | bin (op : BinOp)
  | asg (op : AsgOp)
  | log (op : LogOp)
  | err (rest : List Char)

/-- A token and whether a line terminator precedes it (for ASI and
restricted productions). -/
inductive T where | mk (nl : Bool) (t : Tok)

def T.tok : T → Tok | .mk _ t => t
def T.nl : T → Bool | .mk n _ => n

def isDigit (n : Nat) : Bool := Nat.ble 48 n && Nat.ble n 57
/-- Tests ordered by frequency: lower case first. -/
def isIdStart (n : Nat) : Bool :=
  bif Nat.ble 97 n then Nat.ble n 122
  else bif Nat.ble 65 n then Nat.ble n 90 || Nat.beq n 95 else Nat.beq n 36
def isIdPart (n : Nat) : Bool :=
  bif Nat.ble 97 n then Nat.ble n 122
  else bif Nat.ble 65 n then Nat.ble n 90 || Nat.beq n 95
  else (Nat.ble 48 n && Nat.ble n 57) || Nat.beq n 36
/-- Digits, letters (hex, exponent, radix prefixes, bigint suffix), `_` and `.`. -/
def isNumPart (n : Nat) : Bool := isIdPart n || Nat.beq n 46

/-! Scanners come in take/drop pairs of simple loops instead of one loop
returning a pair: the kernel evaluates lazily, so token text is only
computed where the parser inspects it, and pair-building recursion costs
several times a plain loop step. -/

def wordTake : List Char → List Char
  | c :: cs => bif isIdPart c.toNat then c :: wordTake cs else []
  | [] => []

def wordDrop : List Char → List Char
  | c :: cs => bif isIdPart c.toNat then wordDrop cs else c :: cs
  | [] => []

def isExp (c d : Char) : Bool := (c == 'e' || c == 'E') && (d == '+' || d == '-')

/-- Decimal number text: `isNumPart` characters and an exponent sign. -/
def numTake : List Char → List Char
  | c :: d :: cs =>
    bif isExp c d then c :: d :: numTake cs
    else bif isNumPart c.toNat then c :: numTake (d :: cs) else []
  | [c] => bif isNumPart c.toNat then [c] else []
  | [] => []

def numDrop : List Char → List Char
  | c :: d :: cs =>
    bif isExp c d then numDrop cs
    else bif isNumPart c.toNat then numDrop (d :: cs) else c :: d :: cs
  | [c] => bif isNumPart c.toNat then [] else [c]
  | [] => []

/-- Raw string body before the closing quote `q`; escapes are kept verbatim. -/
def strTake (q : Char) : List Char → List Char
  | '\\' :: c :: cs => '\\' :: c :: strTake q cs
  | c :: cs => bif c == q then [] else c :: strTake q cs
  | [] => []

def strDrop (q : Char) : List Char → Option (List Char)
  | '\\' :: _ :: cs => strDrop q cs
  | c :: cs => bif c == q then some cs else bif c == '\n' then none else strDrop q cs
  | [] => none

/-- Raw template text up to `` ` `` or `${`. -/
def tmplTake : List Char → List Char
  | '\\' :: c :: cs => '\\' :: c :: tmplTake cs
  | '`' :: _ => []
  | '$' :: '{' :: _ => []
  | c :: cs => c :: tmplTake cs
  | [] => []

/-- Input after the template text, and whether the template ended. -/
def tmplDrop : List Char → Option (Bool × List Char)
  | '\\' :: _ :: cs => tmplDrop cs
  | '`' :: cs => some (true, cs)
  | '$' :: '{' :: cs => some (false, cs)
  | _ :: cs => tmplDrop cs
  | [] => none

def blockDrop : List Char → Option (List Char)
  | '*' :: '/' :: cs => some cs
  | _ :: cs => blockDrop cs
  | [] => none

def blockNl : List Char → Bool
  | '*' :: '/' :: _ => false
  | c :: cs => bif c == '\n' then true else blockNl cs
  | [] => false

def lineComment : List Char → List Char
  | c :: cs => bif c == '\n' then c :: cs else lineComment cs
  | [] => []

def isBlank (n : Nat) : Bool := Nat.beq n 32 || Nat.beq n 10 || Nat.beq n 9 || Nat.beq n 13

def blankDrop : List Char → List Char
  | c :: cs => bif isBlank c.toNat then blankDrop cs else c :: cs
  | [] => []

/-- Whether the leading blanks contain a line feed. -/
def blankNl : List Char → Bool
  | c :: cs => let n := c.toNat; bif Nat.beq n 10 then true else bif isBlank n then blankNl cs else false
  | [] => false

/-! Operators: dispatch on the first code point, then match the few
continuations, instead of one long match whose late arms cost a test per
earlier arm. -/

def opGt : List Char → Tok × List Char
  | '>' :: '>' :: '=' :: cs => (.asg (.bin .ushr), cs)
  | '>' :: '>' :: cs => (.bin .ushr, cs)
  | '>' :: '=' :: cs => (.asg (.bin .shr), cs)
  | '>' :: cs => (.bin .shr, cs)
  | '=' :: cs => (.bin .ge, cs)
  | cs => (.bin .gt, cs)

def opLt : List Char → Tok × List Char
  | '<' :: '=' :: cs => (.asg (.bin .shl), cs)
  | '<' :: cs => (.bin .shl, cs)
  | '=' :: cs => (.bin .le, cs)
  | cs => (.bin .lt, cs)

def opEq : List Char → Tok × List Char
  | '=' :: '=' :: cs => (.bin .seq, cs)
  | '=' :: cs => (.bin .eq, cs)
  | '>' :: cs => (.p .arrow, cs)
  | cs => (.asg .assign, cs)

def opBang : List Char → Tok × List Char
  | '=' :: '=' :: cs => (.bin .sne, cs)
  | '=' :: cs => (.bin .ne, cs)
  | cs => (.p .bang, cs)

def opPlus : List Char → Tok × List Char
  | '+' :: cs => (.p .inc, cs)
  | '=' :: cs => (.asg (.bin .add), cs)
  | cs => (.bin .add, cs)

def opMinus : List Char → Tok × List Char
  | '-' :: cs => (.p .dec, cs)
  | '=' :: cs => (.asg (.bin .sub), cs)
  | cs => (.bin .sub, cs)

def opStar : List Char → Tok × List Char
  | '*' :: '=' :: cs => (.asg (.bin .exp), cs)
  | '*' :: cs => (.bin .exp, cs)
  | '=' :: cs => (.asg (.bin .mul), cs)
  | cs => (.bin .mul, cs)

def opSlash : List Char → Tok × List Char
  | '=' :: cs => (.asg (.bin .div), cs)
  | cs => (.bin .div, cs)

def opPercent : List Char → Tok × List Char
  | '=' :: cs => (.asg (.bin .mod), cs)
  | cs => (.bin .mod, cs)

def opAmp : List Char → Tok × List Char
  | '&' :: '=' :: cs => (.asg (.log .and), cs)
  | '&' :: cs => (.log .and, cs)
  | '=' :: cs => (.asg (.bin .band), cs)
  | cs => (.bin .band, cs)

def opBar : List Char → Tok × List Char
  | '|' :: '=' :: cs => (.asg (.log .or), cs)
  | '|' :: cs => (.log .or, cs)
  | '=' :: cs => (.asg (.bin .bor), cs)
  | cs => (.bin .bor, cs)

def opCaret : List Char → Tok × List Char
  | '=' :: cs => (.asg (.bin .bxor), cs)
  | cs => (.bin .bxor, cs)

/-- `?.` before a digit is a conditional followed by a number. -/
def opQuestion : List Char → Tok × List Char
  | '?' :: '=' :: cs => (.asg (.log .nullish), cs)
  | '?' :: cs => (.log .nullish, cs)
  | '.' :: c :: cs => bif isDigit c.toNat then (.p .q, '.' :: c :: cs) else (.p .qdot, c :: cs)
  | cs => (.p .q, cs)

def opDot : List Char → Tok × List Char
  | '.' :: '.' :: cs => (.p .dots, cs)
  | cs => (.p .dot, cs)

/-- Longest-match operator starting with code point `n`; `cs` follows it. -/
def punct (n : Nat) (cs : List Char) : Option (Tok × List Char) :=
  bif Nat.beq n 40 then some (.p .lp, cs) else bif Nat.beq n 41 then some (.p .rp, cs)
  else bif Nat.beq n 46 then some (opDot cs) else bif Nat.beq n 44 then some (.p .comma, cs)
  else bif Nat.beq n 59 then some (.p .semi, cs) else bif Nat.beq n 58 then some (.p .colon, cs)
  else bif Nat.beq n 61 then some (opEq cs) else bif Nat.beq n 91 then some (.p .lb, cs)
  else bif Nat.beq n 93 then some (.p .rb, cs) else bif Nat.beq n 62 then some (opGt cs)
  else bif Nat.beq n 60 then some (opLt cs) else bif Nat.beq n 43 then some (opPlus cs)
  else bif Nat.beq n 45 then some (opMinus cs) else bif Nat.beq n 42 then some (opStar cs)
  else bif Nat.beq n 33 then some (opBang cs) else bif Nat.beq n 63 then some (opQuestion cs)
  else bif Nat.beq n 38 then some (opAmp cs) else bif Nat.beq n 124 then some (opBar cs)
  else bif Nat.beq n 47 then some (opSlash cs) else bif Nat.beq n 37 then some (opPercent cs)
  else bif Nat.beq n 94 then some (opCaret cs) else bif Nat.beq n 126 then some (.p .tilde, cs)
  else bif Nat.beq n 64 then some (.p .at, cs) else none


/-- Continuation of the lexer loop: line-break flag, template depths, input. -/
abbrev K := Bool → List Nat → List Char → List T

def fail (nl : Bool) (cs : List Char) : List T := [.mk nl (.err cs)]

def lexWord (k : K) (nl : Bool) (depth : List Nat) (cs : List Char) : List T :=
  let w := wordTake cs
  .mk nl (.id w (kwOf w)) :: k false depth (wordDrop cs)

def isHex : List Char → Bool
  | '0' :: c :: _ => c == 'x' || c == 'X' || c == 'b' || c == 'B' || c == 'o' || c == 'O'
  | _ => false

def lexNumberRest (k : K) (nl : Bool) (depth : List Nat) (raw rest : List Char) : List T :=
  match rest with
  | 'n' :: rest => .mk nl (.big raw) :: k false depth rest
  | _ => .mk nl (.num raw) :: k false depth rest

/-- Radix-prefixed numbers have no exponent or fraction. -/
def lexNumber (k : K) (nl : Bool) (depth : List Nat) (cs : List Char) : List T :=
  bif isHex cs then
    let raw := (wordTake cs).filter (· != 'n')
    match (wordTake cs).getLast? with
    | some 'n' => .mk nl (.big raw) :: k false depth (wordDrop cs)
    | _ => .mk nl (.num raw) :: k false depth (wordDrop cs)
  else lexNumberRest k nl depth (numTake cs) (numDrop cs)

def lexString (k : K) (nl : Bool) (depth : List Nat) (q : Char) (cs : List Char) : List T :=
  match strDrop q cs with
  | some rest => .mk nl (.str (strTake q cs)) :: k false depth rest
  | none => fail nl cs

def lexPunct (k : K) (nl : Bool) (depth : List Nat) (n : Nat) (cs : List Char) : List T :=
  match punct n cs with
  | some (t, rest) => .mk nl t :: k false depth rest
  | none => fail nl cs

def lexSlash (k : K) (nl : Bool) (depth : List Nat) (cs : List Char) : List T :=
  match cs with
  | '/' :: '/' :: rest => k nl depth (lineComment rest)
  | '/' :: '*' :: rest =>
    match blockDrop rest with
    | some rest' => k (nl || blockNl rest) depth rest'
    | none => fail nl cs
  | _ :: rest => lexPunct k nl depth 47 rest
  | [] => fail nl []

/-- After `` ` `` (`head`) or a substitution's closing `}`. -/
def lexTemplate (k : K) (nl head : Bool) (ds : List Nat) (cs : List Char) : List T :=
  match tmplDrop cs with
  | some (true, rest) => .mk nl (if head then .tFull (tmplTake cs) else .tTail (tmplTake cs)) :: k false ds rest
  | some (false, rest) => .mk nl (if head then .tHead (tmplTake cs) else .tMid (tmplTake cs)) :: k false (0 :: ds) rest
  | none => fail nl cs

def lexClose (k : K) (nl : Bool) (depth : List Nat) (cs : List Char) : List T :=
  match depth with
  | 0 :: ds => lexTemplate k nl false ds cs
  | (d + 1) :: ds => .mk nl (.p .rc) :: k false (d :: ds) cs
  | [] => .mk nl (.p .rc) :: k false [] cs

def lexOpen (k : K) (nl : Bool) (depth : List Nat) (cs : List Char) : List T :=
  .mk nl (.p .lc) :: k false (match depth with | d :: ds => (d + 1) :: ds | [] => []) cs

def lexPrivate (k : K) (nl : Bool) (depth : List Nat) (cs : List Char) : List T :=
  match wordTake cs with
  | [] => fail nl cs
  | w => .mk nl (.priv w) :: k false depth (wordDrop cs)

def startsNumber (n : Nat) : List Char → Bool
  | d :: _ => isDigit n || (Nat.beq n 46 && isDigit d.toNat)
  | [] => isDigit n

/-- One token after blanks. `depth` holds one open-brace count per enclosing
template substitution; a `}` at count zero resumes the template. -/
def lexToken (k : K) (nl : Bool) (depth : List Nat) (c : Char) (cs : List Char) : List T :=
  let n := c.toNat
  bif isIdStart n then lexWord k nl depth (c :: cs)
  else bif startsNumber n cs then lexNumber k nl depth (c :: cs)
  else bif Nat.beq n 34 || Nat.beq n 39 then lexString k nl depth c cs
  else bif Nat.beq n 47 then lexSlash k nl depth (c :: cs)
  else bif Nat.beq n 96 then lexTemplate k nl true depth cs
  else bif Nat.beq n 123 then lexOpen k nl depth cs
  else bif Nat.beq n 125 then lexClose k nl depth cs
  else bif Nat.beq n 35 then lexPrivate k nl depth cs
  else lexPunct k nl depth n cs

def lexStep (k : K) (nl : Bool) (depth : List Nat) (cs : List Char) : List T :=
  match blankDrop cs with
  | [] => match depth with | [] => [] | _ => fail nl []
  | c :: rest => lexToken k (nl || blankNl cs) depth c rest

/-- Kernel-friendly loop: the recursive body only passes itself to `lexStep`,
so each step instantiates a small definition. -/
def lexAux : Nat → K
  | 0, nl, _, cs => fail nl cs
  | fuel + 1, nl, depth, cs => lexStep (lexAux fuel) nl depth cs

/-- Each token consumes at least one character, so `length + 1` fuel suffices. -/
def lex (cs : List Char) : List T := lexAux (cs.length + 1) true [] cs

end Host.Ts
