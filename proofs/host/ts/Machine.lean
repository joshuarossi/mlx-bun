import host.ts.Control
namespace Host.Ts

/-! # The abstract machine

A CEK-style small-step machine: control (`Ctl`), an explicit stack of
frames, the heap. `step` performs one transition; it runs in `M` (continuation-passing over `Free`), so
number operations on referenced numbers go to a server. Statement
completions are `ret` (normal) or `abr` (abrupt); frames that catch
abrupt completions (`try`, loops, labels, scopes with `using`, function
boundaries) are the only ones that inspect them, the rest are popped.
Generators and async functions suspend by moving the frames up to their
boundary into the heap (`Susp`), so `try`/`finally` and `using` scopes
survive suspension. Optional chains unwind to their `chain` frame. -/

def nThis : Name := ['t','h','i','s']
def nHome : Name := ['%','h','o','m','e']
def nCls : Name := ['%','c','l','s']
def nNt : Name := ['%','n','t']
def nDefault : Name := ['*','d','e','f','a','u','l','t','*']
def nUndefined : Name := chars!"undefined"

def privName (n : Name) : Name := '#' :: n

def keyOf (k : Key) : Option PKey :=
  match k with
  | .id n => some (.str n)
  | .str raw => (cook raw).map PKey.str
  | .num raw => (F64.ofLit raw).bind fun x => (F64.toStr x).map PKey.str
  | .priv _ => none
  | .computed _ => none

def isUsing : DeclKind → Bool
  | .using => true
  | _ => false

def matchLabel (l : Option Name) (labels : List Name) : Bool :=
  match l with
  | none => true
  | some x => labels.any (nameEq x)

def resume {S : Type} (s : St S) : Comp → St S
  | .normal v => s.ret v
  | .abrupt a => s.go (.abr a)

/-- Add a `using` resource to the innermost scope frame. -/
def addUsing (r : Val × Val) : List Frame → Option (List Frame)
  | [] => none
  | .s (.scope res) :: fs => some (.s (.scope (r :: res)) :: fs)
  | f :: fs => (addUsing r fs).map (f :: ·)

def fnParams : Func → List Pat
  | .mk _ ps _ _ _ _ _ => ps

def fnRest : Func → Option Pat
  | .mk _ _ r _ _ _ _ => r

def fnProps : Func → List Name
  | .mk _ _ _ _ _ _ ps => ps

def noRest : Func → Func
  | .mk n ps _ b a g pr => .mk n ps none b a g pr

def paramNames (f : Func) : List Name :=
  (fnParams f).foldr (fun p acc => patNames p ++ acc) (patNamesR (fnRest f))

def classCtor : List Member → Option Func
  | [] => none
  | .ctor f :: _ => some f
  | _ :: ms => classCtor ms

mutual
def memberPrivs : List Member → List Name
  | [] => []
  | .method _ _ (.priv n) _ :: ms => n :: memberPrivs ms
  | .field _ (.priv n) _ :: ms => n :: memberPrivs ms
  | _ :: ms => memberPrivs ms
end

section
variable (F : Ffi)

abbrev MS := St F.S

/-! ## Variables -/

def readVar (s : MS F) (n : Name) (env : Env) : RS F :=
  match lookupEnv n env with
  | some c => match s.cell? c with
    | some (some v) => retS F s v
    | some none => refErr s (chars!"cannot access '" ++ n ++ chars!"' before initialization")
    | none => .fail "variable cell"
  | none => .bind (getChain F s (.str n) 16 aGlobal) fun
    | some p => .pure (readProp F s (.obj aGlobal) (some p))
    | none => refErr s (n ++ chars!" is not defined")

def writeVar (s : MS F) (n : Name) (env : Env) (v : Val) : RS F :=
  match lookupEnv n env with
  | some c => match s.cell? c with
    | some (some _) => retS F (s.setCell c v) v
    | some none => refErr s (chars!"cannot access '" ++ n ++ chars!"' before initialization")
    | none => .fail "variable cell"
  | none => refErr s (n ++ chars!" is not defined")

def cellVal? (s : MS F) (n : Name) (env : Env) : Option Val :=
  (lookupEnv n env).bind fun c => (s.cell? c).bind id

def copyIter (s : MS F) : List Name → Env → Env × MS F
  | [], env => (env, s)
  | n :: ns, env => match cellVal? F s n env with
    | some v => let (c, s) := s.alloc (.cell (some v)); copyIter s ns ((n, c) :: env)
    | none => let (c, s) := s.alloc (.cell none); copyIter s ns ((n, c) :: env)

/-- The next iteration's bindings of a `for (let …)` loop (`CreatePerIterationEnvironment`):
fresh cells with the current values, in front of the loop's environment, whose first
`names.length` entries (the current iteration's cells, now shadowed) are dropped, so the
environment does not grow with the iteration count. -/
def nextIter (s : MS F) (names : List Name) (env : Env) : Env × MS F :=
  let (env', s) := copyIter F s names env
  (env'.take names.length ++ env'.drop (2 * names.length), s)

/-! ## Operators -/

def strLt : List Char → List Char → Bool
  | [], [] => false
  | [], _ :: _ => true
  | _ :: _, [] => false
  | a :: as, b :: bs => bif Nat.blt a.toNat b.toNat then true else bif Nat.beq a.toNat b.toNat then strLt as bs else false

def bigNat2 (k : Nat → Nat → Nat) (s : MS F) (a b : Int) : RS F :=
  match a, b with
  | .ofNat x, .ofNat y => retS F s (.big (k x y : Nat))
  | _, _ => .fail "bigint bitwise operation on a negative operand"

def numOp? : BinOp → Option NBin
  | .sub => some .sub | .mul => some .mul | .div => some .div | .mod => some .rem
  | .shl => some .shl | .shr => some .shr | .ushr => some .ushr
  | .band => some .band | .bor => some .bor | .bxor => some .bxor | .add => some .add
  | _ => none

def bigOp (s : MS F) (op : BinOp) (a b : Int) : RS F :=
  match op with
  | .add => retS F s (.big (a + b))
  | .sub => retS F s (.big (a - b))
  | .mul => retS F s (.big (a * b))
  | .div => bif decide (b = 0) then rangeErr s (chars!"division by zero") else retS F s (.big (a.tdiv b))
  | .mod => bif decide (b = 0) then rangeErr s (chars!"division by zero") else retS F s (.big (a.tmod b))
  | .exp => match b with
    | .ofNat k => retS F s (.big (a ^ k))
    | _ => rangeErr s (chars!"negative exponent")
  | .band => bigNat2 F Nat.land s a b
  | .bor => bigNat2 F Nat.lor s a b
  | .bxor => bigNat2 F Nat.xor s a b
  | .shl => match b with
    | .ofNat k => retS F s (.big (a * (2 ^ k : Nat)))
    | _ => .fail "bigint shift by a negative amount"
  | .shr => match b with
    | .ofNat k => retS F s (.big (a / (2 ^ k : Nat)))
    | _ => .fail "bigint shift by a negative amount"
  | _ => typeErr s (chars!"invalid bigint operation")

def arith (s : MS F) (op : BinOp) (a b : Val) : RS F :=
  match a, b with
  | .big x, .big y => bigOp F s op x y
  | .big _, _ => typeErr s (chars!"cannot mix BigInt and other types")
  | _, .big _ => typeErr s (chars!"cannot mix BigInt and other types")
  | _, _ => .bind (toNum a) fun x => .bind (toNum b) fun y =>
    match x, y with
    | some x, some y => match op with
      | .exp => match x, y with
        | .lit p, .lit q => match F64.pow p q with
          | some r => retS F s (.num (.lit r))
          | none => .fail "** with an inexact result"
        | _, _ => .fail "** of a symbolic number"
      | op => match numOp? op with
        | some o => .bind (numBin o x y) fun r => retS F s (.num r)
        | none => .fail "numeric operator"
    | _, _ => match a, b with
      | .sym _, _ => typeErr s (chars!"cannot convert a Symbol to a number")
      | _, .sym _ => typeErr s (chars!"cannot convert a Symbol to a number")
      | _, _ => .fail "ToPrimitive of an object"

def addOp (s : MS F) (a b : Val) : RS F :=
  match a, b with
  | .str x, .str y => retS F s (.str (x ++ y))
  | .str x, b => .bind (primStr b) fun
    | some y => retS F s (.str (x ++ y))
    | none => match b with
      | .sym _ => typeErr s (chars!"cannot convert a Symbol to a string")
      | _ => .fail "string concatenation with an object"
  | a, .str y => .bind (primStr a) fun
    | some x => retS F s (.str (x ++ y))
    | none => match a with
      | .sym _ => typeErr s (chars!"cannot convert a Symbol to a string")
      | _ => .fail "string concatenation with an object"
  | a, b => arith F s .add a b

/-- `a < b` (`strict = true`) or `a <= b`. -/
def compare (s : MS F) (a b : Val) (le : Bool) : RS F :=
  match a, b with
  | .str x, .str y => retS F s (.bool (bif le then !(strLt y x) else strLt x y))
  | .big x, .big y => retS F s (.bool (bif le then decide (x ≤ y) else decide (x < y)))
  | .big _, _ => .fail "bigint/number comparison"
  | _, .big _ => .fail "bigint/number comparison"
  | _, _ => .bind (toNum a) fun x => .bind (toNum b) fun y =>
    match x, y with
    | some x, some y => .bind (numTest (bif le then .le else .lt) x y) fun r => retS F s (.bool r)
    | _, _ => .fail "comparison of objects"

def looseEq (s : MS F) (a b : Val) : M (Option Bool) :=
  match a, b with
  | .undef, .null => .pure (some true)
  | .null, .undef => .pure (some true)
  | .undef, .undef => .pure (some true)
  | .null, .null => .pure (some true)
  | .undef, _ => .pure (some false)
  | .null, _ => .pure (some false)
  | _, .undef => .pure (some false)
  | _, .null => .pure (some false)
  | .num x, .str y => .bind (numTest .eq x (.lit (F64.ofString y))) fun r => .pure (some r)
  | .str x, .num y => .bind (numTest .eq (.lit (F64.ofString x)) y) fun r => .pure (some r)
  | .bool x, .bool y => .pure (some (x == y))
  | .bool x, .num y => .bind (numTest .eq (bif x then one else zeroN) y) fun r => .pure (some r)
  | .num x, .bool y => .bind (numTest .eq x (bif y then one else zeroN)) fun r => .pure (some r)
  | .obj _, .obj _ => .bind (strictEq F s a b) fun r => .pure (some r)
  | .obj _, _ => .pure none
  | _, .obj _ => .pure none
  | a, b => .bind (strictEq F s a b) fun r => .pure (some r)

def protoChainHas (s : MS F) (p : Nat) : Nat → Val → Bool
  | 0, _ => false
  | f + 1, .obj a => match s.obj? a with
    | some o => match o.proto with
      | .obj q => Nat.beq q p || protoChainHas s p f (.obj q)
      | _ => false
    | none => false
  | _, _ => false

def binOp (s : MS F) (op : BinOp) (a b : Val) : RS F :=
  match op with
  | .add => addOp F s a b
  | .lt => compare F s a b false
  | .gt => compare F s b a false
  | .le => compare F s a b true
  | .ge => compare F s b a true
  | .seq => .bind (strictEq F s a b) fun r => retS F s (.bool r)
  | .sne => .bind (strictEq F s a b) fun r => retS F s (.bool (!r))
  | .eq => .bind (looseEq F s a b) fun
    | some r => retS F s (.bool r)
    | none => .fail "== with an object and a primitive"
  | .ne => .bind (looseEq F s a b) fun
    | some r => retS F s (.bool (!r))
    | none => .fail "!= with an object and a primitive"
  | .inst => match b with
    | .obj _ => .bind (dataOf F s b kPrototype) fun
      | some (.obj p) => retS F s (.bool (protoChainHas F s p 64 a))
      | _ => typeErr s (chars!"instanceof with a non-constructor")
    | _ => typeErr s (chars!"instanceof with a non-object")
  | .in_ => match b with
    | .obj _ => .bind (toKey a) fun
      | some k => .bind (lookup F s b k) fun p => retS F s (.bool p.isSome)
      | none => .fail "in with an object key"
    | _ => typeErr s (chars!"in with a non-object")
  | op => arith F s op a b

def unaryOp (s : MS F) (op : UnOp) (v : Val) : RS F :=
  match op with
  | .neg => match v with
    | .big i => retS F s (.big (-i))
    | v => .bind (toNum v) fun
      | some x => .bind (numUn .neg x) fun r => retS F s (.num r)
      | none => .fail "negation of an object"
  | .pos => match v with
    | .big _ => typeErr s (chars!"cannot convert a BigInt to a number")
    | v => .bind (toNum v) fun
      | some x => retS F s (.num x)
      | none => .fail "unary + of an object"
  | .not => .bind (truthy v) fun b => retS F s (.bool (!b))
  | .bnot => match v with
    | .big i => retS F s (.big (-(i + 1)))
    | v => .bind (toNum v) fun
      | some x => .bind (numBin .bxor x (.lit (F64.ofInt (-1)))) fun r => retS F s (.num r)
      | none => .fail "~ of an object"
  | .typeof => retS F s (.str (typeofStr s v))
  | .void => retS F s .undef
  | .delete => .fail "delete"

/-! ## Element access fast paths -/

def elemAt (s : MS F) (v : Val) (i : Nat) : M (Option Val) :=
  match v with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .array es => .pure (nth? es i)
      | .typed k b off n => .bind (typedGet F s k b off n i) fun
        | some (.data x _ _) => .pure (some x)
        | _ => .pure none
      | _ => .pure none
    | none => .pure none
  | .str cs => .pure ((nth? cs i).map fun c => .str [c])
  | _ => .pure none

def isIndexable (s : MS F) : Val → Bool
  | .obj a => match s.obj? a with
    | some ⟨.array _, _, _, _, _⟩ => true
    | some ⟨.typed _ _ _ _, _, _, _, _⟩ => true
    | _ => false
  | .str _ => true
  | _ => false

/-- `o[k]`: element fast path for array-likes and number keys. -/
def getIndex (s : MS F) (o k : Val) : RS F :=
  match numIndex k with
  | some i => bif isIndexable F s o then .bind (elemAt F s o i) fun
      | some v => retS F s v
      | none => getV F s o (.str (F64.natStr i))
    else getV F s o (.str (F64.natStr i))
  | none => .bind (toKey k) fun
    | some key => getV F s o key
    | none => .fail "property key of an object"

/-! ## Calls -/

def enterClosure (s : MS F) (f : Func) (cenv : Env) (arrow : Bool) (home this : Val) (args : List Val) (b : Boundary) : RS F :=
  let (env, s) : Env × MS F := bif arrow then (cenv, s) else
    let (c, s) := s.alloc (.cell (some this))
    let env := (nThis, c) :: cenv
    match home with
    | .undef => (env, s)
    | h => let (c2, s) := s.alloc (.cell (some h)); ((nHome, c2) :: env, s)
  let (env, s) := allocCells s (paramNames f) env
  .pure (((s.push (.k (.fn b))).push (.k (.params f (fnParams f) args env))).ret .undef)

def callStep (s : MS F) (f this : Val) (args : List Val) : RS F :=
  match f with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .fn c => match c with
        | .closure fn cenv arrow home => enterClosure F s fn cenv arrow home this args .call
        | .klass _ _ _ _ => typeErr s (chars!"class constructor cannot be invoked without 'new'")
        | .native n data => callNative F s n data this args
        | .bound t th as => .pure (s.go (.call t th (as ++ args)))
      | _ => typeErr s (chars!"not a function")
    | none => .fail "dangling"
  | _ => typeErr s (chars!"not a function")

def constructStep (s : MS F) (f : Val) (args : List Val) (nt : Val) : RS F :=
  match f with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .fn c => match c with
        | .klass ctor cenv parent inst => match parent with
          | .null =>
            .bind (dataOf F s nt kPrototype) fun pr =>
            let proto : Val := match pr with | some (.obj p) => .obj p | _ => .obj aObjectProto
            let (ob, s) := s.allocObj .ordinary proto []
            let (tc, s) := s.alloc (.cell (some (.obj ob)))
            let fenv := (nThis, tc) :: cenv
            let s := match ctor with
              | none => s.push (.e (.const (.obj ob)))
              | some fn => s.push (.k (.ctorBody (.obj ob) fn cenv args))
            .pure ((s.push (.k (.fields ob inst fenv))).ret .undef)
          | par =>
            let (tc, s) := s.alloc (.cell none)
            let (cc, s) := s.alloc (.cell (some f))
            let (nc, s) := s.alloc (.cell (some nt))
            let env := (nThis, tc) :: (nCls, cc) :: (nNt, nc) :: cenv
            match ctor with
            | none => .pure (((s.push (.k (.fn (.derived tc)))).push (.k (.superRet tc a env))).go (.construct par args nt))
            | some fn => enterClosure F s fn env true .undef .undef args (.derived tc)
        | .native n data => constructNative F s n data args nt
        | .bound t _ as => .pure (s.go (.construct t (as ++ args) (match nt with | .obj b => bif Nat.beq a b then t else nt | _ => nt)))
        | .closure fn cenv false _ =>
          let (ob, s) := s.allocObj .ordinary (.obj aObjectProto) []
          enterClosure F s fn cenv false .undef (.obj ob) args (.ctor (.obj ob))
        | .closure _ _ true _ => typeErr s (chars!"arrow function is not a constructor")
      | _ => typeErr s (chars!"not a constructor")
    | none => .fail "dangling"
  | _ => typeErr s (chars!"not a constructor")

def argsNext (s : MS F) (kind : Nat) (fn this : Val) (acc : List Val) (rest : List Elem) (env : Env) : RS F :=
  match rest with
  | .expr e :: r => .pure ((s.push (.c (.args kind fn this acc r env))).go (.ev e env))
  | .spread e :: r => .pure ((s.push (.c (.spread kind fn this acc r env))).go (.ev e env))
  | .hole :: r => argsNext s kind fn this (.undef :: acc) r env
  | [] => match kind with
    | 0 => .pure (s.go (.call fn this acc.reverse))
    | 1 => .pure (s.go (.construct fn acc.reverse fn))
    | _ => match lookupEnv nThis env, cellVal? F s nCls env, cellVal? F s nNt env with
      | some tc, some (.obj cls), some nt => .pure ((s.push (.k (.superRet tc cls env))).go (.construct fn acc.reverse nt))
      | _, _, _ => .fail "super call outside a derived constructor"

/-- Start iterating `v` generically: `v[Symbol.iterator]()` returns to the top frame. -/
def startIter (s : MS F) (v : Val) : RS F :=
  getV F (s.push (.c (.method v [] [] false))) v (.sym symIterator)

def evCall (s : MS F) (callee : Expr) (args : List Elem) (opt : Bool) (env : Env) : RS F :=
  match callee with
  | .super => match cellVal? F s nCls env with
    | some (.obj c) => match s.obj? c with
      | some ⟨.fn (.klass _ _ par _), _, _, _, _⟩ => argsNext F s 2 par .undef [] args env
      | _ => .fail "super call class"
    | _ => .fail "super call outside a derived constructor"
  | .member o p optObj => .pure ((s.push (.c (.member (.str p) args env optObj opt))).go (.ev o env))
  | .index o k optObj => .pure ((s.push (.c (.index k args env optObj opt))).go (.ev o env))
  | .priv o n optObj => match lookupEnv (privName n) env with
    | some b => .pure ((s.push (.c (.priv b n args env optObj opt))).go (.ev o env))
    | none => .fail "unbound private name"
  | c => .pure ((s.push (.c (.callee args env opt))).go (.ev c env))

/-! ## Literals -/

def evLit (s : MS F) : Lit → RS F
  | .num raw => match F64.ofLit raw with
    | some x => retS F s (.num (.lit x))
    | none => .fail "number literal"
  | .big raw => match F64.parseIntLit raw with
    | some n => retS F s (.big n)
    | none => .fail "bigint literal"
  | .str raw => match cook raw with
    | some cs => retS F s (.str cs)
    | none => .fail "string literal escape"
  | .bool b => retS F s (.bool b)
  | .null => retS F s .null
  -- a fresh `RegExp` per evaluation, with the global constructor's prototype
  | .regex p fl => .bind (getChain F s (.str chars!"RegExp") 16 aGlobal) fun
    | some (.data (.obj c) _ _) => .bind (dataOf F s (.obj c) kPrototype) fun
      | some (.obj pr) => hostN F s .undef [.str p, .str fl] [.obj pr] .regexNew
      | _ => .fail "RegExp.prototype"
    | _ => .fail "regular expression literal without a RegExp global"

def arrayNext (s : MS F) (acc : List Val) (rest : List Elem) (env : Env) : RS F :=
  match rest with
  | [] => let (a, s) := newArray s acc.reverse; retS F s (.obj a)
  | .hole :: r => arrayNext s (.undef :: acc) r env
  | .expr e :: r => .pure ((s.push (.l (.array acc r env))).go (.ev e env))
  | .spread e :: r => .pure ((s.push (.l (.spread acc r env))).go (.ev e env))

/-- Install an accessor half, keeping the other half. -/
def accessorProp (old : Option PropV) (kind : MethodKind) (f : Val) (enum : Bool) : PropV :=
  let (g, st) : Val × Val := match old with
    | some (.acc g st _) => (g, st)
    | _ => (.undef, .undef)
  match kind with
  | .get => .acc f st enum
  | .set => .acc g f enum
  | .method => .data f true enum

def methodProp (s : MS F) (target : Nat) (k : PKey) (kind : MethodKind) (fn : Func) (env : Env) (enum : Bool) : MS F :=
  let (c, s) := closureObj s fn env false (.obj target)
  match s.obj? target with
  | some o => s.setObj target { o with props := setPropL k (accessorProp (findProp k o.props) kind (.obj c) enum) o.props }
  | none => s

def objNext (s : MS F) (o : Nat) (rest : List Property) (env : Env) : RS F :=
  match rest with
  | [] => retS F s (.obj o)
  | p :: r => match p with
    | .init k e => match keyOf k with
      | some key => .pure ((s.push (.l (.objVal o key r env))).go (.ev e env))
      | none => match k with
        | .computed ke => .pure ((s.push (.l (.objKey o p r env))).go (.ev ke env))
        | _ => .fail "object literal key"
    | .short n => readVar F (s.push (.l (.objVal o (.str n) r env))) n env
    | .method kind k fn => match keyOf k with
      | some key => objNext (methodProp F s o key kind fn env true) o r env
      | none => match k with
        | .computed ke => .pure ((s.push (.l (.objKey o p r env))).go (.ev ke env))
        | _ => .fail "object literal key"
    | .spread e => .pure ((s.push (.l (.objSpread o r env))).go (.ev e env))

def tmplNext (s : MS F) (acc : List Char) (quasis : List (List Char)) (subs : List Expr) (env : Env) : RS F :=
  match subs with
  | [] => retS F s (.str acc)
  | e :: es => .pure ((s.push (.l (.tmpl acc quasis es env))).go (.ev e env))

def cookAll : List (List Char) → Option (List Val)
  | [] => some []
  | q :: qs => (cook q).bind fun c => (cookAll qs).map (.str c :: ·)

def taggedNext (s : MS F) (tag : Val) (quasis : List (List Char)) (acc : List Val) (subs : List Expr) (env : Env) : RS F :=
  match subs with
  | e :: es => .pure ((s.push (.l (.tagged tag quasis acc es env))).go (.ev e env))
  | [] =>
    let cooked := (cookAll quasis).getD (quasis.map fun _ => .undef)
    let (raw, s) := newArray s (quasis.map Val.str)
    let (strs, s) := newArray s cooked
    let s := defineProp F s strs (.str (chars!"raw")) (.data (.obj raw) false false)
    .pure (s.go (.call tag .undef (.obj strs :: acc.reverse)))

/-! ## Assignment -/

def readTarget (s : MS F) : Target → RS F
  | .var n env => readVar F s n env
  | .prop o k => getV F s o k
  | .priv o b n => privGetV F s o b n

def storeTarget (s : MS F) (t : Target) (v : Val) : RS F :=
  match t with
  | .var n env => writeVar F s n env v
  | .prop o k => putV F s o k v
  | .priv o b n => privPutV F s o b n v

def asgTarget (s : MS F) (op : AsgOp) (t : Target) (v : Expr) (env : Env) : RS F :=
  match op with
  | .assign => .pure ((s.push (.a (.put none t .undef))).go (.ev v env))
  | op => readTarget F (s.push (.a (.old op t v env))) t

def evAssign (s : MS F) (op : AsgOp) (target : Pat) (v : Expr) (env : Env) : RS F :=
  match target with
  | .id n => asgTarget F s op (.var n env) v env
  | .expr (.member o p _) => .pure ((s.push (.a (.obj op (some (.str p)) none v env))).go (.ev o env))
  | .expr (.index o k _) => .pure ((s.push (.a (.obj op none (some k) v env))).go (.ev o env))
  | .expr (.priv o n _) => match lookupEnv (privName n) env with
    | some b => .pure ((s.push (.a (.privObj op b n v env))).go (.ev o env))
    | none => .fail "unbound private name"
  | .expr _ => .fail "assignment target"
  | .dflt _ _ => .fail "assignment target"
  | p => match op with
    | .assign => .pure ((s.push (.a (.pat p env))).go (.ev v env))
    | _ => .fail "compound destructuring assignment"

def evUpdate (s : MS F) (inc pre : Bool) (t : Expr) (env : Env) : RS F :=
  match t with
  | .id n => readVar F (s.push (.a (.updOld inc pre (.var n env)))) n env
  | .member o p _ => .pure ((s.push (.a (.updObj inc pre (some (.str p)) none env))).go (.ev o env))
  | .index o k _ => .pure ((s.push (.a (.updObj inc pre none (some k) env))).go (.ev o env))
  | .priv o n _ => match lookupEnv (privName n) env with
    | some b => .pure ((s.push (.a (.updPrivObj inc pre b n))).go (.ev o env))
    | none => .fail "unbound private name"
  | _ => .fail "update target"

/-! ## Classes -/

def defineClass (s : MS F) (c : Class) (parent : Option Val) (env : Env) : RS F :=
  match c with
  | .mk name _ members =>
    let (brand, s) := s.alloc (.cell none)
    let env := (memberPrivs members).foldl (fun e n => (privName n, brand) :: e) env
    let (env, s, nameCell) : Env × MS F × Option Nat := match name with
      | some n => let (c, s) := s.alloc (.cell none); ((n, c) :: env, s, some c)
      | none => (env, s, none)
    let parents : M (Option (Val × Val)) := match parent with
      | none => .pure (some (.obj aObjectProto, .obj aFunctionProto))
      | some .null => .pure (some (.null, .obj aFunctionProto))
      | some (.obj pa) => .bind (dataOf F s (.obj pa) kPrototype) fun
        | some pp => .pure (some (pp, .obj pa))
        | none => .pure none
      | some _ => .pure none
    .bind parents fun
    | some (pp, cp) =>
      let ctor := classCtor members
      let parentV : Val := match parent with | some p => p | none => .null
      let inst0 : List InstMember := ((ctor.map fnProps).getD []).reverse.map fun n => .field (.str n) none
      let (p, s) := s.allocObj .ordinary pp []
      let (f, s) := s.allocObj (.fn (.klass ctor env parentV [])) cp [(kPrototype, .data (.obj p) false false)]
      let s := defineProp F s p kConstructor (.data (.obj f) true false)
      let s := match nameCell with | some c => s.setCell c (.obj f) | none => s
      .pure ((s.push (.k (.classMembers f p members inst0 env))).ret .undef)
    | none => typeErr s (chars!"class extends a non-constructor")

def setKlassInst (s : MS F) (f : Nat) (inst : List InstMember) : MS F :=
  match s.obj? f with
  | some o => match o.kind with
    | .fn (.klass c e p _) => s.setObj f { o with kind := .fn (.klass c e p inst) }
    | _ => s
  | none => s

def privMethodProp (s : MS F) (fn : Func) (env : Env) (home : Nat) (kind : MethodKind) (old : Option PropV) : PropV × MS F :=
  let (c, s) := closureObj s fn env false (.obj home)
  match kind with
  | .method => (.data (.obj c) false false, s)
  | k => (accessorProp old k (.obj c) false, s)

def findInstPriv (b : Nat) (n : Name) : List InstMember → Option PropV
  | [] => none
  | .privMethod c m p :: r => bif Nat.beq b c && nameEq n m then some p else findInstPriv b n r
  | _ :: r => findInstPriv b n r

def dropInstPriv (b : Nat) (n : Name) : List InstMember → List InstMember
  | [] => []
  | .privMethod c m p :: r => bif Nat.beq b c && nameEq n m then dropInstPriv b n r else .privMethod c m p :: dropInstPriv b n r
  | i :: r => i :: dropInstPriv b n r

def thisEnv (s : MS F) (v : Val) (env : Env) : Env × MS F :=
  let (c, s) := s.alloc (.cell (some v)); ((nThis, c) :: env, s)

def classNext (s : MS F) (f p : Nat) (ms : List Member) (inst : List InstMember) (env : Env) : RS F :=
  match ms with
  | [] => retS F (setKlassInst F s f inst.reverse) (.obj f)
  | m :: ms => match m with
    | .ctor _ => classNext s f p ms inst env
    | .block _ => .fail "static block"
    | .method static kind k fn => match k with
      | .priv n => match lookupEnv (privName n) env with
        | some b => bif static then
            match s.obj? f with
            | some o =>
              let (pr, s) := privMethodProp F s fn env f kind (findPriv b n o.priv)
              match s.obj? f with
              | some o => classNext (s.setObj f { o with priv := setPrivL b n pr o.priv }) f p ms inst env
              | none => .fail "dangling"
            | none => .fail "dangling"
          else
            let (pr, s) := privMethodProp F s fn env p kind (findInstPriv b n inst)
            classNext s f p ms (.privMethod b n pr :: dropInstPriv b n inst) env
        | none => .fail "unbound private name"
      | .computed e => .pure ((s.push (.k (.classKey f p m ms inst env))).go (.ev e env))
      | k => match keyOf k with
        | some key => classNext (methodProp F s (bif static then f else p) key kind fn env false) f p ms inst env
        | none => .fail "class member key"
    | .field static k init => match k with
      | .priv n => match lookupEnv (privName n) env with
        | some b => bif static then
            match init with
            | some e => let (env', s) := thisEnv F s (.obj f) env
              .pure ((s.push (.k (.privVal f b n [] env'))).push (.k (.classMembers f p ms inst env)) |>.go (.ev e env'))
            | none => match s.obj? f with
              | some o => classNext (s.setObj f { o with priv := setPrivL b n (.data .undef true false) o.priv }) f p ms inst env
              | none => .fail "dangling"
          else classNext s f p ms (.privField b n init :: inst) env
        | none => .fail "unbound private name"
      | .computed e => .pure ((s.push (.k (.classKey f p m ms inst env))).go (.ev e env))
      | k => match keyOf k with
        | some key => bif static then
            match init with
            | some e => let (env', s) := thisEnv F s (.obj f) env
              .pure ((s.push (.k (.classStatic f p key ms inst env))).go (.ev e env'))
            | none => classNext (defineData F s f key .undef) f p ms inst env
          else classNext s f p ms (.field key init :: inst) env
        | none => .fail "class member key"

/-- A computed member key `key` evaluated. -/
def classKeyed (s : MS F) (f p : Nat) (m : Member) (key : PKey) (ms : List Member) (inst : List InstMember) (env : Env) : RS F :=
  match m with
  | .method static kind _ fn => classNext F (methodProp F s (bif static then f else p) key kind fn env false) f p ms inst env
  | .field true _ (some e) => let (env', s) := thisEnv F s (.obj f) env
    .pure ((s.push (.k (.classStatic f p key ms inst env))).go (.ev e env'))
  | .field true _ none => classNext F (defineData F s f key .undef) f p ms inst env
  | .field false _ init => classNext F s f p ms (.field key init :: inst) env
  | _ => .fail "class member key"

def fieldsNext (s : MS F) (o : Nat) (ms : List InstMember) (env : Env) : RS F :=
  match ms with
  | [] => retS F s .undef
  | .field k none :: r => fieldsNext (defineData F s o k .undef) o r env
  | .field k (some e) :: r => .pure ((s.push (.k (.fieldVal o k r env))).go (.ev e env))
  | .privField b n none :: r => match s.obj? o with
    | some ob => fieldsNext (s.setObj o { ob with priv := setPrivL b n (.data .undef true false) ob.priv }) o r env
    | none => .fail "dangling"
  | .privField b n (some e) :: r => .pure ((s.push (.k (.privVal o b n r env))).go (.ev e env))
  | .privMethod b n p :: r => match s.obj? o with
    | some ob => fieldsNext (s.setObj o { ob with priv := setPrivL b n p ob.priv }) o r env
    | none => .fail "dangling"

/-! ## Function entry and exit -/

def startBody (s : MS F) (f : Func) (env : Env) : RS F :=
  match f with
  | .mk _ _ _ body _ _ props => match body with
    | .expr e => .pure ((s.push (.s .ret)).go (.ev e env))
    | .block ss =>
      let s := enterBlock s ss env
      match s.stack, props with
      | _, [] => .pure s
      -- base constructor: parameter properties first (derived: after `super()`)
      | _ :: _ :: .k (.fn (.ctor o)) :: _, ps => .pure ((s.push (.k (.paramProps o ps env))).ret .undef)
      | _, _ => .pure s

def bodyStmts : Body → List Stmt
  | .block ss => ss
  | .expr e => [.ret (some e)]

def enterBody (s : MS F) (f : Func) (env : Env) : RS F :=
  match f with
  | .mk _ _ _ body async gen _ => match async, gen, s.stack with
    | false, false, _ => startBody F s f env
    | true, false, .k (.fn _) :: rest =>
      let (p, s) := newPromise { s with stack := rest }
      startBody F (s.push (.k (.fn (.async p)))) f env
    | a, true, .k (.fn _) :: rest =>
      let (g, s) := s.allocObj (.gen (.start (bodyStmts body) env) a []) (.obj (bif a then aAsyncGenProto else aGenProto)) []
      retS F { s with stack := rest } (.obj g)
    | _, _, _ => .fail "function boundary"

def paramsNext (s : MS F) (f : Func) (ps : List Pat) (args : List Val) (env : Env) : RS F :=
  match ps with
  | p :: ps =>
    let v := nthD .undef args 0
    match p, v with
    | .dflt q d, .undef => .pure ((s.push (.k (.paramDflt f q ps args.tail env))).go (.ev d env))
    | p, v => .pure ((s.push (.k (.params f ps args.tail env))).go (.bind p v env .init .let_))
  | [] => match fnRest f with
    | some r => let (a, s) := newArray s args
      .pure ((s.push (.k (.params (noRest f) [] [] env))).go (.bind r (.obj a) env .init .let_))
    | none => enterBody F s f env

/-- Complete the head request of async generator `g`. -/
def agenComplete (s : MS F) (g : Nat) (c : Comp) : MS F :=
  let s := setGen s g .done
  match agenQueue s g with
  | (p, _) :: q =>
    let s := setQueue s g q
    let s := match c with
      | .abrupt (.throw e) => settle s p true e
      | .abrupt (.ret v) => let (r, s) := iterResult s v true; resolveP s p (.obj r)
      | .normal _ => let (r, s) := iterResult s .undef true; resolveP s p (.obj r)
      | _ => s
    agenDrain s g
  | [] => s.ret .undef

def boundaryRet (s : MS F) (b : Boundary) : RS F :=
  match b with
  | .call => retS F s .undef
  | .ctor o => retS F s o
  | .derived tc => match s.cell? tc with
    | some (some v) => retS F s v
    | _ => refErr s (chars!"must call super constructor before returning")
  | .async p => retS F (resolveP s p .undef) (.obj p)
  | .gen g => match genOf s g with
    | some (_, true) => .pure (agenComplete F s g (.normal .undef))
    | _ => let (r, s) := iterResult (setGen s g .done) .undef true; retS F s (.obj r)

def boundaryAbr (s : MS F) (b : Boundary) (a : Abrupt) : RS F :=
  match a with
  | .ret v => match b with
    | .call => retS F s v
    | .ctor o => match v with
      | .obj _ => retS F s v
      | _ => retS F s o
    | .derived tc => match v with
      | .obj _ => retS F s v
      | .undef => boundaryRet F s b
      | _ => typeErr s (chars!"derived constructor returned a non-object")
    | .async p => retS F (resolveP s p v) (.obj p)
    | .gen g => match genOf s g with
      | some (_, true) => .pure (agenComplete F s g (.abrupt (.ret v)))
      | _ => let (r, s) := iterResult (setGen s g .done) v true; retS F s (.obj r)
  | .throw e => match b with
    | .async p => retS F (settle s p true e) (.obj p)
    | .gen g => match genOf s g with
      | some (_, true) => .pure (agenComplete F s g (.abrupt (.throw e)))
      | _ => .pure ((setGen s g .done).go (.abr (.throw e)))
    | _ => .pure (s.go (.abr (.throw e)))
  | _ => .fail "break or continue across a function boundary"

/-- `await v`: suspend to the nearest async boundary. -/
def awaitVal (s : MS F) (v : Val) : RS F :=
  let (p, s) := promiseFor s v
  match splitSusp [] s.stack with
  | some (frames, .k (.fn (.async q)), rest) =>
    let s := react { s with stack := rest } p (.resume ⟨frames, s.stores⟩)
    retS F s (.obj q)
  | some (frames, .k (.fn (.gen _)), rest) =>
    let s := react { s with stack := rest } p (.resume ⟨frames, s.stores⟩)
    retS F s .undef
  | _ => .fail "await outside an async function"

def nearestGen : List Frame → Option (Nat × Bool)
  | [] => none
  | .k (.fn (.gen g)) :: _ => some (g, false)
  | .k (.fn (.async _)) :: _ => none
  | .k (.fn _) :: _ => none
  | _ :: fs => nearestGen fs

/-- Sync `yield r` where `r` is already an iterator result. -/
def yieldResult (s : MS F) (r : Val) : RS F :=
  match splitSusp [] s.stack with
  | some (frames, .k (.fn (.gen g)), rest) =>
    retS F { setGen s g (.suspended ⟨frames, s.stores⟩) with stack := rest } r
  | _ => .fail "yield outside a generator"

def yieldVal (s : MS F) (v : Val) : RS F :=
  let (r, s) := iterResult s v false
  yieldResult F s (.obj r)

/-- Async generator `yield` after its operand was awaited: fulfill the head
request, then suspend (or continue with the next queued request). -/
def agenYield (s : MS F) (v : Val) : RS F :=
  match splitSusp [] s.stack with
  | some (frames, .k (.fn (.gen g)), rest) =>
    match agenQueue s g with
    | (p, _) :: q =>
      let (r, s) := iterResult s v false
      let s := resolveP (setQueue s g q) p (.obj r)
      let s := setGen { s with stack := rest } g (.suspended ⟨frames, s.stores⟩)
      .pure (agenDrain s g)
    | [] => .fail "async generator yield without a request"
  | _ => .fail "yield outside a generator"

/-! ## Statements -/

def declNext (s : MS F) (kind : DeclKind) (ds : List (Pat × Option Expr)) (env : Env) : RS F :=
  match ds with
  | [] => retS F s .undef
  | (p, some e) :: r => .pure ((s.push (.s (.decl kind p r env))).go (.ev e env))
  | (p, none) :: r => .pure ((s.push (.s (.declNext kind r env))).go (.bind p .undef env .init kind))

def enumObj (s : MS F) (members : List (Key × Option Expr)) : Option (MS F × Nat) :=
  let (o, s) := s.allocObj .ordinary (.obj aObjectProto) []
  let rec go (s : MS F) (next : F64) : List (Key × Option Expr) → Option (MS F)
    | [] => some s
    | (k, init) :: r => (keyOf k).bind fun key =>
      let v : Option Val := match init with
        | none => some (.num (.lit next))
        | some (.lit (.num raw)) => (F64.ofLit raw).map fun x => .num (.lit x)
        | some (.unary .neg (.lit (.num raw))) => (F64.ofLit raw).map fun x => .num (.lit (F64.neg x))
        | some (.lit (.str raw)) => (cook raw).map Val.str
        | _ => none
      v.bind fun v =>
        let s := defineData F s o key v
        match v with
        | .num (.lit x) =>
          let s := match F64.toStr x, key with
            | some cs, .str n => defineData F s o (.str cs) (.str n)
            | _, _ => s
          go s (F64.add x (.fin false 1 0)) r
        | _ => go s next r
  (go s (.zero false) members).map fun s => (s, o)

def forStart (s : MS F) (init : Option ForHead) (test update : Option Expr) (body : Stmt) (env : Env) (labels : List Name) : RS F :=
  match init with
  | some (.decl kind ds) => match kind with
    | .let_ | .const =>
      let names := declsNames ds
      let (env1, s) := allocCells s names env
      declNext F (s.push (.lp (.forTest true test update body env1 names labels))) kind ds env1
    | _ => .fail "for with a var or using declaration"
  | some (.expr e) => .pure ((s.push (.lp (.forTest false test update body env [] labels))).go (.ev e env))
  | none => .pure ((s.push (.lp (.forTest false test update body env [] labels))).ret .undef)

def exLoopF (s : MS F) : Nat → Stmt → Env → List Name → RS F
  | 0, _, _, _ => .fail "label nesting"
  | f + 1, st, env, labels => match st with
  | .for_ init test update body => forStart F s init test update body env labels
  | .forOf aw kind p e body => .pure ((s.push (.lp (.forOfSrc aw kind p body env labels))).go (.ev e env))
  | .while_ c body => .pure ((s.push (.lp (.whileTest c body env labels))).go (.ev c env))
  | .doWhile body c => .pure ((s.push (.lp (.doBody body c env labels))).go (.ex body env))
  | .labeled l st => exLoopF s f st env (l :: labels)
  | st => .pure ((labels.foldl (fun s l => s.push (.s (.label l))) s).go (.ex st env))

def exLoop (s : MS F) (st : Stmt) (env : Env) (labels : List Name) : RS F := exLoopF F s 8 st env labels

def caseStmts : List (Option Expr × List Stmt) → List Stmt
  | [] => []
  | (_, ss) :: r => ss ++ caseStmts r

def fromDefault : List (Option Expr × List Stmt) → Option (List (Option Expr × List Stmt))
  | [] => none
  | (none, ss) :: r => some ((none, ss) :: r)
  | _ :: r => fromDefault r

def runCases (s : MS F) (cs : List (Option Expr × List Stmt)) (env : Env) : RS F :=
  .pure (((s.push (.s .switchBody)).push (.s (.block (caseStmts cs) env))).ret .undef)

def switchNext (s : MS F) (d : Val) (cs all : List (Option Expr × List Stmt)) (env : Env) : RS F :=
  match cs with
  | [] => match fromDefault all with
    | some r => runCases F s r env
    | none => retS F s .undef
  | (none, _) :: r => switchNext s d r all env
  | (some t, _) :: _ => .pure ((s.push (.s (.switchCase d cs all env))).go (.ev t env))

def exStep (s : MS F) (st : Stmt) (env : Env) : RS F :=
  match st with
  | .expr e => .pure (s.go (.ev e env))
  | .decl kind ds => declNext F s kind ds env
  | .func _ => retS F s .undef
  | .cls c => match c with
    | .mk (some n) _ _ => .pure ((s.push (.s (.decl .let_ (.id n) [] env))).go (.ev (.cls c) env))
    | _ => .pure (s.go (.ev (.cls c) env))
  | .enum _ n members => match enumObj F s members with
    | some (s, o) => match lookupEnv n env with
      | some c => retS F (s.setCell c (.obj o)) .undef
      | none => .fail "enum binding"
    | none => .fail "enum member initializer"
  | .ret e => match e with
    | some e => .pure ((s.push (.s .ret)).go (.ev e env))
    | none => .pure (s.go (.abr (.ret .undef)))
  | .if_ c t e => .pure ((s.push (.s (.if_ t e env))).go (.ev c env))
  | .block ss => .pure (enterBlock s ss env)
  | .for_ _ _ _ _ | .forOf _ _ _ _ _ | .while_ _ _ | .doWhile _ _ => exLoop F s st env []
  | .forIn _ _ _ _ => .fail "for-in"
  | .switch d cases =>
    let (env', s) := hoist s (caseStmts cases) env
    .pure (((s.push (.s (.scope []))).push (.s (.switchD cases env'))).go (.ev d env))
  | .try_ b h f => .pure (enterBlock (s.push (.s (.try_ h f env))) b env)
  | .throw e => .pure ((s.push (.s .throw)).go (.ev e env))
  | .break l => .pure (s.go (.abr (.brk l)))
  | .continue l => .pure (s.go (.abr (.cont l)))
  | .labeled l st => exLoop F s st env [l]
  | .empty => retS F s .undef

def evStep (s : MS F) (e : Expr) (env : Env) : RS F :=
  match e with
  | .lit l => evLit F s l
  | .id n => readVar F s n env
  | .this => readVar F s nThis env
  | .super => .fail "super property access"
  | .template none quasis subs => match quasis with
    | q :: qs => match cook q with
      | some c => tmplNext F s c qs subs env
      | none => .fail "template escape"
    | [] => .fail "template"
  | .template (some tag) quasis subs => .pure ((s.push (.l (.tagged .undef quasis [] subs env))).go (.ev tag env))
  | .array elems => arrayNext F s [] elems env
  | .object props => let (o, s) := s.allocObj .ordinary (.obj aObjectProto) []; objNext F s o props env
  | .func f => let (a, s) := closureObj s f env false .undef; retS F s (.obj a)
  | .arrow f => let (a, s) := closureObj s f env true .undef; retS F s (.obj a)
  | .cls c => match c with
    | .mk _ (some sup) _ => .pure ((s.push (.k (.classHeritage c env))).go (.ev sup env))
    | _ => defineClass F s c none env
  | .member o p opt => .pure ((s.push (.e (.member (.str p) opt))).go (.ev o env))
  | .priv o n opt => match lookupEnv (privName n) env with
    | some b => .pure ((s.push (.e (.priv b n opt))).go (.ev o env))
    | none => .fail "unbound private name"
  | .index o k opt => .pure ((s.push (.e (.indexL k env opt))).go (.ev o env))
  | .call callee args opt => evCall F s callee args opt env
  | .new callee args => .pure ((s.push (.c (.newCallee args env))).go (.ev callee env))
  | .chain e => .pure ((s.push (.e .chain)).go (.ev e env))
  | .unary op x => match op, x with
    | .typeof, .id n => match lookupEnv n env with
      | some _ => .pure ((s.push (.e .typeof)).go (.ev x env))
      | none => .bind (getChain F s (.str n) 16 aGlobal) fun
        | some _ => .pure ((s.push (.e .typeof)).go (.ev x env))
        | none => retS F s (.str (chars!"undefined"))
    | .delete, _ => .fail "delete"
    | op, x => .pure ((s.push (.e (.unary op))).go (.ev x env))
  | .update inc pre t => evUpdate F s inc pre t env
  | .bin op a b => .pure ((s.push (.e (.binL op b env))).go (.ev a env))
  | .log op a b => .pure ((s.push (.e (.logL op b env))).go (.ev a env))
  | .cond c a b => .pure ((s.push (.e (.cond a b env))).go (.ev c env))
  | .assign op t v => evAssign F s op t v env
  | .seq a b => .pure ((s.push (.e (.seq b env))).go (.ev a env))
  | .yield arg d => match arg with
    | some a => .pure ((s.push (.k (.yield d))).go (.ev a env))
    | none => .pure ((s.push (.k (.yield d))).ret .undef)
  | .await x => .pure ((s.push (.k .await)).go (.ev x env))

/-! ## Frames receiving a value -/

def retE (s : MS F) (f : ExprF) (v : Val) : RS F :=
  match f with
  | .unary op => unaryOp F s op v
  | .binL op b env => .pure ((s.push (.e (.binR op v))).go (.ev b env))
  | .binR op a => binOp F s op a v
  | .logL op b env => match op with
    | .and => .bind (truthy v) fun t => bif t then .pure (s.go (.ev b env)) else retS F s v
    | .or => .bind (truthy v) fun t => bif t then retS F s v else .pure (s.go (.ev b env))
    | .nullish => bif isNullish v then .pure (s.go (.ev b env)) else retS F s v
  | .cond a b env => .bind (truthy v) fun t => .pure (s.go (.ev (bif t then a else b) env))
  | .seq b env => .pure (s.go (.ev b env))
  | .member k opt => bif opt && isNullish v then .pure (s.go .short) else getV F s v k
  | .indexL k env opt => bif opt && isNullish v then .pure (s.go .short) else .pure ((s.push (.e (.indexR v))).go (.ev k env))
  | .indexR o => match o with
    | .undef | .null => typeErr s (chars!"cannot read properties of nullish")
    | o => getIndex F s o v
  | .priv b n opt => bif opt && isNullish v then .pure (s.go .short) else privGetV F s v b n
  | .chain => retS F s v
  | .const c => retS F s c
  | .typeof => retS F s (.str (typeofStr s v))

def spreadElems (s : MS F) (v : Val) (again : Frame) (k : List Val → RS F) : RS F :=
  .bind (elemsOf F s v) fun
    | some es => k es
    | none => match v with
      | .obj _ => startIter F ((s.push again).push (.b (.collectIt []))) v
      | _ => typeErr s (chars!"spread of a non-iterable")

def retC (s : MS F) (f : CallF) (v : Val) : RS F :=
  match f with
  | .callee args env opt => bif opt && isNullish v then .pure (s.go .short) else argsNext F s 0 v .undef [] args env
  | .member k args env optObj optCall =>
    bif optObj && isNullish v then .pure (s.go .short) else getV F (s.push (.c (.method v args env optCall))) v k
  | .index ke args env optObj optCall =>
    bif optObj && isNullish v then .pure (s.go .short) else .pure ((s.push (.c (.indexK v args env optCall))).go (.ev ke env))
  | .indexK o args env optCall => getIndex F (s.push (.c (.method o args env optCall))) o v
  | .priv b n args env optObj optCall =>
    bif optObj && isNullish v then .pure (s.go .short) else privGetV F (s.push (.c (.method v args env optCall))) v b n
  | .method this args env optCall => bif optCall && isNullish v then .pure (s.go .short) else argsNext F s 0 v this [] args env
  | .args kind fn this acc rest env => argsNext F s kind fn this (v :: acc) rest env
  | .spread kind fn this acc rest env =>
    spreadElems F s v (.c (.spread kind fn this acc rest env)) fun es => argsNext F s kind fn this (es.reverse ++ acc) rest env
  | .newCallee args env => argsNext F s 1 v .undef [] args env

def retL (s : MS F) (f : LitF) (v : Val) : RS F :=
  match f with
  | .array acc rest env => arrayNext F s (v :: acc) rest env
  | .spread acc rest env => spreadElems F s v (.l (.spread acc rest env)) fun es => arrayNext F s (es.reverse ++ acc) rest env
  | .object o rest env => objNext F s o rest env
  | .objKey o p rest env => .bind (toKey v) fun
    | some key => match p with
      | .init _ e => .pure ((s.push (.l (.objVal o key rest env))).go (.ev e env))
      | .method kind _ fn => objNext F (methodProp F s o key kind fn env true) o rest env
      | _ => .fail "object literal key"
    | none => .fail "object literal key of an object"
  | .objVal o k rest env => objNext F (defineData F s o k v) o rest env
  | .objSpread o rest env => match v with
    | .obj a => match s.obj? a with
      | some src => .bind (dataProps F s src) fun
        | some kvs => objNext F (kvs.foldl (fun s (k, x) => defineData F s o k x) s) o rest env
        | none => .fail "object spread over accessors"
      | none => .fail "dangling"
    | .str _ => .fail "object spread of a string"
    | _ => objNext F s o rest env
  | .tmpl acc quasis subs env => .bind (primStr v) fun
    | some piece => match quasis with
      | q :: qs => match cook q with
        | some c => tmplNext F s (acc ++ piece ++ c) qs subs env
        | none => .fail "template escape"
      | [] => .fail "template"
    | none => match v with
      | .sym _ => typeErr s (chars!"cannot convert a Symbol to a string")
      | _ => .fail "template substitution of an object"
  | .tagged tag quasis acc subs env => match tag with
    | .undef => taggedNext F s v quasis acc subs env
    | t => taggedNext F s t quasis (v :: acc) subs env

def retA (s : MS F) (f : AsgF) (v : Val) : RS F :=
  match f with
  | .pat p env => .pure ((s.push (.e (.const v))).go (.bind p v env .assign .let_))
  | .obj op k kexpr val env => match k, kexpr with
    | some key, _ => asgTarget F s op (.prop v key) val env
    | none, some ke => .pure ((s.push (.a (.key op v val env))).go (.ev ke env))
    | none, none => .fail "assignment target"
  | .key op o val env => match numIndex v with
    | some i => asgTarget F s op (.prop o (.str (F64.natStr i))) val env
    | none => .bind (toKey v) fun
      | some key => asgTarget F s op (.prop o key) val env
      | none => .fail "property key of an object"
  | .privObj op b n val env => asgTarget F s op (.priv v b n) val env
  | .old op t val env => match op with
    | .bin bo => .pure ((s.push (.a (.put (some bo) t v))).go (.ev val env))
    | .log lo => match lo with
      | .and => .bind (truthy v) fun b => bif b then .pure ((s.push (.a (.put none t v))).go (.ev val env)) else retS F s v
      | .or => .bind (truthy v) fun b => bif b then retS F s v else .pure ((s.push (.a (.put none t v))).go (.ev val env))
      | .nullish => bif isNullish v then .pure ((s.push (.a (.put none t v))).go (.ev val env)) else retS F s v
    | .assign => .fail "assignment"
  | .put op t old => match op with
    | some bo => binOp F (s.push (.a (.put none t old))) bo old v
    | none => storeTarget F s t v
  | .updObj inc pre k kexpr env => match k, kexpr with
    | some key, _ => readTarget F (s.push (.a (.updOld inc pre (.prop v key)))) (.prop v key)
    | none, some ke => .pure ((s.push (.a (.updKey inc pre v))).go (.ev ke env))
    | none, none => .fail "update target"
  | .updKey inc pre o => .bind (match numIndex v with
      | some i => .pure (some (PKey.str (F64.natStr i)))
      | none => toKey v) fun
    | some key => readTarget F (s.push (.a (.updOld inc pre (.prop o key)))) (.prop o key)
    | none => .fail "property key of an object"
  | .updPrivObj inc pre b n => readTarget F (s.push (.a (.updOld inc pre (.priv v b n)))) (.priv v b n)
  | .updOld inc pre t => match v with
    | .big i => let nv : Val := .big (bif inc then i + 1 else i - 1)
      storeTarget F (s.push (.e (.const (bif pre then nv else v)))) t nv
    | v => .bind (toNum v) fun
      | some x => .bind (numBin (bif inc then .add else .sub) x one) fun y =>
        storeTarget F (s.push (.e (.const (bif pre then .num y else .num x)))) t (.num y)
      | none => .fail "update of an object"

def finOrResume (s : MS F) (fin : Option (List Stmt)) (env : Env) (c : Comp) : RS F :=
  match fin with
  | some ss => .pure (enterBlock (s.push (.s (.finally_ c))) ss env)
  | none => .pure (resume s c)

def retSt (s : MS F) (f : StmtF) (v : Val) : RS F :=
  match f with
  | .block rest env => match rest with
    | [] => retS F s .undef
    | st :: r => .pure ((s.push (.s (.block r env))).go (.ex st env))
  | .scope res => match res with
    | [] => retS F s v
    | (x, m) :: r => .pure ((s.push (.s (.dispose r (.normal v)))).go (.call m x []))
  | .dispose rest c => match rest with
    | [] => .pure (resume s c)
    | (x, m) :: r => .pure ((s.push (.s (.dispose r c))).go (.call m x []))
  | .if_ t e env => .bind (truthy v) fun b => bif b then .pure (s.go (.ex t env)) else match e with
    | some e => .pure (s.go (.ex e env))
    | none => retS F s .undef
  | .decl kind p rest env =>
    let reg : M (Option (MS F)) := bif isUsing kind then
        match v with
        | .undef | .null => .pure (some s)
        | v => .bind (dataOf F s v (.sym symDispose)) fun
          | some m@(.obj _) => .pure ((addUsing (v, m) s.stack).map fun st => { s with stack := st })
          | _ => .pure none
      else .pure (some s)
    .bind reg fun
    | some s => .pure ((s.push (.s (.declNext kind rest env))).go (.bind p v env .init kind))
    | none => typeErr s (chars!"using value has no [Symbol.dispose] method")
  | .declNext kind rest env => declNext F s kind rest env
  | .ret => .pure (s.go (.abr (.ret v)))
  | .throw => .pure (s.go (.abr (.throw v)))
  | .try_ _ fin env => finOrResume F s fin env (.normal .undef)
  | .catch_ fin env => finOrResume F s fin env (.normal .undef)
  | .finally_ c => .pure (resume s c)
  | .label _ => retS F s .undef
  | .switchD cases env => switchNext F s v cases cases env
  | .switchCase d cs all env => match cs with
    | (_, _) :: r => .bind (strictEq F s d v) fun b => bif b then runCases F s cs env else switchNext F s d r all env
    | [] => .fail "switch"
  | .switchBody => retS F s .undef

def forOfStep (s : MS F) (src : IterSrc) (aw : Bool) (kind : Option DeclKind) (p : Pat) (body : Stmt) (env : Env) (labels : List Name) : RS F :=
  match src with
  | .index v i => .bind (elemAt F s v i) fun
    | some x => forOfBind s (.index v (i + 1)) x
    | none => retS F s .undef
  | .proto it next =>
    let s := s.push (.lp (.forOfNext it next aw kind p body env labels))
    .pure ((bif aw then s.push (.k .await) else s).go (.call next it []))
where
  forOfBind (s : MS F) (src : IterSrc) (x : Val) : RS F :=
    match kind with
    | some .using => .fail "for-of with using"
    | some k => let (env', s) := allocCells s (patNames p) env
      .pure (((s.push (.lp (.forOfBody src aw kind p body env labels))).push (.s (.block [body] env'))).go (.bind p x env' .init k))
    | none => .pure (((s.push (.lp (.forOfBody src aw kind p body env labels))).push (.s (.block [body] env))).go (.bind p x env .assign .let_))

/-- `IteratorClose` (`AsyncIteratorClose` when `aw`: `return()`'s result is awaited). -/
def closeIter (s : MS F) (src : IterSrc) (aw : Bool) (c : Comp) : RS F :=
  match src with
  | .proto it _ => .bind (dataOf F s it kReturn) fun
    | some m@(.obj _) => let s := s.push (.lp (.close c)); .pure ((bif aw then s.push (.k .await) else s).go (.call m it []))
    | _ => .pure (resume s c)
  | .index _ _ => .pure (resume s c)

def forTestStep (s : MS F) (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) : RS F :=
  match test with
  | some t => .pure ((s.push (.lp (.forBody test update body env names labels))).go (.ev t env))
  | none => .pure ((s.push (.lp (.forUpd test update body env names labels))).go (.ex body env))

def retLp (s : MS F) (f : LoopF) (v : Val) : RS F :=
  match f with
  | .forTest copy test update body env names labels =>
    let (env, s) := bif copy then nextIter F s names env else (env, s)
    forTestStep F s test update body env names labels
  | .forBody test update body env names labels => .bind (truthy v) fun b =>
    bif b then .pure ((s.push (.lp (.forUpd test update body env names labels))).go (.ex body env)) else retS F s .undef
  | .forUpd test update body env names labels =>
    let (env, s) := nextIter F s names env
    match update with
    | some u => .pure ((s.push (.lp (.forTest false test update body env names labels))).go (.ev u env))
    | none => forTestStep F s test update body env names labels
  | .whileTest c body env labels => .bind (truthy v) fun b =>
    bif b then .pure ((s.push (.lp (.whileBody c body env labels))).go (.ex body env)) else retS F s .undef
  | .whileBody c body env labels => .pure ((s.push (.lp (.whileTest c body env labels))).go (.ev c env))
  | .doBody body c env labels => .pure ((s.push (.lp (.whileTest c body env labels))).go (.ev c env))
  | .forOfSrc aw kind p body env labels =>
    bif aw then (match v with
      | .obj _ => getV F ((s.push (.lp (.forOfIt aw kind p body env labels))).push (.c (.method v [] [] false))) v
          (.sym symAsyncIterator)
      | _ => typeErr s (chars!"for await over a non-object")) else
    bif isIndexable F s v then forOfStep F s (.index v 0) aw kind p body env labels
    else match v with
      | .obj _ => startIter F (s.push (.lp (.forOfIt aw kind p body env labels))) v
      | _ => typeErr s (chars!"for-of over a non-iterable")
  | .forOfIt aw kind p body env labels => .bind (dataOf F s v kNext) fun
    | some next => forOfStep F s (.proto v next) aw kind p body env labels
    | none => .fail "iterator next accessor"
  | .forOfNext it next aw kind p body env labels => .bind (dataOf F s v kDone) fun d => .bind (truthy (d.getD .undef)) fun done =>
    bif done then retS F s .undef else .bind (dataOf F s v kValue) fun
      | some x => forOfStep.forOfBind F aw kind p body env labels s (.proto it next) x
      | none => .fail "iterator value accessor"
  | .forOfBody src aw kind p body env labels => forOfStep F s src aw kind p body env labels
  | .close c => .pure (resume s c)

def arrNext (s : MS F) (ps : List (Option Pat)) (rest : Option Pat) (vs : List Val) (env : Env) (mode : BindMode) (kind : DeclKind) : RS F :=
  match ps with
  | [] => match rest with
    | none => retS F s .undef
    | some r => let (a, s) := newArray s vs; .pure (s.go (.bind r (.obj a) env mode kind))
  | none :: ps => arrNext s ps rest vs.tail env mode kind
  | some p :: ps => .pure ((s.push (.b (.arr ps rest vs.tail env mode kind))).go (.bind p (nthD .undef vs 0) env mode kind))

def restObj (s : MS F) (src : Val) (used : List PKey) : M (Option (Nat × MS F)) :=
  match src with
  | .obj a => match s.obj? a with
    | some o => .bind (dataProps F s o) fun
      | some kvs =>
        let (r, s) := s.allocObj .ordinary (.obj aObjectProto) []
        let s := (kvs.filter fun (k, _) => !(used.any (keyEq k))).foldl (fun s (k, v) => defineData F s r k v) s
        .pure (some (r, s))
      | none => .pure none
    | none => .pure none
  | _ => .pure none

def objPatNext (s : MS F) (src : Val) (ps : List (Key × Pat)) (rest : Option Pat) (used : List PKey) (env : Env) (mode : BindMode) (kind : DeclKind) : RS F :=
  match ps with
  | [] => match rest with
    | none => retS F s .undef
    | some r => .bind (restObj F s src used) fun
      | some (o, s) => .pure (s.go (.bind r (.obj o) env mode kind))
      | none => .fail "object rest pattern"
  | (k, p) :: ps => match keyOf k with
    | some key => getV F (s.push (.b (.objVal src key p ps rest (key :: used) env mode kind))) src key
    | none => match k with
      | .computed e => .pure ((s.push (.b (.objKey src p ps rest used env mode kind))).go (.ev e env))
      | _ => .fail "pattern key"

def bindStep (s : MS F) (p : Pat) (v : Val) (env : Env) (mode : BindMode) (kind : DeclKind) : RS F :=
  match p with
  | .id n => match mode with
    | .init => match lookupEnv n env with
      | some c => retS F (s.setCell c v) .undef
      | none => .fail "binding without a cell"
    | .assign => writeVar F s n env v
  | .dflt q d => match v with
    | .undef => .pure ((s.push (.b (.dflt q env mode kind))).go (.ev d env))
    | v => .pure (s.go (.bind q v env mode kind))
  | .array ps rest => .bind (elemsOf F s v) fun
    | some vs => arrNext F s ps rest vs env mode kind
    | none => match v with
      | .obj _ => startIter F ((s.push (.b (.arrSrc ps rest env mode kind))).push (.b (.collectIt []))) v
      | _ => typeErr s (chars!"array pattern over a non-iterable")
  | .object ps rest => bif isNullish v then typeErr s (chars!"cannot destructure nullish") else
    objPatNext F s v ps rest [] env mode kind
  | .expr _ => .fail "member target in a destructuring assignment"

def retB (s : MS F) (f : BindF) (v : Val) : RS F :=
  match f with
  | .dflt p env mode kind => .pure (s.go (.bind p v env mode kind))
  | .arr ps rest vs env mode kind => arrNext F s ps rest vs env mode kind
  | .arrSrc ps rest env mode kind => .bind (elemsOf F s v) fun
    | some vs => arrNext F s ps rest vs env mode kind
    | none => .fail "collected iterator"
  | .obj src ps rest used env mode kind => objPatNext F s src ps rest used env mode kind
  | .objKey src p ps rest used env mode kind => .bind (toKey v) fun
    | some key => getV F (s.push (.b (.objVal src key p ps rest (key :: used) env mode kind))) src key
    | none => .fail "pattern key of an object"
  | .objVal src _ p ps rest used env mode kind =>
    .pure ((s.push (.b (.obj src ps rest used env mode kind))).go (.bind p v env mode kind))
  | .collect acc it next => .bind (dataOf F s v kDone) fun d => .bind (truthy (d.getD .undef)) fun done =>
    bif done then let (a, s) := newArray s acc.reverse; retS F s (.obj a)
    else .bind (dataOf F s v kValue) fun
      | some x => .pure ((s.push (.b (.collect (x :: acc) it next))).go (.call next it []))
      | none => .fail "iterator value accessor"
  | .collectIt acc => .bind (dataOf F s v kNext) fun
    | some next => .pure ((s.push (.b (.collect acc v next))).go (.call next v []))
    | none => .fail "iterator next accessor"

def retK (s : MS F) (f : FnF) (v : Val) : RS F :=
  match f with
  | .fn b => boundaryRet F s b
  | .params fn ps args env => paramsNext F s fn ps args env
  | .paramDflt fn p ps args env => .pure ((s.push (.k (.params fn ps args env))).go (.bind p v env .init .let_))
  | .classHeritage c env => defineClass F s c (some v) env
  | .classMembers f p ms inst env => classNext F s f p ms inst env
  | .classKey f p m ms inst env => .bind (toKey v) fun
    | some key => classKeyed F s f p m key ms inst env
    | none => .fail "class key of an object"
  | .classStatic f p k ms inst env => classNext F (defineData F s f k v) f p ms inst env
  | .fields o ms env => fieldsNext F s o ms env
  | .fieldVal o k ms env => fieldsNext F (defineData F s o k v) o ms env
  | .privVal o b n ms env => match s.obj? o with
    | some ob => fieldsNext F (s.setObj o { ob with priv := setPrivL b n (.data v true false) ob.priv }) o ms env
    | none => .fail "dangling"
  | .ctorBody o fn env args => enterClosure F s fn env false .undef o args (.ctor o)
  | .superRet tc cls env => match s.cell? tc with
    | some (some _) => refErr s (chars!"super constructor called twice")
    | _ =>
      let s := s.setCell tc v
      match v, s.obj? cls with
      | .obj o, some ⟨.fn (.klass ctor cenv _ inst), _, _, _, _⟩ =>
        let (fenv, s) := thisEnv F s v cenv
        let props := (ctor.map fnProps).getD []
        .pure ((((s.push (.e (.const v))).push (.k (.paramProps v props env))).push (.k (.fields o inst fenv))).ret .undef)
      | _, _ => .fail "super constructor result"
  | .paramProps o ns env => match ns with
    | [] => retS F s .undef
    | n :: r => match cellVal? F s n env with
      | some x => putV F (s.push (.k (.paramProps o r env))) o (.str n) x
      | none => .fail "parameter property"
  | .native n data => nativeRet F s n data v
  | .promiseThen p => retS F (resolveP s p v) .undef
  | .yield d => bif d then
      bif (match nearestGen s.stack with | some (g, _) => (genOf s g).elim false Prod.snd | none => false) then
        (match v with
          | .obj _ => getV F ((s.push (.k .ystarAIt)).push (.c (.method v [] [] false))) v (.sym symAsyncIterator)
          | _ => typeErr s (chars!"yield* over a non-object")) else
      bif isIndexable F s v then
        let (it, s) := s.allocObj (.iter v 0 0) (.obj aArrayIterProto) []
        .pure ((s.push (.k .ystarIt)).ret (.obj it))
      else startIter F (s.push (.k .ystarIt)) v
    else match nearestGen s.stack with
      | some (g, _) => match genOf s g with
        -- async generators await the operand; `ystarIt` then performs the yield
        | some (_, true) => awaitVal F (s.push (.k .ystarIt)) v
        | _ => yieldVal F s v
      | none => .fail "yield outside a generator"
  | .ystarIt => match nearestGen s.stack with
    | some (g, _) => match genOf s g with
      | some (_, true) => agenYield F s v
      | _ => .bind (dataOf F s v kNext) fun
        | some next => .pure ((s.push (.k (.ystarNext v next))).go (.call next v [.undef]))
        | none => .fail "iterator next accessor"
    | none => .fail "yield outside a generator"
  | .ystarNext it next => .bind (dataOf F s v kDone) fun d => .bind (truthy (d.getD .undef)) fun done =>
    bif done then .bind (dataOf F s v kValue) fun
      | some x => retS F s x
      | none => .fail "iterator value accessor"
    else yieldResult F (s.push (.k (.ystarResume it next))) v
  | .ystarResume it next => .pure ((s.push (.k (.ystarNext it next))).go (.call next it [v]))
  -- async `yield*` (ECMA-262 YieldExpression : yield * AssignmentExpression, async case):
  -- inner results are awaited, their values yielded without a further await
  | .ystarAIt => .bind (dataOf F s v kNext) fun
    | some next => .pure (((s.push (.k (.ystarAResult v next))).push (.k .await)).go (.call next v [.undef]))
    | none => .fail "iterator next accessor"
  | .ystarAResult it next => .bind (dataOf F s v kDone) fun d => .bind (truthy (d.getD .undef)) fun done =>
    .bind (dataOf F s v kValue) fun
      | some x => bif done then retS F s x else agenYield F (s.push (.k (.ystarAResume it next))) x
      | none => .fail "iterator value accessor"
  | .ystarAResume it next => .pure (((s.push (.k (.ystarAResult it next))).push (.k .await)).go (.call next it [v]))
  | .ystarAReturned it next => .bind (dataOf F s v kDone) fun d => .bind (truthy (d.getD .undef)) fun done =>
    .bind (dataOf F s v kValue) fun
      | some x => bif done then .pure (s.go (.abr (.ret x))) else agenYield F (s.push (.k (.ystarAResume it next))) x
      | none => .fail "iterator value accessor"
  | .ystarAReturn => .pure (s.go (.abr (.ret v)))
  | .await => awaitVal F s v
  | .modules rest => match rest with
    | [] => retS F s v
    | (ss, env) :: r => .pure (((s.push (.k (.modules r))).push (.s (.block ss env))).ret .undef)

def retStepImpl (s : MS F) (f : Frame) (v : Val) : RS F :=
  match f with
  | .e f => retE F s f v
  | .c f => retC F s f v
  | .l f => retL F s f v
  | .a f => retA F s f v
  | .s f => retSt F s f v
  | .lp f => retLp F s f v
  | .b f => retB F s f v
  | .k f => retK F s f v

/-- A frame receiving a value (kernel: `Frame.rec` with closed minors). -/
@[implemented_by retStepImpl]
def retStep (s : MS F) (f : Frame) (v : Val) : RS F :=
  Frame.rec (motive := fun _ => (G : Ffi) → St G.S → Val → RS G)
    (fun x G t w => retE G t x w) (fun x G t w => retC G t x w) (fun x G t w => retL G t x w)
    (fun x G t w => retA G t x w) (fun x G t w => retSt G t x w) (fun x G t w => retLp G t x w)
    (fun x G t w => retB G t x w) (fun x G t w => retK G t x w) f F s v

/-! ## Frames receiving an abrupt completion -/

def abrSt (s : MS F) (f : StmtF) (a : Abrupt) : RS F :=
  match f with
  | .scope res => match res with
    | [] => .pure (s.go (.abr a))
    | (x, m) :: r => .pure ((s.push (.s (.dispose r (.abrupt a)))).go (.call m x []))
  | .dispose rest c => match a with
    | .throw e => match c with
      | .abrupt (.throw e0) => .bind (mkError F s aSuppressedProto .undef .undef) fun
        | (.obj se, s) =>
          let s := defineProp F s se (.str (chars!"error")) (.data e true false)
          let s := defineProp F s se (.str (chars!"suppressed")) (.data e0 true false)
          retSt F s (.dispose rest (.abrupt (.throw (.obj se)))) .undef
        | _ => .fail "error"
      | _ => retSt F s (.dispose rest (.abrupt (.throw e))) .undef
    | a => .pure (s.go (.abr a))
  | .try_ handler fin env => match a, handler with
    | .throw e, some (param, body) => match param with
      | some p => let (env', s) := allocCells s (patNames p) env
        .pure ((((s.push (.s (.catch_ fin env))).push (.s (.block [.block body] env')))).go (.bind p e env' .init .let_))
      | none => .pure (enterBlock (s.push (.s (.catch_ fin env))) body env)
    | a, _ => finOrResume F s fin env (.abrupt a)
  | .catch_ fin env => finOrResume F s fin env (.abrupt a)
  | .label l => match a with
    | .brk (some m) => bif nameEq l m then retS F s .undef else .pure (s.go (.abr a))
    | a => .pure (s.go (.abr a))
  | .switchBody => match a with
    | .brk none => retS F s .undef
    | a => .pure (s.go (.abr a))
  | _ => .pure (s.go (.abr a))

def abrLp (s : MS F) (f : LoopF) (a : Abrupt) : RS F :=
  let loopAbr (cont : RS F) (labels : List Name) : RS F :=
    match a with
    | .cont l => bif matchLabel l labels then cont else .pure (s.go (.abr a))
    | .brk l => bif matchLabel l labels then retS F s .undef else .pure (s.go (.abr a))
    | a => .pure (s.go (.abr a))
  match f with
  | .forUpd test update body env names labels => loopAbr (retLp F s (.forUpd test update body env names labels) .undef) labels
  | .whileBody c body env labels => loopAbr (retLp F s (.whileBody c body env labels) .undef) labels
  | .doBody body c env labels => loopAbr (retLp F s (.doBody body c env labels) .undef) labels
  | .forOfBody src aw kind p body env labels => match a with
    | .cont l => bif matchLabel l labels then forOfStep F s src aw kind p body env labels else closeIter F s src aw (.abrupt a)
    | .brk l => bif matchLabel l labels then closeIter F s src aw (.normal .undef) else closeIter F s src aw (.abrupt a)
    | a => closeIter F s src aw (.abrupt a)
  | .close c => match c with
    | .abrupt (.throw e) => .pure (s.go (.abr (.throw e)))
    | _ => .pure (s.go (.abr a))
  | _ => .pure (s.go (.abr a))

def abrK (s : MS F) (f : FnF) (a : Abrupt) : RS F :=
  match f with
  | .fn b => boundaryAbr F s b a
  | .native n data => nativeAbr F s n data a
  | .promiseThen p => match a with
    | .throw e => retS F (settle s p true e) .undef
    | a => .pure (s.go (.abr a))
  | .modules _ => .pure (s.go (.halt (.abrupt a)))
  | .ystarResume it _ => match a with
    | .ret _ => .bind (dataOf F s it kReturn) fun
      | some m@(.obj _) => .pure ((s.push (.lp (.close (.abrupt a)))).go (.call m it []))
      | _ => .pure (s.go (.abr a))
    | a => .pure (s.go (.abr a))
  | .ystarAResume it next => match a with
    | .ret v => .bind (dataOf F s it kReturn) fun
      | some m@(.obj _) => .pure (((s.push (.k (.ystarAReturned it next))).push (.k .await)).go (.call m it [v]))
      | _ => awaitVal F (s.push (.k .ystarAReturn)) v
    | .throw e => .bind (dataOf F s it (.str chars!"throw")) fun
      | some m@(.obj _) => .pure (((s.push (.k (.ystarAResult it next))).push (.k .await)).go (.call m it [e]))
      | _ => .fail "async yield* throw into an iterator without throw"
    | a => .pure (s.go (.abr a))
  | _ => .pure (s.go (.abr a))

def abrStepImpl (s : MS F) (f : Frame) (a : Abrupt) : RS F :=
  match f with
  | .s f => abrSt F s f a
  | .lp f => abrLp F s f a
  | .k f => abrK F s f a
  | _ => .pure (s.go (.abr a))

@[implemented_by abrStepImpl]
def abrStep (s : MS F) (f : Frame) (a : Abrupt) : RS F :=
  Frame.rec (motive := fun _ => (G : Ffi) → St G.S → Abrupt → RS G)
    (fun _ G t b => .pure (t.go (.abr b))) (fun _ G t b => .pure (t.go (.abr b))) (fun _ G t b => .pure (t.go (.abr b)))
    (fun _ G t b => .pure (t.go (.abr b))) (fun x G t b => abrSt G t x b) (fun x G t b => abrLp G t x b)
    (fun _ G t b => .pure (t.go (.abr b))) (fun x G t b => abrK G t x b) f F s a

/-! ## Jobs and the step -/

def runJob (s : MS F) (j : Job) : RS F :=
  match j.r with
  | .resume su => .pure (({ s with stack := su.frames }.setStores su.stores).go (bif j.throw then .abr (.throw j.v) else .ret j.v))
  | .then_ onF onR d st =>
    let f := bif j.throw then onR else onF
    match f with
    | .obj _ => .pure (({ s with stack := [.k (.promiseThen d)] }.setStores st).go (.call f .undef [j.v]))
    | _ => retS F (bif j.throw then settle s d true j.v else resolveP s d j.v) .undef
  | .adopt p => match isPromise s j.v with
    | some q => retS F (react s q (.forward p)) .undef
    | none => retS F (settle s p false j.v) .undef
  | .forward p => retS F (bif j.throw then settle s p true j.v else resolveP s p j.v) .undef

def shortStep (s : MS F) : RS F :=
  match s.stack with
  | .e .chain :: fs => retS F { s with stack := fs } .undef
  | _ :: fs => .pure ({ s with stack := fs }.go .short)
  | [] => .fail "optional chain outside a chain"

def stepJobs (s : MS F) (v : Val) : RS F :=
  match s.jobs with
  | j :: js => runJob F (s.setJobs js) j
  | [] => .pure (s.go (.halt (.normal v)))

def stepRetImpl (s : MS F) (v : Val) : RS F :=
  match s.stack with
  | f :: fs => retStep F { s with stack := fs } f v
  | [] => stepJobs F s v

/-- A value returns to the top frame, else to the job queue. -/
@[implemented_by stepRetImpl]
def stepRet (s : MS F) (v : Val) : RS F :=
  List.rec (motive := fun _ => (G : Ffi) → St G.S → Val → RS G) (fun G t w => stepJobs G t w)
    (fun f fs _ G t w => retStep G { t with stack := fs } f w) s.stack F s v

def stepAbrImpl (s : MS F) (a : Abrupt) : RS F :=
  match s.stack with
  | f :: fs => abrStep F { s with stack := fs } f a
  | [] => .pure (s.go (.halt (.abrupt a)))

@[implemented_by stepAbrImpl]
def stepAbr (s : MS F) (a : Abrupt) : RS F :=
  List.rec (motive := fun _ => (G : Ffi) → St G.S → Abrupt → RS G) (fun _ t b => .pure (t.go (.halt (.abrupt b))))
    (fun f fs _ G t b => abrStep G { t with stack := fs } f b) s.stack F s a

def stepImpl (s : MS F) : RS F :=
  match s.ctl with
  | .ev e env => evStep F s e env
  | .ex st env => exStep F s st env
  | .ret v => stepRet F s v
  | .abr a => stepAbr F s a
  | .call f t as => callStep F s f t as
  | .construct f as nt => constructStep F s f as nt
  | .bind p v env m k => bindStep F s p v env m k
  | .short => shortStep F s
  | .halt _ => .pure s

/-- One transition (kernel: `Ctl.rec` with closed minors). -/
@[implemented_by stepImpl]
def step (s : MS F) : RS F :=
  Ctl.rec (motive := fun _ => (G : Ffi) → St G.S → RS G)
    (fun e env G t => evStep G t e env) (fun x env G t => exStep G t x env) (fun v G t => stepRet G t v)
    (fun a G t => stepAbr G t a) (fun f th as G t => callStep G t f th as) (fun f as nt G t => constructStep G t f as nt)
    (fun p v env m k G t => bindStep G t p v env m k) (fun G t => shortStep G t) (fun _ _ t => .pure t) s.ctl F s

end
end Host.Ts
