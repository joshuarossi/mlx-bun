import host.ts.Harness
namespace Host.Ts.Mock
open Host.Ts

/-! # A mock MLX FFI for measurements

Fresh handles; shapes are recorded by `mlx_zeros`, `mlx_reshape`,
`mlx_slice`, `mlx_concatenate_axis` and copied from the first array
argument by every other op with an out-parameter. Arrays' shape memory is
native region `h` (the handle). It is a test double for the trace
measurements, not a model of MLX. -/

structure MArr where
  shape : List NumV
  dtype : NumV

structure St where
  next : Nat
  arrs : Trie MArr
  vecs : Trie (List Int)

def init : St := ⟨1000, .nil, .nil⟩

def argBig : Arg → Option Int
  | .big i => some i
  | .num (.lit x) => F64.toInt? x
  | _ => none

def argNat (a : Arg) : Option Nat := (argBig a).map Int.toNat

def cellsI32 : Nat → List Byte → Option (List NumV)
  | 0, _ => some []
  | n + 1, bs => match readCell .i32 bs with
    | some (.num x) => (cellsI32 n (bs.drop 4)).map (x :: ·)
    | _ => none

def cellsU64 : Nat → List Byte → Option (List Int)
  | 0, _ => some []
  | n + 1, bs => match readCell .u64 bs with
    | some (.big i) => (cellsU64 n (bs.drop 8)).map (i :: ·)
    | _ => none

def arrOf (s : St) (h : Int) : Option MArr := s.arrs.get h.toNat

def fresh (s : St) (a : MArr) : Nat × St := (s.next, { s with next := s.next + 1, arrs := s.arrs.set s.next a })

def firstArr (s : St) : List Arg → Option MArr
  | [] => none
  | a :: as => match argBig a with
    | some h => match arrOf s h with
      | some m => some m
      | none => firstArr s as
    | none => firstArr s as

def f32Dtype : NumV := .lit (F64.ofNat 10)

/-- An op writing a new array through out-parameter `o`. -/
def outOp (s : St) (o : Arg) (a : MArr) : M (Option (St × Ret × List (Nat × Nat × List Byte))) :=
  match o with
  | .jsPtr b off _ =>
    let (h, s) := fresh s a
    .pure (some (s, .num zeroN, [(b, off, cellParts .u64 (.big h) 8 0)]))
  | _ => .pure none

def subAll : List NumV → List NumV → M (List NumV)
  | a :: as, b :: bs => .bind (numBin .sub a b) fun d => .bind (subAll as bs) fun r => .pure (d :: r)
  | _, _ => .pure []

def concatShape (axis : Nat) : List MArr → M (Option (List NumV))
  | [] => .pure none
  | [a] => .pure (some a.shape)
  | a :: r => .bind (concatShape axis r) fun
    | some sh => .bind (numBin .add (nthD zeroN a.shape axis) (nthD zeroN sh axis)) fun d =>
      .pure (some (setNth zeroN a.shape axis d))
    | none => .pure none

def call (s : St) (name : Name) (args : List Arg) : M (Option (St × Ret × List (Nat × Nat × List Byte))) :=
  let ok (s : St) (r : Ret) := M.pure (some (s, r, ([] : List (Nat × Nat × List Byte))))
  bif nameEq name chars!"mlx_array_new" then
    let (h, s) := fresh s ⟨[], f32Dtype⟩
    ok s (.big h)
  else bif nameEq name chars!"mlx_array_free" || nameEq name chars!"mlx_vector_array_free"
      || nameEq name chars!"mlx_stream_free" || nameEq name chars!"mlx_string_free" then ok s (.num zeroN)
  else bif nameEq name chars!"mlx_array_ndim" then
    match args with
    | [a] => match (argBig a).bind (arrOf s) with
      | some m => ok s (.big (len m.shape))
      | none => .pure none
    | _ => .pure none
  else bif nameEq name chars!"mlx_array_shape" then
    match args with
    | [a] => match argBig a with
      | some h => ok s (.ptr h.toNat 0)
      | none => .pure none
    | _ => .pure none
  else bif nameEq name chars!"mlx_array_dtype" then
    match args with
    | [a] => match (argBig a).bind (arrOf s) with
      | some m => ok s (.num m.dtype)
      | none => .pure none
    | _ => .pure none
  else bif nameEq name chars!"mlx_reshape" then
    match args with
    | [o, a, .jsPtr _ _ bs, n, _] => match (argBig a).bind (arrOf s), argNat n with
      | some m, some k => match cellsI32 k bs with
        | some sh => outOp s o ⟨sh, m.dtype⟩
        | none => .pure none
      | _, _ => .pure none
    | _ => .pure none
  else bif nameEq name chars!"mlx_zeros" then
    match args with
    | [o, .jsPtr _ _ bs, n, .num dt, _] => match argNat n with
      | some k => match cellsI32 k bs with
        | some sh => outOp s o ⟨sh, dt⟩
        | none => .pure none
      | none => .pure none
    | _ => .pure none
  else bif nameEq name chars!"mlx_slice" then
    match args with
    | [o, a, .jsPtr _ _ st, n, .jsPtr _ _ sp, _, _, _, _] => match (argBig a).bind (arrOf s), argNat n with
      | some m, some k => match cellsI32 k st, cellsI32 k sp with
        | some lo, some hi => .bind (subAll hi lo) fun sh => outOp s o ⟨sh, m.dtype⟩
        | _, _ => .pure none
      | _, _ => .pure none
    | _ => .pure none
  else bif nameEq name chars!"mlx_transpose_axes" then
    match args with
    | [o, a, .jsPtr _ _ bs, n, _] => match (argBig a).bind (arrOf s), argNat n with
      | some m, some k => match (cellsI32 k bs).bind fun ax => ax.mapM fun x => match x with
          | .lit f => (F64.toIndex? f).map (nthD zeroN m.shape)
          | .ref _ => none with
        | some sh => outOp s o ⟨sh, m.dtype⟩
        | none => .pure none
      | _, _ => .pure none
    | _ => .pure none
  else bif nameEq name chars!"mlx_vector_array_new_data" then
    match args with
    | [.jsPtr _ _ bs, n] => match argNat n with
      | some k => match cellsU64 k bs with
        | some hs => ok { s with next := s.next + 1, vecs := s.vecs.set s.next hs } (.big s.next)
        | none => .pure none
      | none => .pure none
    | _ => .pure none
  else bif nameEq name chars!"mlx_concatenate_axis" then
    match args with
    | [o, v, ax, _] => match (argBig v).bind fun h => s.vecs.get h.toNat, argNat ax with
      | some hs, some axis => match hs.mapM (arrOf s) with
        | some ms => .bind (concatShape axis ms) fun
          | some sh => outOp s o ⟨sh, (ms.head?.map MArr.dtype).getD f32Dtype⟩
          | none => .pure none
        | none => .pure none
      | _, _ => .pure none
    | _ => .pure none
  else bif nameEq name chars!"mlx_default_gpu_stream_new" || nameEq name chars!"mlx_default_cpu_stream_new"
      || nameEq name chars!"mlx_string_new" then ok { s with next := s.next + 1 } (.big s.next)
  else bif nameEq name chars!"mlx_version" then ok s (.num zeroN)
  else bif nameEq name chars!"mlx_string_data" then ok s (.cstr chars!"0.32.2")
  else bif nameEq name chars!"mlx_set_error_handler" then ok s .void
  else match args with
    | o@(.jsPtr _ _ _) :: rest => match firstArr s rest with
      | some m => outOp s o m
      | none => outOp s o ⟨[], f32Dtype⟩
    | _ => ok s (.num zeroN)

def read (s : St) (r off n : Nat) : Option (List Byte) :=
  (s.arrs.get r).map fun m => ((cellBytes .i32 (m.shape.map Cell.num)).drop off).take n

def ffi : Ffi := ⟨St, call, read, fun _ => 4096⟩

end Host.Ts.Mock
