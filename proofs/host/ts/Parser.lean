import host.ts.Lexer
namespace Host.Ts

/-! Kernel-reducible recursive-descent parser with TypeScript erasure.

Kernel reduction instantiates the whole body of every unfolded definition,
so the parser is many small non-recursive definitions. Recursion between
grammar levels goes through a record `Rec` of parsers built by `knot`, one
level per unit of nesting fuel; loops use separate structural fuel. Every
parser returns `none` on failure; there is no error recovery. -/

abbrev Ts := List T
abbrev R (α : Type) := Option (α × Ts)

def Kw.code : Kw → Nat
  | .break_ => 0
  | .case_ => 1
  | .catch_ => 2
  | .class_ => 3
  | .const_ => 4
  | .continue_ => 5
  | .debugger_ => 6
  | .default_ => 7
  | .delete_ => 8
  | .do_ => 9
  | .else_ => 10
  | .enum_ => 11
  | .export_ => 12
  | .extends_ => 13
  | .false_ => 14
  | .finally_ => 15
  | .for_ => 16
  | .function_ => 17
  | .if_ => 18
  | .import_ => 19
  | .in_ => 20
  | .instanceof_ => 21
  | .new_ => 22
  | .null_ => 23
  | .return_ => 24
  | .super_ => 25
  | .switch_ => 26
  | .this_ => 27
  | .throw_ => 28
  | .true_ => 29
  | .try_ => 30
  | .typeof_ => 31
  | .var_ => 32
  | .void_ => 33
  | .while_ => 34
  | .with_ => 35
  | .let_ => 36
  | .static_ => 37
  | .yield_ => 38
  | .await_ => 39
  | .async_ => 40
  | .get_ => 41
  | .set_ => 42
  | .of_ => 43
  | .as_ => 44
  | .from_ => 45
  | .type_ => 46
  | .interface_ => 47
  | .declare_ => 48
  | .readonly_ => 49
  | .private_ => 50
  | .public_ => 51
  | .protected_ => 52
  | .abstract_ => 53
  | .override_ => 54
  | .satisfies_ => 55
  | .is_ => 56
  | .keyof_ => 57
  | .infer_ => 58
  | .asserts_ => 59
  | .implements_ => 60
  | .namespace_ => 61
  | .module_ => 62
  | .using_ => 63
  | .constructor_ => 64
  | .accessor_ => 65
  | .unique_ => 66
  | .global_ => 67

def P.code : P → Nat
  | .lp => 0
  | .rp => 1
  | .lb => 2
  | .rb => 3
  | .lc => 4
  | .rc => 5
  | .semi => 6
  | .comma => 7
  | .dot => 8
  | .dots => 9
  | .colon => 10
  | .q => 11
  | .qdot => 12
  | .arrow => 13
  | .bang => 14
  | .tilde => 15
  | .inc => 16
  | .dec => 17
  | .at => 18

def peq (x y : P) : Bool := Nat.beq x.code y.code
def kweq (x y : Kw) : Bool := Nat.beq x.code y.code

/-- Fuel for loops: each iteration consumes a token. -/
def loopFuel : Nat := 1000000
/-- Fuel for grammar nesting through `knot`. -/
def depthFuel : Nat := 10000

def bnd {α β : Type} (x : R α) (f : α → Ts → R β) : R β :=
  match x with
  | some (a, ts) => f a ts
  | none => none

def isP (x : P) : Ts → Bool
  | .mk _ (.p y) :: _ => peq x y
  | _ => false

def eat (x : P) : Ts → Option Ts
  | .mk _ (.p y) :: ts => bif peq x y then some ts else none
  | _ => none

def eatKw (k : Kw) : Ts → Option Ts
  | .mk _ (.id _ (some k')) :: ts => bif kweq k k' then some ts else none
  | _ => none

def isKw (k : Kw) : Ts → Bool
  | .mk _ (.id _ (some k')) :: _ => kweq k k'
  | _ => false

/-- Identifier usable as a binding or reference. -/
def ident : Ts → R Name
  | .mk _ (.id n none) :: ts => some (n, ts)
  | .mk _ (.id n (some k)) :: ts => bif k.reserved then none else some (n, ts)
  | _ => none

def startsBinding : Ts → Bool
  | .mk _ (.id _ none) :: _ => true
  | .mk _ (.id _ (some k)) :: _ => !k.reserved
  | .mk _ (.p .lb) :: _ => true
  | .mk _ (.p .lc) :: _ => true
  | _ => false

/-- Statement terminator: `;`, or automatic insertion before `}`, at the end
of input or after a line break. -/
def semi : Ts → Option Ts
  | .mk _ (.p .semi) :: ts => some ts
  | .mk nl (.p .rc) :: ts => some (.mk nl (.p .rc) :: ts)
  | [] => some []
  | t :: ts => bif t.nl then some (t :: ts) else none

/-- A `>` closing type arguments, splitting `>>`, `>=` and the like. -/
def closeAngle : Ts → Option Ts
  | .mk _ (.bin .gt) :: ts => some ts
  | .mk _ (.bin .shr) :: ts => some (.mk false (.bin .gt) :: ts)
  | .mk _ (.bin .ushr) :: ts => some (.mk false (.bin .shr) :: ts)
  | .mk _ (.bin .ge) :: ts => some (.mk false (.asg .assign) :: ts)
  | .mk _ (.asg (.bin .shr)) :: ts => some (.mk false (.bin .ge) :: ts)
  | .mk _ (.asg (.bin .ushr)) :: ts => some (.mk false (.asg (.bin .shr)) :: ts)
  | _ => none

def opens : Tok → Bool
  | .p .lp | .p .lb | .p .lc | .tHead _ => true
  | _ => false

def closes : Tok → Bool
  | .p .rp | .p .rb | .p .rc | .tTail _ => true
  | _ => false

/-- Input after the group closing at depth zero; starts after its opener.
Only for erased type syntax: bracket kinds are not matched. -/
def skipGroup : Nat → Nat → Ts → Option Ts
  | 0, _, _ => none
  | _ + 1, _, [] => none
  | f + 1, d, t :: ts =>
    bif opens t.tok then skipGroup f (d + 1) ts
    else bif closes t.tok then (match d with | 0 => some ts | d + 1 => skipGroup f d ts)
    else skipGroup f d ts

def group (ts : Ts) : Option Ts := skipGroup loopFuel 0 ts

/-! ## Erased type syntax -/

structure TRec where
  ty : Ts → Option Ts
  union : Ts → Option Ts
  operand : Ts → Option Ts

def tyArgsLoop (t : TRec) : Nat → Ts → Option Ts
  | 0, _ => none
  | f + 1, ts =>
    match t.ty ts with
    | some (.mk _ (.p .comma) :: ts) =>
      match closeAngle ts with
      | some ts => some ts
      | none => tyArgsLoop t f ts
    | some ts => closeAngle ts
    | none => none

/-- `<T, U>` type arguments. -/
def tyArgs (t : TRec) : Ts → Option Ts
  | .mk _ (.bin .lt) :: ts => tyArgsLoop t loopFuel ts
  | _ => none

def tyParamDefault (t : TRec) : Ts → Option Ts
  | .mk _ (.asg .assign) :: ts => t.ty ts
  | ts => some ts

def tyParamName : Ts → Option Ts
  | .mk _ (.id _ (some .const_)) :: .mk _ (.id _ _) :: ts => some ts
  | .mk _ (.id _ _) :: ts => some ts
  | _ => none

def tyParam (t : TRec) (ts : Ts) : Option Ts :=
  match tyParamName ts with
  | some (.mk _ (.id _ (some .extends_)) :: ts) => (t.ty ts).bind (tyParamDefault t)
  | some ts => tyParamDefault t ts
  | none => none

def tyParamsLoop (t : TRec) : Nat → Ts → Option Ts
  | 0, _ => none
  | f + 1, ts =>
    match tyParam t ts with
    | some (.mk _ (.p .comma) :: ts) =>
      match closeAngle ts with
      | some ts => some ts
      | none => tyParamsLoop t f ts
    | some ts => closeAngle ts
    | none => none

/-- `<T extends U = V>` type parameters. -/
def tyParams (t : TRec) : Ts → Option Ts
  | .mk _ (.bin .lt) :: ts => tyParamsLoop t loopFuel ts
  | _ => none

/-- After a type name: qualified parts and type arguments. -/
def tyName (t : TRec) : Nat → Ts → Option Ts
  | 0, _ => none
  | f + 1, .mk _ (.p .dot) :: .mk _ (.id _ _) :: ts => tyName t f ts
  | _ + 1, .mk nl (.bin .lt) :: ts => tyArgs t (.mk nl (.bin .lt) :: ts)
  | _ + 1, ts => some ts

/-- After `(`: a function type `(...) => T` or a parenthesized type. -/
def tyParen (t : TRec) (ts : Ts) : Option Ts :=
  match group ts with
  | some (.mk _ (.p .arrow) :: ts) => t.ty ts
  | r => r

/-- Type predicate `x is T` after a name. -/
def tyPredicate (t : TRec) : Ts → Option Ts
  | .mk _ (.id _ (some .is_)) :: ts => t.ty ts
  | ts => some ts

def tyWord (t : TRec) (k : Option Kw) (ts : Ts) : Option Ts :=
  match k with
  | some .keyof_ => t.operand ts
  | some .readonly_ => t.operand ts
  | some .unique_ => t.operand ts
  | some .infer_ => (match ts with | .mk _ (.id _ _) :: ts => some ts | _ => none)
  | some .new_ => (match ts with | .mk _ (.p .lp) :: ts => tyParen t ts | _ => none)
  | some .asserts_ => (match ts with | .mk _ (.id _ _) :: ts => tyPredicate t ts | _ => none)
  | some .typeof_ => (match ts with | .mk _ (.id _ _) :: ts => tyName t loopFuel ts | _ => none)
  | some .import_ => (match ts with | .mk _ (.p .lp) :: ts => (group ts).bind (tyName t loopFuel) | _ => none)
  | _ => (tyName t loopFuel ts).bind (tyPredicate t)

def tyPrimary (t : TRec) : Ts → Option Ts
  | .mk _ (.id _ k) :: ts => tyWord t k ts
  | .mk _ (.p .lp) :: ts => tyParen t ts
  | .mk _ (.p .lb) :: ts => group ts
  | .mk _ (.p .lc) :: ts => group ts
  | .mk _ (.tHead _) :: ts => group ts
  | .mk _ (.tFull _) :: ts => some ts
  | .mk _ (.str _) :: ts => some ts
  | .mk _ (.num _) :: ts => some ts
  | .mk _ (.big _) :: ts => some ts
  | .mk _ (.bin .sub) :: .mk _ (.num _) :: ts => some ts
  | .mk nl (.bin .lt) :: ts =>
    match tyParams t (.mk nl (.bin .lt) :: ts) with
    | some (.mk _ (.p .lp) :: ts) => tyParen t ts
    | _ => none
  | _ => none

/-- Array and indexed-access suffixes on the same line. -/
def tyPostfix (t : TRec) : Nat → Ts → Option Ts
  | 0, _ => none
  | f + 1, .mk false (.p .lb) :: .mk _ (.p .rb) :: ts => tyPostfix t f ts
  | f + 1, .mk false (.p .lb) :: ts =>
    match t.ty ts with
    | some (.mk _ (.p .rb) :: ts) => tyPostfix t f ts
    | _ => none
  | _ + 1, ts => some ts

def tyOperand (t : TRec) (ts : Ts) : Option Ts := (tyPrimary t ts).bind (tyPostfix t loopFuel)

def tyUnionLoop (t : TRec) : Nat → Ts → Option Ts
  | 0, _ => none
  | f + 1, .mk _ (.bin .bor) :: ts => (t.operand ts).bind (tyUnionLoop t f)
  | f + 1, .mk _ (.bin .band) :: ts => (t.operand ts).bind (tyUnionLoop t f)
  | _ + 1, ts => some ts

def tyLead : Ts → Ts
  | .mk _ (.bin .bor) :: ts => ts
  | .mk _ (.bin .band) :: ts => ts
  | ts => ts

def tyUnion (t : TRec) (ts : Ts) : Option Ts := (t.operand (tyLead ts)).bind (tyUnionLoop t loopFuel)

def tyCond (t : TRec) : Ts → Option Ts
  | .mk _ (.p .q) :: ts =>
    match t.ty ts with
    | some (.mk _ (.p .colon) :: ts) => t.ty ts
    | _ => none
  | _ => none

/-- Full type: a union, or a conditional `A extends B ? C : D`. -/
def tyFull (t : TRec) (ts : Ts) : Option Ts :=
  match t.union ts with
  | some (.mk _ (.id _ (some .extends_)) :: ts) => (t.union ts).bind (tyCond t)
  | r => r

def tyDead : TRec := ⟨fun _ => none, fun _ => none, fun _ => none⟩

def tyKnot : Nat → TRec
  | 0 => tyDead
  | n + 1 => let t := tyKnot n; ⟨tyFull t, tyUnion t, tyOperand t⟩

def tyRec : TRec := tyKnot depthFuel
def ty (ts : Ts) : Option Ts := tyRec.ty ts

/-- Optional `: T` annotation. -/
def annot : Ts → Option Ts
  | .mk _ (.p .colon) :: ts => ty ts
  | ts => some ts

def optTyParams : Ts → Option Ts
  | .mk nl (.bin .lt) :: ts => tyParams tyRec (.mk nl (.bin .lt) :: ts)
  | ts => some ts

/-- Optional-member `?` or definite-assignment `!` marker. -/
def marker : Ts → Ts
  | .mk _ (.p .q) :: ts => ts
  | .mk false (.p .bang) :: ts => ts
  | ts => ts

/-! ## Expressions and statements -/

/-- Mutually recursive grammar entry points, one nesting level deeper. -/
structure Rec where
  assign : Ts → R Expr
  expr : Ts → R Expr
  unary : Ts → R Expr
  bin : Nat → Ts → R Expr
  lhs : Ts → R Expr
  binding : Ts → R Pat
  stmt : Ts → R (Option Stmt)
  /-- A function body's statements after its `{`, through the closing `}`. -/
  stmts : Ts → R (List Stmt)
  /-- A class body's members after its `{`, through the closing `}`. -/
  members : Ts → R (List Member)

/-- Comma-separated items up to `close`; a trailing comma is allowed. -/
def listLoop {α : Type} (close : P) (p : Ts → R α) : Nat → List α → Ts → R (List α)
  | 0, _, _ => none
  | f + 1, acc, ts =>
    match eat close ts with
    | some ts => some (acc.reverse, ts)
    | none =>
      match p ts with
      | some (a, .mk _ (.p .comma) :: ts) => listLoop close p f (a :: acc) ts
      | some (a, ts) => (eat close ts).map fun ts => ((a :: acc).reverse, ts)
      | none => none

def list {α : Type} (close : P) (p : Ts → R α) (ts : Ts) : R (List α) := listLoop close p loopFuel [] ts

def elem (r : Rec) : Ts → R Elem
  | .mk _ (.p .dots) :: ts => bnd (r.assign ts) fun e ts => some (.spread e, ts)
  | ts => bnd (r.assign ts) fun e ts => some (.expr e, ts)

/-- An array element; a hole leaves its comma for the list loop. -/
def arrElem (r : Rec) : Ts → R Elem
  | .mk nl (.p .comma) :: ts => some (.hole, .mk nl (.p .comma) :: ts)
  | ts => elem r ts

def key (r : Rec) : Ts → R Key
  | .mk _ (.id n _) :: ts => some (.id n, ts)
  | .mk _ (.str s) :: ts => some (.str s, ts)
  | .mk _ (.num s) :: ts => some (.num s, ts)
  | .mk _ (.priv n) :: ts => some (.priv n, ts)
  | .mk _ (.p .lb) :: ts => bnd (r.assign ts) fun e ts => (eat .rb ts).map fun ts => (.computed e, ts)
  | _ => none

def withDefault (r : Rec) (p : Pat) : Ts → R Pat
  | .mk _ (.asg .assign) :: ts => bnd (r.assign ts) fun d ts => some (.dflt p d, ts)
  | ts => some (p, ts)

def elemPat (r : Rec) (ts : Ts) : R Pat := bnd (r.binding ts) (withDefault r)

def arrPatLoop (r : Rec) : Nat → List (Option Pat) → Ts → R Pat
  | 0, _, _ => none
  | _ + 1, acc, .mk _ (.p .rb) :: ts => some (.array acc.reverse none, ts)
  | f + 1, acc, .mk _ (.p .comma) :: ts => arrPatLoop r f (none :: acc) ts
  | _ + 1, acc, .mk _ (.p .dots) :: ts =>
    bnd (r.binding ts) fun p ts => (eat .rb ts).map fun ts => (.array acc.reverse (some p), ts)
  | f + 1, acc, ts =>
    match elemPat r ts with
    | some (p, .mk _ (.p .comma) :: ts) => arrPatLoop r f (some p :: acc) ts
    | some (p, .mk _ (.p .rb) :: ts) => some (.array (some p :: acc).reverse none, ts)
    | _ => none

def objPatProp (r : Rec) (ts : Ts) : R (Key × Pat) :=
  bnd (key r ts) fun k ts =>
    match ts, k with
    | .mk _ (.p .colon) :: ts, _ => bnd (elemPat r ts) fun p ts => some ((k, p), ts)
    | ts, .id n => bnd (withDefault r (.id n) ts) fun p ts => some ((k, p), ts)
    | _, _ => none

def objPatLoop (r : Rec) : Nat → List (Key × Pat) → Ts → R Pat
  | 0, _, _ => none
  | _ + 1, acc, .mk _ (.p .rc) :: ts => some (.object acc.reverse none, ts)
  | _ + 1, acc, .mk _ (.p .dots) :: ts =>
    bnd (r.binding ts) fun p ts => (eat .rc ts).map fun ts => (.object acc.reverse (some p), ts)
  | f + 1, acc, ts =>
    match objPatProp r ts with
    | some (kp, .mk _ (.p .comma) :: ts) => objPatLoop r f (kp :: acc) ts
    | some (kp, .mk _ (.p .rc) :: ts) => some (.object (kp :: acc).reverse none, ts)
    | _ => none

def bindingP (r : Rec) : Ts → R Pat
  | .mk _ (.p .lb) :: ts => arrPatLoop r loopFuel [] ts
  | .mk _ (.p .lc) :: ts => objPatLoop r loopFuel [] ts
  | ts => bnd (ident ts) fun n ts => some (.id n, ts)

/-- Parameters before erasure: `this` parameters disappear; modifiers mark
constructor parameter properties. -/
inductive Param where
  | plain (p : Pat) | rest (p : Pat) | prop (n : Name) (p : Pat) | this

def paramModifier : Option Kw → Bool
  | some .public_ | some .private_ | some .protected_ | some .readonly_ | some .override_ => true
  | _ => false

/-- Skips parameter modifiers; reports whether there were any. -/
def modifiers : Nat → Bool → Ts → Bool × Ts
  | 0, m, ts => (m, ts)
  | f + 1, m, .mk nl (.id n k) :: ts =>
    bif paramModifier k && startsBinding ts then modifiers f true ts else (m, .mk nl (.id n k) :: ts)
  | _ + 1, m, ts => (m, ts)

def patName : Pat → Name
  | .id n => n
  | .dflt (.id n) _ => n
  | _ => []

def paramTail (r : Rec) (prop : Bool) (ts : Ts) : R Param :=
  bnd (r.binding ts) fun p ts =>
    match annot (marker ts) with
    | some ts => bnd (withDefault r p ts) fun p ts => some (bif prop then .prop (patName p) p else .plain p, ts)
    | none => none

def paramP (r : Rec) : Ts → R Param
  | .mk _ (.id _ (some .this_)) :: ts => (annot ts).map fun ts => (.this, ts)
  | .mk _ (.p .dots) :: ts =>
    bnd (r.binding ts) fun p ts => (annot (marker ts)).map fun ts => (.rest p, ts)
  | ts => let m := modifiers 8 false ts; paramTail r m.1 m.2

def Param.pats : List Param → List Pat
  | .plain p :: ps => p :: Param.pats ps
  | .prop _ p :: ps => p :: Param.pats ps
  | _ :: ps => Param.pats ps
  | [] => []

def Param.restOf : List Param → Option Pat
  | .rest p :: _ => some p
  | _ :: ps => Param.restOf ps
  | [] => none

def Param.props : List Param → List Name
  | .prop n _ :: ps => n :: Param.props ps
  | _ :: ps => Param.props ps
  | [] => []

def mkFunc (name : Option Name) (ps : List Param) (body : Body) (async gen : Bool) : Func :=
  .mk name (Param.pats ps) (Param.restOf ps) body async gen (Param.props ps)

def stmtsLoop (r : Rec) : Nat → List Stmt → Ts → R (List Stmt)
  | 0, _, _ => none
  | _ + 1, acc, .mk _ (.p .rc) :: ts => some (acc.reverse, ts)
  | f + 1, acc, ts =>
    match r.stmt ts with
    | some (some s, ts) => stmtsLoop r f (s :: acc) ts
    | some (none, ts) => stmtsLoop r f acc ts
    | none => none

def block (r : Rec) : Ts → R (List Stmt)
  | .mk _ (.p .lc) :: ts => stmtsLoop r loopFuel [] ts
  | _ => none

def funcBody (r : Rec) (name : Option Name) (ps : List Param) (async gen : Bool) : Ts → R (Option Func)
  | .mk _ (.p .lc) :: ts =>
    bnd (r.stmts ts) fun b ts => some (some (mkFunc name ps (.block b) async gen), ts)
  | ts => (semi ts).map fun ts => (none, ts)

/-- Signature and body after a function's name. Overload signatures and
abstract members have no body and erase to `none`. -/
def funcRest (r : Rec) (name : Option Name) (async gen : Bool) (ts : Ts) : R (Option Func) :=
  match optTyParams ts with
  | some (.mk _ (.p .lp) :: ts) =>
    bnd (list .rp (paramP r) ts) fun ps ts =>
      match annot ts with
      | some ts => funcBody r name ps async gen ts
      | none => none
  | _ => none

def arrowBody (r : Rec) (ps : List Param) (async : Bool) : Ts → R Expr
  | .mk _ (.p .lc) :: ts =>
    bnd (stmtsLoop r loopFuel [] ts) fun b ts => some (.arrow (mkFunc none ps (.block b) async false), ts)
  | ts => bnd (r.assign ts) fun e ts => some (.arrow (mkFunc none ps (.expr e) async false), ts)

/-- Arrow function from its parameter list `(`...`)`. -/
def arrowParams (r : Rec) (async : Bool) : Ts → R Expr
  | .mk _ (.p .lp) :: ts =>
    bnd (list .rp (paramP r) ts) fun ps ts =>
      match annot ts with
      | some (.mk _ (.p .arrow) :: ts) => arrowBody r ps async ts
      | _ => none
  | _ => none

/-- After `(`: whether the group is an arrow parameter list, optionally with
a return type. -/
def arrowAhead (ts : Ts) : Bool :=
  match group ts with
  | some (.mk _ (.p .arrow) :: _) => true
  | some (.mk _ (.p .colon) :: ts) => (match ty ts with | some (.mk _ (.p .arrow) :: _) => true | _ => false)
  | _ => false

def tmplLoop (r : Rec) : Nat → List (List Char) → List Expr → Ts → R (List (List Char) × List Expr)
  | 0, _, _, _ => none
  | f + 1, qs, es, ts =>
    match r.expr ts with
    | some (e, .mk _ (.tMid s) :: ts) => tmplLoop r f (s :: qs) (e :: es) ts
    | some (e, .mk _ (.tTail s) :: ts) => some (((s :: qs).reverse, (e :: es).reverse), ts)
    | _ => none

def template (r : Rec) (tag : Option Expr) : Ts → R Expr
  | .mk _ (.tFull s) :: ts => some (.template tag [s] [], ts)
  | .mk _ (.tHead s) :: ts => bnd (tmplLoop r loopFuel [s] [] ts) fun qe ts => some (.template tag qe.1 qe.2, ts)
  | _ => none

def keyStart : Ts → Bool
  | .mk _ (.id _ _) :: _ | .mk _ (.str _) :: _ | .mk _ (.num _) :: _ => true
  | .mk _ (.p .lb) :: _ | .mk _ (.priv _) :: _ | .mk _ (.bin .mul) :: _ => true
  | _ => false

def methodFunc (r : Rec) (async gen : Bool) (ts : Ts) : R Func :=
  match funcRest r none async gen ts with
  | some (some f, ts) => some (f, ts)
  | _ => none

def propMethod (r : Rec) (kind : MethodKind) (async gen : Bool) (ts : Ts) : R Property :=
  bnd (key r ts) fun k ts => bnd (methodFunc r async gen ts) fun f ts => some (.method kind k f, ts)

def propAfterKey (r : Rec) (k : Key) : Ts → R Property
  | .mk _ (.p .colon) :: ts => bnd (r.assign ts) fun e ts => some (.init k e, ts)
  | .mk nl (.p .lp) :: ts =>
    bnd (methodFunc r false false (.mk nl (.p .lp) :: ts)) fun f ts => some (.method .method k f, ts)
  | .mk nl (.bin .lt) :: ts =>
    bnd (methodFunc r false false (.mk nl (.bin .lt) :: ts)) fun f ts => some (.method .method k f, ts)
  | ts => match k with
    | .id n => some (.short n, ts)
    | _ => none

def propWord (r : Rec) (n : Name) (k : Kw) (ts : Ts) : R Property :=
  bif keyStart ts then
    match k, ts with
    | .get_, ts => propMethod r .get false false ts
    | .set_, ts => propMethod r .set false false ts
    | .async_, .mk _ (.bin .mul) :: ts => propMethod r .method true true ts
    | .async_, ts => propMethod r .method true false ts
    | _, ts => propAfterKey r (.id n) ts
  else propAfterKey r (.id n) ts

def propP (r : Rec) : Ts → R Property
  | .mk _ (.p .dots) :: ts => bnd (r.assign ts) fun e ts => some (.spread e, ts)
  | .mk _ (.bin .mul) :: ts => propMethod r .method false true ts
  | .mk _ (.id n (some k)) :: ts => propWord r n k ts
  | ts => bnd (key r ts) (propAfterKey r)

/-- Class member modifiers. `erased` marks `declare` and `abstract` members. -/
structure Mods where
  static : Bool
  kind : MethodKind
  async : Bool
  gen : Bool
  erased : Bool

def Mods.none : Mods := ⟨false, .method, false, false, false⟩

def Mods.add (m : Mods) : Kw → Option Mods
  | .static_ => some { m with static := true }
  | .get_ => some { m with kind := .get }
  | .set_ => some { m with kind := .set }
  | .async_ => some { m with async := true }
  | .declare_ | .abstract_ => some { m with erased := true }
  | .public_ | .private_ | .protected_ | .readonly_ | .override_ | .accessor_ => some m
  | _ => none

/-- A modifier word must be followed by more of the member. -/
def memberMods : Nat → Mods → Ts → Mods × Ts
  | 0, m, ts => (m, ts)
  | f + 1, m, .mk nl (.id n (some k)) :: ts =>
    match (bif keyStart ts then m.add k else none) with
    | some m => memberMods f m ts
    | none => (m, .mk nl (.id n (some k)) :: ts)
  | f + 1, m, .mk _ (.bin .mul) :: ts => memberMods f { m with gen := true } ts
  | _ + 1, m, ts => (m, ts)

def fieldInit (r : Rec) : Ts → R (Option Expr)
  | .mk _ (.asg .assign) :: ts => bnd (r.assign ts) fun e ts => some (some e, ts)
  | ts => some (none, ts)

def memberMethod (r : Rec) (m : Mods) (k : Key) (ctor : Bool) (ts : Ts) : R (Option Member) :=
  match funcRest r none m.async m.gen ts with
  | some (some f, ts) =>
    some (bif m.erased then none else bif ctor then some (.ctor f) else some (.method m.static m.kind k f), ts)
  | some (none, ts) => some (none, ts)
  | none => none

def memberAfterKey (r : Rec) (m : Mods) (k : Key) (ctor : Bool) : Ts → R (Option Member)
  | .mk nl (.p .lp) :: ts => memberMethod r m k ctor (.mk nl (.p .lp) :: ts)
  | .mk nl (.bin .lt) :: ts => memberMethod r m k ctor (.mk nl (.bin .lt) :: ts)
  | ts =>
    match annot ts with
    | some ts => bnd (fieldInit r ts) fun init ts =>
      (semi ts).map fun ts => (bif m.erased then none else some (.field m.static k init), ts)
    | none => none

/-- Index signatures `[k: T]: U` are erased. -/
def memberBody (r : Rec) (m : Mods) : Ts → R (Option Member)
  | .mk _ (.p .lb) :: .mk _ (.id _ _) :: .mk _ (.p .colon) :: ts =>
    match (group ts).bind annot with
    | some ts => (semi ts).map fun ts => (none, ts)
    | none => none
  | .mk _ (.id n (some .constructor_)) :: .mk nl (.p .lp) :: ts =>
    memberAfterKey r m (.id n) (!m.static) (.mk nl (.p .lp) :: ts)
  | ts => bnd (key r ts) fun k ts => memberAfterKey r m k false (marker ts)

def memberP (r : Rec) : Ts → R (Option Member)
  | .mk _ (.p .semi) :: ts => some (none, ts)
  | .mk _ (.id _ (some .static_)) :: .mk _ (.p .lc) :: ts =>
    bnd (stmtsLoop r loopFuel [] ts) fun ss ts => some (some (.block ss), ts)
  | ts => let mt := memberMods 16 Mods.none ts; memberBody r mt.1 mt.2

def membersLoop (r : Rec) : Nat → List Member → Ts → R (List Member)
  | 0, _, _ => none
  | _ + 1, acc, .mk _ (.p .rc) :: ts => some (acc.reverse, ts)
  | f + 1, acc, ts =>
    match memberP r ts with
    | some (some m, ts) => membersLoop r f (m :: acc) ts
    | some (none, ts) => membersLoop r f acc ts
    | none => none

def optTyArgs : Ts → Option Ts
  | .mk nl (.bin .lt) :: ts => tyArgs tyRec (.mk nl (.bin .lt) :: ts)
  | ts => some ts

def heritage (r : Rec) : Ts → R (Option Expr)
  | .mk _ (.id _ (some .extends_)) :: ts =>
    bnd (r.lhs ts) fun e ts => (optTyArgs ts).map fun ts => (some e, ts)
  | ts => some (none, ts)

def tyListLoop : Nat → Ts → Option Ts
  | 0, _ => none
  | f + 1, ts =>
    match ty ts with
    | some (.mk _ (.p .comma) :: ts) => tyListLoop f ts
    | r => r

def implementsP : Ts → Option Ts
  | .mk _ (.id _ (some .implements_)) :: ts => tyListLoop loopFuel ts
  | ts => some ts

def classTail (r : Rec) (name : Option Name) (ts : Ts) : R Class :=
  match optTyParams ts with
  | some ts => bnd (heritage r ts) fun sup ts =>
    match implementsP ts with
    | some (.mk _ (.p .lc) :: ts) =>
      bnd (r.members ts) fun ms ts => some (.mk name sup ms, ts)
    | _ => none
  | none => none

/-- After `class`: an optional name, then the class tail. -/
def classP (r : Rec) (ts : Ts) : R Class :=
  match ts with
  | .mk _ (.id _ (some .extends_)) :: _ => classTail r none ts
  | .mk _ (.id _ (some .implements_)) :: _ => classTail r none ts
  | _ =>
    match ident ts with
    | some (n, ts) => classTail r (some n) ts
    | none => classTail r none ts

/-- After `function` (and `async`): generator star, optional name, rest. -/
def funcHead (r : Rec) (async : Bool) : Ts → R (Option Func)
  | .mk _ (.bin .mul) :: ts =>
    match ident ts with
    | some (n, ts) => funcRest r (some n) async true ts
    | none => funcRest r none async true ts
  | ts =>
    match ident ts with
    | some (n, ts) => funcRest r (some n) async false ts
    | none => funcRest r none async false ts

def funcExpr (r : Rec) (async : Bool) (ts : Ts) : R Expr :=
  match funcHead r async ts with
  | some (some f, ts) => some (.func f, ts)
  | _ => none

def primaryWord (r : Rec) (n : Name) (k : Kw) (ts : Ts) : R Expr :=
  match k, ts with
  | .this_, ts => some (.this, ts)
  | .super_, ts => some (.super, ts)
  | .true_, ts => some (.lit (.bool true), ts)
  | .false_, ts => some (.lit (.bool false), ts)
  | .null_, ts => some (.lit .null, ts)
  | .function_, ts => funcExpr r false ts
  | .class_, ts => bnd (classP r ts) fun c ts => some (.cls c, ts)
  | .async_, .mk false (.id _ (some .function_)) :: ts => funcExpr r true ts
  | k, ts => bif k.reserved then none else some (.id n, ts)

def primary (r : Rec) : Ts → R Expr
  | .mk _ (.id n none) :: ts => some (.id n, ts)
  | .mk _ (.id n (some k)) :: ts => primaryWord r n k ts
  | .mk _ (.num s) :: ts => some (.lit (.num s), ts)
  | .mk _ (.str s) :: ts => some (.lit (.str s), ts)
  | .mk _ (.big s) :: ts => some (.lit (.big s), ts)
  | .mk _ (.re p f) :: ts => some (.lit (.regex p f), ts)
  | .mk nl (.tFull s) :: ts => template r none (.mk nl (.tFull s) :: ts)
  | .mk nl (.tHead s) :: ts => template r none (.mk nl (.tHead s) :: ts)
  | .mk _ (.p .lp) :: ts => bnd (r.expr ts) fun e ts => (eat .rp ts).map fun ts => (e, ts)
  | .mk _ (.p .lb) :: ts => bnd (list .rb (arrElem r) ts) fun es ts => some (.array es, ts)
  | .mk _ (.p .lc) :: ts => bnd (list .rc (propP r) ts) fun ps ts => some (.object ps, ts)
  | _ => none

def args (r : Rec) (ts : Ts) : R (List Elem) := list .rp (elem r) ts

/-- Step result: `some (e, optional)` applied a suffix; `none` ends the chain. -/
abbrev Step := Option (Expr × Bool)

def optStep (r : Rec) (e : Expr) : Ts → R Step
  | .mk _ (.id n _) :: ts => some (some (.member e n true, true), ts)
  | .mk _ (.priv n) :: ts => some (some (.priv e n true, true), ts)
  | .mk _ (.p .lb) :: ts =>
    bnd (r.expr ts) fun i ts => (eat .rb ts).map fun ts => (some (.index e i true, true), ts)
  | .mk _ (.p .lp) :: ts => bnd (args r ts) fun a ts => some (some (.call e a true, true), ts)
  | _ => none

/-- Type arguments are erased when a call follows them. -/
def typeArgsStep (e : Expr) (ts : Ts) : R Step :=
  match optTyArgs ts with
  | some (.mk nl (.p .lp) :: rest) => some (some (e, false), .mk nl (.p .lp) :: rest)
  | _ => some (none, ts)

def suffixStep (r : Rec) (call : Bool) (e : Expr) : Ts → R Step
  | .mk _ (.p .dot) :: .mk _ (.id n _) :: ts => some (some (.member e n false, false), ts)
  | .mk _ (.p .dot) :: .mk _ (.priv n) :: ts => some (some (.priv e n false, false), ts)
  | .mk _ (.p .qdot) :: ts => optStep r e ts
  | .mk _ (.p .lb) :: ts =>
    bnd (r.expr ts) fun i ts => (eat .rb ts).map fun ts => (some (.index e i false, false), ts)
  | .mk nl (.p .lp) :: ts =>
    bif call then bnd (args r ts) fun a ts => some (some (.call e a false, false), ts)
    else some (none, .mk nl (.p .lp) :: ts)
  | .mk false (.p .bang) :: ts => some (some (e, false), ts)
  | .mk nl (.tFull s) :: ts =>
    bnd (template r (some e) (.mk nl (.tFull s) :: ts)) fun e ts => some (some (e, false), ts)
  | .mk nl (.tHead s) :: ts =>
    bnd (template r (some e) (.mk nl (.tHead s) :: ts)) fun e ts => some (some (e, false), ts)
  | .mk nl (.bin .lt) :: ts => typeArgsStep e (.mk nl (.bin .lt) :: ts)
  | ts => some (none, ts)

/-- Member, call and non-null suffixes; a chain containing `?.` is wrapped
in `chain`. -/
def suffixLoop (r : Rec) (call : Bool) : Nat → Bool → Expr → Ts → R Expr
  | 0, _, _, _ => none
  | f + 1, ch, e, ts =>
    match suffixStep r call e ts with
    | some (some (e, o), ts) => suffixLoop r call f (ch || o) e ts
    | some (none, ts) => some (bif ch then .chain e else e, ts)
    | none => none

def newArgs (c : Expr) (r : Rec) : Ts → R Expr
  | .mk _ (.p .lp) :: ts => bnd (args r ts) fun a ts => some (.new c a, ts)
  | ts => some (.new c [], ts)

/-- After `new`: a member-expression callee and optional arguments. -/
def newP (r : Rec) (ts : Ts) : R Expr :=
  bnd (bnd (primary r ts) (suffixLoop r false loopFuel false)) fun c ts => newArgs c r ts

def lhsP (r : Rec) : Ts → R Expr
  | .mk _ (.id _ (some .new_)) :: ts => bnd (newP r ts) (suffixLoop r true loopFuel false)
  | ts => bnd (primary r ts) (suffixLoop r true loopFuel false)

def postfixP (r : Rec) (ts : Ts) : R Expr :=
  bnd (lhsP r ts) fun e ts =>
    match ts with
    | .mk false (.p .inc) :: ts => some (.update true false e, ts)
    | .mk false (.p .dec) :: ts => some (.update false false e, ts)
    | ts => some (e, ts)

def un (r : Rec) (op : UnOp) (ts : Ts) : R Expr := bnd (r.unary ts) fun e ts => some (.unary op e, ts)

def unaryWord (r : Rec) (nl : Bool) (n : Name) (k : Kw) (ts : Ts) : R Expr :=
  match k with
  | .typeof_ => un r .typeof ts
  | .void_ => un r .void ts
  | .delete_ => un r .delete ts
  | .await_ => bnd (r.unary ts) fun e ts => some (.await e, ts)
  | _ => postfixP r (.mk nl (.id n (some k)) :: ts)

def unaryP (r : Rec) : Ts → R Expr
  | .mk _ (.p .bang) :: ts => un r .not ts
  | .mk _ (.p .tilde) :: ts => un r .bnot ts
  | .mk _ (.bin .add) :: ts => un r .pos ts
  | .mk _ (.bin .sub) :: ts => un r .neg ts
  | .mk _ (.p .inc) :: ts => bnd (r.unary ts) fun e ts => some (.update true true e, ts)
  | .mk _ (.p .dec) :: ts => bnd (r.unary ts) fun e ts => some (.update false true e, ts)
  | .mk nl (.id n (some k)) :: ts => unaryWord r nl n k ts
  | ts => postfixP r ts

/-- `as` and `satisfies` take a type and are erased. -/
inductive BinK where | bin (op : BinOp) | log (op : LogOp) | erase

def binPrec : BinOp → Nat
  | .bor => 4 | .bxor => 5 | .band => 6
  | .eq | .ne | .seq | .sne => 7
  | .lt | .gt | .le | .ge | .inst | .in_ => 8
  | .shl | .shr | .ushr => 9
  | .add | .sub => 10
  | .mul | .div | .mod => 11
  | .exp => 12

def binOf : Tok → Option (Nat × BinK)
  | .log .nullish => some (1, .log .nullish)
  | .log .or => some (2, .log .or)
  | .log .and => some (3, .log .and)
  | .bin op => some (binPrec op, .bin op)
  | .id _ (some .in_) => some (8, .bin .in_)
  | .id _ (some .instanceof_) => some (8, .bin .inst)
  | .id _ (some .as_) => some (8, .erase)
  | .id _ (some .satisfies_) => some (8, .erase)
  | _ => none

/-- Right operands bind tighter, except right-associative `**`. -/
def rhsMin : BinK → Nat → Nat
  | .bin .exp, p => p - 1
  | _, p => p

def binLoop (r : Rec) (min : Nat) : Nat → Expr → Ts → R Expr
  | 0, _, _ => none
  | _ + 1, l, [] => some (l, [])
  | f + 1, l, t :: ts =>
    match binOf t.tok with
    | some (p, k) =>
      bif Nat.blt min p then
        match k with
        | .erase => bif t.nl then some (l, t :: ts) else (ty ts).bind (binLoop r min f l)
        | .bin op => bnd (r.bin (rhsMin k p) ts) fun e ts => binLoop r min f (.bin op l e) ts
        | .log op => bnd (r.bin p ts) fun e ts => binLoop r min f (.log op l e) ts
      else some (l, t :: ts)
    | none => some (l, t :: ts)

def binP (r : Rec) (min : Nat) (ts : Ts) : R Expr := bnd (r.unary ts) (binLoop r min loopFuel)

def condP (r : Rec) (ts : Ts) : R Expr :=
  bnd (binP r 0 ts) fun c ts =>
    match ts with
    | .mk _ (.p .q) :: ts =>
      match r.assign ts with
      | some (a, .mk _ (.p .colon) :: ts) => bnd (r.assign ts) fun b ts => some (.cond c a b, ts)
      | _ => none
    | ts => some (c, ts)

def elemToPat (f : Expr → Option Pat) : Elem → Option (Option Pat)
  | .hole => some none
  | .expr e => (f e).map some
  | .spread _ => none

def propToPat (f : Expr → Option Pat) : Property → Option (Key × Pat)
  | .init k v => (f v).map (k, ·)
  | .short n => some (.id n, .id n)
  | _ => none

/-- Assignment target from an expression (the cover grammar). -/
def toPat : Nat → Expr → Option Pat
  | 0, _ => none
  | _ + 1, .id n => some (.id n)
  | _ + 1, .member o p b => some (.expr (.member o p b))
  | _ + 1, .priv o p b => some (.expr (.priv o p b))
  | _ + 1, .index o i b => some (.expr (.index o i b))
  | _ + 1, .assign .assign p d => some (.dflt p d)
  | f + 1, .array es => (es.mapM (elemToPat (toPat f))).map (Pat.array · none)
  | f + 1, .object ps => (ps.mapM (propToPat (toPat f))).map (Pat.object · none)
  | _, _ => none

def assignRest (r : Rec) (ts : Ts) : R Expr :=
  bnd (condP r ts) fun l ts =>
    match ts with
    | .mk _ (.asg op) :: ts =>
      match toPat 64 l with
      | some p => bnd (r.assign ts) fun v ts => some (.assign op p v, ts)
      | none => none
    | ts => some (l, ts)

def yieldEnds : Ts → Bool
  | .mk nl (.p x) :: _ =>
    nl || peq x .rp || peq x .rb || peq x .rc || peq x .semi || peq x .comma || peq x .colon
  | t :: _ => t.nl
  | [] => true

def yieldP (r : Rec) : Ts → R Expr
  | .mk false (.bin .mul) :: ts => bnd (r.assign ts) fun e ts => some (.yield (some e) true, ts)
  | ts => bif yieldEnds ts then some (.yield none false, ts)
    else bnd (r.assign ts) fun e ts => some (.yield (some e) false, ts)

def asyncArrow (r : Rec) (all : Ts) : Ts → R Expr
  | .mk false (.id m none) :: .mk false (.p .arrow) :: ts => arrowBody r [.plain (.id m)] true ts
  | .mk false (.p .lp) :: ts =>
    bif arrowAhead ts then arrowParams r true (.mk false (.p .lp) :: ts) else assignRest r all
  | _ => assignRest r all

def assignWord (r : Rec) (n : Name) (k : Kw) (all ts : Ts) : R Expr :=
  match k, ts with
  | .async_, ts => asyncArrow r all ts
  | .yield_, ts => yieldP r ts
  | k, .mk false (.p .arrow) :: ts => bif k.reserved then none else arrowBody r [.plain (.id n)] false ts
  | _, _ => assignRest r all

def assignP (r : Rec) : Ts → R Expr
  | .mk _ (.id n none) :: .mk false (.p .arrow) :: ts => arrowBody r [.plain (.id n)] false ts
  | .mk nl (.id n (some k)) :: ts => assignWord r n k (.mk nl (.id n (some k)) :: ts) ts
  | .mk nl (.p .lp) :: ts =>
    bif arrowAhead ts then arrowParams r false (.mk nl (.p .lp) :: ts) else assignRest r (.mk nl (.p .lp) :: ts)
  | .mk nl (.bin .lt) :: ts => (optTyParams (.mk nl (.bin .lt) :: ts)).bind (arrowParams r false)
  | ts => assignRest r ts

def exprLoop (r : Rec) : Nat → Expr → Ts → R Expr
  | 0, _, _ => none
  | f + 1, e, .mk _ (.p .comma) :: ts => bnd (r.assign ts) fun e' ts => exprLoop r f (.seq e e') ts
  | _ + 1, e, ts => some (e, ts)

def exprP (r : Rec) (ts : Ts) : R Expr := bnd (r.assign ts) (exprLoop r loopFuel)

/-- `x!: T = e`: a definite-assignment marker and annotation are erased. -/
def declarator (r : Rec) (ts : Ts) : R (Pat × Option Expr) :=
  bnd (r.binding ts) fun p ts =>
    match annot (marker ts) with
    | some (.mk _ (.asg .assign) :: ts) => bnd (r.assign ts) fun e ts => some ((p, some e), ts)
    | some ts => some ((p, none), ts)
    | none => none

def declsLoop (r : Rec) : Nat → List (Pat × Option Expr) → Ts → R (List (Pat × Option Expr))
  | 0, _, _ => none
  | f + 1, acc, .mk _ (.p .comma) :: ts => bnd (declarator r ts) fun d ts => declsLoop r f (d :: acc) ts
  | _ + 1, acc, ts => some (acc.reverse, ts)

def decls (r : Rec) (ts : Ts) : R (List (Pat × Option Expr)) :=
  bnd (declarator r ts) fun d ts => declsLoop r loopFuel [d] ts

def declStmt (r : Rec) (k : DeclKind) (ts : Ts) : R (Option Stmt) :=
  bnd (decls r ts) fun ds ts => (semi ts).map fun ts => (some (.decl k ds), ts)

def exprStmt (r : Rec) (ts : Ts) : R (Option Stmt) :=
  bnd (exprP r ts) fun e ts => (semi ts).map fun ts => (some (.expr e), ts)

def enumMember (r : Rec) (ts : Ts) : R (Key × Option Expr) :=
  bnd (key r ts) fun k ts => bnd (fieldInit r ts) fun e ts => some ((k, e), ts)

def enumP (r : Rec) (const : Bool) (ts : Ts) : R (Option Stmt) :=
  match ident ts with
  | some (n, .mk _ (.p .lc) :: ts) => bnd (list .rc (enumMember r) ts) fun ms ts => some (some (.enum const n ms), ts)
  | _ => none

def funcDecl (r : Rec) (async : Bool) (ts : Ts) : R (Option Stmt) :=
  bnd (funcHead r async ts) fun f ts => some (f.map .func, ts)

def classDecl (r : Rec) (ts : Ts) : R (Option Stmt) :=
  bnd (classP r ts) fun c ts => some (some (.cls c), ts)

def body (r : Rec) (ts : Ts) : R Stmt := bnd (r.stmt ts) fun s ts => some (s.getD .empty, ts)

def paren (r : Rec) : Ts → R Expr
  | .mk _ (.p .lp) :: ts => bnd (r.expr ts) fun e ts => (eat .rp ts).map fun ts => (e, ts)
  | _ => none

def ifP (r : Rec) (ts : Ts) : R (Option Stmt) :=
  bnd (paren r ts) fun c ts => bnd (body r ts) fun t ts =>
    match ts with
    | .mk _ (.id _ (some .else_)) :: ts => bnd (body r ts) fun e ts => some (some (.if_ c t (some e)), ts)
    | ts => some (some (.if_ c t none), ts)

def whileP (r : Rec) (ts : Ts) : R (Option Stmt) :=
  bnd (paren r ts) fun c ts => bnd (body r ts) fun b ts => some (some (.while_ c b), ts)

def doP (r : Rec) (ts : Ts) : R (Option Stmt) :=
  bnd (body r ts) fun b ts =>
    match eatKw .while_ ts with
    | some ts => bnd (paren r ts) fun c ts =>
      some (some (.doWhile b c), match ts with | .mk _ (.p .semi) :: ts => ts | ts => ts)
    | none => none

def optExpr (r : Rec) (close : P) (ts : Ts) : R (Option Expr) :=
  match eat close ts with
  | some ts => some (none, ts)
  | none => bnd (r.expr ts) fun e ts => (eat close ts).map fun ts => (some e, ts)

/-- `for (init; test; update)` after its initializer. -/
def forRest (r : Rec) (init : Option ForHead) (ts : Ts) : R (Option Stmt) :=
  bnd (optExpr r .semi ts) fun test ts => bnd (optExpr r .rp ts) fun upd ts =>
    bnd (body r ts) fun b ts => some (some (.for_ init test upd b), ts)

def forEach (r : Rec) (await : Bool) (kind : Option DeclKind) (p : Pat) : Ts → R (Option Stmt)
  | .mk _ (.id _ (some .of_)) :: ts =>
    bnd (r.assign ts) fun e ts => bnd (body r ((eat .rp ts).getD [])) fun b ts =>
      some (some (.forOf await kind p e b), ts)
  | .mk _ (.id _ (some .in_)) :: ts =>
    bnd (r.expr ts) fun e ts => bnd (body r ((eat .rp ts).getD [])) fun b ts =>
      some (some (.forIn kind p e b), ts)
  | _ => none

def forDecl (r : Rec) (await : Bool) (k : DeclKind) (ts : Ts) : R (Option Stmt) :=
  bnd (r.binding ts) fun p ts =>
    match ts with
    | .mk _ (.id _ (some .of_)) :: _ | .mk _ (.id _ (some .in_)) :: _ => forEach r await (some k) p ts
    | ts =>
      let first : R (Pat × Option Expr) :=
        match annot (marker ts) with
        | some (.mk _ (.asg .assign) :: ts) => bnd (r.assign ts) fun e ts => some ((p, some e), ts)
        | some ts => some ((p, none), ts)
        | none => none
      bnd first fun d ts => bnd (declsLoop r loopFuel [d] ts) fun ds ts =>
        (eat .semi ts).bind fun ts => forRest r (some (.decl k ds)) ts

def forKind : Kw → Option DeclKind
  | .var_ => some .var | .let_ => some .let_ | .const_ => some .const | .using_ => some .using
  | _ => none

def forHead (r : Rec) (await : Bool) : Ts → R (Option Stmt)
  | .mk _ (.p .semi) :: ts => forRest r none ts
  | .mk nl (.id n (some k)) :: ts =>
    match forKind k with
    | some d => bif startsBinding ts then forDecl r await d ts else forExpr r await (.mk nl (.id n (some k)) :: ts)
    | none => forExpr r await (.mk nl (.id n (some k)) :: ts)
  | ts => forExpr r await ts
where
  forExpr (r : Rec) (await : Bool) : Ts → R (Option Stmt)
    | .mk _ (.id n none) :: .mk nl (.id m (some k)) :: ts =>
      bif kweq k .of_ || kweq k .in_ then forEach r await none (.id n) (.mk nl (.id m (some k)) :: ts)
      else forInit r (.mk false (.id n none) :: .mk nl (.id m (some k)) :: ts)
    | ts => forInit r ts
  forInit (r : Rec) (ts : Ts) : R (Option Stmt) :=
    bnd (r.expr ts) fun e ts => (eat .semi ts).bind fun ts => forRest r (some (.expr e)) ts

def forP (r : Rec) : Ts → R (Option Stmt)
  | .mk _ (.id _ (some .await_)) :: .mk _ (.p .lp) :: ts => forHead r true ts
  | .mk _ (.p .lp) :: ts => forHead r false ts
  | _ => none

def retP (r : Rec) : Ts → R (Option Stmt)
  | .mk _ (.p .semi) :: ts => some (some (.ret none), ts)
  | .mk nl (.p .rc) :: ts => some (some (.ret none), .mk nl (.p .rc) :: ts)
  | [] => some (some (.ret none), [])
  | t :: ts => bif t.nl then some (some (.ret none), t :: ts)
    else bnd (r.expr (t :: ts)) fun e ts => (semi ts).map fun ts => (some (.ret (some e)), ts)

def jumpP (brk : Bool) : Ts → R (Option Stmt)
  | .mk false (.id n none) :: ts =>
    (semi ts).map fun ts => (some (bif brk then .break (some n) else .continue (some n)), ts)
  | ts => (semi ts).map fun ts => (some (bif brk then .break none else .continue none), ts)

def catchP (r : Rec) : Ts → R (Option (Option Pat × List Stmt))
  | .mk _ (.id _ (some .catch_)) :: .mk _ (.p .lp) :: ts =>
    bnd (r.binding ts) fun p ts =>
      match annot ts with
      | some (.mk _ (.p .rp) :: ts) => bnd (block r ts) fun b ts => some (some (some p, b), ts)
      | _ => none
  | .mk _ (.id _ (some .catch_)) :: ts => bnd (block r ts) fun b ts => some (some (none, b), ts)
  | ts => some (none, ts)

def finallyP (r : Rec) : Ts → R (Option (List Stmt))
  | .mk _ (.id _ (some .finally_)) :: ts => bnd (block r ts) fun b ts => some (some b, ts)
  | ts => some (none, ts)

def tryP (r : Rec) (ts : Ts) : R (Option Stmt) :=
  bnd (block r ts) fun b ts => bnd (catchP r ts) fun h ts => bnd (finallyP r ts) fun f ts =>
    some (some (.try_ b h f), ts)

def caseEnd : Ts → Bool
  | .mk _ (.id _ (some .case_)) :: _ | .mk _ (.id _ (some .default_)) :: _ | .mk _ (.p .rc) :: _ => true
  | _ => false

def caseBody (r : Rec) : Nat → List Stmt → Ts → R (List Stmt)
  | 0, _, _ => none
  | f + 1, acc, ts =>
    bif caseEnd ts then some (acc.reverse, ts)
    else match r.stmt ts with
      | some (some s, ts) => caseBody r f (s :: acc) ts
      | some (none, ts) => caseBody r f acc ts
      | none => none

def casesLoop (r : Rec) : Nat → List (Option Expr × List Stmt) → Ts → R (List (Option Expr × List Stmt))
  | 0, _, _ => none
  | _ + 1, acc, .mk _ (.p .rc) :: ts => some (acc.reverse, ts)
  | f + 1, acc, .mk _ (.id _ (some .case_)) :: ts =>
    match r.expr ts with
    | some (e, .mk _ (.p .colon) :: ts) => bnd (caseBody r loopFuel [] ts) fun b ts => casesLoop r f ((some e, b) :: acc) ts
    | _ => none
  | f + 1, acc, .mk _ (.id _ (some .default_)) :: .mk _ (.p .colon) :: ts =>
    bnd (caseBody r loopFuel [] ts) fun b ts => casesLoop r f ((none, b) :: acc) ts
  | _, _, _ => none

def switchP (r : Rec) (ts : Ts) : R (Option Stmt) :=
  bnd (paren r ts) fun d ts =>
    match ts with
    | .mk _ (.p .lc) :: ts => bnd (casesLoop r loopFuel [] ts) fun cs ts => some (some (.switch d cs), ts)
    | _ => none

/-- `type X<T> = T;` is erased. -/
def typeAlias : Ts → R (Option Stmt)
  | .mk _ (.id _ _) :: ts =>
    match optTyParams ts with
    | some (.mk _ (.asg .assign) :: ts) => ((ty ts).bind semi).map fun ts => (none, ts)
    | _ => none
  | _ => none

def interfaceExtends : Ts → Option Ts
  | .mk _ (.id _ (some .extends_)) :: ts => tyListLoop loopFuel ts
  | ts => some ts

/-- `interface X<T> extends Y { ... }` is erased. -/
def interfaceP : Ts → R (Option Stmt)
  | .mk _ (.id _ _) :: ts =>
    match (optTyParams ts).bind interfaceExtends with
    | some (.mk _ (.p .lc) :: ts) => (group ts).map fun ts => (none, ts)
    | _ => none
  | _ => none

def typeAhead : Ts → Bool
  | .mk _ (.id _ _) :: .mk _ (.asg .assign) :: _ | .mk _ (.id _ _) :: .mk _ (.bin .lt) :: _ => true
  | _ => false

def stmtWord (r : Rec) (k : Kw) (all ts : Ts) : R (Option Stmt) :=
  match k, ts with
  | .var_, ts => declStmt r .var ts
  | .const_, .mk _ (.id _ (some .enum_)) :: ts => enumP r true ts
  | .const_, ts => declStmt r .const ts
  | .let_, ts => bif startsBinding ts then declStmt r .let_ ts else exprStmt r all
  | .using_, .mk false (.id n k') :: ts => declStmt r .using (.mk false (.id n k') :: ts)
  | .await_, .mk false (.id _ (some .using_)) :: ts => declStmt r .awaitUsing ts
  | .function_, ts => funcDecl r false ts
  | .async_, .mk false (.id _ (some .function_)) :: ts => funcDecl r true ts
  | .class_, ts => classDecl r ts
  | .abstract_, .mk _ (.id _ (some .class_)) :: ts => classDecl r ts
  | .enum_, ts => enumP r false ts
  | .if_, ts => ifP r ts
  | .for_, ts => forP r ts
  | .while_, ts => whileP r ts
  | .do_, ts => doP r ts
  | .return_, ts => retP r ts
  | .break_, ts => jumpP true ts
  | .continue_, ts => jumpP false ts
  | .throw_, ts => bnd (r.expr ts) fun e ts => (semi ts).map fun ts => (some (.throw e), ts)
  | .try_, ts => tryP r ts
  | .switch_, ts => switchP r ts
  | .type_, ts => bif typeAhead ts then typeAlias ts else exprStmt r all
  | .interface_, .mk nl (.id n k') :: ts => interfaceP (.mk nl (.id n k') :: ts)
  | _, _ => exprStmt r all

def stmtP (r : Rec) : Ts → R (Option Stmt)
  | .mk _ (.p .lc) :: ts => bnd (stmtsLoop r loopFuel [] ts) fun ss ts => some (some (.block ss), ts)
  | .mk _ (.p .semi) :: ts => some (some .empty, ts)
  | .mk _ (.id n none) :: .mk _ (.p .colon) :: ts => bnd (body r ts) fun s ts => some (some (.labeled n s), ts)
  | .mk nl (.id n (some k)) :: ts => stmtWord r k (.mk nl (.id n (some k)) :: ts) ts
  | ts => exprStmt r ts

def deadRec : Rec :=
  ⟨fun _ => none, fun _ => none, fun _ => none, fun _ _ => none, fun _ => none, fun _ => none, fun _ => none,
    fun _ => none, fun _ => none⟩

def Rec.withStmts (r : Rec) (s : Ts → R (List Stmt)) : Rec := { r with stmts := s }
def Rec.withMembers (r : Rec) (m : Ts → R (List Member)) : Rec := { r with members := m }

/-- The grammar one nesting level above `r`. -/
def mkRec (r : Rec) : Rec :=
  ⟨assignP r, exprP r, unaryP r, binP r, lhsP r, bindingP r, stmtP r, stmtsLoop r loopFuel [], membersLoop r loopFuel []⟩

def knot : Nat → Rec
  | 0 => deadRec
  | n + 1 => mkRec (knot n)

/-! ## Modules -/

/-- `type` specifiers are erased (`none`). -/
def importSpec : Ts → R (Option Spec)
  | .mk _ (.id _ (some .type_)) :: .mk _ (.id _ _) :: .mk _ (.id _ (some .as_)) :: .mk _ (.id _ _) :: ts => some (none, ts)
  | .mk _ (.id _ (some .type_)) :: .mk _ (.id _ _) :: ts => some (none, ts)
  | .mk _ (.id n _) :: .mk _ (.id _ (some .as_)) :: .mk _ (.id m _) :: ts => some (some (.named n m), ts)
  | .mk _ (.id n _) :: ts => some (some (.named n n), ts)
  | _ => none

def exportSpec : Ts → R (Option (Name × Name))
  | .mk _ (.id _ (some .type_)) :: .mk _ (.id _ _) :: .mk _ (.id _ (some .as_)) :: .mk _ (.id _ _) :: ts => some (none, ts)
  | .mk _ (.id _ (some .type_)) :: .mk _ (.id _ _) :: ts => some (none, ts)
  | .mk _ (.id n _) :: .mk _ (.id _ (some .as_)) :: .mk _ (.id m _) :: ts => some (some (n, m), ts)
  | .mk _ (.id n _) :: ts => some (some (n, n), ts)
  | _ => none

def fromP : Ts → R (List Char)
  | .mk _ (.id _ (some .from_)) :: .mk _ (.str s) :: ts => (semi ts).map fun ts => (s, ts)
  | _ => none

/-- An import whose specifiers are all `type` specifiers is erased entirely. -/
def importItem (specs : List Spec) (ss : List (Option Spec)) (src : List Char) : Option Item :=
  match specs ++ ss.filterMap id, ss with
  | [], _ :: _ => none
  | sp, _ => some (.import_ sp src)

def importNamed (specs : List Spec) : Ts → R (Option Item)
  | .mk _ (.p .lc) :: ts =>
    bnd (list .rc importSpec ts) fun ss ts => bnd (fromP ts) fun s ts => some (importItem specs ss s, ts)
  | .mk _ (.bin .mul) :: .mk _ (.id _ (some .as_)) :: .mk _ (.id n _) :: ts =>
    bnd (fromP ts) fun s ts => some (some (.import_ (specs ++ [.ns n]) s), ts)
  | ts => bnd (fromP ts) fun s ts => some (some (.import_ specs s), ts)

/-- After `import`. Type-only imports are erased; Bun also drops imports
whose bindings are only used as types, which is not decided here. -/
def importP : Ts → R (Option Item)
  | .mk _ (.str s) :: ts => (semi ts).map fun ts => (some (.import_ [] s), ts)
  | .mk _ (.id _ (some .type_)) :: .mk _ (.p .lc) :: ts =>
    ((group ts).bind fun ts => (fromP ts).map (·.2)).map fun ts => (none, ts)
  | .mk _ (.id _ (some .type_)) :: .mk _ (.id _ none) :: ts => (fromP ts).map fun st => (none, st.2)
  | .mk _ (.id n none) :: .mk _ (.p .comma) :: ts => importNamed [.default n] ts
  | .mk _ (.id n none) :: ts => importNamed [.default n] ts
  | ts => importNamed [] ts

def exportDefault (r : Rec) : Ts → R (Option Item)
  | .mk nl (.id n (some .function_)) :: ts =>
    bnd (r.stmt (.mk nl (.id n (some .function_)) :: ts)) fun s ts => some (s.map .export_, ts)
  | .mk nl (.id n (some .class_)) :: ts =>
    bnd (r.stmt (.mk nl (.id n (some .class_)) :: ts)) fun s ts => some (s.map .export_, ts)
  | ts => bnd (r.assign ts) fun e ts => (semi ts).map fun ts => (some (.exportDefault e), ts)

def exportFrom : Ts → R (Option (List Char))
  | .mk _ (.id _ (some .from_)) :: .mk _ (.str s) :: ts => (semi ts).map fun ts => (some s, ts)
  | ts => (semi ts).map fun ts => (none, ts)

/-- After `export`. -/
def exportP (r : Rec) : Ts → R (Option Item)
  | .mk _ (.id _ (some .default_)) :: ts => exportDefault r ts
  | .mk _ (.p .lc) :: ts =>
    bnd (list .rc exportSpec ts) fun ss ts => bnd (exportFrom ts) fun s ts => some (some (.exportNamed (ss.filterMap id) s), ts)
  | .mk _ (.bin .mul) :: .mk _ (.id _ (some .as_)) :: .mk _ (.id n _) :: ts =>
    bnd (fromP ts) fun s ts => some (some (.exportAll (some n) s), ts)
  | .mk _ (.bin .mul) :: ts => bnd (fromP ts) fun s ts => some (some (.exportAll none s), ts)
  | .mk _ (.id _ (some .type_)) :: .mk _ (.p .lc) :: ts =>
    bnd ((group ts).map fun ts => ((), ts)) fun _ ts => bnd (exportFrom ts) fun _ ts => some (none, ts)
  | ts => bnd (r.stmt ts) fun s ts => some (s.map .export_, ts)

def itemP (r : Rec) : Ts → R (Option Item)
  | .mk _ (.id _ (some .import_)) :: ts => importP ts
  | .mk _ (.id _ (some .export_)) :: ts => exportP r ts
  | ts => bnd (r.stmt ts) fun s ts => some (s.map .stmt, ts)

/-- Items to the end of input; `.inr` holds the input where parsing stopped. -/
def itemsLoop (r : Rec) : Nat → List Item → Ts → List Item ⊕ Ts
  | 0, _, ts => .inr ts
  | _ + 1, acc, [] => .inl acc.reverse
  | f + 1, acc, ts =>
    match itemP r ts with
    | some (some i, ts) => itemsLoop r f (i :: acc) ts
    | some (none, ts) => itemsLoop r f acc ts
    | none => .inr ts

def parseTokens (ts : Ts) : List Item ⊕ Ts := itemsLoop (knot depthFuel) loopFuel [] ts

def parse (cs : List Char) : Option Module :=
  match parseTokens (lex cs) with
  | .inl m => some m
  | .inr _ => none

theorem parse_of_lex {cs : List Char} {ts : Ts} (h : lex cs = ts) :
    parse cs = (parseTokens ts).getLeft? := by
  unfold parse; rw [h]; split <;> simp_all

theorem parse_isSome {cs : List Char} {ts : Ts} (h : lex cs = ts)
    (ok : (parseTokens ts).isLeft = true) : (parse cs).isSome = true := by
  unfold parse; rw [h]; split <;> simp_all

/-! ## Resumable parsing

A large module is parsed in separately kernel-checked steps: one module
item (`itemP`), class member (`memberP`) or statement (`Rec.stmt`) from a
token suffix, returning the remaining suffix. `Run` composes such steps
and the loop lemmas below turn a run into the loop's result, so no single
check evaluates the whole module. -/

/-- A loop's stop test: the end of input for items, `}` for members and statements. -/
def stopNil : Ts → Bool
  | [] => true
  | _ => false

def stopRc : Ts → Bool
  | .mk _ (.p .rc) :: _ => true
  | _ => false

/-- `Run p stop ts xs ts' n`: `n` steps of `p`, none at a `stop` input, take
`ts` to `ts'` and produce `xs` (erased steps produce nothing). -/
inductive Run {α : Type} (p : Ts → R (Option α)) (stop : Ts → Bool) : Ts → List α → Ts → Nat → Prop
  | nil (ts : Ts) : Run p stop ts [] ts 0
  | some {ts ts₁ ts' : Ts} {x : α} {xs : List α} {n : Nat} :
      stop ts = false → p ts = Option.some (Option.some x, ts₁) → Run p stop ts₁ xs ts' n →
      Run p stop ts (x :: xs) ts' (n + 1)
  | none {ts ts₁ ts' : Ts} {xs : List α} {n : Nat} :
      stop ts = false → p ts = Option.some (Option.none, ts₁) → Run p stop ts₁ xs ts' n →
      Run p stop ts xs ts' (n + 1)

theorem Run.append {α : Type} {p : Ts → R (Option α)} {stop : Ts → Bool} {a b c : Ts} {xs ys : List α}
    {n m : Nat} (h₁ : Run p stop a xs b n) (h₂ : Run p stop b ys c m) :
    Run p stop a (List.append xs ys) c (Nat.add n m) := by
  have e : ∀ k, Nat.add (k + 1) m = Nat.add k m + 1 := fun k => Nat.succ_add k m
  induction h₁ with
  | nil => simpa using h₂
  | some hs hp _ ih => rw [e]; exact .some hs hp (ih h₂)
  | none hs hp _ ih => rw [e]; exact .none hs hp (ih h₂)

theorem itemsLoop_run' {r : Rec} {ts e : Ts} {xs : List Item} {n : Nat} (h : Run (itemP r) stopNil ts xs e n) :
    e = [] → ∀ (f : Nat) (acc : List Item), n < f → itemsLoop r f acc ts = .inl (acc.reverse ++ xs) := by
  induction h with
  | nil => intro he f acc hf; subst he; cases f with
    | zero => omega
    | succ f => simp [itemsLoop]
  | @some ts _ _ x _ _ hs hp _ ih =>
    intro he f acc hf; cases f with
    | zero => omega
    | succ f =>
      cases ts with
      | nil => simp [stopNil] at hs
      | cons t ts => simp only [itemsLoop, hp]; rw [ih he f (x :: acc) (by omega)]; simp
  | @none ts _ _ _ _ hs hp _ ih =>
    intro he f acc hf; cases f with
    | zero => omega
    | succ f =>
      cases ts with
      | nil => simp [stopNil] at hs
      | cons t ts => simp only [itemsLoop, hp]; exact ih he f acc (by omega)

/-- A run of items to the end of input is the item loop's result. -/
theorem itemsLoop_run {r : Rec} {ts : Ts} {xs : List Item} {n f : Nat} (h : Run (itemP r) stopNil ts xs [] n)
    (hf : n < f) : itemsLoop r f [] ts = .inl xs := by
  simpa using itemsLoop_run' h rfl f [] hf

theorem stmtsLoop_run' {r : Rec} {ts e rest : Ts} {nl : Bool} {xs : List Stmt} {n : Nat}
    (h : Run r.stmt stopRc ts xs e n) :
    e = .mk nl (.p .rc) :: rest → ∀ (f : Nat) (acc : List Stmt), n < f → stmtsLoop r f acc ts = some (acc.reverse ++ xs, rest) := by
  induction h with
  | nil => intro he f acc hf; subst he; cases f with
    | zero => omega
    | succ f => simp [stmtsLoop]
  | @some ts _ _ x _ _ hs hp _ ih =>
    intro he f acc hf; cases f with
    | zero => omega
    | succ f =>
      rw [stmtsLoop.eq_def]; split
      · omega
      · simp_all [stopRc]
      · simp only [hp]; rw [ih he _ _ (by omega)]; simp
  | @none ts _ _ _ _ hs hp _ ih =>
    intro he f acc hf; cases f with
    | zero => omega
    | succ f =>
      rw [stmtsLoop.eq_def]; split
      · omega
      · simp_all [stopRc]
      · simp only [hp]; exact ih he _ _ (by omega)

/-- A run of statements to a `}` is the statement loop's result. -/
theorem stmtsLoop_run {r : Rec} {ts rest : Ts} {nl : Bool} {xs : List Stmt} {n f : Nat}
    (h : Run r.stmt stopRc ts xs (.mk nl (.p .rc) :: rest) n) (hf : n < f) : stmtsLoop r f [] ts = some (xs, rest) := by
  simpa using stmtsLoop_run' h rfl f [] hf

theorem membersLoop_run' {r : Rec} {ts e rest : Ts} {nl : Bool} {xs : List Member} {n : Nat}
    (h : Run (memberP r) stopRc ts xs e n) :
    e = .mk nl (.p .rc) :: rest → ∀ (f : Nat) (acc : List Member), n < f → membersLoop r f acc ts = some (acc.reverse ++ xs, rest) := by
  induction h with
  | nil => intro he f acc hf; subst he; cases f with
    | zero => omega
    | succ f => simp [membersLoop]
  | @some ts _ _ x _ _ hs hp _ ih =>
    intro he f acc hf; cases f with
    | zero => omega
    | succ f =>
      rw [membersLoop.eq_def]; split
      · omega
      · simp_all [stopRc]
      · simp only [hp]; rw [ih he _ _ (by omega)]; simp
  | @none ts _ _ _ _ hs hp _ ih =>
    intro he f acc hf; cases f with
    | zero => omega
    | succ f =>
      rw [membersLoop.eq_def]; split
      · omega
      · simp_all [stopRc]
      · simp only [hp]; exact ih he _ _ (by omega)

/-- A run of class members to a `}` is the member loop's result. -/
theorem membersLoop_run {r : Rec} {ts rest : Ts} {nl : Bool} {xs : List Member} {n f : Nat}
    (h : Run (memberP r) stopRc ts xs (.mk nl (.p .rc) :: rest) n) (hf : n < f) : membersLoop r f [] ts = some (xs, rest) := by
  simpa using membersLoop_run' h rfl f [] hf

end Host.Ts
