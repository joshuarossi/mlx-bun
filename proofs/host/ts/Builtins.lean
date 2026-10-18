import host.ts.Props
import host.ts.StringIndex
namespace Host.Ts

/-! # Builtins

Leaf builtins in Lean; builtins that call back into JavaScript
(`Array.prototype.map`, `forEach`, ...) are JavaScript in `Prelude`.
Builtins that run JavaScript (`call`, `apply`, getters through
`Reflect.get`, generator resumption, promise jobs) set the control state
instead of returning a value.

Modelling decisions recorded here:
* `FinalizationRegistry` never calls its callback: `register`/`unregister`
  are no-ops. For MLX handles this is sound under MLX reference counting:
  the backstop only frees handles the program leaked, and a free the model
  omits cannot change which FFI calls the program issues before it.
* `performance.now()` returns `0` (profiling only).
* `console.*` output is not modelled.
* `JSCallback` pointers are opaque; callbacks are never invoked (MLX
  errors are not modelled: the FFI model returns statuses).
* Holes are not modelled: `Array(n)` is `n` undefined elements. -/

def arg (args : List Val) (i : Nat) : Val := nthD .undef args i

section
variable (F : Ffi)

abbrev RS := Mr F.S

def retS (s : St F.S) (v : Val) : RS F := .pure (s.ret v)

/-! ## Element lists of arrays, typed arrays and strings -/

def typedElems (s : St F.S) (k : EltK) (b off : Nat) : Nat → Nat → M (List Val)
  | 0, _ => .pure []
  | n + 1, i => .bind (typedGet F s k b off (i + n + 1) i) fun
    | some (.data v _ _) => .bind (typedElems s k b off n (i + 1)) fun vs => .pure (v :: vs)
    | _ => .fail "typed array element"

def elemsOf (s : St F.S) : Val → M (Option (List Val))
  | .obj a => match s.obj? a with
    | some ⟨.array es, _, _, _, _⟩ => .pure (some es)
    | some ⟨.typed k b off n, _, _, _, _⟩ => .bind (typedElems F s k b off n 0) fun vs => .pure (some vs)
    | _ => .pure none
  | .str cs => .pure (some (cs.map fun c => .str [c]))
  | _ => .pure none

def strictEq (s : St F.S) : Val → Val → M Bool
  | .num x, .num y => numTest .eq x y
  | .str a, .str b => .pure (nameEq a b)
  | .bool a, .bool b => .pure (a == b)
  | .undef, .undef => .pure true
  | .null, .null => .pure true
  | .big a, .big b => .pure (decide (a = b))
  | .sym a, .sym b => .pure (Nat.beq a b)
  | .obj a, .obj b => .pure (Nat.beq a b)
  | .ptr (.js a) o, .ptr (.js b) p => .pure (Nat.beq a b && Nat.beq o p)
  | .ptr (.ext a) o, .ptr (.ext b) p => .pure (Nat.beq a b && Nat.beq o p)
  | _, _ => let _ := s; .pure false

def indexOfL (s : St F.S) (v : Val) : List Val → Nat → M (Option Nat)
  | [], _ => .pure none
  | x :: xs, i => .bind (strictEq F s x v) fun b => bif b then .pure (some i) else indexOfL s v xs (i + 1)

/-- Relative index (`slice`, `at`): negative counts from the end. -/
def relIdx (n : Nat) (v : Val) (dflt : Nat) : M Nat :=
  match v with
  | .undef => .pure dflt
  | .num (.lit x) => match F64.truncInt x with
    | some (.ofNat i) => .pure (bif Nat.ble i n then i else n)
    | some (.negSucc i) => .pure (n - (i + 1))
    | none => .pure (bif F64.lt x (F64.zero false) then 0 else bif F64.isNaN x then 0 else n)
  | _ => .fail "relative index from a non-literal"

def joinStr (s : St F.S) (sep : List Char) : List Val → Bool → M (List Char)
  | [], _ => .pure []
  | v :: vs, first =>
    let piece : M (List Char) := match v with
      | .undef | .null => .pure []
      | v => .bind (primStr v) fun | some cs => .pure cs | none => .fail "join of an object element"
    .bind piece fun p => .bind (joinStr s sep vs false) fun r => .pure ((bif first then [] else sep) ++ p ++ r)

/-! ## Objects -/

def setArray (s : St F.S) (a : Nat) (es : List Val) : St F.S :=
  match s.obj? a with
  | some o => s.setObj a { o with kind := .array es }
  | none => s

def arrayOf (s : St F.S) (a : Nat) : Option (Obj × List Val) :=
  match s.obj? a with
  | some o => match o.kind with
    | .array es => some (o, es)
    | _ => none
  | none => none

def keyVal : PKey → Val
  | .str cs => .str cs
  | .sym i => .sym i

def freezeProps : Props → Props
  | [] => []
  | (k, .data v _ e) :: ps => (k, .data v false e) :: freezeProps ps
  | p :: ps => p :: freezeProps ps

def dataProps (s : St F.S) (o : Obj) : M (Option (List (PKey × Val))) :=
  let ks := ownKeys F s o
  let rec go : List PKey → M (Option (List (PKey × Val)))
    | [] => .pure (some [])
    | k :: ks => .bind (ownGet F s o k) fun
      | some (.data v _ _) => .bind (go ks) fun r => .pure (r.map ((k, v) :: ·))
      | _ => .pure none
  go ks

def objN (s : St F.S) (this : Val) (args : List Val) : ObjN → RS F
  | .keys => match arg args 0 with
    | .obj a => match s.obj? a with
      | some o => let (r, s) := newArray s ((ownKeys F s o).map keyVal); retS F s (.obj r)
      | none => .fail "dangling"
    | _ => typeErr s (chars!"Object.keys of a primitive")
  | .entries => match arg args 0 with
    | .obj a => match s.obj? a with
      | some o => .bind (dataProps F s o) fun
        | some kvs =>
          let rec mk (s : St F.S) : List (PKey × Val) → List Val × St F.S
            | [] => ([], s)
            | (k, v) :: r => let (p, s) := newArray s [keyVal k, v]; let (ps, s) := mk s r; (.obj p :: ps, s)
          let (ps, s) := mk s kvs
          let (r, s) := newArray s ps
          retS F s (.obj r)
        | none => .fail "Object.entries over accessors"
      | none => .fail "dangling"
    | _ => typeErr s (chars!"Object.entries of a primitive")
  | .values => match arg args 0 with
    | .obj a => match s.obj? a with
      | some o => .bind (dataProps F s o) fun
        | some kvs => let (r, s) := newArray s (kvs.map Prod.snd); retS F s (.obj r)
        | none => .fail "Object.values over accessors"
      | none => .fail "dangling"
    | _ => typeErr s (chars!"Object.values of a primitive")
  | .freeze => match arg args 0 with
    | .obj a => match s.obj? a with
      | some o => match o.kind with
        | .typed _ _ _ n => bif Nat.beq n 0 then retS F (s.setObj a { o with extensible := false }) (.obj a)
            else typeErr s (chars!"cannot freeze a typed array with elements")
        | _ => retS F (s.setObj a { o with extensible := false, props := freezeProps o.props }) (.obj a)
      | none => .fail "dangling"
    | v => retS F s v
  | .isFrozen => match arg args 0 with
    | .obj a => match s.obj? a with
      | some o => retS F s (.bool (!o.extensible))
      | none => .fail "dangling"
    | _ => retS F s (.bool true)
  | .hasOwn => hasOwn s (arg args 0) (arg args 1)
  | .protoHasOwn => hasOwn s this (arg args 0)
  | .getPrototypeOf => match arg args 0 with
    | .obj a => match s.obj? a with
      | some o => retS F s o.proto
      | none => .fail "dangling"
    | v => match protoOf F s v with
      | some p => retS F s (.obj p)
      | none => typeErr s (chars!"getPrototypeOf of nullish")
  | .fromEntries => .bind (elemsOf F s (arg args 0)) fun
    | some es =>
      let (o, s) := s.allocObj .ordinary (.obj aObjectProto) []
      let rec go (s : St F.S) : List Val → M (St F.S)
        | [] => .pure s
        | e :: es => match e with
          | .obj p => match arrayOf F s p with
            | some (_, k :: v :: _) => .bind (toKey k) fun
              | some key => go (defineData F s o key v) es
              | none => .fail "fromEntries key"
            | _ => .fail "fromEntries entry"
          | _ => .fail "fromEntries entry"
      .bind (go s es) fun s => retS F s (.obj o)
    | none => .fail "fromEntries of a non-array"
  | .assign => match arg args 0 with
    | .obj t =>
      let rec goA (s : St F.S) : List Val → M (St F.S)
        | [] => .pure s
        | .obj a :: r => match s.obj? a with
          | some o => .bind (dataProps F s o) fun
            | some kvs => goA (kvs.foldl (fun s (k, v) => defineData F s t k v) s) r
            | none => .fail "Object.assign over accessors"
          | none => .fail "dangling"
        | _ :: r => goA s r
      .bind (goA s args.tail) fun s => retS F s (.obj t)
    | _ => .fail "Object.assign target"
  | .protoToString => match this with
    | .obj a => match s.obj? a with
      | some ⟨.array _, _, _, _, _⟩ => retS F s (.str (chars!"[object Array]"))
      | _ => retS F s (.str (chars!"[object Object]"))
    | .undef => retS F s (.str (chars!"[object Undefined]"))
    | .null => retS F s (.str (chars!"[object Null]"))
    | _ => .fail "Object.prototype.toString of a primitive"
where
  hasOwn (s : St F.S) (o k : Val) : RS F :=
    match o with
    | .obj a => match s.obj? a with
      | some ob => .bind (toKey k) fun
        | some key => .bind (ownGet F s ob key) fun p => retS F s (.bool p.isSome)
        | none => .fail "hasOwn key"
      | none => .fail "dangling"
    | _ => .fail "hasOwn on a primitive"

/-! ## Arrays -/

def arrN (s : St F.S) (this : Val) (args : List Val) : ArrN → RS F
  | .isArray => match arg args 0 with
    | .obj a => retS F s (.bool (arrayOf F s a).isSome)
    | _ => retS F s (.bool false)
  | .ctor => match args with
    | [.num (.lit x)] => match F64.toIndex? x with
      | some n => let (r, s) := newArray s (List.replicate n .undef); retS F s (.obj r)
      | none => rangeErr s (chars!"invalid array length")
    | vs => let (r, s) := newArray s vs; retS F s (.obj r)
  | .push => withArr fun a _ es =>
      let es := es ++ args
      retS F (setArray F s a es) (natV (len es))
  | .pop => withArr fun a _ es => match es.reverse with
      | [] => retS F s .undef
      | v :: r => retS F (setArray F s a r.reverse) v
  | .shift => withArr fun a _ es => match es with
      | [] => retS F s .undef
      | v :: r => retS F (setArray F s a r) v
  | .unshift => withArr fun a _ es => let es := args ++ es; retS F (setArray F s a es) (natV (len es))
  | .slice => .bind (elemsOf F s this) fun
      | some es => let n := len es
        .bind (relIdx n (arg args 0) 0) fun i => .bind (relIdx n (arg args 1) n) fun j =>
        let (r, s) := newArray s ((es.drop i).take (j - i)); retS F s (.obj r)
      | none => .fail "slice of a non-array"
  | .at => .bind (elemsOf F s this) fun
      | some es => match arg args 0 with
        | .num (.lit x) => match F64.truncInt x with
          | some (.ofNat i) => retS F s (nthD .undef es i)
          | some (.negSucc i) => let n := len es; bif Nat.ble (i + 1) n then retS F s (nthD .undef es (n - (i + 1))) else retS F s .undef
          | none => retS F s (nthD .undef es 0)
        | .undef => retS F s (nthD .undef es 0)
        | _ => .fail "at with a non-literal index"
      | none => .fail "at of a non-array"
  | .includes => .bind (elemsOf F s this) fun
      | some es => .bind (indexOfL F s (arg args 0) es 0) fun r => retS F s (.bool r.isSome)
      | none => .fail "includes of a non-array"
  | .indexOf => .bind (elemsOf F s this) fun
      | some es => .bind (indexOfL F s (arg args 0) es 0) fun
        | some i => retS F s (natV i)
        | none => retS F s (intV (-1))
      | none => .fail "indexOf of a non-array"
  | .lastIndexOf => .bind (elemsOf F s this) fun
      | some es => .bind (indexOfL F s (arg args 0) es.reverse 0) fun
        | some i => retS F s (natV (len es - 1 - i))
        | none => retS F s (intV (-1))
      | none => .fail "lastIndexOf of a non-array"
  | .join => .bind (elemsOf F s this) fun
      | some es =>
        let sep : M (List Char) := match arg args 0 with
          | .undef => .pure [',']
          | v => .bind (primStr v) fun | some cs => .pure cs | none => .fail "join separator"
        .bind sep fun sep => .bind (joinStr F s sep es true) fun r => retS F s (.str r)
      | none => .fail "join of a non-array"
  | .fill => withArr fun a _ es => let n := len es
      .bind (relIdx n (arg args 1) 0) fun i => .bind (relIdx n (arg args 2) n) fun j =>
      let v := arg args 0
      let es := (List.range n).map fun k => bif Nat.ble i k && Nat.blt k j then v else nthD .undef es k
      retS F (setArray F s a es) this
  | .concat => .bind (elemsOf F s this) fun
      | some es =>
        let rec go : List Val → M (List Val)
          | [] => .pure []
          | v :: vs => .bind (go vs) fun r => match v with
            | .obj b => match arrayOf F s b with
              | some (_, xs) => .pure (xs ++ r)
              | none => .pure (v :: r)
            | _ => .pure (v :: r)
        .bind (go args) fun more => let (r, s) := newArray s (es ++ more); retS F s (.obj r)
      | none => .fail "concat of a non-array"
  | .splice => withArr fun a _ es => let n := len es
      .bind (relIdx n (arg args 0) 0) fun i =>
      let del : M Nat := match args with
        | [_] => .pure (n - i)
        | _ => match arg args 1 with
          | .num (.lit x) => .pure (match F64.truncInt x with | some (.ofNat d) => d | _ => 0)
          | .undef => .pure 0
          | _ => .fail "splice count"
      .bind del fun d =>
      let removed := (es.drop i).take d
      let es := es.take i ++ args.drop 2 ++ es.drop (i + d)
      let (r, s) := newArray (setArray F s a es) removed
      retS F s (.obj r)
  | .reverse => withArr fun a _ es => retS F (setArray F s a es.reverse) this
where
  withArr (k : Nat → Obj → List Val → RS F) : RS F :=
    match this with
    | .obj a => match arrayOf F s a with
      | some (o, es) => bif o.extensible then k a o es else typeErr s (chars!"cannot modify a frozen array")
      | none => .fail "array method on a non-array"
    | _ => .fail "array method on a primitive"

/-! ## Iterators -/

def iterN (s : St F.S) (this : Val) : IterN → RS F
  | .values => mk 0
  | .keys => mk 1
  | .entries => mk 2
  | .self => retS F s this
  | .next => match this with
    | .obj a => match s.obj? a with
      | some o => match o.kind with
        | .iter src i mode => .bind (elemsOf F s src) fun
          | some es => match nth? es i with
            | some v =>
              let s := s.setObj a { o with kind := .iter src (i + 1) mode }
              let mkv : Val × St F.S := match mode with
                | 0 => (v, s)
                | 1 => (natV i, s)
                | _ => let (p, s) := newArray s [natV i, v]; (.obj p, s)
              let (r, s) := iterResult mkv.2 mkv.1 false
              retS F s (.obj r)
            | none => let (r, s) := iterResult s .undef true; retS F s (.obj r)
          | none => .fail "iterator source"
        | _ => typeErr s (chars!"next on a non-iterator")
      | none => .fail "dangling"
    | _ => typeErr s (chars!"next on a non-iterator")
where
  mk (mode : Nat) : RS F :=
    let (r, s) := s.allocObj (.iter this 0 mode) (.obj aArrayIterProto) []
    retS F s (.obj r)

/-! ## Math and numbers -/

def toNum (v : Val) : M (Option NumV) :=
  match v with
  | .num x => .pure (some x)
  | .bool b => .pure (some (bif b then one else zeroN))
  | .undef => .pure (some (.lit .nan))
  | .null => .pure (some zeroN)
  | .str cs => .pure (some (.lit (F64.ofString cs)))
  | _ => .pure none

def F64.roundHalfUp (x : F64) : F64 :=
  match x with
  | .fin s m e => match e with
    | .ofNat _ => x
    | .negSucc _ =>
      let f := F64.floor x
      let d := F64.sub x f
      let r := bif F64.lt d F64.half then f else F64.add f (F64.fin false 1 0)
      bif s && F64.isZero r then .zero true else r
  | _ => x

def mathN (s : St F.S) (args : List Val) : MathN → RS F
  | .floor => un .floor
  | .ceil => un .ceil
  | .trunc => un .trunc
  | .fround => un .f32
  | .round => lit fun x => F64.roundHalfUp x
  | .sign => lit fun x => match x with
    | .fin true _ _ => F64.ofInt (-1) | .fin false _ _ => F64.ofNat 1 | x => x
  | .abs => .bind (toNum (arg args 0)) fun
    | some x => .bind (numBin .max x (.lit (F64.zero false))) fun _ =>
      match x with
      | .lit (.fin _ m e) => retS F s (.num (.lit (.fin false m e)))
      | .lit (.zero _) => retS F s (.num (.lit (.zero false)))
      | .lit (.inf _) => retS F s (.num (.lit (.inf false)))
      | .lit .nan => retS F s (.num (.lit .nan))
      | x => .bind (numUn .neg x) fun y => .bind (numBin .max x y) fun r => retS F s (.num r)
    | none => .fail "Math.abs of a non-number"
  | .min => fold .min (.lit (.inf false)) args
  | .max => fold .max (.lit (.inf true)) args
  | .pow => .bind (toNum (arg args 0)) fun x => .bind (toNum (arg args 1)) fun y =>
    match x, y with
    | some (.lit a), some (.lit b) => match F64.pow a b with
      | some r => retS F s (.num (.lit r))
      | none => .fail "Math.pow with an inexact result"
    | _, _ => .fail "Math.pow of a symbolic number"
  | .sqrt => lit? fun x => some (F64.sqrt x)
where
  un (op : NUn) : RS F := .bind (toNum (arg args 0)) fun
    | some x => .bind (numUn op x) fun r => retS F s (.num r)
    | none => .fail "Math of a non-number"
  lit (f : F64 → F64) : RS F := .bind (toNum (arg args 0)) fun
    | some (.lit x) => retS F s (.num (.lit (f x)))
    | _ => .fail "Math of a symbolic number"
  lit? (f : F64 → Option F64) : RS F := .bind (toNum (arg args 0)) fun
    | some (.lit x) => match f x with
      | some r => retS F s (.num (.lit r))
      | none => .fail "Math.sqrt with an inexact result"
    | _ => .fail "Math of a symbolic number"
  fold (op : NBin) (acc : NumV) : List Val → RS F
    | [] => retS F s (.num acc)
    | v :: vs => .bind (toNum v) fun
      | some x => .bind (numBin op acc x) fun r => fold op r vs
      | none => .fail "Math.min/max of a non-number"

def isSafeInt (x : F64) : Bool :=
  match F64.toInt? x with
  | some i => Nat.ble i.natAbs (2 ^ 53 - 1)
  | none => false

def parseBig (cs : List Char) : Option Int :=
  match F64.trimWs cs with
  | '-' :: r => (F64.parseIntLit r).map fun n => -(n : Int)
  | [] => some 0
  | r => (F64.parseIntLit r).map fun n => (n : Int)

def numN (s : St F.S) (this : Val) (args : List Val) : NumN → RS F
  | .number => match args with
    | [] => retS F s (.num zeroN)
    | v :: _ => match v with
      | .big i => retS F s (intV i)
      | .ptr _ _ => .fail "Number of a pointer"
      | v => .bind (toNum v) fun
        | some x => retS F s (.num x)
        | none => .fail "Number of an object"
  | .isSafeInteger => litTest isSafeInt
  | .isInteger => litTest fun x => (F64.toInt? x).isSome
  | .isFinite => litTest fun | .fin _ _ _ => true | .zero _ => true | _ => false
  | .isNaN => litTest F64.isNaN
  | .bigint => match arg args 0 with
    | .big i => retS F s (.big i)
    | .ptr m off => retS F s (.big (ptrInt m off))
    | .num (.lit x) => match F64.toInt? x with
      | some i => retS F s (.big i)
      | none => rangeErr s (chars!"not an integer")
    | .num _ => .fail "BigInt of a symbolic number"
    | .bool b => retS F s (.big (bif b then 1 else 0))
    | .str cs => match parseBig cs with
      | some i => retS F s (.big i)
      | none => throwErr s aErrorProto (chars!"SyntaxError: cannot convert to BigInt")
    | _ => typeErr s (chars!"cannot convert to BigInt")
  | .string => match args with
    | [] => retS F s (.str [])
    | .sym _ :: _ => retS F s (.str (chars!"Symbol()"))
    | v :: _ => .bind (primStr v) fun
      | some cs => retS F s (.str cs)
      | none => .fail "String of an object"
  | .boolean => .bind (truthy (arg args 0)) fun b => retS F s (.bool b)
  | .numToString => match arg args 0 with
    | .undef => str this
    | .num (.lit (.fin false 10 0)) => str this
    | _ => .fail "Number.prototype.toString radix"
  | .bigToString => str this
  | .symbol => let (a, s) := s.alloc (.cell none); retS F s (.sym (a + 16))
  | .parseInt => match arg args 0 with
    | .str cs => match F64.parseIntLit (F64.trimWs cs) with
      | some n => retS F s (natV n)
      | none => retS F s (.num (.lit .nan))
    | _ => .fail "parseInt of a non-string"
  | .parseFloat => match arg args 0 with
    | .str cs => retS F s (.num (.lit (F64.ofString cs)))
    | _ => .fail "parseFloat of a non-string"
where
  litTest (f : F64 → Bool) : RS F := match arg args 0 with
    | .num (.lit x) => retS F s (.bool (f x))
    | .num _ => .fail "number predicate of a symbolic number"
    | _ => retS F s (.bool false)
  str (v : Val) : RS F := .bind (primStr v) fun
    | some cs => retS F s (.str cs)
    | none => .fail "toString"

/-! ## Strings -/

def isPrefix : List Char → List Char → Bool
  | [], _ => true
  | _, [] => false
  | a :: as, b :: bs => chEq a b && isPrefix as bs

def findSub (p : List Char) : List Char → Nat → Option Nat
  | [], i => bif p.isEmpty then some i else none
  | c :: cs, i => bif isPrefix p (c :: cs) then some i else findSub p cs (i + 1)

def splitOn (sep : List Char) (cs : List Char) : Nat → List (List Char)
  | 0 => [cs]
  | f + 1 => match findSub sep cs 0 with
    | some i => cs.take i :: splitOn sep (cs.drop (i + len sep)) f
    | none => [cs]

def lowerC (c : Char) : Char := bif Nat.ble 65 c.toNat && Nat.ble c.toNat 90 then Char.ofNat (c.toNat + 32) else c
def upperC (c : Char) : Char := bif Nat.ble 97 c.toNat && Nat.ble c.toNat 122 then Char.ofNat (c.toNat - 32) else c

def strArg (v : Val) : M (List Char) :=
  .bind (primStr v) fun | some cs => .pure cs | none => .fail "string argument"

def thisStr (this : Val) : M (List Char) :=
  match this with
  | .str cs => .pure cs
  | _ => .fail "string method on a non-string"

def strN (s : St F.S) (this : Val) (args : List Val) : StrN → RS F
  | .slice => .bind (thisStr this) fun cs => let n := len cs
    .bind (relIdx n (arg args 0) 0) fun i => .bind (relIdx n (arg args 1) n) fun j => retS F s (.str ((cs.drop i).take (j - i)))
  | .substring => .bind (thisStr this) fun cs => let n := len cs
    .bind (relIdx n (arg args 0) 0) fun i => .bind (relIdx n (arg args 1) n) fun j =>
    let (a, b) := bif Nat.ble i j then (i, j) else (j, i)
    retS F s (.str ((cs.drop a).take (b - a)))
  | .startsWith => .bind (thisStr this) fun cs => .bind (strArg (arg args 0)) fun p => retS F s (.bool (isPrefix p cs))
  | .endsWith => .bind (thisStr this) fun cs => .bind (strArg (arg args 0)) fun p => retS F s (.bool (isPrefix p.reverse cs.reverse))
  | .includes => .bind (thisStr this) fun cs => .bind (strArg (arg args 0)) fun p => retS F s (.bool (findSub p cs 0).isSome)
  | .indexOf => .bind (thisStr this) fun cs => .bind (strArg (arg args 0)) fun p => match findSub p cs 0 with
    | some i => retS F s (natV i)
    | none => retS F s (intV (-1))
  | .split => .bind (thisStr this) fun cs => match arg args 0 with
    | .str [] => let (r, s) := newArray s (cs.map fun c => .str [c]); retS F s (.obj r)
    | .str sep => let (r, s) := newArray s ((splitOn sep cs (len cs + 1)).map Val.str); retS F s (.obj r)
    | .undef => let (r, s) := newArray s [.str cs]; retS F s (.obj r)
    | _ => .fail "split by a non-string"
  | .trim => .bind (thisStr this) fun cs => retS F s (.str (F64.trimWs cs))
  | .toLowerCase => .bind (thisStr this) fun cs => retS F s (.str (cs.map lowerC))
  | .toUpperCase => .bind (thisStr this) fun cs => retS F s (.str (cs.map upperC))
  | .replace => .bind (thisStr this) fun cs => match arg args 0, arg args 1 with
    | .str p, .str r => bif r.contains '$' then .fail "replace pattern with $" else
      match findSub p cs 0 with
      | some i => retS F s (.str (cs.take i ++ r ++ cs.drop (i + len p)))
      | none => retS F s (.str cs)
    | _, _ => .fail "replace with a regular expression or function"
  | .padStart => .bind (thisStr this) fun cs => match arg args 0 with
    | .num (.lit x) => match F64.toIndex? x with
      | some n => .bind (match arg args 1 with | .undef => .pure [' '] | v => strArg v) fun fill =>
        let k := n - len cs
        let pad := (List.replicate (k / len fill + 1) fill).flatten.take k
        retS F s (.str (pad ++ cs))
      | none => retS F s (.str cs)
    | _ => .fail "padStart length"
  | .charCodeAt => .bind (thisStr this) fun cs => match arg args 0 with
    | .num (.lit x) => match F64.toIndex? x with
      | some i => match nth? cs i with
        | some c => retS F s (natV c.toNat)
        | none => retS F s (.num (.lit .nan))
      | none => retS F s (.num (.lit .nan))
    | .undef => match cs with
      | c :: _ => retS F s (natV c.toNat)
      | [] => retS F s (.num (.lit .nan))
    | _ => .fail "charCodeAt index"
  | .at => .bind (thisStr this) fun cs => match arg args 0 with
    | .num (.lit x) => match F64.truncInt x with
      | some (.ofNat i) => retS F s ((nth? cs i).elim .undef fun c => .str [c])
      | some (.negSucc i) => let n := len cs
        bif Nat.ble (i + 1) n then retS F s ((nth? cs (n - (i + 1))).elim .undef fun c => .str [c]) else retS F s .undef
      | none => retS F s .undef
    | _ => .fail "at index"
  | .toString => .bind (thisStr this) fun cs => retS F s (.str cs)
  | .concat => .bind (thisStr this) fun cs =>
    let rec go : List Val → M (List Char)
      | [] => .pure []
      | v :: vs => .bind (strArg v) fun a => .bind (go vs) fun b => .pure (a ++ b)
    .bind (go args) fun r => retS F s (.str (cs ++ r))

def str2N (s : St F.S) (this : Val) (args : List Val) : Str2N → RS F
  | .raw => match arg args 0 with
    | .obj a => .bind (dataOf F s (.obj a) (.str (chars!"raw"))) fun
      | some (.obj r) => match arrayOf F s r with
        | some (_, qs) =>
          let rec go : List Val → List Val → M (List Char)
            | [], _ => .pure []
            | [q], _ => strArg q
            | q :: qs, v :: vs => .bind (strArg q) fun a => .bind (strArg v) fun b => .bind (go qs vs) fun c => .pure (a ++ b ++ c)
            | q :: qs, [] => .bind (strArg q) fun a => .bind (go qs []) fun c => .pure (a ++ c)
          .bind (go qs args.tail) fun r => retS F s (.str r)
        | none => .fail "String.raw strings"
      | _ => .fail "String.raw strings"
    | _ => .fail "String.raw strings"
  | .repeat => .bind (thisStr this) fun cs => match arg args 0 with
    | .num (.lit x) => match F64.toIndex? x with
      | some n => retS F s (.str (List.replicate n cs).flatten)
      | none => rangeErr s (chars!"invalid count")
    | _ => .fail "repeat count"
  | .padEnd => .bind (thisStr this) fun cs => match arg args 0 with
    | .num (.lit x) => match F64.toIndex? x with
      | some n => .bind (match arg args 1 with | .undef => .pure [' '] | v => strArg v) fun fill =>
        let k := n - len cs
        retS F s (.str (cs ++ ((List.replicate (k / len fill + 1) fill).flatten.take k)))
      | none => retS F s (.str cs)
    | _ => .fail "padEnd length"
  | .trimEnd => .bind (thisStr this) fun cs => retS F s (.str ((cs.reverse.dropWhile F64.isWs).reverse))
  | .trimStart => .bind (thisStr this) fun cs => retS F s (.str (cs.dropWhile F64.isWs))
  | .replaceAll => .bind (thisStr this) fun cs => match arg args 0, arg args 1 with
    | .str p, .str r => bif r.contains '$' || p.isEmpty then .fail "replaceAll pattern" else
      retS F s (.str (List.intercalate r (splitOn p cs (len cs + 1))))
    | _, _ => .fail "replaceAll with a regular expression or function"
  | .lastIndexOf => .bind (thisStr this) fun cs => .bind (strArg (arg args 0)) fun p =>
    match findSub p.reverse cs.reverse 0 with
    | some i => retS F s (natV (len cs - len p - i))
    | none => retS F s (intV (-1))
  | .fromCharCode =>
    let rec goC : List Val → M (List Char)
      | [] => .pure []
      | .num (.lit x) :: vs => .bind (goC vs) fun r => .pure (Char.ofNat (F64.toUint16 x) :: r)
      | _ => .fail "fromCharCode"
    .bind (goC args) fun r => retS F s (.str r)

/-! ## Errors -/

def mkError (s : St F.S) (proto : Nat) (msg : Val) (opts : Val) : M (Val × St F.S) :=
  let (a, s) := s.allocObj .ordinary (.obj proto) []
  let withMsg : M (St F.S) := match msg with
    | .undef => .pure s
    | v => .bind (primStr v) fun
      | some cs => .pure (defineProp F s a kMessage (.data (.str cs) true false))
      | none => .fail "error message of an object"
  .bind withMsg fun s =>
    match opts with
    | .obj _ => .bind (dataOf F s opts (.str (chars!"cause"))) fun
      | some .undef => .pure (.obj a, s)
      | some c => .pure (.obj a, defineProp F s a (.str (chars!"cause")) (.data c true false))
      | none => .fail "error cause accessor"
    | _ => .pure (.obj a, s)

def errN (s : St F.S) (this : Val) (args : List Val) (nt : Val) : ErrN → RS F
  | .error => mk aErrorProto
  | .typeError => mk aTypeErrorProto
  | .rangeError => mk aRangeErrorProto
  | .referenceError => mk aReferenceErrorProto
  | .suppressed => .bind (mkError F s aSuppressedProto (arg args 2) .undef) fun
    | (.obj a, s) =>
      let s := defineProp F s a (.str (chars!"error")) (.data (arg args 0) true false)
      let s := defineProp F s a (.str (chars!"suppressed")) (.data (arg args 1) true false)
      retS F s (.obj a)
    | _ => .fail "error"
  | .toString => .bind (dataOf F s this (.str (chars!"name"))) fun n => .bind (dataOf F s this kMessage) fun m =>
    match n, m with
    | some (.str n), some (.str []) => retS F s (.str n)
    | some (.str n), some (.str m) => retS F s (.str (n ++ [':', ' '] ++ m))
    | _, _ => .fail "Error.prototype.toString"
where
  mk (proto : Nat) : RS F :=
    let proto := match nt with
      | .obj _ => proto
      | _ => proto
    .bind (mkError F s proto (arg args 0) (arg args 1)) fun (v, s) => retS F s v

/-! ## Map, Set, WeakMap -/

def findEntry (s : St F.S) (k : Val) : List (Val × Val) → Nat → M (Option Nat)
  | [], _ => .pure none
  | (j, _) :: es, i => .bind (sameValueZero j k) fun b => bif b then .pure (some i) else findEntry s k es (i + 1)
where
  sameValueZero (a b : Val) : M Bool := match a, b with
    | .num (.lit .nan), .num (.lit .nan) => .pure true
    | a, b => strictEq F s a b

def mapEntryValueLinear (s : St F.S) (k : Val) (es : List (Val × Val)) : M Val :=
  .bind (findEntry F s k es 0) fun
    | some i => .pure ((nth? es i).elim .undef Prod.snd)
    | none => .pure .undef

/-- Preserve short-list traversal and all non-string SameValueZero requests.
Large string-key maps derive an index from their unchanged ordered entries. -/
@[implemented_by mapEntryValueLinear]
def mapEntryValue (s : St F.S) (k : Val) (es : List (Val × Val)) : M Val :=
  match k with
  | .str cs => bif KeyIndex.large es 16 then
      M.pure ((KeyIndex.lookup (StringIndex.buildValues es) (pack cs)).getD .undef)
      else mapEntryValueLinear F s k es
  | _ => mapEntryValueLinear F s k es

def mapOf (s : St F.S) (this : Val) : Option (Nat × Obj × List (Val × Val)) :=
  match this with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .map es => some (a, o, es)
      | _ => none
    | none => none
  | _ => none

def setOf (s : St F.S) (this : Val) : Option (Nat × Obj × List Val) :=
  match this with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .set es => some (a, o, es)
      | _ => none
    | none => none
  | _ => none

def pairsOf (s : St F.S) : List Val → Option (List (Val × Val))
  | [] => some []
  | .obj p :: r => match arrayOf F s p with
    | some (_, k :: v :: _) => (pairsOf s r).map ((k, v) :: ·)
    | some (_, [k]) => (pairsOf s r).map ((k, .undef) :: ·)
    | _ => none
  | _ => none

def mapN (s : St F.S) (this : Val) (args : List Val) : MapN → RS F
  | .ctor => ctor aMapProto
  | .weakCtor => ctor aWeakMapProto
  | .get => withMap fun _ _ es => .bind (mapEntryValue F s (arg args 0) es) fun v => retS F s v
  | .has => withMap fun _ _ es => .bind (findEntry F s (arg args 0) es 0) fun r => retS F s (.bool r.isSome)
  | .set => withMap fun a o es => .bind (findEntry F s (arg args 0) es 0) fun
    | some i => retS F (s.setObj a { o with kind := .map (setNth (.undef, .undef) es i (arg args 0, arg args 1)) }) this
    | none => retS F (s.setObj a { o with kind := .map (es ++ [(arg args 0, arg args 1)]) }) this
  | .delete => withMap fun a o es => .bind (findEntry F s (arg args 0) es 0) fun
    | some i => retS F (s.setObj a { o with kind := .map (es.take i ++ es.drop (i + 1)) }) (.bool true)
    | none => retS F s (.bool false)
  | .clear => withMap fun a o _ => retS F (s.setObj a { o with kind := .map [] }) .undef
  | .keys => withMap fun _ _ es => snapshot (es.map Prod.fst) 0
  | .values => withMap fun _ _ es => snapshot (es.map Prod.snd) 0
  | .entries => withMap fun _ _ es =>
    let rec mk (s : St F.S) : List (Val × Val) → List Val × St F.S
      | [] => ([], s)
      | (k, v) :: r => let (p, s) := newArray s [k, v]; let (ps, s) := mk s r; (.obj p :: ps, s)
    let (ps, s) := mk s es
    let (arr, s) := newArray s ps
    let (it, s) := s.allocObj (.iter (.obj arr) 0 0) (.obj aArrayIterProto) []
    retS F s (.obj it)
where
  withMap (k : Nat → Obj → List (Val × Val) → RS F) : RS F :=
    match mapOf F s this with
    | some (a, o, es) => k a o es
    | none => typeErr s (chars!"Map method on a non-Map")
  snapshot (vs : List Val) (mode : Nat) : RS F :=
    let (arr, s) := newArray s vs
    let (it, s) := s.allocObj (.iter (.obj arr) 0 mode) (.obj aArrayIterProto) []
    retS F s (.obj it)
  ctor (proto : Nat) : RS F :=
    .bind (match arg args 0 with
      | .undef | .null => .pure (some [])
      | v => .bind (elemsOf F s v) fun
        | some es => .pure (pairsOf F s es)
        | none => .pure none) fun
    | some es => let (a, s) := s.allocObj (.map es) (.obj proto) []; retS F s (.obj a)
    | none => .fail "Map from a non-array iterable"

def setN (s : St F.S) (this : Val) (args : List Val) : SetN → RS F
  | .ctor => .bind (match arg args 0 with
      | .undef | .null => .pure (some [])
      | v => elemsOf F s v) fun
    | some es =>
      let rec dedup (acc : List Val) : List Val → M (List Val)
        | [] => .pure acc.reverse
        | v :: vs => .bind (findEntry F s v (acc.map fun x => (x, x)) 0) fun
          | some _ => dedup acc vs
          | none => dedup (v :: acc) vs
      .bind (dedup [] es) fun es => let (a, s) := s.allocObj (.set es) (.obj aSetProto) []; retS F s (.obj a)
    | none => .fail "Set from a non-array iterable"
  | .add => withSet fun a o es => .bind (findEntry F s (arg args 0) (es.map fun x => (x, x)) 0) fun
    | some _ => retS F s this
    | none => retS F (s.setObj a { o with kind := .set (es ++ [arg args 0]) }) this
  | .has => withSet fun _ _ es => .bind (findEntry F s (arg args 0) (es.map fun x => (x, x)) 0) fun r => retS F s (.bool r.isSome)
  | .delete => withSet fun a o es => .bind (findEntry F s (arg args 0) (es.map fun x => (x, x)) 0) fun
    | some i => retS F (s.setObj a { o with kind := .set (es.take i ++ es.drop (i + 1)) }) (.bool true)
    | none => retS F s (.bool false)
  | .clear => withSet fun a o _ => retS F (s.setObj a { o with kind := .set [] }) .undef
  | .values => withSet fun _ _ es =>
    let (arr, s) := newArray s es
    let (it, s) := s.allocObj (.iter (.obj arr) 0 0) (.obj aArrayIterProto) []
    retS F s (.obj it)
where
  withSet (k : Nat → Obj → List Val → RS F) : RS F :=
    match setOf F s this with
    | some (a, o, es) => k a o es
    | none => typeErr s (chars!"Set method on a non-Set")

/-! ## Buffers -/

def eltOfCode : Nat → EltK
  | 0 => .i8 | 1 => .u8 | 2 => .i16 | 3 => .u16 | 4 => .i32 | 5 => .u32 | 6 => .f32 | 7 => .f64 | 8 => .i64 | _ => .u64

def cellsOf (k : EltK) : List Val → M (Option (List Cell))
  | [] => .pure (some [])
  | v :: vs => .bind (toCell k v) fun
    | some c => .bind (cellsOf k vs) fun r => .pure (r.map (c :: ·))
    | none => .pure none

def cellBytes (k : EltK) : List Cell → List Byte
  | [] => []
  | c :: cs => cellParts k c k.size 0 ++ cellBytes k cs

def newTyped (s : St F.S) (k : EltK) (proto : Nat) (bytes : List Byte) (n : Nat) : Nat × St F.S :=
  let (b, s) := s.allocObj (.buf bytes) (.obj aArrayBufferProto) []
  s.allocObj (.typed k b 0 n) (.obj proto) []

def typedOf (s : St F.S) (this : Val) : Option (Nat × Obj × EltK × Nat × Nat × Nat) :=
  match this with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .typed k b off n => some (a, o, k, b, off, n)
      | _ => none
    | none => none
  | _ => none

def viewOf (s : St F.S) (this : Val) : Option (Nat × Nat × Nat) :=
  match this with
  | .obj a => match s.obj? a with
    | some ⟨.view b off n, _, _, _, _⟩ => some (b, off, n)
    | _ => none
  | _ => none

def offsetArg (v : Val) : M Nat :=
  match v with
  | .undef => .pure 0
  | .num (.lit x) => match F64.toIndex? x with
    | some n => .pure n
    | none => .fail "offset"
  | _ => .fail "offset from a non-literal"

def isLittle (v : Val) : M Bool := truthy v

/-- UTF-8 bytes of a string (code points below `0x110000`). -/
def utf8 : List Char → List Nat
  | [] => []
  | c :: cs =>
    let n := c.toNat
    (bif Nat.blt n 0x80 then [n]
     else bif Nat.blt n 0x800 then [0xC0 + n / 64, 0x80 + n % 64]
     else bif Nat.blt n 0x10000 then [0xE0 + n / 4096, 0x80 + (n / 64) % 64, 0x80 + n % 64]
     else [0xF0 + n / 262144, 0x80 + (n / 4096) % 64, 0x80 + (n / 64) % 64, 0x80 + n % 64]) ++ utf8 cs

def bufN (s : St F.S) (this : Val) (args : List Val) (data : List Val) : BufN → RS F
  | .typedCtor => match data with
    | [.num (.lit c), .num (.lit p)] => match F64.toIndex? c, F64.toIndex? p with
      | some c, some proto => typedCtor (eltOfCode c) proto
      | _, _ => .fail "typed array constructor data"
    | _ => .fail "typed array constructor data"
  | .arrayBuffer => .bind (offsetArg (arg args 0)) fun n =>
    let (b, s) := s.allocObj (.buf (zeroBytes n)) (.obj aArrayBufferProto) []
    retS F s (.obj b)
  | .dataView => match arg args 0 with
    | .obj b => .bind (offsetArg (arg args 1)) fun off =>
      let n := byteLen F s b
      .bind (match arg args 2 with | .undef => .pure (n - off) | v => offsetArg v) fun l =>
      let (v, s) := s.allocObj (.view b off l) (.obj aDataViewProto) []
      retS F s (.obj v)
    | _ => typeErr s (chars!"DataView of a non-buffer")
  | .getU32 => get .u32
  | .getI32 => get .i32
  | .getF32 => get .f32
  | .getBigU64 => get .u64
  | .setU32 => set .u32
  | .setI32 => set .i32
  | .setF32 => set .f32
  | .setBigU64 => set .u64
  | .taSlice => match typedOf F s this with
    | some (_, o, k, b, off, n) =>
      .bind (relIdx n (arg args 0) 0) fun i => .bind (relIdx n (arg args 1) n) fun j =>
      match bufBytes F s b with
      | some bs =>
        let cnt := j - i
        let bytes := (bs.drop (off + i * k.size)).take (cnt * k.size)
        let proto := match o.proto with | .obj p => p | _ => aTypedProto
        let (r, s) := newTyped F s k proto bytes cnt
        retS F s (.obj r)
      | none => .fail "typed buffer"
    | none => typeErr s (chars!"slice of a non-typed array")
  | .taSubarray => match typedOf F s this with
    | some (_, o, k, b, off, n) =>
      .bind (relIdx n (arg args 0) 0) fun i => .bind (relIdx n (arg args 1) n) fun j =>
      let (r, s) := s.allocObj (.typed k b (off + i * k.size) (j - i)) o.proto []
      retS F s (.obj r)
    | none => typeErr s (chars!"subarray of a non-typed array")
  | .taFill => match typedOf F s this with
    | some (_, _, k, b, off, n) =>
      .bind (relIdx n (arg args 1) 0) fun i => .bind (relIdx n (arg args 2) n) fun j =>
      .bind (toCell k (arg args 0)) fun
      | some c => match s.obj? b with
        | some ⟨.buf bs, p, ps, pr, ex⟩ =>
          let bs := (List.range (j - i)).foldl (fun bs t => writeCell k c bs (off + (i + t) * k.size)) bs
          retS F (s.setObj b ⟨.buf bs, p, ps, pr, ex⟩) this
        | _ => .fail "fill of native memory"
      | none => typeErr s (chars!"fill value")
    | none => typeErr s (chars!"fill of a non-typed array")
  | .taSet => match typedOf F s this with
    | some (_, _, k, b, off, _) => .bind (elemsOf F s (arg args 0)) fun
      | some vs => .bind (offsetArg (arg args 1)) fun pos => .bind (cellsOf k vs) fun
        | some cs => match s.obj? b with
          | some ⟨.buf bs, p, ps, pr, ex⟩ =>
            let start := off + pos * k.size
            let bs := bs.take start ++ cellBytes k cs ++ bs.drop (start + len cs * k.size)
            retS F (s.setObj b ⟨.buf bs, p, ps, pr, ex⟩) .undef
          | _ => .fail "set into native memory"
        | none => typeErr s (chars!"set values")
      | none => .fail "set from a non-array"
    | none => typeErr s (chars!"set of a non-typed array")
  | .bufferFrom => match arg args 0 with
    | .str cs => let bytes := utf8 cs
      let (r, s) := newTyped F s .u8 aBufferProto (bytes.map Byte.lit) (len bytes)
      retS F s (.obj r)
    | _ => .fail "Buffer.from of a non-string"
where
  typedCtor (k : EltK) (proto : Nat) : RS F :=
    match arg args 0 with
    | .undef => let (r, s) := newTyped F s k proto [] 0; retS F s (.obj r)
    | .num (.lit x) => match F64.toIndex? x with
      | some n => let (r, s) := newTyped F s k proto (zeroBytes (n * k.size)) n; retS F s (.obj r)
      | none => rangeErr s (chars!"invalid typed array length")
    | .num _ => .fail "typed array of symbolic length"
    | .obj a => match s.obj? a with
      | some ⟨.buf bs, _, _, _, _⟩ => .bind (offsetArg (arg args 1)) fun off =>
        .bind (match arg args 2 with | .undef => .pure ((len bs - off) / k.size) | v => offsetArg v) fun n =>
        let (r, s) := s.allocObj (.typed k a off n) (.obj proto) []; retS F s (.obj r)
      | some ⟨.extBuf _ _ l, _, _, _, _⟩ => .bind (offsetArg (arg args 1)) fun off =>
        .bind (match arg args 2 with | .undef => .pure ((l - off) / k.size) | v => offsetArg v) fun n =>
        let (r, s) := s.allocObj (.typed k a off n) (.obj proto) []; retS F s (.obj r)
      | _ => .bind (elemsOf F s (.obj a)) fun
        | some vs => .bind (cellsOf k vs) fun
          | some cs => let (r, s) := newTyped F s k proto (cellBytes k cs) (len cs); retS F s (.obj r)
          | none => typeErr s (chars!"cannot convert to typed array elements")
        | none => .fail "typed array from a non-array iterable"
    | _ => typeErr s (chars!"typed array argument")
  get (k : EltK) : RS F := match viewOf F s this with
    | some (b, off, _) => .bind (offsetArg (arg args 0)) fun pos => .bind (isLittle (arg args 1)) fun le =>
      match bufBytes F s b with
      | some bs => let sl := (bs.drop (off + pos)).take k.size
        match readCell k (bif le then sl else sl.reverse) with
        | some c => retS F s (cellVal c)
        | none => .fail "DataView read of mixed bytes"
      | none => .fail "DataView buffer"
    | none => typeErr s (chars!"DataView method on a non-view")
  set (k : EltK) : RS F := match viewOf F s this with
    | some (b, off, _) => .bind (offsetArg (arg args 0)) fun pos => .bind (isLittle (arg args 2)) fun le =>
      .bind (toCell k (arg args 1)) fun
      | some c => match s.obj? b with
        | some ⟨.buf bs, p, ps, pr, ex⟩ =>
          let parts := cellParts k c k.size 0
          let parts := bif le then parts else parts.reverse
          let st := off + pos
          retS F (s.setObj b ⟨.buf (bs.take st ++ parts ++ bs.drop (st + k.size)), p, ps, pr, ex⟩) .undef
        | _ => .fail "DataView write to native memory"
      | none => typeErr s (chars!"DataView value")
    | none => typeErr s (chars!"DataView method on a non-view")

end
end Host.Ts
