import host.mlx.OrdinaryConvCut
import host.mlx.OrdinaryConcatNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.ConvNative
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

noncomputable def primitive : Prim := .conv1d 1 0 1 10240
noncomputable def outputNode : Node := ⟨primitive,[22587,1329],[.lit 1,.lit 1,.lit 10240],12⟩
noncomputable def targetNode (R : Ren) : Node := ⟨primitive,[R.node 22587,R.node 1329],[.lit 1,.lit 1,.lit 10240],12⟩
noncomputable def final : Host.Mlx.Ffi.St := createZero ConvCall.native outputNode

theorem conv_infer : infer primitive [([.lit 1,.lit 4,.lit 10240],12),([.lit 10240,.lit 4,.lit 1],12)] =
    M.pure (some (.node [.lit 1,.lit 1,.lit 10240] 12)) := rfl

theorem call_conv (s : Host.Mlx.Ffi.St) (out stream : Arg) (b off x w i j : Nat)
    (ho : slotOf out = some (b,off,0)) (hx : s.nodeId? x = some i) (hw : s.nodeId? w = some j)
    (hi : shapesOf s [i,j] = some [([.lit 1,.lit 4,.lit 10240],12),([.lit 10240,.lit 4,.lit 1],12)]) :
    Host.Mlx.Ffi.call s chars!"mlx_conv1d" [out,.big (Int.ofNat x),.big (Int.ofNat w),
      .num one,.num zeroN,.num one,.num (.lit (F64.ofInt 10240)),stream] =
    okW (createZero s ⟨primitive,[i,j],[.lit 1,.lit 1,.lit 10240],12⟩) status0 [u64Write b off s.next] := by
  have sy : symOf chars!"mlx_conv1d" = some .conv1d := by decide +kernel
  have a1 : argNat (.num one) = some 1 := by decide +kernel
  have a0 : argNat (.num zeroN) = some 0 := by decide +kernel
  have ag : argNat (.num (.lit (F64.ofInt 10240))) = some 10240 := by decide +kernel
  have ha : arrIns s [.big (Int.ofNat x),.big (Int.ofNat w)] = some [i,j] := by
    simp only [arrIns,List.mapM_cons,List.mapM_nil,argNat_big_nat,Option.bind_some,hx,hw]
    rfl
  unfold Host.Mlx.Ffi.call
  rw [sy]
  simp only [ha,a1,a0,ag]
  exact opOut_node_zero s out b off primitive [i,j] _ _ 12 ho hi conv_infer

theorem source_metadata : shapesOf ConvCall.native [22587,1329] =
    some [([.lit 1,.lit 4,.lit 10240],12),([.lit 10240,.lit 4,.lit 1],12)] := by
  simp only [shapesOf,ConvCall.source_input_node,ConvCall.source_weight_node,ConvCall.source_input_shape,
    ConvCall.source_weight_shape,ConvCall.source_input_dtype,ConvCall.source_weight_dtype,Option.bind_some,Option.map_some]

theorem source_native_call : Host.Mlx.Ffi.call ConvCall.native chars!"mlx_conv1d"
    [.jsPtr 3126867 0 ConvCall.outputBytes,.big (Int.ofNat 29372),.big (Int.ofNat 1365),
      .num one,.num zeroN,.num one,.num (.lit (F64.ofInt 10240)),.big (Int.ofNat 2)] =
    okW final status0 [u64Write 3126867 0 29375] := by
  have hx : ConvCall.native.nodeId? 29372 = some 22587 := by
    simp only [Host.Mlx.Ffi.St.nodeId?,ConvCall.source_array]; rfl
  have hw : ConvCall.native.nodeId? 1365 = some 1329 := by
    simp only [Host.Mlx.Ffi.St.nodeId?,ConvCall.source_weight_array]; rfl
  simpa only [ConvCall.source_counter,final,outputNode] using call_conv ConvCall.native
    (.jsPtr 3126867 0 ConvCall.outputBytes) (.big (Int.ofNat 2)) 3126867 0 29372 1365 22587 1329
    (by rw [ConvCall.source_output_bytes]; rfl) hx hw source_metadata

def weightRoles : Shape := [.literal (.lit (F64.ofInt 10240)),.literal (.lit (F64.ofInt 4)),.literal (.lit (F64.ofInt 1))]

theorem weight_literal : weightRoles.Literal := ⟨⟨_,rfl⟩,⟨⟨_,rfl⟩,⟨⟨_,rfl⟩,True.intro⟩⟩⟩
theorem weight_holds (ν : Nat → F64) (C : CSrv) :
    Shape.Holds ν C weightRoles [.lit 10240,.lit 4,.lit 1] := by
  refine .cons (.literal _ _ rfl ?_) (.cons (.literal _ _ rfl ?_) (.cons (.literal _ _ rfl ?_) .nil))
  all_goals change F64.toInt? (F64.ofInt _) = some _; decide +kernel

def preRoles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  if i = 22587 then {base i with shape := ConcatNative.shapeRoles 4,dtype := 12}
  else if i = 1329 then {base i with shape := weightRoles,dtype := 12} else base i

def outputRole : GraphNode := ⟨ConcatNative.shapeRoles 1,12,some (.conv1d 1 0 1 10240,[22587,1329])⟩
def postRoles (base : Nat → GraphNode) := nodeWrite (preRoles base) 22590 outputRole

theorem created_role (base : Nat → GraphNode) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (boundary : Nat → Prop) :
    NodeRel (postRoles base) ν₀ ν C₀ C R boundary 22590 outputNode (targetNode R) := by
  constructor
  · change outputRole.Holds ν₀ C₀ Owned.Annotated.identity outputNode
    refine ⟨ConcatNative.shape_holds ν₀ C₀ 1 (by decide +kernel),rfl,?_⟩
    intro p ins he
    cases he
    exact ⟨.conv1d 1 0 1 10240,rfl⟩
  · change outputRole.Holds ν C R (targetNode R)
    refine ⟨ConcatNative.shape_holds ν C 1 (by decide +kernel),rfl,?_⟩
    intro p ins he
    cases he
    exact ⟨.conv1d 1 0 1 10240,rfl⟩
  · intro he
    cases he

theorem transport {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (base : Nat → GraphNode) (objects : Nat → Object) (boundary : Nat → Prop)
    {H N : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (preRoles base) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail ConvCall.native target)
    (inputLive : H 29372) (weightLive : H 1365) (nodeBound : target.nnext < 2^64) (handleBound : target.next < 2^64)
    (stream : Arg) :
    Host.Mlx.Ffi.call target chars!"mlx_conv1d"
      [.jsPtr (R.a 3126867) 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),.big (Int.ofNat (R.handle 29372)),
        .big (Int.ofNat (R.handle 1365)),.num one,.num zeroN,.num one,.num (.lit (F64.ofInt 10240)),stream] =
      okW (createZero target (targetNode R)) status0 [u64Write (R.a 3126867) 0 (R.handle 29375)] ∧
    Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (postRoles base) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) (fun a => a = 29375 ∨ H a) (fun i => i = 22590 ∨ N i) tail
      final (createZero target (targetNode R)) := by
  have ix := h.arrLive 29372 22587 inputLive ConvCall.source_array
  have iw := h.arrLive 1365 1329 weightLive ConvCall.source_weight_array
  obtain ⟨x,hx,hrx⟩ := h.node_view ix ConvCall.source_input_node
  obtain ⟨w,hw,hrw⟩ := h.node_view iw ConvCall.source_weight_node
  have hxs : Shape.Holds ν C (ConcatNative.shapeRoles 4) x.shape := by
    simpa only [preRoles,ite_true] using hrx.target.shape
  have hws : Shape.Holds ν C weightRoles w.shape := by
    simpa only [preRoles,ite_eq_right (by decide : 1329 ≠ 22587),ite_true] using hrw.target.shape
  have xshape : x.shape = [.lit 1,.lit 4,.lit 10240] := Shape.literal_unique (ConcatNative.shape_literal 4)
    hxs (ConcatNative.shape_holds ν C 4 (by decide +kernel))
  have wshape : w.shape = [.lit 10240,.lit 4,.lit 1] := Shape.literal_unique weight_literal hws (weight_holds ν C)
  have xdtype : x.dtype = 12 := by simpa only [preRoles,ite_true] using hrx.target.dtype
  have wdtype : w.dtype = 12 := by
    simpa only [preRoles,ite_eq_right (by decide : 1329 ≠ 22587),ite_true] using hrw.target.dtype
  have metadata : shapesOf target [R.node 22587,R.node 1329] =
      some [([.lit 1,.lit 4,.lit 10240],12),([.lit 10240,.lit 4,.lit 1],12)] := by
    simp only [shapesOf,hx,hw,xshape,wshape,xdtype,wdtype,Option.bind_some,Option.map_some]
  have xId := h.nodeId? 29372 22587 inputLive (by decide +kernel) ConvCall.source_array
  have wId := h.nodeId? 1365 1329 weightLive (by decide +kernel) ConvCall.source_weight_array
  have next : target.next = R.handle 29375 := by
    have hh := h.handleMap.head
    rw [ConvCall.source_counter] at hh
    exact hh.symm
  refine ⟨?_,?_⟩
  · simpa only [next,targetNode] using call_conv target
      (.jsPtr (R.a 3126867) 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0)) stream
      (R.a 3126867) 0 (R.handle 29372) (R.handle 1365) (R.node 22587) (R.node 1329) (by rfl) xId wId metadata
  · have created : NodeRel (postRoles base) ν₀ ν C₀ C R boundary ConvCall.native.nnext outputNode (targetNode R) := by
      rw [ConvCall.source_node_counter]
      exact created_role base ν₀ ν C₀ C R boundary
    have preserved := h.createZeroRoles outputNode (targetNode R) created
      (fun i ne _ _ p => NodeRel.write_frame (by simpa only [ConvCall.source_node_counter] using ne) p)
      (by rw [ConvCall.source_node_counter]; decide +kernel) nodeBound
      (by rw [ConvCall.source_counter]; decide +kernel) handleBound
    simpa only [ConvCall.source_counter,ConvCall.source_node_counter,final] using preserved

end Host.Load.Run.Full.Ordinary.ConvNative
