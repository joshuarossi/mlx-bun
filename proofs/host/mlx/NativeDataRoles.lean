import host.mlx.NativeSliceDynamicRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

/-- Original array_new_data copy length, including the existing symbolic
shape fallback. -/
def dataCopy {α : Type} (shape : List Dim) (dtype : Nat) (bytes : List α) : List α :=
  match natsOfDims shape with
  | some ds => bytes.take (ds.foldr (· * ·) 1 * dtSize dtype)
  | none => bytes

def dataNode (shape : List Dim) (dtype : Nat) (bytes : List Byte) : Node :=
  ⟨.data (dataCopy shape dtype bytes),[],shape,dtype⟩

theorem call_array_new_data (s : St) (dataBuffer shapeBuffer : Nat) (bytes shapeBytes : List Byte)
    (count dtypeArg : Arg) (shape : List Dim) (dtype : Nat)
    (hs : dimsArg (.jsPtr shapeBuffer 0 shapeBytes) count = some shape) (hd : argNat dtypeArg = some dtype) :
    Ffi.call s chars!"mlx_array_new_data" [.jsPtr dataBuffer 0 bytes,.jsPtr shapeBuffer 0 shapeBytes,count,dtypeArg] =
      ok (createZero s (dataNode shape dtype bytes)) (.big (Int.ofNat s.next)) := by
  have sy : symOf chars!"mlx_array_new_data" = some .arrayNewData := by decide +kernel
  unfold Ffi.call
  rw [sy]
  simp only [hs,hd]
  rfl

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def dataRole (shape : List Dim) (dtype : Nat) (shapeRoles : Shape) (bytes : List Owned.Annotated.Byte) : GraphNode :=
  ⟨shapeRoles,dtype,some (.data (dataCopy shape dtype bytes),[])⟩

theorem dataCopy_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    (shape : List Dim) (dtype : Nat) {roles : List Owned.Annotated.Byte} {bytes : List Byte}
    (h : ListR (Owned.Annotated.Byte.Holds ν C R) roles bytes) :
    ListR (Owned.Annotated.Byte.Holds ν C R) (dataCopy shape dtype roles) (dataCopy shape dtype bytes) := by
  unfold dataCopy
  cases natsOfDims shape with
  | none => exact h
  | some ds => exact h.take _

theorem data_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (base : Nat → GraphNode) (boundary : Nat → Prop) (fresh : Nat)
    (shape : List Dim) (dtype : Nat) (shapeRoles : Shape) (byteRoles : List Owned.Annotated.Byte)
    (bytes bytes' : List Byte)
    (hs : Shape.Holds ν₀ C₀ shapeRoles shape) (ht : Shape.Holds ν C shapeRoles shape)
    (hb : ListR (Owned.Annotated.Byte.Holds ν₀ C₀ Owned.Annotated.identity) byteRoles bytes)
    (hb' : ListR (Owned.Annotated.Byte.Holds ν C R) byteRoles bytes') :
    NodeRel (nodeWrite base fresh (dataRole shape dtype shapeRoles byteRoles)) ν₀ ν C₀ C R boundary fresh
      (dataNode shape dtype bytes) (dataNode shape dtype bytes') := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (dataRole shape dtype shapeRoles byteRoles).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨hs,rfl,?_⟩
    intro p ins he
    cases he
    exact ⟨.data (dataCopy_holds shape dtype hb),rfl⟩
  · simp only [nodeWrite,ite_true]
    change (dataRole shape dtype shapeRoles byteRoles).Holds ν C R _
    refine ⟨ht,rfl,?_⟩
    intro p ins he
    cases he
    exact ⟨.data (dataCopy_holds shape dtype hb'),rfl⟩
  · intro he
    simp only [nodeWrite,ite_true] at he
    cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- A copied-data constructor preserves fixed numeric byte meanings through
the original truncation and fresh producer/handle allocation. Shape bytes and
enum/count arguments are shared fixed occurrences; no target decoder or call
equation is assumed. -/
theorem array_new_data {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {base : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel base ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (dataBuffer shapeBuffer : Nat) (bytes bytes' shapeBytes : List Byte) (count dtypeArg : Arg)
    (shape : List Dim) (dtype : Nat) (shapeRoles : Shape) (byteRoles : List Owned.Annotated.Byte)
    (sourceShape : dimsArg (.jsPtr shapeBuffer 0 shapeBytes) count = some shape)
    (sourceDtype : argNat dtypeArg = some dtype)
    (shapeSource : Shape.Holds ν₀ C₀ shapeRoles shape) (shapeTarget : Shape.Holds ν C shapeRoles shape)
    (sourceBytes : ListR (Owned.Annotated.Byte.Holds ν₀ C₀ Owned.Annotated.identity) byteRoles bytes)
    (targetBytes : ListR (Owned.Annotated.Byte.Holds ν C R) byteRoles bytes')
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    Ffi.call s chars!"mlx_array_new_data" [.jsPtr dataBuffer 0 bytes,.jsPtr shapeBuffer 0 shapeBytes,count,dtypeArg] =
      ok (NativeRoles.createZero s (dataNode shape dtype bytes)) (.big (Int.ofNat s.next)) ∧
    Ffi.call s' chars!"mlx_array_new_data" [.jsPtr (R.a dataBuffer) 0 bytes',.jsPtr (R.a shapeBuffer) 0 shapeBytes,count,dtypeArg] =
      ok (NativeRoles.createZero s' (dataNode shape dtype bytes')) (.big (Int.ofNat s'.next)) ∧
    Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel (nodeWrite base s.nnext (dataRole shape dtype shapeRoles byteRoles)) ν₀ ν C₀ C R boundary)
      ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
      (NativeRoles.createZero s (dataNode shape dtype bytes)) (NativeRoles.createZero s' (dataNode shape dtype bytes')) := by
  have targetShape : dimsArg (.jsPtr (R.a shapeBuffer) 0 shapeBytes) count = some shape := by
    cases hc : argNat count with
    | none => simp only [dimsArg,hc] at sourceShape; cases sourceShape
    | some n => cases n <;> simpa only [dimsArg,hc] using sourceShape
  exact ⟨call_array_new_data s dataBuffer shapeBuffer bytes shapeBytes count dtypeArg shape dtype sourceShape sourceDtype,
    call_array_new_data s' (R.a dataBuffer) (R.a shapeBuffer) bytes' shapeBytes count dtypeArg shape dtype targetShape sourceDtype,
    h.createZeroRoles _ _ (data_created base boundary s.nnext shape dtype shapeRoles byteRoles bytes bytes'
      shapeSource shapeTarget sourceBytes targetBytes)
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
