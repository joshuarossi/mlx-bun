import host.ts.Value
import host.ts.Source
namespace Host.Ts

/-! # Machine primitives: names, heap, numbers, conversions, buffers -/

def chEq (a b : Char) : Bool := Nat.beq a.toNat b.toNat

def nameEq : List Char → List Char → Bool
  | [], [] => true
  | a :: as, b :: bs => chEq a b && nameEq as bs
  | _, _ => false

def lookupEnv (n : Name) : Env → Option Nat
  | [] => none
  | (m, a) :: e => bif nameEq n m then some a else lookupEnv n e

def keyEq : PKey → PKey → Bool
  | .str a, .str b => nameEq a b
  | .sym a, .sym b => Nat.beq a b
  | _, _ => false

def findProp (k : PKey) : Props → Option PropV
  | [] => none
  | (j, p) :: ps => bif keyEq k j then some p else findProp k ps

/-- Replace or append (insertion order is kept). -/
def setPropL (k : PKey) (p : PropV) : Props → Props
  | [] => [(k, p)]
  | (j, q) :: ps => bif keyEq k j then (j, p) :: ps else (j, q) :: setPropL k p ps

def removeProp (k : PKey) : Props → Props
  | [] => []
  | (j, q) :: ps => bif keyEq k j then ps else (j, q) :: removeProp k ps

def privEq (b : Nat) (n : Name) : (Nat × Name) → Bool
  | (c, m) => Nat.beq b c && nameEq n m

def findPriv (b : Nat) (n : Name) : List ((Nat × Name) × PropV) → Option PropV
  | [] => none
  | (j, p) :: ps => bif privEq b n j then some p else findPriv b n ps

def setPrivL (b : Nat) (n : Name) (p : PropV) : List ((Nat × Name) × PropV) → List ((Nat × Name) × PropV)
  | [] => [((b, n), p)]
  | (j, q) :: ps => bif privEq b n j then (j, p) :: ps else (j, q) :: setPrivL b n p ps

/-! ## Intrinsic addresses, allocated first by `Init`. -/

def aObjectProto : Nat := 1
def aFunctionProto : Nat := 2
def aArrayProto : Nat := 3
def aErrorProto : Nat := 4
def aTypeErrorProto : Nat := 5
def aRangeErrorProto : Nat := 6
def aReferenceErrorProto : Nat := 7
def aPromiseProto : Nat := 8
def aGenProto : Nat := 9
def aAsyncGenProto : Nat := 10
def aMapProto : Nat := 11
def aSetProto : Nat := 12
def aWeakMapProto : Nat := 13
def aArrayBufferProto : Nat := 14
def aDataViewProto : Nat := 15
def aTypedProto : Nat := 16
/-- Typed array prototypes: `17 + EltK.code`. -/
def aTypedProtoOf (k : EltK) : Nat := 17 + k.code
def aStringProto : Nat := 27
def aNumberProto : Nat := 28
def aBigIntProto : Nat := 29
def aBooleanProto : Nat := 30
def aSymbolProto : Nat := 31
def aGlobal : Nat := 32
def aSuppressedProto : Nat := 33
def aIterProto : Nat := 34
def aArrayIterProto : Nat := 35
def aFinRegProto : Nat := 36
def aAlsProto : Nat := 37
def aBufferProto : Nat := 38
def aJsCallbackProto : Nat := 39
/-- First free address after the intrinsics. -/
def aFirst : Nat := 40

/-! ## State operations -/

section
variable {S : Type}

def St.cell? (s : St S) (a : Nat) : Option (Option Val) :=
  match s.heap.get a with
  | some (.cell v) => some v
  | _ => none

def St.obj? (s : St S) (a : Nat) : Option Obj :=
  match s.heap.get a with
  | some (.obj o) => some o
  | _ => none

def St.setObj (s : St S) (a : Nat) (o : Obj) : St S := { s with heap := s.heap.set a (.obj o) }
def St.setCell (s : St S) (a : Nat) (v : Val) : St S := { s with heap := s.heap.set a (.cell (some v)) }

def St.alloc (s : St S) (h : HObj) : Nat × St S :=
  (s.next, { s with heap := s.heap.set s.next h, next := Nat.succ s.next })

def St.allocObj (s : St S) (k : Kind) (proto : Val) (props : Props) : Nat × St S :=
  s.alloc (.obj ⟨k, proto, props, [], true⟩)

def St.go (s : St S) (c : Ctl) : St S := { s with ctl := c }
def St.push (s : St S) (f : Frame) : St S := { s with stack := f :: s.stack }
def St.ret (s : St S) (v : Val) : St S := { s with ctl := .ret v }

end

abbrev Mr (S : Type) := M (St S)

def strOf (s : String) : List Char := s.toList

/-- A new error object with `message`, thrown. -/
def throwErr {S : Type} (s : St S) (proto : Nat) (msg : List Char) : Mr S :=
  let (a, s) := s.allocObj .ordinary (.obj proto) [(.str ['m','e','s','s','a','g','e'], .data (.str msg) true false)]
  .pure (s.go (.abr (.throw (.obj a))))

def typeErr {S : Type} (s : St S) (msg : List Char) : Mr S := throwErr s aTypeErrorProto msg
def refErr {S : Type} (s : St S) (msg : List Char) : Mr S := throwErr s aReferenceErrorProto msg
def rangeErr {S : Type} (s : St S) (msg : List Char) : Mr S := throwErr s aRangeErrorProto msg

def newArray {S : Type} (s : St S) (vs : List Val) : Nat × St S := s.allocObj (.array vs) (.obj aArrayProto) []

def iterResult {S : Type} (s : St S) (v : Val) (done : Bool) : Nat × St S :=
  s.allocObj .ordinary (.obj aObjectProto)
    [(.str ['v','a','l','u','e'], .data v true true), (.str ['d','o','n','e'], .data (.bool done) true true)]

/-! ## Numbers through the server -/

def numBin (op : NBin) : NumV → NumV → M NumV
  | .lit x, .lit y => .pure (.lit (F64.bin op x y))
  | a, b => .bin op a b fun i => .pure (.ref i)

def numUn (op : NUn) : NumV → M NumV
  | .lit x => .pure (.lit (F64.un op x))
  | a => .un op a fun i => .pure (.ref i)

def numTest (op : NTest) : NumV → NumV → M Bool
  | .lit x, .lit y => .pure (F64.test op x y)
  | a, b => .test op a b .pure

def numConc : NumV → M F64
  | .lit x => .pure x
  | a => .conc a .pure

def one : NumV := .lit (F64.fin false 1 0)
def zeroN : NumV := .lit (F64.zero false)
def natV (n : Nat) : Val := .num (.lit (F64.ofNat n))
def intV (i : Int) : Val := .num (.lit (F64.ofInt i))

/-! ## Conversions -/

def isNullish : Val → Bool
  | .undef | .null => true
  | _ => false

def truthy : Val → M Bool
  | .undef | .null => .pure false
  | .bool b => .pure b
  | .num x => numTest .truthy x zeroN
  | .big i => .pure (!(i == 0))
  | .str s => .pure (!s.isEmpty)
  | _ => .pure true

def isCallableKind : Kind → Bool
  | .fn _ => true
  | _ => false

def typeofStr {S : Type} (s : St S) : Val → List Char
  | .undef => chars!"undefined"
  | .null => chars!"object"
  | .bool _ => chars!"boolean"
  | .num _ | .ptr _ _ => chars!"number"
  | .big _ => chars!"bigint"
  | .str _ => chars!"string"
  | .sym _ => chars!"symbol"
  | .obj a => match s.obj? a with
    | some o => bif isCallableKind o.kind then chars!"function" else chars!"object"
    | none => chars!"object"

def bigStr (i : Int) : List Char :=
  match i with
  | .ofNat n => F64.natStr n
  | .negSucc n => '-' :: F64.natStr (n + 1)

/-- `ToString` of a primitive; `none` for objects and symbols. -/
def primStr : Val → M (Option (List Char))
  | .str s => .pure (some s)
  | .num x => .bind (numConc x) fun f => match F64.toStr f with
    | some cs => .pure (some cs)
    | none => .fail "Number::toString of a non-integer"
  | .big i => .pure (some (bigStr i))
  | .bool b => .pure (some (bif b then chars!"true" else chars!"false"))
  | .undef => .pure (some (chars!"undefined"))
  | .null => .pure (some (chars!"null"))
  | _ => .pure none

/-- Canonical array index of a property key. -/
def digitsNat : List Char → Nat → Option Nat
  | [], n => some n
  | c :: cs, n =>
    let d := c.toNat
    bif Nat.ble 48 d && Nat.ble d 57 then digitsNat cs (n * 10 + (d - 48)) else none

def keyIndex : PKey → Option Nat
  | .str ['0'] => some 0
  | .str ('0' :: _) => none
  | .str [] => none
  | .str cs => match digitsNat cs 0 with
    | some n => bif Nat.blt n (2 ^ 32 - 1) then some n else none
    | none => none
  | .sym _ => none

def numIndex : Val → Option Nat
  | .num (.lit x) => F64.toIndex? x
  | _ => none

/-- `ToPropertyKey` of a primitive. -/
def toKey : Val → M (Option PKey)
  | .sym i => .pure (some (.sym i))
  | v => .bind (primStr v) fun o => .pure (o.map PKey.str)

def nthD {α : Type} (d : α) : List α → Nat → α
  | [], _ => d
  | a :: _, 0 => a
  | _ :: as, n + 1 => nthD d as n

def nth? {α : Type} : List α → Nat → Option α
  | [], _ => none
  | a :: _, 0 => some a
  | _ :: as, n + 1 => nth? as n

def setNth {α : Type} (d : α) : List α → Nat → α → List α
  | [], 0, a => [a]
  | [], n + 1, a => d :: setNth d [] n a
  | _ :: as, 0, a => a :: as
  | b :: as, n + 1, a => b :: setNth d as n a

def lenL {α : Type} : List α → Nat → Nat
  | [], n => n
  | _ :: as, n => lenL as (Nat.succ n)

def len {α : Type} (l : List α) : Nat := lenL l 0

/-! ## Strings: escapes and code units -/

def hexVal (c : Char) : Option Nat := F64.digitVal c >>= fun d => bif Nat.blt d 16 then some d else none

def hexN : Nat → List Char → Nat → Option (Nat × List Char)
  | 0, cs, v => some (v, cs)
  | n + 1, c :: cs, v => (hexVal c).bind fun d => hexN n cs (v * 16 + d)
  | _, [], _ => none

def hexBrace : Nat → List Char → Nat → Option (Nat × List Char)
  | 0, _, _ => none
  | _ + 1, '}' :: cs, v => some (v, cs)
  | f + 1, c :: cs, v => (hexVal c).bind fun d => hexBrace f cs (v * 16 + d)
  | _, [], _ => none

/-- Cooked value of string/template literal raw text. Surrogate pairs from
`\u` escapes are kept as separate code units. -/
def unescape : Nat → List Char → Option (List Char)
  | 0, _ => none
  | _, [] => some []
  | f + 1, '\\' :: c :: cs =>
    let k (x : Char) (rest : List Char) := (unescape f rest).map (x :: ·)
    match c with
    | 'n' => k '\n' cs | 't' => k '\t' cs | 'r' => k '\r' cs | 'b' => k (Char.ofNat 8) cs
    | 'f' => k (Char.ofNat 12) cs | 'v' => k (Char.ofNat 11) cs | '0' => k (Char.ofNat 0) cs
    | '\n' => unescape f cs
    | 'x' => (hexN 2 cs 0).bind fun (v, cs) => k (Char.ofNat v) cs
    | 'u' => match cs with
      | '{' :: cs => (hexBrace 8 cs 0).bind fun (v, cs) => k (Char.ofNat v) cs
      | cs => (hexN 4 cs 0).bind fun (v, cs) => k (Char.ofNat v) cs
    | c => k c cs
  | f + 1, c :: cs => (unescape f cs).map (c :: ·)

def cook (raw : List Char) : Option (List Char) := unescape (raw.length + 1) raw

/-- UTF-16 length. -/
def u16Len : List Char → Nat → Nat
  | [], n => n
  | c :: cs, n => u16Len cs (bif Nat.blt 0xFFFF c.toNat then n + 2 else n + 1)

/-! ## Buffer bytes -/

def leBytes : Nat → Nat → List Nat
  | 0, _ => []
  | k + 1, v => v % 256 :: leBytes k (v / 256)

def leNat : List Nat → Nat
  | [] => 0
  | b :: bs => b + 256 * leNat bs

def F64.f64Bits : F64 → Nat
  | .nan => 0x7ff8000000000000
  | .inf s => (bif s then 2 ^ 63 else 0) + 0x7ff0000000000000
  | .zero s => bif s then 2 ^ 63 else 0
  | .fin s m0 e0 =>
    let tz := Nat.log2 (Nat.xor m0 (Nat.sub m0 1))
    let m := Nat.shiftRight m0 tz
    let e : Int := e0 + tz
    let sign := bif s then 2 ^ 63 else 0
    let l := Nat.log2 m
    let E : Int := e + l
    bif F64.ilt E (-1022) then sign + m * 2 ^ (e + 1074).toNat
    else sign + (E + 1023).toNat * 2 ^ 52 + (m * 2 ^ (52 - l) - 2 ^ 52)

def F64.ofF64Bits (b : Nat) : F64 :=
  let s := Nat.ble (2 ^ 63) b
  let ex := (b / 2 ^ 52) % 2048
  let fr := b % 2 ^ 52
  bif Nat.beq ex 2047 then (bif Nat.beq fr 0 then .inf s else .nan)
  else bif Nat.beq ex 0 then (bif Nat.beq fr 0 then .zero s else F64.round F64.b64 s fr 1 (-1074))
  else F64.round F64.b64 s (fr + 2 ^ 52) 1 ((ex : Int) - 1075)

def modInt (i : Int) (m : Nat) : Nat := (i % (m : Int)).toNat

/-- Bytes of a concrete element. -/
def encodeCell (k : EltK) : Cell → Option (List Nat)
  | .num (.lit x) => some (match k with
    | .i8 | .u8 => leBytes 1 (F64.toUint8 x)
    | .i16 | .u16 => leBytes 2 (F64.toUint16 x)
    | .i32 | .u32 => leBytes 4 (F64.toUint32 x)
    | .f32 => leBytes 4 (F64.f32Bits (F64.toF32 x))
    | .f64 => leBytes 8 (F64.f64Bits x)
    | .i64 | .u64 => leBytes 8 (match F64.truncInt x with | some i => modInt i (2 ^ 64) | none => 0))
  | .big i => some (leBytes k.size (modInt i (2 ^ (8 * k.size))))
  | .num (.ref _) => none

def signed (bits : Nat) (u : Nat) : Int :=
  bif Nat.blt u (2 ^ (bits - 1)) then (u : Int) else (u : Int) - ((2 ^ bits : Nat) : Int)

def decodeCell (k : EltK) (bs : List Nat) : Cell :=
  let u := leNat bs
  match k with
  | .u8 | .u16 | .u32 => .num (.lit (F64.ofNat u))
  | .i8 => .num (.lit (F64.ofInt (signed 8 u)))
  | .i16 => .num (.lit (F64.ofInt (signed 16 u)))
  | .i32 => .num (.lit (F64.ofInt (signed 32 u)))
  | .f32 => .num (.lit (F64.ofF32Bits u))
  | .f64 => .num (.lit (F64.ofF64Bits u))
  | .i64 => .big (signed 64 u)
  | .u64 => .big (u : Int)

def kindEq (a b : EltK) : Bool := Nat.beq a.code b.code

def concByte : Byte → Option Nat
  | .lit b => some b
  | .part k c i => (encodeCell k c).bind fun bs => nth? bs i

def concBytes : List Byte → Option (List Nat)
  | [] => some []
  | b :: bs => (concByte b).bind fun x => (concBytes bs).map (x :: ·)

/-- The element bytes are exactly element `c` written as `k`. -/
def wholeCell (k : EltK) : List Byte → Nat → Option Cell
  | .part j c 0 :: rest, n => bif kindEq j k && partsFrom k rest 1 n then some c else none
  | _, _ => none
where partsFrom (k : EltK) : List Byte → Nat → Nat → Bool
  | [], i, n => Nat.beq i n
  | .part j _ m :: rest, i, n => kindEq j k && Nat.beq m i && partsFrom k rest (i + 1) n
  | _, _, _ => false

def readCell (k : EltK) (bs : List Byte) : Option Cell :=
  let n := k.size
  match wholeCell k (bs.take n) n with
  | some c => some c
  | none => (concBytes (bs.take n)).bind fun ns => bif Nat.beq (len ns) n then some (decodeCell k ns) else none

def cellParts (k : EltK) (c : Cell) : Nat → Nat → List Byte
  | 0, _ => []
  | n + 1, i => .part k c i :: cellParts k c n (i + 1)

def writeCell (k : EltK) (c : Cell) (bs : List Byte) (off : Nat) : List Byte :=
  bs.take off ++ cellParts k c k.size 0 ++ bs.drop (off + k.size)

def cellVal : Cell → Val
  | .num x => .num x
  | .big i => .big i

def zeroBytes : Nat → List Byte
  | 0 => []
  | n + 1 => .lit 0 :: zeroBytes n

/-- Convert a value for storage as element kind `k`. -/
def numCell (k : EltK) (x : NumV) : M (Option Cell) :=
  match k with
  | .i8 => .bind (numUn .int8 x) fun y => .pure (some (.num y))
  | .u8 => .bind (numUn .uint8 x) fun y => .pure (some (.num y))
  | .i16 => .bind (numUn .int16 x) fun y => .pure (some (.num y))
  | .u16 => .bind (numUn .uint16 x) fun y => .pure (some (.num y))
  | .i32 => .bind (numUn .int32 x) fun y => .pure (some (.num y))
  | .u32 => .bind (numUn .uint32 x) fun y => .pure (some (.num y))
  | .f32 => .bind (numUn .f32 x) fun y => .pure (some (.num y))
  | .f64 => .pure (some (.num x))
  | .i64 | .u64 => .pure none

def toCell (k : EltK) : Val → M (Option Cell)
  | .num x => numCell k x
  | .big i => match k with
    | .i64 => .pure (some (.big (signed 64 (modInt i (2 ^ 64)))))
    | .u64 => .pure (some (.big (modInt i (2 ^ 64) : Nat)))
    | _ => .pure none
  | .bool b => numCell k (.lit (bif b then F64.fin false 1 0 else F64.zero false))
  | .undef => match k with
    | .i64 | .u64 => .pure none
    | .f32 | .f64 => .pure (some (.num (.lit .nan)))
    | _ => .pure (some (.num zeroN))
  | .null => numCell k zeroN
  | _ => .pure none

end Host.Ts
