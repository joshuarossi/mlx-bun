import host.mlx.NativeLiteralGeometry
import host.mlx.NativeProducerInputs
import host.mlx.NativeReshapeRoles
import host.mlx.QuantizedInference
import host.mlx.NativeCStringRoles
import host.mlx.NativeArguments

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def constantDimension (i : Int) : Dimension := .literal (.lit (F64.ofInt i))

theorem constantDimension_holds (ν : Nat → F64) (C : CSrv) (i : Int)
    (exact : F64.toInt? (F64.ofInt i) = some i) :
    (constantDimension i).Holds ν C (.lit i) := .literal _ _ rfl exact

def qmmInner (transpose : Bool) (bits : Nat) (rows cols : Int) : Int :=
  bif transpose then cols * 32 / bits else rows

def qmmOuter (transpose : Bool) (bits : Nat) (rows cols : Int) : Int :=
  bif transpose then rows else cols * 32 / bits

/-- Only the input feature dimension is constrained. Its leading dimensions
can retain either literal or symbolic fixed annotations. -/
structure QmmGeometry (ν : Nat → F64) (transpose : Bool) (bits : Nat) (rows cols : Int)
    (input weight scales bias : Shape) : Prop where
  weightValues : weight.literalValues ν = some [rows,cols]
  scaleValues : ∃ is : List Int, scales.literalValues ν = some is ∧ bias.literalValues ν = some is
  innerValue : (nthD (constantDimension 0) input (len input - 1)).literalValue ν =
    some (qmmInner transpose bits rows cols)

theorem QmmGeometry.subst (ν : Nat → F64) (θ : Nat → SymE) (tr : Bool) (bits : Nat)
    (rows cols : Int) (input weight scales bias : Shape) :
    QmmGeometry ν tr bits rows cols (Shape.subst θ input) (Shape.subst θ weight)
        (Shape.subst θ scales) (Shape.subst θ bias) ↔
      QmmGeometry (Owned.Annotated.nextValuation θ ν) tr bits rows cols input weight scales bias := by
  have dimZero : (constantDimension 0).subst θ = constantDimension 0 := rfl
  have inner : (nthD (constantDimension 0) (Shape.subst θ input) (len (Shape.subst θ input)-1)).literalValue ν =
      (nthD (constantDimension 0) input (len input-1)).literalValue (Owned.Annotated.nextValuation θ ν) := by
    simp only [Shape.subst,Host.Ts.len_map]
    rw [show nthD (constantDimension 0) (input.map (Dimension.subst θ)) (len input-1) =
        (nthD (constantDimension 0) input (len input-1)).subst θ from by
      simpa only [dimZero] using Host.Ts.nthD_map (Dimension.subst θ) (constantDimension 0) input (len input-1)]
    exact Dimension.literalValue_subst ν θ _
  constructor <;> intro h
  · exact ⟨by simpa only [Shape.literalValues_subst] using h.weightValues,
      by simpa only [Shape.literalValues_subst] using h.scaleValues, by rw [← inner]; exact h.innerValue⟩
  · exact ⟨by simpa only [Shape.literalValues_subst] using h.weightValues,
      by simpa only [Shape.literalValues_subst] using h.scaleValues, by rw [inner]; exact h.innerValue⟩

theorem QmmGeometry.infer {ν : Nat → F64} {C : CSrv} {tr : Bool} {bits : Nat} {rows cols : Int}
    {xr wr sr br : Shape} (h : QmmGeometry ν tr bits rows cols xr wr sr br)
    (group dx dw ds db : Nat) {x w sc bi : List Dim}
    (hx : Shape.Holds ν C xr x) (hw : Shape.Holds ν C wr w)
    (hs : Shape.Holds ν C sr sc) (hb : Shape.Holds ν C br bi)
    (weightDtype : dw = dtUint32) (nonzero : Nat.beq bits 0 = false)
    (float : isFloat (promote dx (promote ds db)) = true) :
    infer (.qmm tr group bits chars!"affine") [(x,dx),(w,dw),(sc,ds),(bi,db)] =
      M.pure (some (.node (setAt x (len x-1) (.lit (qmmOuter tr bits rows cols)))
        (promote dx (promote ds db)))) := by
  have zero : (constantDimension 0).Holds ν C (.lit 0) := constantDimension_holds ν C 0 (by decide +kernel)
  have last := InferenceRoles.nthD_roles hx zero (len xr-1)
  have feature := last.literalValue h.innerValue
  rw [hx.len_eq] at feature
  have inner : dEq (nthD (.lit 0) x (len x-1)) (.lit (qmmInner tr bits rows cols)) = M.pure true := by
    rw [feature]
    exact InferenceRoles.dEq_self _
  obtain ⟨is,hsc,hbi⟩ := h.scaleValues
  have eqScales : bi = sc := (hb.literalValues hbi).trans (hs.literalValues hsc).symm
  rw [hw.literalValues h.weightValues,weightDtype,eqScales]
  exact InferenceRoles.qmm_affine tr group bits x sc rows cols dx ds db nonzero inner float

def qmmShape (input : Shape) (tr : Bool) (bits : Nat) (rows cols : Int) : Shape :=
  setAt input (len input-1) (constantDimension (qmmOuter tr bits rows cols))

theorem qmmShape_subst (θ : Nat → SymE) (input : Shape) (tr : Bool) (bits : Nat) (rows cols : Int) :
    Shape.subst θ (qmmShape input tr bits rows cols) = qmmShape (Shape.subst θ input) tr bits rows cols := by
  simp only [qmmShape,Shape.subst,Host.Ts.len_map]
  rw [← Host.Mlx.Ffi.setAt_map (Dimension.subst θ) input (len input-1) (constantDimension (qmmOuter tr bits rows cols))]
  rfl

theorem qmmShape_holds {ν : Nat → F64} {C : CSrv} {input : Shape} {shape : List Dim}
    (h : Shape.Holds ν C input shape) (tr : Bool) (bits : Nat) (rows cols : Int)
    (exact : F64.toInt? (F64.ofInt (qmmOuter tr bits rows cols)) = some (qmmOuter tr bits rows cols)) :
    Shape.Holds ν C (qmmShape input tr bits rows cols)
      (setAt shape (len shape-1) (.lit (qmmOuter tr bits rows cols))) := by
  unfold qmmShape
  rw [← h.len_eq]
  exact InferenceRoles.setAt_roles h (constantDimension_holds ν C _ exact) _

def qmmRole (roles : Nat → GraphNode) (x w sc bi : Nat) (tr : Bool) (group bits : Nat) (rows cols : Int) : GraphNode :=
  ⟨qmmShape (roles x).shape tr bits rows cols,
    promote (roles x).dtype (promote (roles sc).dtype (roles bi).dtype),
    some (.qmm tr group bits chars!"affine",[x,w,sc,bi])⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.Annotated

def qmmNode (x w sc bi : Nat) (tr : Bool) (group bits : Nat) (shape : List Dim) (dtype : Nat) : Node :=
  ⟨.qmm tr group bits chars!"affine",[x,w,sc,bi],shape,dtype⟩

theorem call_qmm_null (s : St) (out stream : Arg) (b off hx hw hsc hbi x w sc bi group bits modeBuffer : Nat)
    (modeBytes : List Byte) (tr : Bool) (metadata : List (List Dim × Nat)) (shape : List Dim) (dtype : Nat)
    (slot : slotOf out = some (b,off,0))
    (producers : arrIns s [.big (Int.ofNat hx),.big (Int.ofNat hw),.big (Int.ofNat hsc),.big (Int.ofNat hbi)] = some [x,w,sc,bi])
    (mode : cstrArg (.jsPtr modeBuffer 0 modeBytes) = some chars!"affine")
    (groupsBound : group < 2^32) (bitsBound : bits < 2^32)
    (shapes : shapesOf s [x,w,sc,bi] = some metadata)
    (inference : infer (.qmm tr group bits chars!"affine") metadata = M.pure (some (.node shape dtype))) :
    Ffi.call s chars!"mlx_quantized_matmul"
      [out,.big (Int.ofNat hx),.big (Int.ofNat hw),.big (Int.ofNat hsc),.big (Int.ofNat hbi),.bool tr,
        .big (Int.ofNat (packedOptInt group)),.big (Int.ofNat (packedOptInt bits)),.jsPtr modeBuffer 0 modeBytes,stream] =
      okW (NativeRoles.createZero s (qmmNode x w sc bi tr group bits shape dtype)) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_quantized_matmul" = some .qmm := by decide +kernel
  unfold Ffi.call
  rw [symbol]
  simp only [producers,Arguments.optInt_packed group groupsBound,Arguments.optInt_packed bits bitsBound,mode,Option.getD_some]
  exact opOut_node_zero s out b off (.qmm tr group bits chars!"affine") [x,w,sc,bi] _ shape dtype slot shapes inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

theorem qmm_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {x w sc bi fresh : Nat}
    {xn xn' sn sn' bn bn' : Node} (tr : Bool) (group bits : Nat) (rows cols : Int)
    (hx : NodeRel roles ν₀ ν C₀ C R boundary x xn xn')
    (hs : NodeRel roles ν₀ ν C₀ C R boundary sc sn sn')
    (hb : NodeRel roles ν₀ ν C₀ C R boundary bi bn bn')
    (exact : F64.toInt? (F64.ofInt (qmmOuter tr bits rows cols)) = some (qmmOuter tr bits rows cols)) :
    NodeRel (nodeWrite roles fresh (qmmRole roles x w sc bi tr group bits rows cols)) ν₀ ν C₀ C R boundary fresh
      (qmmNode x w sc bi tr group bits (setAt xn.shape (len xn.shape-1) (.lit (qmmOuter tr bits rows cols)))
        (promote xn.dtype (promote sn.dtype bn.dtype)))
      (qmmNode (R.node x) (R.node w) (R.node sc) (R.node bi) tr group bits
        (setAt xn'.shape (len xn'.shape-1) (.lit (qmmOuter tr bits rows cols)))
        (promote xn'.dtype (promote sn'.dtype bn'.dtype))) := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (qmmRole roles x w sc bi tr group bits rows cols).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨qmmShape_holds hx.source.shape tr bits rows cols exact,?_,?_⟩
    · simp only [qmmRole,qmmNode,hx.source.dtype,hs.source.dtype,hb.source.dtype]
    · intro p ins eq; cases eq; exact ⟨.qmm tr group bits chars!"affine",rfl⟩
  · simp only [nodeWrite,ite_true]
    change (qmmRole roles x w sc bi tr group bits rows cols).Holds ν C R _
    refine ⟨qmmShape_holds hx.target.shape tr bits rows cols exact,?_,?_⟩
    · simp only [qmmRole,qmmNode,hx.target.dtype,hs.target.dtype,hb.target.dtype]
    · intro p ins eq; cases eq; exact ⟨.qmm tr group bits chars!"affine",rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- Original packed optional integers, C-string mode, ordered input producers,
fixed dimension guards and fresh output allocation. Every indexed native
object and compiled/configuration payload is preserved. -/
theorem qmm_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (out out' stream stream' : Arg) (b off hx hw hsc hbi x w sc bi group bits modeBuffer : Nat)
    (modeBytes modeBytes' : List Byte) (tr : Bool) (rows cols : Int) (xn wn sn bn : Node)
    (handlesLive : listSupport H [hx,hw,hsc,hbi])
    (producers : Ffi.nodesOf s [hx,hw,hsc,hbi] = some [x,w,sc,bi])
    (sourceX : s.nodes.get x = some xn) (sourceW : s.nodes.get w = some wn)
    (sourceSc : s.nodes.get sc = some sn) (sourceBi : s.nodes.get bi = some bn)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (mode : cstrArg (.jsPtr modeBuffer 0 modeBytes) = some chars!"affine")
    (modeRelated : ListR (ByteR (NumberRoles ν₀ ν C₀ C) R) modeBytes modeBytes')
    (sourceGeometry : QmmGeometry ν₀ tr bits rows cols (roles x).shape (roles w).shape (roles sc).shape (roles bi).shape)
    (targetGeometry : QmmGeometry ν tr bits rows cols (roles x).shape (roles w).shape (roles sc).shape (roles bi).shape)
    (weightDtype : (roles w).dtype = dtUint32) (nonzero : Nat.beq bits 0 = false)
    (float : isFloat (promote (roles x).dtype (promote (roles sc).dtype (roles bi).dtype)) = true)
    (outerExact : F64.toInt? (F64.ofInt (qmmOuter tr bits rows cols)) = some (qmmOuter tr bits rows cols))
    (groupBound : group < 2^32) (bitsBound : bits < 2^32)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ (xn' sn' bn' : Node),
      Ffi.call s chars!"mlx_quantized_matmul"
        [out,.big (Int.ofNat hx),.big (Int.ofNat hw),.big (Int.ofNat hsc),.big (Int.ofNat hbi),.bool tr,
          .big (Int.ofNat (packedOptInt group)),.big (Int.ofNat (packedOptInt bits)),.jsPtr modeBuffer 0 modeBytes,stream] =
        okW (NativeRoles.createZero s (qmmNode x w sc bi tr group bits
          (setAt xn.shape (len xn.shape-1) (.lit (qmmOuter tr bits rows cols)))
          (promote xn.dtype (promote sn.dtype bn.dtype)))) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_quantized_matmul"
        [out',.big (Int.ofNat (R.handle hx)),.big (Int.ofNat (R.handle hw)),.big (Int.ofNat (R.handle hsc)),
          .big (Int.ofNat (R.handle hbi)),.bool tr,.big (Int.ofNat (packedOptInt group)),.big (Int.ofNat (packedOptInt bits)),
          .jsPtr (R.a modeBuffer) 0 modeBytes',stream'] =
        okW (NativeRoles.createZero s' (qmmNode (R.node x) (R.node w) (R.node sc) (R.node bi) tr group bits
          (setAt xn'.shape (len xn'.shape-1) (.lit (qmmOuter tr bits rows cols)))
          (promote xn'.dtype (promote sn'.dtype bn'.dtype)))) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (qmmRole roles x w sc bi tr group bits rows cols)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (qmmNode x w sc bi tr group bits
          (setAt xn.shape (len xn.shape-1) (.lit (qmmOuter tr bits rows cols)))
          (promote xn.dtype (promote sn.dtype bn.dtype))))
        (NativeRoles.createZero s' (qmmNode (R.node x) (R.node w) (R.node sc) (R.node bi) tr group bits
          (setAt xn'.shape (len xn'.shape-1) (.lit (qmmOuter tr bits rows cols)))
          (promote xn'.dtype (promote sn'.dtype bn'.dtype)))) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [hx,hw,hsc,hbi] [x,w,sc,bi] handlesLive producers
  obtain ⟨xn',hx',hrx⟩ := h.node_view support.1 sourceX
  obtain ⟨wn',hw',hrw⟩ := h.node_view support.2.1 sourceW
  obtain ⟨sn',hs',hrs⟩ := h.node_view support.2.2.1 sourceSc
  obtain ⟨bn',hb',hrb⟩ := h.node_view support.2.2.2.1 sourceBi
  have inference := sourceGeometry.infer group xn.dtype wn.dtype sn.dtype bn.dtype
    hrx.source.shape hrw.source.shape hrs.source.shape hrb.source.shape
    (hrw.source.dtype.trans weightDtype) nonzero (by simpa only [hrx.source.dtype,hrs.source.dtype,hrb.source.dtype] using float)
  have inference' := targetGeometry.infer group xn'.dtype wn'.dtype sn'.dtype bn'.dtype
    hrx.target.shape hrw.target.shape hrs.target.shape hrb.target.shape
    (hrw.target.dtype.trans weightDtype) nonzero (by simpa only [hrx.target.dtype,hrs.target.dtype,hrb.target.dtype] using float)
  have metadata : Ffi.shapesOf s [x,w,sc,bi] = some [(xn.shape,xn.dtype),(wn.shape,wn.dtype),(sn.shape,sn.dtype),(bn.shape,bn.dtype)] := by
    simp only [Ffi.shapesOf,sourceX,sourceW,sourceSc,sourceBi,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node x,R.node w,R.node sc,R.node bi] =
      some [(xn'.shape,xn'.dtype),(wn'.shape,wn'.dtype),(sn'.shape,sn'.dtype),(bn'.shape,bn'.dtype)] := by
    simp only [Ffi.shapesOf,hx',hw',hs',hb',Option.bind_some,Option.map_some]
  have mode' := (Arguments.cstrArg_roles modeBuffer 0 modeRelated).symm.trans mode
  exact ⟨xn',sn',bn',call_qmm_null s out stream b off hx hw hsc hbi x w sc bi group bits modeBuffer modeBytes tr
      _ _ _ sourceSlot ha mode groupBound bitsBound metadata inference,
    call_qmm_null s' out' stream' (R.a b) off (R.handle hx) (R.handle hw) (R.handle hsc) (R.handle hbi)
      (R.node x) (R.node w) (R.node sc) (R.node bi) group bits (R.a modeBuffer) modeBytes' tr
      _ _ _ targetSlot ha' mode' groupBound bitsBound metadata' inference',
    h.createZeroRoles _ _ (qmm_created tr group bits rows cols hrx hrs hrb outerExact)
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
