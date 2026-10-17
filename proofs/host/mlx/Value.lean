namespace Host.Mlx

/-! Array values of MLX's C API, the trusted dependency boundary. MLX arrays
are immutable values; evaluation order, memory placement, buffer reuse and
GPU synchronization are MLX's responsibility. Elements are stored as raw bits
in row-major order of the logical shape. -/

-- mlx_dtype enum values (mlx-c array.h).
inductive Dtype where
  | bool | uint8 | uint16 | uint32 | uint64 | int8 | int16 | int32 | int64
  | float16 | float32 | float64 | bfloat16 | complex64
  deriving DecidableEq, Repr

def Dtype.code : Dtype → Nat
  | .bool => 0 | .uint8 => 1 | .uint16 => 2 | .uint32 => 3 | .uint64 => 4
  | .int8 => 5 | .int16 => 6 | .int32 => 7 | .int64 => 8
  | .float16 => 9 | .float32 => 10 | .float64 => 11 | .bfloat16 => 12 | .complex64 => 13

def Dtype.ofCode : Nat → Option Dtype
  | 0 => some .bool | 1 => some .uint8 | 2 => some .uint16 | 3 => some .uint32 | 4 => some .uint64
  | 5 => some .int8 | 6 => some .int16 | 7 => some .int32 | 8 => some .int64
  | 9 => some .float16 | 10 => some .float32 | 11 => some .float64 | 12 => some .bfloat16
  | 13 => some .complex64 | _ => none

theorem Dtype.ofCode_code (d : Dtype) : Dtype.ofCode d.code = some d := by cases d <;> rfl

def Dtype.bytes : Dtype → Nat
  | .bool | .uint8 | .int8 => 1
  | .uint16 | .int16 | .float16 | .bfloat16 => 2
  | .uint32 | .int32 | .float32 => 4
  | .uint64 | .int64 | .float64 | .complex64 => 8

structure Value where
  dtype : Dtype
  shape : List Nat
  elems : Nat → Nat

def Value.size (v : Value) : Nat := v.shape.foldr (· * ·) 1

-- Row-major strides and flat index of a multi-index.
def strides : List Nat → List Nat
  | [] => []
  | _ :: rest => rest.foldr (· * ·) 1 :: strides rest

def flat (shape idx : List Nat) : Nat :=
  (List.zipWith (· * ·) (strides shape) idx).foldr (· + ·) 0

-- Multi-index of a flat row-major position.
def unflat : List Nat → Nat → List Nat
  | [], _ => []
  | _ :: rest, i => i / rest.foldr (· * ·) 1 :: unflat rest (i % rest.foldr (· * ·) 1)

def reshape (v : Value) (shape : List Nat) : Option Value :=
  if shape.foldr (· * ·) 1 = v.size then some { v with shape := shape } else none

def transpose (v : Value) (axes : List Nat) : Option Value :=
  if axes.length = v.shape.length ∧ (List.range v.shape.length).all (fun a => axes.contains a) then
    let shape := axes.map (fun a => v.shape.getD a 0)
    some { v with shape := shape
                  elems := fun i =>
                    let out := unflat shape i
                    let src := (List.range v.shape.length).map (fun a => out.getD (axes.idxOf a) 0)
                    v.elems (flat v.shape src) }
  else none

-- Unit-stride slice [start, stop) per axis.
def slice (v : Value) (start stop : List Nat) : Option Value :=
  if start.length = v.shape.length ∧ stop.length = v.shape.length ∧
      (List.zip start (List.zip stop v.shape)).all (fun (a, b, n) => a ≤ b ∧ b ≤ n) then
    let shape := List.zipWith (· - ·) stop start
    some { v with shape := shape
                  elems := fun i => v.elems (flat v.shape (List.zipWith (· + ·) start (unflat shape i))) }
  else none

-- Write `update` into the unit-stride region of `v` starting at `start`.
def sliceUpdate (v update : Value) (start : List Nat) : Option Value :=
  if update.dtype = v.dtype ∧ start.length = v.shape.length ∧ update.shape.length = v.shape.length ∧
      (List.zip start (List.zip update.shape v.shape)).all (fun (a, n, m) => a + n ≤ m) then
    some { v with elems := fun i =>
      let idx := unflat v.shape i
      if (List.zip idx (List.zip start update.shape)).all (fun (x, a, n) => a ≤ x ∧ x < a + n) then
        update.elems (flat update.shape (List.zipWith (· - ·) idx start))
      else v.elems i }
  else none

def concatenate (a b : Value) (axis : Nat) : Option Value :=
  if a.dtype = b.dtype ∧ a.shape.length = b.shape.length ∧ axis < a.shape.length ∧
      (List.range a.shape.length).all (fun k => k = axis ∨ a.shape.getD k 0 = b.shape.getD k 0) then
    let na := a.shape.getD axis 0
    let shape := a.shape.set axis (na + b.shape.getD axis 0)
    some { dtype := a.dtype, shape := shape
           elems := fun i =>
             let idx := unflat shape i
             let x := idx.getD axis 0
             if x < na then a.elems (flat a.shape idx) else b.elems (flat b.shape (idx.set axis (x - na))) }
  else none

def zeros (shape : List Nat) (dtype : Dtype) : Value := ⟨dtype, shape, fun _ => 0⟩

-- `take` along axis 0 of a 2-D array by uint32 row indices (embedding gather).
def takeRows (v indices : Value) : Option Value :=
  match v.shape with
  | [rows, cols] =>
    some { dtype := v.dtype, shape := indices.shape ++ [cols]
           elems := fun i =>
             let r := indices.elems (i / cols)
             if r < rows then v.elems (r * cols + i % cols) else 0 }
  | _ => none

theorem reshape_elems (v : Value) (shape : List Nat) (w : Value) (h : reshape v shape = some w) :
    w.elems = v.elems ∧ w.dtype = v.dtype ∧ w.shape = shape := by
  unfold reshape at h
  split at h
  · cases h; exact ⟨rfl, rfl, rfl⟩
  · cases h

end Host.Mlx
