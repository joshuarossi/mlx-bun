import host.ts.Core
namespace Host.Ts

/-! # Property access

Every get may run a getter and every put a setter, so these produce the
next control state: `ret v`, a call of the accessor (the waiting frame is
already on the stack), or a thrown error. Array lengths and elements,
typed-array elements and `length`/`byteLength`/`size` of builtin objects
are read from the object's kind. -/

def kLength : PKey := .str ['l','e','n','g','t','h']
def kPrototype : PKey := .str ['p','r','o','t','o','t','y','p','e']
def kConstructor : PKey := .str ['c','o','n','s','t','r','u','c','t','o','r']
def kNext : PKey := .str ['n','e','x','t']
def kDone : PKey := .str ['d','o','n','e']
def kValue : PKey := .str ['v','a','l','u','e']
def kReturn : PKey := .str ['r','e','t','u','r','n']
def kMessage : PKey := .str ['m','e','s','s','a','g','e']

section
variable (F : Ffi)

/-- Bytes of a buffer: JS bytes, or native memory read now. -/
def bufBytes (s : St F.S) (b : Nat) : Option (List Byte) :=
  match s.obj? b with
  | some ⟨.buf bs, _, _, _, _⟩ => some bs
  | some ⟨.extBuf r off len, _, _, _, _⟩ => F.read s.ffi r off len
  | _ => none

def typedGet (s : St F.S) (k : EltK) (b off n i : Nat) : M (Option PropV) :=
  bif Nat.blt i n then
    match bufBytes F s b with
    | some bs => match readCell k (bs.drop (off + i * k.size)) with
      | some c => .pure (some (.data (cellVal c) true true))
      | none => .fail "typed array element of mixed or symbolic bytes"
    | none => .fail "typed array buffer"
  else .pure none

def byteLen (s : St F.S) (b : Nat) : Nat :=
  match s.obj? b with
  | some ⟨.buf bs, _, _, _, _⟩ => len bs
  | some ⟨.extBuf _ _ n, _, _, _, _⟩ => n
  | _ => 0

def findExport (n : Name) : List (Name × Nat) → Option Nat
  | [] => none
  | (m, a) :: es => bif nameEq n m then some a else findExport n es

/-- Own property of an object, including kind-provided ones. -/
def ownGet (s : St F.S) (o : Obj) (k : PKey) : M (Option PropV) :=
  match o.kind with
  | .array es => match keyIndex k with
    | some i => .pure ((nth? es i).map fun v => .data v true true)
    | none => bif keyEq k kLength then .pure (some (.data (natV (len es)) true false)) else .pure (findProp k o.props)
  | .typed kk b off n => match keyIndex k with
    | some i => typedGet F s kk b off n i
    | none =>
      bif keyEq k kLength then .pure (some (.data (natV n) false false))
      else bif keyEq k (.str (chars!"byteLength")) then .pure (some (.data (natV (n * kk.size)) false false))
      else bif keyEq k (.str (chars!"byteOffset")) then .pure (some (.data (natV off) false false))
      else bif keyEq k (.str (chars!"buffer")) then .pure (some (.data (.obj b) false false))
      else .pure (findProp k o.props)
  | .buf bs => bif keyEq k (.str (chars!"byteLength")) then .pure (some (.data (natV (len bs)) false false)) else .pure (findProp k o.props)
  | .extBuf _ _ n => bif keyEq k (.str (chars!"byteLength")) then .pure (some (.data (natV n) false false)) else .pure (findProp k o.props)
  | .map m => bif keyEq k (.str (chars!"size")) then .pure (some (.data (natV m.size) false false)) else .pure (findProp k o.props)
  | .set m => bif keyEq k (.str (chars!"size")) then .pure (some (.data (natV m.size) false false)) else .pure (findProp k o.props)
  | .ns ex => match k with
    | .str n => match findExport n ex with
      | some c => match s.cell? c with
        | some (some v) => .pure (some (.data v true true))
        | _ => .fail "namespace binding uninitialized"
      | none => .pure none
    | .sym _ => .pure none
  | _ => .pure (findProp k o.props)

def getChain (s : St F.S) (k : PKey) : Nat → Nat → M (Option PropV)
  | 0, _ => .fail "prototype chain too deep"
  | f + 1, a => match s.obj? a with
    | some o => .bind (ownGet F s o k) fun
      | some p => .pure (some p)
      | none => match o.proto with
        | .obj b => getChain s k f b
        | _ => .pure none
    | none => .fail "dangling object"

def protoOf (s : St F.S) : Val → Option Nat
  | .obj _ => none
  | .str _ => some aStringProto
  | .num _ | .ptr _ _ => some aNumberProto
  | .big _ => some aBigIntProto
  | .bool _ => some aBooleanProto
  | .sym _ => some aSymbolProto
  | _ => none

/-- Property lookup on any value, without running accessors. -/
def lookup (s : St F.S) (recv : Val) (k : PKey) : M (Option PropV) :=
  match recv with
  | .obj a => getChain F s k 16 a
  | .str cs => match keyIndex k with
    | some i => .pure ((nth? cs i).map fun c => .data (.str [c]) false true)
    | none => bif keyEq k kLength then .pure (some (.data (natV (u16Len cs 0)) false false))
      else getChain F s k 16 aStringProto
  | v => match protoOf F s v with
    | some p => getChain F s k 16 p
    | none => .pure none

/-- Run a property's value: data, or the getter on `recv`. -/
def readProp (s : St F.S) (recv : Val) : Option PropV → St F.S
  | some (.data v _ _) => s.ret v
  | some (.acc .undef _ _) => s.ret .undef
  | some (.acc g _ _) => s.go (.call g recv [])
  | none => s.ret .undef

def getV (s : St F.S) (recv : Val) (k : PKey) : Mr F.S :=
  match recv with
  | .undef | .null => typeErr s (chars!"cannot read properties of " ++ (bif isNullish recv && (match recv with | .null => true | _ => false) then chars!"null" else chars!"undefined"))
  | _ => .bind (lookup F s recv k) fun p => .pure (readProp F s recv p)

/-- `CreateDataProperty` on an ordinary or array object (no setters run). -/
def defineData (s : St F.S) (a : Nat) (k : PKey) (v : Val) : St F.S :=
  match s.obj? a with
  | some o => match o.kind, keyIndex k with
    | .array es, some i => s.setObj a { o with kind := .array (setNth .undef es i v) }
    | _, _ => s.setObj a { o with props := setPropL k (.data v true true) o.props }
  | none => s

def defineProp (s : St F.S) (a : Nat) (k : PKey) (p : PropV) : St F.S :=
  match s.obj? a with
  | some o => s.setObj a { o with props := setPropL k p o.props }
  | none => s

def resize (es : List Val) (n : Nat) : List Val :=
  bif Nat.ble n (len es) then es.take n else es ++ List.replicate (n - len es) .undef

/-- Store into a typed array element (out-of-range writes are ignored). -/
def typedPut (s : St F.S) (a : Nat) (o : Obj) (k : EltK) (b off n i : Nat) (v : Val) : Mr F.S :=
  .bind (toCell k v) fun
    | some c => bif Nat.blt i n then
        match s.obj? b with
        | some bo => match bo.kind with
          | .buf bs => .pure ((s.setObj b { bo with kind := .buf (writeCell k c bs (off + i * k.size)) }).ret v)
          | _ => .fail "store into native memory"
        | none => .fail "typed array buffer"
      else .pure (s.ret v)
    | none => let _ := o; let _ := a; typeErr s (chars!"cannot convert to typed array element")

/-- `obj[k] = v` (strict mode): own data, inherited setter, or new property. -/
def putV (s : St F.S) (recv : Val) (k : PKey) (v : Val) : Mr F.S :=
  match recv with
  | .obj a => match s.obj? a with
    | some o => match o.kind, keyIndex k with
      | .array es, some i =>
        bif o.extensible then .pure ((s.setObj a { o with kind := .array (setNth .undef es i v) }).ret v)
        else typeErr s (chars!"cannot assign to a frozen array")
      | .typed kk b off n, some i => typedPut F s a o kk b off n i v
      | .ns _, _ => typeErr s (chars!"cannot assign to a module namespace")
      | .array es, none =>
        bif keyEq k kLength then
          (match v with
           | .num (.lit x) => match F64.toIndex? x with
             | some n => bif o.extensible then .pure ((s.setObj a { o with kind := .array (resize es n) }).ret v)
                 else typeErr s (chars!"cannot assign to a frozen array")
             | none => rangeErr s (chars!"invalid array length")
           | _ => .fail "array length from a non-literal")
        else putOrd s a o k v
      | _, _ => putOrd s a o k v
    | none => .fail "dangling object"
  | _ => typeErr s (chars!"cannot create a property on a primitive")
where
  putOrd (s : St F.S) (a : Nat) (o : Obj) (k : PKey) (v : Val) : Mr F.S :=
    match findProp k o.props with
    | some (.data _ w e) => bif w then .pure ((s.setObj a { o with props := setPropL k (.data v true e) o.props }).ret v)
      else typeErr s (chars!"cannot assign to a read-only property")
    | some (.acc _ .undef _) => typeErr s (chars!"cannot set a property that has only a getter")
    | some (.acc _ st _) => .pure ((s.push (.e (.const v))).go (.call st (.obj a) [v]))
    | none =>
      let inherited : M (Option PropV) := match o.proto with
        | .obj p => getChain F s k 16 p
        | _ => .pure none
      .bind inherited fun
        | some (.acc _ .undef _) => typeErr s (chars!"cannot set a property that has only a getter")
        | some (.acc _ st _) => .pure ((s.push (.e (.const v))).go (.call st (.obj a) [v]))
        | some (.data _ false _) => typeErr s (chars!"cannot assign to a read-only property")
        | _ => bif o.extensible then .pure ((s.setObj a { o with props := o.props ++ [(k, .data v true true)] }).ret v)
          else typeErr s (chars!"cannot add a property to a non-extensible object")

def privGetV (s : St F.S) (recv : Val) (b : Nat) (n : Name) : Mr F.S :=
  match recv with
  | .obj a => match s.obj? a with
    | some o => match findPriv b n o.priv with
      | some p => .pure (readProp F s recv (some p))
      | none => typeErr s (chars!"private member #" ++ n ++ chars!" is not present")
    | none => .fail "dangling object"
  | _ => typeErr s (chars!"private member on a primitive")

def privPutV (s : St F.S) (recv : Val) (b : Nat) (n : Name) (v : Val) : Mr F.S :=
  match recv with
  | .obj a => match s.obj? a with
    | some o => match findPriv b n o.priv with
      | some (.data _ true e) => .pure ((s.setObj a { o with priv := setPrivL b n (.data v true e) o.priv }).ret v)
      | some (.acc _ .undef _) => typeErr s (chars!"private accessor has no setter")
      | some (.acc _ st _) => .pure ((s.push (.e (.const v))).go (.call st recv [v]))
      | some _ => typeErr s (chars!"private method is not writable")
      | none => typeErr s (chars!"private member #" ++ n ++ chars!" is not present")
    | none => .fail "dangling object"
  | _ => typeErr s (chars!"private member on a primitive")

/-- Data value of a property without accessors (builtin internals). -/
def dataOf (s : St F.S) (recv : Val) (k : PKey) : M (Option Val) :=
  .bind (lookup F s recv k) fun
    | some (.data v _ _) => .pure (some v)
    | none => .pure (some .undef)
    | _ => .pure none

/-- Own enumerable string keys in order (`Object.keys`). -/
def ownKeys (s : St F.S) (o : Obj) : List PKey :=
  let idx : List PKey := match o.kind with
    | .array es => (List.range (len es)).map fun i => .str (F64.natStr i)
    | .typed _ _ _ n => (List.range n).map fun i => .str (F64.natStr i)
    | .ns ex => ex.map fun (n, _) => .str n
    | _ => []
  let _ := s
  idx ++ (o.props.filter fun
    | (.str _, .data _ _ true) => true
    | (.str _, .acc _ _ true) => true
    | _ => false).map Prod.fst

end
end Host.Ts
