import host.mlx.NativeConvGeometry
import host.mlx.NativeBinaryRoles

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

structure ConvParameters where
  stride : Nat
  padding : Nat
  dilation : Nat
  groups : Nat
  strideValue : F64
  paddingValue : F64
  dilationValue : F64
  groupsValue : F64
  strideDecode : argNat (.num (.lit strideValue)) = some stride
  paddingDecode : argNat (.num (.lit paddingValue)) = some padding
  dilationDecode : argNat (.num (.lit dilationValue)) = some dilation
  groupsDecode : argNat (.num (.lit groupsValue)) = some groups

def convNode (p : ConvParameters) (x w : Nat) (shape : List Dim) (dtype : Nat) : Node :=
  ⟨.conv1d p.stride p.padding p.dilation p.groups,[x,w],shape,dtype⟩

theorem call_conv_null (p : ConvParameters) (s : St) (out stream : Arg) (b off hx hw x w : Nat)
    (xn wn : Node) (shape : List Dim) (slot : slotOf out = some (b,off,0))
    (producers : arrIns s [.big (Int.ofNat hx),.big (Int.ofNat hw)] = some [x,w])
    (metadata : shapesOf s [x,w] = some [(xn.shape,xn.dtype),(wn.shape,wn.dtype)])
    (inference : infer (.conv1d p.stride p.padding p.dilation p.groups) [(xn.shape,xn.dtype),(wn.shape,wn.dtype)] =
      M.pure (some (.node shape (promote xn.dtype wn.dtype)))) :
    Ffi.call s chars!"mlx_conv1d" [out,.big (Int.ofNat hx),.big (Int.ofNat hw),.num (.lit p.strideValue),
      .num (.lit p.paddingValue),.num (.lit p.dilationValue),.num (.lit p.groupsValue),stream] =
      okW (createZero s (convNode p x w shape (promote xn.dtype wn.dtype))) status0 [u64Write b off s.next] := by
  have symbol : symOf chars!"mlx_conv1d" = some .conv1d := by decide +kernel
  unfold Ffi.call
  rw [symbol]
  simp only [producers,p.strideDecode,p.paddingDecode,p.dilationDecode,p.groupsDecode]
  exact opOut_node_zero s out b off (.conv1d p.stride p.padding p.dilation p.groups) [x,w] _ _ _ slot metadata inference

end Host.Mlx.Ffi.NativeRoles

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi.NativeRoles

def convRole (roles : Nat → GraphNode) (p : ConvParameters) (x w : Nat) (output : Shape) : GraphNode :=
  ⟨output,promote (roles x).dtype (roles w).dtype,some (.conv1d p.stride p.padding p.dilation p.groups,[x,w])⟩

theorem conv_created {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {x w fresh : Nat} {xn xn' wn wn' : Node}
    {output : Shape} {shape shape' : List Dim} (p : ConvParameters)
    (hx : NodeRel roles ν₀ ν C₀ C R boundary x xn xn') (hw : NodeRel roles ν₀ ν C₀ C R boundary w wn wn')
    (hs : Shape.Holds ν₀ C₀ output shape) (hs' : Shape.Holds ν C output shape') :
    NodeRel (nodeWrite roles fresh (convRole roles p x w output)) ν₀ ν C₀ C R boundary fresh
      (convNode p x w shape (promote xn.dtype wn.dtype))
      (convNode p (R.node x) (R.node w) shape' (promote xn'.dtype wn'.dtype)) := by
  constructor
  · simp only [nodeWrite,ite_true]
    change (convRole roles p x w output).Holds ν₀ C₀ Owned.Annotated.identity _
    refine ⟨hs,?_,?_⟩
    · simp only [convRole,convNode,hx.source.dtype,hw.source.dtype]
    · intro q ins eq; cases eq; exact ⟨.conv1d p.stride p.padding p.dilation p.groups,rfl⟩
  · simp only [nodeWrite,ite_true]
    change (convRole roles p x w output).Holds ν C R _
    refine ⟨hs',?_,?_⟩
    · simp only [convRole,convNode,hx.target.dtype,hw.target.dtype]
    · intro q ins eq; cases eq; exact ⟨.conv1d p.stride p.padding p.dilation p.groups,rfl⟩
  · intro he; simp only [nodeWrite,ite_true] at he; cases he

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

theorem conv_null {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {roles : Nat → GraphNode} {boundary : Nat → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel roles ν₀ ν C₀ C R boundary) ObjRel H N tail s s')
    (p : ConvParameters) (out out' stream stream' : Arg) (b off hx hw x w : Nat) (xn wn : Node) (output : Shape)
    (handlesLive : listSupport H [hx,hw]) (producers : Ffi.nodesOf s [hx,hw] = some [x,w])
    (sourceX : s.nodes.get x = some xn) (sourceW : s.nodes.get w = some wn)
    (sourceSlot : slotOf out = some (b,off,0)) (targetSlot : slotOf out' = some (R.a b,off,0))
    (sourceGeometry : ConvGeometry ν₀ (roles x).shape (roles w).shape output p.stride p.padding p.dilation p.groups)
    (targetGeometry : ConvGeometry ν (roles x).shape (roles w).shape output p.stride p.padding p.dilation p.groups)
    (sourceNodes : s.nnext < 2^64) (targetNodes : s'.nnext < 2^64)
    (sourceHandles : s.next < 2^64) (targetHandles : s'.next < 2^64) :
    ∃ (shape shape' : List Dim) (xn' wn' : Node),
      Ffi.call s chars!"mlx_conv1d" [out,.big (Int.ofNat hx),.big (Int.ofNat hw),.num (.lit p.strideValue),
        .num (.lit p.paddingValue),.num (.lit p.dilationValue),.num (.lit p.groupsValue),stream] =
        okW (NativeRoles.createZero s (convNode p x w shape (promote xn.dtype wn.dtype))) status0 [u64Write b off s.next] ∧
      Ffi.call s' chars!"mlx_conv1d" [out',.big (Int.ofNat (R.handle hx)),.big (Int.ofNat (R.handle hw)),.num (.lit p.strideValue),
        .num (.lit p.paddingValue),.num (.lit p.dilationValue),.num (.lit p.groupsValue),stream'] =
        okW (NativeRoles.createZero s' (convNode p (R.node x) (R.node w) shape' (promote xn'.dtype wn'.dtype))) status0 [u64Write (R.a b) off s'.next] ∧
      Live (NumberRoles ν₀ ν C₀ C) R
        (NodeRel (nodeWrite roles s.nnext (convRole roles p x w output)) ν₀ ν C₀ C R boundary)
        ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
        (NativeRoles.createZero s (convNode p x w shape (promote xn.dtype wn.dtype)))
        (NativeRoles.createZero s' (convNode p (R.node x) (R.node w) shape' (promote xn'.dtype wn'.dtype))) := by
  obtain ⟨ha,ha',support⟩ := h.arrIns_handles [hx,hw] [x,w] handlesLive producers
  obtain ⟨xn',hx',hrx⟩ := h.node_view support.1 sourceX
  obtain ⟨wn',hw',hrw⟩ := h.node_view support.2.1 sourceW
  obtain ⟨shape,hs,inference⟩ := sourceGeometry.infer xn.dtype wn.dtype hrx.source.shape hrw.source.shape
  obtain ⟨shape',hs',inference'⟩ := targetGeometry.infer xn'.dtype wn'.dtype hrx.target.shape hrw.target.shape
  have metadata : Ffi.shapesOf s [x,w] = some [(xn.shape,xn.dtype),(wn.shape,wn.dtype)] := by
    simp only [Ffi.shapesOf,sourceX,sourceW,Option.bind_some,Option.map_some]
  have metadata' : Ffi.shapesOf s' [R.node x,R.node w] = some [(xn'.shape,xn'.dtype),(wn'.shape,wn'.dtype)] := by
    simp only [Ffi.shapesOf,hx',hw',Option.bind_some,Option.map_some]
  exact ⟨shape,shape',xn',wn',call_conv_null p s out stream b off hx hw x w xn wn shape sourceSlot ha metadata inference,
    call_conv_null p s' out' stream' (R.a b) off (R.handle hx) (R.handle hw) (R.node x) (R.node w) xn' wn' shape'
      targetSlot ha' metadata' inference',
    h.createZeroRoles _ _ (conv_created p hrx hrw hs hs')
      (fun _ ne _ _ q => NodeRel.write_frame ne q) sourceNodes targetNodes sourceHandles targetHandles⟩

end Host.Mlx.Ffi.NativeRoles.Live
