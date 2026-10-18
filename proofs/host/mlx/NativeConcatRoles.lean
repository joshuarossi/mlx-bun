import host.mlx.NativeConcatGeometry
import host.mlx.NativeVector
import host.mlx.OrdinaryConcatNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

def concatNode (x y axis : Nat) (shape : List Dim) (dtype : Nat) : Node := ⟨.concat axis,[x,y],shape,dtype⟩

theorem call_concat_null (s : St) (out stream : Arg) (b off vec x y axis : Nat) (axisValue : F64) (axisInt : Int)
    (xn yn : Node) (shape : List Dim)
    (slot : slotOf out = some (b,off,0)) (vector : s.obj? vec = some (.vec [x,y]))
    (first : s.nodes.get x = some xn)
    (metadata : shapesOf s [x,y] = some [(xn.shape,xn.dtype),(yn.shape,yn.dtype)])
    (axisDecode : F64.toInt? axisValue = some axisInt) (normalize : axisOf axisInt (len xn.shape) = some axis)
    (inference : infer (.concat axis) [(xn.shape,xn.dtype),(yn.shape,yn.dtype)] =
      M.pure (some (.node shape (promote xn.dtype yn.dtype)))) :
    Ffi.call s chars!"mlx_concatenate_axis" [out,.big (Int.ofNat vec),.num (.lit axisValue),stream] =
      okW (createZero s (concatNode x y axis shape (promote xn.dtype yn.dtype))) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_concatenate_axis" = some .concat := by decide +kernel
  unfold Ffi.call
  rw [symbol]
  simp only [argNat_big_nat,Option.bind_some,vector,argInt,axisDecode,first,normalize]
  exact opOut_node_zero s out b off (.concat axis) [x,y] _ _ _ slot metadata inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def concatRole (roles : Nat → GraphNode) (x y axis : Nat) (output : Shape) : GraphNode :=
  ⟨output,promote (roles x).dtype (roles y).dtype,some (.concat axis,[x,y])⟩

theorem concat_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {x y fresh : Nat} {xn xn' yn yn' : Node}
    {output : Shape} {shape shape' : List Dim} (axis : Nat)
    (hx : NodeRel roles ν₀ ν C₀ C R boundary x xn xn') (hy : NodeRel roles ν₀ ν C₀ C R boundary y yn yn')
    (hs : Shape.Holds ν₀ C₀ output shape) (hs' : Shape.Holds ν C output shape') :
    NodeRel (nodeWrite roles fresh (concatRole roles x y axis output)) ν₀ ν C₀ C R boundary fresh
      (concatNode x y axis shape (promote xn.dtype yn.dtype))
      (concatNode (R.node x) (R.node y) axis shape' (promote xn'.dtype yn'.dtype)) := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (concatRole roles x y axis output).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨hs,?_,?_⟩
    · simp only [concatRole,concatNode,hx.source.dtype,hy.source.dtype]
    · intro p ins eq; cases eq; exact ⟨.concat axis,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (concatRole roles x y axis output).Holds ν C R _
    refine ⟨hs',?_,?_⟩
    · simp only [concatRole,concatNode,hx.target.dtype,hy.target.dtype]
    · intro p ins eq; cases eq; exact ⟨.concat axis,rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem concat_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail s s')
    (out out' stream stream' : Arg) (b off vec x y axis : Nat) (axisValue : F64) (axisInt : Int)
    (xn yn : Node) (output : Shape) (vectorLive : H vec) (inputsLive : listSupport N [x,y])
    (sourceVector : s.obj? vec = some (.vec [x,y])) (sourceX : s.nodes.get x = some xn) (sourceY : s.nodes.get y = some yn)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (axisDecode : F64.toInt? axisValue = some axisInt) (normalize : axisOf axisInt (len (roles x).shape) = some axis)
    (sourceGeometry : ConcatGeometry ν₀ (roles x).shape (roles y).shape output axis)
    (targetGeometry : ConcatGeometry ν (roles x).shape (roles y).shape output axis)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ (shape shape' : List Dim) (xn' yn' : Node),
      Ffi.call s chars!"mlx_concatenate_axis" [out,.big (Int.ofNat vec),.num (.lit axisValue),stream] =
        okW (NativeRoles.createZero s (concatNode x y axis shape (promote xn.dtype yn.dtype))) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_concatenate_axis" [out',.big (Int.ofNat (R.handle vec)),.num (.lit axisValue),stream'] =
        okW (NativeRoles.createZero s' (concatNode (R.node x) (R.node y) axis shape' (promote xn'.dtype yn'.dtype)))
          status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (concatRole roles x y axis output)) ν₀ ν C₀ C R boundary)
        (ObjectRel objects ν₀ ν C₀ C R) (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (concatNode x y axis shape (promote xn.dtype yn.dtype)))
        (NativeRoles.createZero s' (concatNode (R.node x) (R.node y) axis shape' (promote xn'.dtype yn'.dtype))) := by
  obtain ⟨xn',hx',hrx⟩ := h.node_view inputsLive.1 sourceX
  obtain ⟨yn',hy',hry⟩ := h.node_view inputsLive.2.1 sourceY
  have weak := h.mono (fun _ _ p => p) (fun _ _ _ p => p) (fun _ _ _ p => p.base)
  have vector' := weak.vec_view vec vectorLive [x,y] sourceVector
  obtain ⟨shape,hs,inference⟩ := sourceGeometry.infer xn.dtype yn.dtype hrx.source.shape hry.source.shape
  obtain ⟨shape',hs',inference'⟩ := targetGeometry.infer xn'.dtype yn'.dtype hrx.target.shape hry.target.shape
  have metadata : Ffi.shapesOf s [x,y] = some [(xn.shape,xn.dtype),(yn.shape,yn.dtype)] := by
    simp only [Ffi.shapesOf,sourceX,sourceY,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node x,R.node y] = some [(xn'.shape,xn'.dtype),(yn'.shape,yn'.dtype)] := by
    simp only [Ffi.shapesOf,hx',hy',Option.bind_some,Option.map_some]
  exact ⟨shape,shape',xn',yn',call_concat_null s out stream b off vec x y axis axisValue axisInt xn yn shape
      sourceSlot sourceVector sourceX metadata axisDecode (by simpa only [← hrx.source.shape.len_eq] using normalize) inference,
    call_concat_null s' out' stream' (R.a b) off (R.handle vec) (R.node x) (R.node y) axis axisValue axisInt xn' yn' shape'
      targetSlot vector' hx' metadata' axisDecode (by simpa only [← hrx.target.shape.len_eq] using normalize) inference',
    h.createZeroRoles _ _ (concat_created axis hrx hry hs hs')
      (fun _ ne _ _ p => NodeRel.write_frame ne p) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
