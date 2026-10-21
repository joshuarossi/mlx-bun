import metal.Token
import metal.Syntax

namespace Metal

/-! # Metal parser

Kernel-reducible recursive-descent parser from preprocessed tokens
(proofs/metal/Preprocess.lean) to the untyped syntax of
proofs/metal/Syntax.lean, after proofs/host/ts/Parser.lean: many small
non-recursive definitions; recursion between grammar levels goes through a
record `Rec` of parsers built by `knot`, one level per unit of nesting fuel;
loops use separate structural fuel. Every parser returns `none` on failure;
there is no error recovery and no token is skipped.

Two C++ ambiguities are decided from what the unit has declared so far
(`ParseCtx`), never by backtracking over a whole construct:
- a name followed by `<` starts template arguments only if it is `as_type`,
  `static_cast`, or a template function defined earlier in the unit
  (the kernel itself in MLX's instantiation line);
- a parenthesis starts a C-style cast only if its tokens up to the next `)`
  are exactly a type, and a statement is a declaration exactly when it starts
  with `constexpr`, `const`, an address space or a type name. Type names are
  the builtin scalar and vector names, the typedef names MLX's preamble
  provides (`bfloat16_t`, `uint8_t`, …), `auto`, `void`, and the template type
  parameters in scope. -/

abbrev Ts := List Tok
abbrev R (α : Type) := Option (α × Ts)

/-- Fuel for loops: each iteration consumes a token. -/
def loopFuel : Nat := 1000000
/-- Fuel for grammar nesting through `knot`. -/
def depthFuel : Nat := 10000

def bnd {α β : Type} (x : R α) (f : α → Ts → R β) : R β :=
  match x with
  | some (a, ts) => f a ts
  | none => none

def nameEq : List Char → List Char → Bool
  | [], [] => true
  | c :: cs, d :: ds => Nat.beq c.toNat d.toNat && nameEq cs ds
  | _, _ => false

def nameIn (n : List Char) : List (List Char) → Bool
  | [] => false
  | m :: ms => nameEq n m || nameIn n ms

/-! ## Words -/

/-- Words the grammar gives meaning to; `reserved` covers the other C++ and
Metal keywords, which are never names. -/
inductive Kw where
  | const_ | constexpr_ | device_ | constant_ | threadgroup_ | thread_
  | static_ | inline_ | template_ | typename_
  | for_ | if_ | else_ | return_ | continue_ | break_
  | true_ | false_ | staticCast | decltype_
  | reserved

def kwOf : List Char → Option Kw
  | ['c','o','n','s','t'] => some .const_
  | ['c','o','n','s','t','e','x','p','r'] => some .constexpr_
  | ['d','e','v','i','c','e'] => some .device_
  | ['c','o','n','s','t','a','n','t'] => some .constant_
  | ['t','h','r','e','a','d','g','r','o','u','p'] => some .threadgroup_
  | ['t','h','r','e','a','d'] => some .thread_
  | ['s','t','a','t','i','c'] => some .static_
  | ['i','n','l','i','n','e'] => some .inline_
  | ['t','e','m','p','l','a','t','e'] => some .template_
  | ['t','y','p','e','n','a','m','e'] => some .typename_
  | ['f','o','r'] => some .for_
  | ['i','f'] => some .if_
  | ['e','l','s','e'] => some .else_
  | ['r','e','t','u','r','n'] => some .return_
  | ['c','o','n','t','i','n','u','e'] => some .continue_
  | ['b','r','e','a','k'] => some .break_
  | ['t','r','u','e'] => some .true_
  | ['f','a','l','s','e'] => some .false_
  | ['s','t','a','t','i','c','_','c','a','s','t'] => some .staticCast
  | ['d','e','c','l','t','y','p','e'] => some .decltype_
  | ['w','h','i','l','e'] | ['d','o'] | ['s','w','i','t','c','h'] | ['c','a','s','e']
  | ['d','e','f','a','u','l','t'] | ['g','o','t','o'] | ['s','i','z','e','o','f']
  | ['s','t','r','u','c','t'] | ['c','l','a','s','s'] | ['u','n','i','o','n'] | ['e','n','u','m']
  | ['u','s','i','n','g'] | ['n','a','m','e','s','p','a','c','e'] | ['t','y','p','e','d','e','f']
  | ['v','o','l','a','t','i','l','e'] | ['s','i','g','n','e','d'] | ['u','n','s','i','g','n','e','d']
  | ['e','x','t','e','r','n'] | ['r','e','g','i','s','t','e','r'] | ['m','u','t','a','b','l','e']
  | ['o','p','e','r','a','t','o','r'] | ['t','h','i','s'] | ['n','e','w'] | ['d','e','l','e','t','e']
  | ['n','u','l','l','p','t','r'] | ['a','l','i','g','n','a','s'] | ['a','l','i','g','n','o','f']
  | ['r','e','i','n','t','e','r','p','r','e','t','_','c','a','s','t']
  | ['c','o','n','s','t','_','c','a','s','t'] | ['d','y','n','a','m','i','c','_','c','a','s','t']
  | ['k','e','r','n','e','l'] | ['v','e','r','t','e','x'] | ['f','r','a','g','m','e','n','t'] => some .reserved
  | _ => none

/-- Scalar names that also have 2-, 3- and 4-vectors (`float4`, `uint3`). -/
def vecBase : List Char → Bool
  | ['b','o','o','l'] | ['c','h','a','r'] | ['u','c','h','a','r'] | ['s','h','o','r','t']
  | ['u','s','h','o','r','t'] | ['i','n','t'] | ['u','i','n','t'] | ['l','o','n','g']
  | ['u','l','o','n','g'] | ['h','a','l','f'] | ['f','l','o','a','t'] | ['b','f','l','o','a','t'] => true
  | _ => false

/-- Type names without vectors: `void`, `auto`, and the fixed-width typedefs. -/
def scalarName : List Char → Bool
  | ['v','o','i','d'] | ['a','u','t','o'] | ['s','i','z','e','_','t']
  | ['i','n','t','8','_','t'] | ['i','n','t','1','6','_','t'] | ['i','n','t','3','2','_','t']
  | ['i','n','t','6','4','_','t'] | ['u','i','n','t','8','_','t'] | ['u','i','n','t','1','6','_','t']
  | ['u','i','n','t','3','2','_','t'] | ['u','i','n','t','6','4','_','t']
  | ['f','l','o','a','t','1','6','_','t'] | ['b','f','l','o','a','t','1','6','_','t'] => true
  | n => vecBase n

def vecSuffix : List Char → Bool
  | [c] => Nat.ble 50 c.toNat && Nat.ble c.toNat 52
  | _ :: cs => vecSuffix cs
  | [] => false

def builtinType (n : List Char) : Bool := scalarName n || (vecSuffix n && vecBase n.dropLast)

/-- What the unit has declared so far. -/
structure ParseCtx where
  /-- Template type parameters in scope. -/
  types : List (List Char) := []
  /-- Template functions defined earlier in the unit. -/
  templates : List (List Char) := []

def ParseCtx.isType (c : ParseCtx) (n : List Char) : Bool := builtinType n || nameIn n c.types

def ParseCtx.isTemplate (c : ParseCtx) (n : List Char) : Bool :=
  nameEq n ['a','s','_','t','y','p','e'] || nameIn n c.templates

def isKw : List Char → Bool
  | n => match kwOf n with | some _ => true | none => false

/-- A name that is neither a keyword nor a type. -/
def ParseCtx.plain (c : ParseCtx) (n : List Char) : Bool := !isKw n && !c.isType n

/-! ## Types -/

def spaceOf : Option Kw → Option Space
  | some .device_ => some .device
  | some .constant_ => some .constant
  | some .threadgroup_ => some .threadgroup
  | some .thread_ => some .thread
  | _ => none

/-- `const` and an address space before a type name, in either order, each at most once. -/
def qualsLoop : Nat → Bool → Option Space → Ts → Option (Bool × Option Space × Ts)
  | 0, _, _, _ => none
  | f + 1, c, s, .ident n :: ts =>
    match kwOf n, spaceOf (kwOf n) with
    | some .const_, _ => bif c then none else qualsLoop f true s ts
    | _, some sp => (match s with | none => qualsLoop f c (some sp) ts | some _ => none)
    | _, _ => some (c, s, .ident n :: ts)
  | _ + 1, c, s, ts => some (c, s, ts)

def typeSpec (c : ParseCtx) (ts : Ts) : R TypeSpec :=
  match qualsLoop 4 false none ts with
  | some (q, s, .ident n :: ts) =>
    bif c.isType n then
      match ts with
      | .punct ['*'] :: ts => some ({ const := q, space := s, name := n, pointer := true }, ts)
      | ts => some ({ const := q, space := s, name := n }, ts)
    else none
  | _ => none

/-- Whether a statement is a declaration. -/
def startsDecl (c : ParseCtx) : Ts → Bool
  | .ident n :: _ =>
    match kwOf n with
    | some .const_ | some .constexpr_ => true
    | k => (spaceOf k).isSome || c.isType n
  | _ => false

/-! ## Expressions and statements -/

/-- Mutually recursive grammar entry points, one nesting level deeper. -/
structure Rec where
  /-- Assignment expression. -/
  assign : Ts → R Expr
  /-- Cast expression: prefix operators, casts, postfix expressions. -/
  unary : Ts → R Expr
  /-- Binary operators binding tighter than the given precedence. -/
  bin : Nat → Ts → R Expr
  stmt : Ts → R Stmt

def argsLoop (r : Rec) : Nat → List Expr → Ts → R (List Expr)
  | 0, _, _ => none
  | f + 1, acc, ts =>
    match r.assign ts with
    | some (e, .punct [','] :: ts) => argsLoop r f (e :: acc) ts
    | some (e, .punct [')'] :: ts) => some ((e :: acc).reverse, ts)
    | _ => none

/-- Call arguments after `(`, through `)`. -/
def args (r : Rec) : Ts → R (List Expr)
  | .punct [')'] :: ts => some ([], ts)
  | ts => argsLoop r loopFuel [] ts

/-- Precedence of relational operators: a template argument's expression
binds tighter, so `>` closes the argument list. -/
def relPrec : Nat := 7

def targ (c : ParseCtx) (r : Rec) (ts : Ts) : R TArg :=
  match typeSpec c ts with
  | some (t, ts) => some (.type t, ts)
  | none => bnd (r.bin relPrec ts) fun e ts => some (.expr e, ts)

def targsLoop (c : ParseCtx) (r : Rec) : Nat → List TArg → Ts → R (List TArg)
  | 0, _, _ => none
  | f + 1, acc, ts =>
    match targ c r ts with
    | some (a, .punct [','] :: ts) => targsLoop c r f (a :: acc) ts
    | some (a, .punct ['>'] :: ts) => some ((a :: acc).reverse, ts)
    | _ => none

/-- Template arguments `<…>`. -/
def targs (c : ParseCtx) (r : Rec) : Ts → R (List TArg)
  | .punct ['<'] :: ts => targsLoop c r loopFuel [] ts
  | _ => none

/-- `::`-qualified continuation of a name. -/
def pathLoop : Nat → List (List Char) → Ts → R (List (List Char))
  | 0, _, _ => none
  | f + 1, acc, .punct [':', ':'] :: .ident n :: ts =>
    bif isKw n then none else pathLoop f (n :: acc) ts
  | _ + 1, acc, ts => some (acc.reverse, ts)

def staticCastP (c : ParseCtx) (r : Rec) : Ts → R Expr
  | .punct ['<'] :: ts =>
    match typeSpec c ts with
    | some (t, .punct ['>'] :: .punct ['('] :: ts) =>
      match r.assign ts with
      | some (e, .punct [')'] :: ts) => some (.cast .static t e, ts)
      | _ => none
    | _ => none
  | _ => none

/-- `T(e)` after the type name. -/
def functionalCast (r : Rec) (n : List Char) : Ts → R Expr
  | .punct ['('] :: ts =>
    match r.assign ts with
    | some (e, .punct [')'] :: ts) => some (.cast .functional { name := n } e, ts)
    | _ => none
  | _ => none

/-- `f<…>(…)` from the template arguments. -/
def templateCall (c : ParseCtx) (r : Rec) (n : List Char) (ts : Ts) : R Expr :=
  bnd (targs c r ts) fun as ts =>
    match ts with
    | .punct ['('] :: ts => bnd (args r ts) fun es ts => some (.call (.name [n]) as es, ts)
    | _ => none

def primaryWord (c : ParseCtx) (r : Rec) (n : List Char) (ts : Ts) : R Expr :=
  match kwOf n with
  | some .true_ => some (.bool true, ts)
  | some .false_ => some (.bool false, ts)
  | some .staticCast => staticCastP c r ts
  | some _ => none
  | none =>
    bif c.isType n then functionalCast r n ts
    else match c.isTemplate n, ts with
      | true, .punct ['<'] :: _ => templateCall c r n ts
      | _, ts => bnd (pathLoop loopFuel [n] ts) fun p ts => some (.name p, ts)

def primary (c : ParseCtx) (r : Rec) : Ts → R Expr
  | .int v u l h :: ts => some (.int v u l h, ts)
  | .float m e s :: ts => some (.float m e s, ts)
  | .ident n :: ts => primaryWord c r n ts
  | _ => none

/-- Subscripts, calls, member accesses and postfix `++`/`--`. -/
def postfixLoop (r : Rec) : Nat → Expr → Ts → R Expr
  | 0, _, _ => none
  | f + 1, e, .punct ['['] :: ts =>
    match r.assign ts with
    | some (i, .punct [']'] :: ts) => postfixLoop r f (.index e i) ts
    | _ => none
  | f + 1, e, .punct ['('] :: ts => bnd (args r ts) fun as ts => postfixLoop r f (.call e [] as) ts
  | f + 1, e, .punct ['.'] :: .ident n :: ts => postfixLoop r f (.member e n) ts
  | f + 1, e, .punct ['+', '+'] :: ts => postfixLoop r f (.step true false e) ts
  | f + 1, e, .punct ['-', '-'] :: ts => postfixLoop r f (.step false false e) ts
  | _ + 1, e, ts => some (e, ts)

/-- After `(`: a type and `)`, so a C-style cast. -/
def castAhead (c : ParseCtx) (ts : Ts) : Option (TypeSpec × Ts) :=
  match typeSpec c ts with
  | some (t, .punct [')'] :: ts) => some (t, ts)
  | _ => none

def un (r : Rec) (op : UnOp) (ts : Ts) : R Expr := bnd (r.unary ts) fun e ts => some (.unary op e, ts)

def unaryP (c : ParseCtx) (r : Rec) : Ts → R Expr
  | .punct ['-'] :: ts => un r .neg ts
  | .punct ['!'] :: ts => un r .not ts
  | .punct ['~'] :: ts => un r .bitNot ts
  | .punct ['*'] :: ts => un r .deref ts
  | .punct ['+', '+'] :: ts => bnd (r.unary ts) fun e ts => some (.step true true e, ts)
  | .punct ['-', '-'] :: ts => bnd (r.unary ts) fun e ts => some (.step false true e, ts)
  | .punct ['('] :: ts =>
    match castAhead c ts with
    | some (t, ts) => bnd (r.unary ts) fun e ts => some (.cast .c t e, ts)
    | none =>
      match r.assign ts with
      | some (e, .punct [')'] :: ts) => postfixLoop r loopFuel e ts
      | _ => none
  | ts => bnd (primary c r ts) (postfixLoop r loopFuel)

/-- C++ precedence, tightest first: multiplicative 10, additive 9, shift 8,
relational 7, equality 6, `&` 5, `^` 4, `|` 3, `&&` 2, `||` 1. -/
def binOf : Tok → Option (Nat × BinOp)
  | .punct ['*'] => some (10, .mul)
  | .punct ['/'] => some (10, .div)
  | .punct ['%'] => some (10, .mod)
  | .punct ['+'] => some (9, .add)
  | .punct ['-'] => some (9, .sub)
  | .punct ['<', '<'] => some (8, .shl)
  | .punct ['>', '>'] => some (8, .shr)
  | .punct ['<'] => some (7, .lt)
  | .punct ['<', '='] => some (7, .le)
  | .punct ['>'] => some (7, .gt)
  | .punct ['>', '='] => some (7, .ge)
  | .punct ['=', '='] => some (6, .eq)
  | .punct ['!', '='] => some (6, .ne)
  | .punct ['&'] => some (5, .bitAnd)
  | .punct ['^'] => some (4, .bitXor)
  | .punct ['|'] => some (3, .bitOr)
  | .punct ['&', '&'] => some (2, .and)
  | .punct ['|', '|'] => some (1, .or)
  | _ => none

/-- Left-associative: right operands bind tighter. -/
def binLoop (r : Rec) (min : Nat) : Nat → Expr → Ts → R Expr
  | 0, _, _ => none
  | _ + 1, l, [] => some (l, [])
  | f + 1, l, t :: ts =>
    match binOf t with
    | some (p, op) =>
      bif Nat.blt min p then bnd (r.bin p ts) fun e ts => binLoop r min f (.binary op l e) ts
      else some (l, t :: ts)
    | none => some (l, t :: ts)

def binP (r : Rec) (min : Nat) (ts : Ts) : R Expr := bnd (r.unary ts) (binLoop r min loopFuel)

/-- `c ? a : b`, right-associative through its last operand. -/
def condP (r : Rec) (ts : Ts) : R Expr :=
  bnd (binP r 0 ts) fun c ts =>
    match ts with
    | .punct ['?'] :: ts =>
      match r.assign ts with
      | some (a, .punct [':'] :: ts) => bnd (r.assign ts) fun b ts => some (.cond c a b, ts)
      | _ => none
    | ts => some (c, ts)

def assignOf : Tok → Option (Option BinOp)
  | .punct ['='] => some none
  | .punct ['+', '='] => some (some .add)
  | .punct ['-', '='] => some (some .sub)
  | .punct ['*', '='] => some (some .mul)
  | .punct ['/', '='] => some (some .div)
  | .punct ['%', '='] => some (some .mod)
  | .punct ['&', '='] => some (some .bitAnd)
  | .punct ['|', '='] => some (some .bitOr)
  | .punct ['^', '='] => some (some .bitXor)
  | .punct ['<', '<', '='] => some (some .shl)
  | .punct ['>', '>', '='] => some (some .shr)
  | _ => none

/-- Right-associative assignment over a conditional expression. -/
def assignP (r : Rec) (ts : Ts) : R Expr :=
  bnd (condP r ts) fun l ts =>
    match ts with
    | t :: rest =>
      match assignOf t with
      | some op => bnd (r.assign rest) fun v ts => some (.assign op l v, ts)
      | none => some (l, t :: rest)
    | [] => some (l, [])

def extentsLoop (r : Rec) : Nat → List Expr → Ts → R (List Expr)
  | 0, _, _ => none
  | f + 1, acc, .punct ['['] :: ts =>
    match r.assign ts with
    | some (e, .punct [']'] :: ts) => extentsLoop r f (e :: acc) ts
    | _ => none
  | _ + 1, acc, ts => some (acc.reverse, ts)

def bracesLoop (r : Rec) : Nat → List Expr → Ts → R (List Expr)
  | 0, _, _ => none
  | f + 1, acc, ts =>
    match r.assign ts with
    | some (e, .punct [','] :: ts) => bracesLoop r f (e :: acc) ts
    | some (e, .punct ['}'] :: ts) => some ((e :: acc).reverse, ts)
    | _ => none

def initP (r : Rec) : Ts → R (Option Init)
  | .punct ['='] :: .punct ['{'] :: .punct ['}'] :: ts => some (some (.braces []), ts)
  | .punct ['='] :: .punct ['{'] :: ts => bnd (bracesLoop r loopFuel [] ts) fun es ts => some (some (.braces es), ts)
  | .punct ['='] :: ts => bnd (r.assign ts) fun e ts => some (some (.expr e), ts)
  | ts => some (none, ts)

def declarator (c : ParseCtx) (r : Rec) : Ts → R Declarator
  | .ident n :: ts =>
    bif c.plain n then
      bnd (extentsLoop r loopFuel [] ts) fun xs ts =>
        bnd (initP r ts) fun i ts => some ({ name := n, extents := xs, init := i }, ts)
    else none
  | _ => none

/-- Declarators through the declaration's `;`. -/
def declaratorsLoop (c : ParseCtx) (r : Rec) : Nat → List Declarator → Ts → R (List Declarator)
  | 0, _, _ => none
  | f + 1, acc, ts =>
    match declarator c r ts with
    | some (d, .punct [','] :: ts) => declaratorsLoop c r f (d :: acc) ts
    | some (d, .punct [';'] :: ts) => some ((d :: acc).reverse, ts)
    | _ => none

def declRest (c : ParseCtx) (r : Rec) (cx : Bool) (ts : Ts) : R Stmt :=
  bnd (typeSpec c ts) fun t ts =>
    bnd (declaratorsLoop c r loopFuel [] ts) fun ds ts =>
      match t.pointer, ds with
      | true, _ :: _ :: _ => none
      | _, _ => some (.decl cx t ds, ts)

def declP (c : ParseCtx) (r : Rec) : Ts → R Stmt
  | .ident n :: ts =>
    match kwOf n with
    | some .constexpr_ => declRest c r true ts
    | _ => declRest c r false (.ident n :: ts)
  | _ => none

def exprStmt (r : Rec) (ts : Ts) : R Stmt :=
  match r.assign ts with
  | some (e, .punct [';'] :: ts) => some (.expr e, ts)
  | _ => none

def forInit (c : ParseCtx) (r : Rec) : Ts → R (Option Stmt)
  | .punct [';'] :: ts => some (none, ts)
  | ts => bif startsDecl c ts then bnd (declP c r ts) fun s ts => some (some s, ts)
    else bnd (exprStmt r ts) fun s ts => some (some s, ts)

def forCond (r : Rec) : Ts → R (Option Expr)
  | .punct [';'] :: ts => some (none, ts)
  | ts =>
    match r.assign ts with
    | some (e, .punct [';'] :: ts) => some (some e, ts)
    | _ => none

def forStep (r : Rec) : Ts → R (Option Expr)
  | .punct [')'] :: ts => some (none, ts)
  | ts =>
    match r.assign ts with
    | some (e, .punct [')'] :: ts) => some (some e, ts)
    | _ => none

/-- After `for`. -/
def forP (c : ParseCtx) (r : Rec) : Ts → R Stmt
  | .punct ['('] :: ts =>
    bnd (forInit c r ts) fun i ts => bnd (forCond r ts) fun k ts => bnd (forStep r ts) fun s ts =>
      bnd (r.stmt ts) fun b ts => some (.loop i k s b, ts)
  | _ => none

/-- After `if`. -/
def ifP (r : Rec) : Ts → R Stmt
  | .punct ['('] :: ts =>
    match r.assign ts with
    | some (c, .punct [')'] :: ts) =>
      bnd (r.stmt ts) fun t ts =>
        match ts with
        | .ident ['e','l','s','e'] :: ts => bnd (r.stmt ts) fun e ts => some (.ite c t (some e), ts)
        | ts => some (.ite c t none, ts)
    | _ => none
  | _ => none

/-- After `return`. -/
def retP (r : Rec) : Ts → R Stmt
  | .punct [';'] :: ts => some (.ret none, ts)
  | ts =>
    match r.assign ts with
    | some (e, .punct [';'] :: ts) => some (.ret (some e), ts)
    | _ => none

def hintOf : List Tok → Option LoopHint
  | [.ident ['c','l','a','n','g'], .ident ['l','o','o','p'], .ident ['u','n','r','o','l','l'],
      .punct ['('], .ident ['f','u','l','l'], .punct [')']] => some .unrollFull
  | [.ident ['c','l','a','n','g'], .ident ['l','o','o','p'],
      .ident ['u','n','r','o','l','l','_','c','o','u','n','t'],
      .punct ['('], .int n false false false, .punct [')']] => some (.unrollCount n)
  | _ => none

/-- A loop hint applies to the `for` statement (or the next hint) after it. -/
def loopAhead : Ts → Bool
  | .ident ['f','o','r'] :: _ => true
  | .pragma _ :: _ => true
  | _ => false

def stmtsLoop (r : Rec) : Nat → List Stmt → Ts → R (List Stmt)
  | 0, _, _ => none
  | _ + 1, acc, .punct ['}'] :: ts => some (acc.reverse, ts)
  | f + 1, acc, ts => bnd (r.stmt ts) fun s ts => stmtsLoop r f (s :: acc) ts

def stmtWord (c : ParseCtx) (r : Rec) (n : List Char) (ts : Ts) : R Stmt :=
  match kwOf n, ts with
  | some .for_, ts => forP c r ts
  | some .if_, ts => ifP r ts
  | some .return_, ts => retP r ts
  | some .continue_, .punct [';'] :: ts => some (.continue_, ts)
  | some .break_, .punct [';'] :: ts => some (.break_, ts)
  | some .continue_, _ | some .break_, _ => none
  | _, ts => bif startsDecl c (.ident n :: ts) then declP c r (.ident n :: ts) else exprStmt r (.ident n :: ts)

def stmtP (c : ParseCtx) (r : Rec) : Ts → R Stmt
  | .punct ['{'] :: ts => bnd (stmtsLoop r loopFuel [] ts) fun b ts => some (.block b, ts)
  | .punct [';'] :: ts => some (.empty, ts)
  | .pragma ps :: ts =>
    match hintOf ps with
    | some h => bif loopAhead ts then bnd (r.stmt ts) fun s ts => some (.pragma h s, ts) else none
    | none => none
  | .ident n :: ts => stmtWord c r n ts
  | ts => exprStmt r ts

def deadRec : Rec := ⟨fun _ => none, fun _ => none, fun _ _ => none, fun _ => none⟩

/-- The grammar one nesting level above `r`. -/
def mkRec (c : ParseCtx) (r : Rec) : Rec := ⟨assignP r, unaryP c r, binP r, stmtP c r⟩

def knot (c : ParseCtx) : Nat → Rec
  | 0 => deadRec
  | n + 1 => mkRec c (knot c n)

def ParseCtx.grammar (c : ParseCtx) : Rec := knot c depthFuel

/-- An expression spanning all of `ts`. -/
def parseExpr (c : ParseCtx) (ts : Ts) : Option Expr :=
  match c.grammar.assign ts with
  | some (e, []) => some e
  | _ => none

def stmtsToEnd (r : Rec) : Nat → List Stmt → Ts → Option (List Stmt)
  | 0, _, _ => none
  | _ + 1, acc, [] => some acc.reverse
  | f + 1, acc, ts =>
    match r.stmt ts with
    | some (s, ts) => stmtsToEnd r f (s :: acc) ts
    | none => none

/-- Statements spanning all of `ts`. -/
def parseStmts (c : ParseCtx) (ts : Ts) : Option (List Stmt) := stmtsToEnd c.grammar loopFuel [] ts

/-! ## Functions and the unit -/

def tparam : Ts → R TParam
  | .ident ['t','y','p','e','n','a','m','e'] :: .ident n :: ts =>
    bif (ParseCtx.plain {} n) then some (.type n, ts) else none
  | .ident ['i','n','t'] :: .ident n :: ts => bif (ParseCtx.plain {} n) then some (.int n, ts) else none
  | .ident ['b','o','o','l'] :: .ident n :: ts => bif (ParseCtx.plain {} n) then some (.bool n, ts) else none
  | _ => none

/-- Template parameters after `template <`, through `>`. -/
def tparamsLoop : Nat → List TParam → Ts → R (List TParam)
  | 0, _, _ => none
  | f + 1, acc, ts =>
    match tparam ts with
    | some (p, .punct [','] :: ts) => tparamsLoop f (p :: acc) ts
    | some (p, .punct ['>'] :: ts) => some ((p :: acc).reverse, ts)
    | _ => none

def typeParams : List TParam → List (List Char)
  | .type n :: ps => n :: typeParams ps
  | _ :: ps => typeParams ps
  | [] => []

/-- `[[buffer(i)]]` or `[[builtin]]` after a parameter name. -/
def attrP : Ts → R (Option Attr)
  | .punct ['['] :: .punct ['['] :: .ident ['b','u','f','f','e','r'] :: .punct ['('] ::
      .int i false false false :: .punct [')'] :: .punct [']'] :: .punct [']'] :: ts => some (some (.buffer i), ts)
  | .punct ['['] :: .punct ['['] :: .ident n :: .punct [']'] :: .punct [']'] :: ts =>
    bif isKw n || nameEq n ['b','u','f','f','e','r'] then none else some (some (.builtin n), ts)
  | .punct ['['] :: _ => none
  | ts => some (none, ts)

def paramP (c : ParseCtx) (ts : Ts) : R Param :=
  bnd (typeSpec c ts) fun t ts =>
    let rf : Bool × Ts := match t.pointer, ts with
      | false, .punct ['&'] :: ts => (true, ts)
      | _, ts => (false, ts)
    match rf.2 with
    | .ident n :: ts =>
      bif c.plain n then bnd (attrP ts) fun a ts => some ({ t, reference := rf.1, name := n, attr := a }, ts)
      else none
    | _ => none

def paramsLoop (c : ParseCtx) : Nat → List Param → Ts → R (List Param)
  | 0, _, _ => none
  | f + 1, acc, ts =>
    match paramP c ts with
    | some (p, .punct [','] :: ts) => paramsLoop c f (p :: acc) ts
    | some (p, .punct [')'] :: ts) => some ((p :: acc).reverse, ts)
    | _ => none

/-- Parameters after `(`, through `)`. -/
def params (c : ParseCtx) : Ts → R (List Param)
  | .punct [')'] :: ts => some ([], ts)
  | ts => paramsLoop c loopFuel [] ts

def kernelAttr : Ts → Bool × Ts
  | .punct ['['] :: .punct ['['] :: .ident ['k','e','r','n','e','l'] :: .punct [']'] :: .punct [']'] :: ts => (true, ts)
  | ts => (false, ts)

/-- `static` and `inline`, as written. -/
def specsLoop : Nat → List (List Char) → Ts → List (List Char) × Ts
  | 0, acc, ts => (acc.reverse, ts)
  | f + 1, acc, .ident n :: ts =>
    match kwOf n with
    | some .static_ | some .inline_ => specsLoop f (n :: acc) ts
    | _ => (acc.reverse, .ident n :: ts)
  | _ + 1, acc, ts => (acc.reverse, ts)

/-- A function definition after its template parameters (if any). -/
def funcP (templates : List (List Char)) (tps : List TParam) (ts : Ts) : R Func :=
  let c : ParseCtx := { types := typeParams tps, templates }
  let k := kernelAttr ts
  let s := specsLoop 3 [] k.2
  bnd (typeSpec c s.2) fun res ts =>
    match ts with
    | .ident n :: .punct ['('] :: ts =>
      bif c.plain n then
        bnd (params c ts) fun ps ts =>
          match ts with
          | .punct ['{'] :: ts =>
            bnd (stmtsLoop c.grammar loopFuel [] ts) fun body ts =>
              some ({ tparams := tps, kernel := k.1, specifiers := s.1, result := res, name := n,
                      params := ps, body }, ts)
          | _ => none
      else none
    | _ => none

/-- A template function's name with its template arguments. -/
def instName (c : ParseCtx) : Ts → R (List Char × List TArg)
  | .ident n :: ts =>
    bif nameIn n c.templates then bnd (targs c c.grammar ts) fun as ts => some ((n, as), ts) else none
  | _ => none

/-- MLX's explicit instantiation after `template`. -/
def instantiateP (templates : List (List Char)) : Ts → R Top
  | .punct ['['] :: .punct ['['] :: .ident ['h','o','s','t','_','n','a','m','e'] :: .punct ['('] :: .str h ::
      .punct [')'] :: .punct [']'] :: .punct [']'] ::
      .punct ['['] :: .punct ['['] :: .ident ['k','e','r','n','e','l'] :: .punct [']'] :: .punct [']'] ::
      .ident ['d','e','c','l','t','y','p','e'] :: .punct ['('] :: ts =>
    match instName { templates } ts with
    | some ((n, as), .punct [')'] :: ts) =>
      match instName { templates } ts with
      | some ((m, bs), .punct [';'] :: ts) =>
        bif nameEq n m && TArg.beqs as bs then some (.instantiate h n as, ts) else none
      | _ => none
    | _ => none
  | _ => none

def topP (templates : List (List Char)) : Ts → R Top
  | .ident ['t','e','m','p','l','a','t','e'] :: .punct ['<'] :: ts =>
    bnd (tparamsLoop loopFuel [] ts) fun tps ts => bnd (funcP templates tps ts) fun f ts => some (.func f, ts)
  | .ident ['t','e','m','p','l','a','t','e'] :: ts => instantiateP templates ts
  | ts => bnd (funcP templates [] ts) fun f ts => some (.func f, ts)

/-- Template functions are visible to the rest of the unit. -/
def declares (tm : List (List Char)) : Top → List (List Char)
  | .func f => match f.tparams with
    | [] => tm
    | _ :: _ => f.name :: tm
  | _ => tm

def unitLoop : Nat → List (List Char) → List Top → Ts → Option (List Top)
  | 0, _, _, _ => none
  | _ + 1, _, acc, [] => some acc.reverse
  | f + 1, tm, acc, ts =>
    match topP tm ts with
    | some (t, ts) => unitLoop f (declares tm t) (t :: acc) ts
    | none => none

/-- The whole unit: kernel header, MLX's signature and body, MLX's instantiation. -/
def parseUnit (ts : List Tok) : Option (List Top) := unitLoop loopFuel [] [] ts

end Metal
