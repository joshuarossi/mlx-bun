import host.mlx.OrdinarySliceCut
import host.mlx.OrdinaryConcatNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.SliceNative
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

abbrev starts : List Dim := [.lit 0,.lit 1,.lit 0]
abbrev stops : List Dim := [.lit 1,.lit 4,.lit 10240]
abbrev strides : List Dim := [.lit 1,.lit 1,.lit 1]

noncomputable def primitive : Prim := .slice starts stops strides
noncomputable def outputNode : Node := ⟨primitive,[22587],[.lit 1,.lit 3,.lit 10240],12⟩
noncomputable def targetNode (R : Ren) : Node := ⟨primitive,[R.node 22587],[.lit 1,.lit 3,.lit 10240],12⟩
noncomputable def final : Host.Mlx.Ffi.St := createZero SliceCall.native outputNode

theorem start_dims (b off : Nat) : dimsArg (.jsPtr b off SliceCall.startBytes) (.big (Int.ofNat 3)) = some starts := by
  rw [SliceCall.source_start_bytes]; rfl
theorem stop_dims (b off : Nat) : dimsArg (.jsPtr b off SliceCall.stopBytes) (.big (Int.ofNat 3)) = some stops := by
  rw [SliceCall.source_stop_bytes]; rfl
theorem stride_dims (b off : Nat) : dimsArg (.jsPtr b off SliceCall.strideBytes) (.big (Int.ofNat 3)) = some strides := by
  rw [SliceCall.source_stride_bytes]; rfl

theorem slice_infer : infer primitive [([.lit 1,.lit 4,.lit 10240],12)] =
    M.pure (some (.node [.lit 1,.lit 3,.lit 10240] 12)) := rfl

theorem call_slice (s : Host.Mlx.Ffi.St) (out stream : Arg)
    (b off a i st so sp spo sr sro : Nat)
    (ho : slotOf out = some (b,off,0)) (hn : s.nodeId? a = some i)
    (hi : shapesOf s [i] = some [([.lit 1,.lit 4,.lit 10240],12)]) :
    Host.Mlx.Ffi.call s chars!"mlx_slice"
      [out,.big (Int.ofNat a),.jsPtr st so SliceCall.startBytes,.big (Int.ofNat 3),
        .jsPtr sp spo SliceCall.stopBytes,.big (Int.ofNat 3),.jsPtr sr sro SliceCall.strideBytes,.big (Int.ofNat 3),stream] =
      okW (createZero s ⟨primitive,[i],[.lit 1,.lit 3,.lit 10240],12⟩) status0 [u64Write b off s.next] := by
  have sy : symOf chars!"mlx_slice" = some .slice := by decide +kernel
  have ha : arrIns s [.big (Int.ofNat a)] = some [i] := by
    simp only [arrIns,List.mapM_cons,List.mapM_nil,argNat_big_nat,Option.bind_some,hn]
    rfl
  unfold Host.Mlx.Ffi.call
  rw [sy]
  simp only [ha,start_dims,stop_dims,stride_dims]
  exact opOut_node_zero s out b off primitive [i] _ _ 12 ho hi slice_infer

theorem source_metadata : shapesOf SliceCall.native [22587] = some [([.lit 1,.lit 4,.lit 10240],12)] := by
  simp only [shapesOf,SliceCall.source_input_node,SliceCall.source_input_shape,SliceCall.source_input_dtype,
    Option.bind_some,Option.map_some]

theorem source_native_call : Host.Mlx.Ffi.call SliceCall.native chars!"mlx_slice"
    [.jsPtr 3126780 0 SliceCall.outputBytes,.big (Int.ofNat 29372),
      .jsPtr 3126752 0 SliceCall.startBytes,.big (Int.ofNat 3),.jsPtr 3126754 0 SliceCall.stopBytes,.big (Int.ofNat 3),
      .jsPtr 3126768 0 SliceCall.strideBytes,.big (Int.ofNat 3),.big (Int.ofNat 2)] =
    okW final status0 [u64Write 3126780 0 29373] := by
  have hn : SliceCall.native.nodeId? 29372 = some 22587 := by
    simp only [Host.Mlx.Ffi.St.nodeId?,SliceCall.source_array]
    rfl
  simpa only [SliceCall.source_counter,final,outputNode] using call_slice SliceCall.native
    (.jsPtr 3126780 0 SliceCall.outputBytes) (.big (Int.ofNat 2)) 3126780 0 29372 22587
    3126752 0 3126754 0 3126768 0 (by rw [SliceCall.source_output_bytes]; rfl) hn source_metadata

def startRoles : Shape := [.literal (.lit (F64.ofInt 0)),.literal (.lit (F64.ofInt 1)),.literal (.lit (F64.ofInt 0))]
def strideRoles : Shape := [.literal (.lit (F64.ofInt 1)),.literal (.lit (F64.ofInt 1)),.literal (.lit (F64.ofInt 1))]

theorem start_holds (ν : Nat → F64) (C : CSrv) : Shape.Holds ν C startRoles starts := by
  refine .cons (.literal _ _ rfl ?_) (.cons (.literal _ _ rfl ?_) (.cons (.literal _ _ rfl ?_) .nil))
  all_goals change F64.toInt? (F64.ofInt _) = some _; decide +kernel

theorem stride_holds (ν : Nat → F64) (C : CSrv) : Shape.Holds ν C strideRoles strides := by
  refine .cons (.literal _ _ rfl ?_) (.cons (.literal _ _ rfl ?_) (.cons (.literal _ _ rfl ?_) .nil))
  all_goals change F64.toInt? (F64.ofInt _) = some _; decide +kernel

def preRoles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  if i = 22587 then {base i with shape := ConcatNative.shapeRoles 4,dtype := 12} else base i

def outputRole : GraphNode := ⟨ConcatNative.shapeRoles 3,12,
  some (.slice startRoles (ConcatNative.shapeRoles 4) strideRoles,[22587])⟩
def postRoles (base : Nat → GraphNode) := nodeWrite (preRoles base) 22588 outputRole

theorem created_role (base : Nat → GraphNode) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (boundary : Nat → Prop) :
    NodeRel (postRoles base) ν₀ ν C₀ C R boundary 22588 outputNode (targetNode R) := by
  constructor
  · change outputRole.Holds ν₀ C₀ Owned.Annotated.identity outputNode
    refine ⟨ConcatNative.shape_holds ν₀ C₀ 3 (by decide +kernel),rfl,?_⟩
    intro p ins he
    cases he
    exact ⟨.slice (start_holds ν₀ C₀) (ConcatNative.shape_holds ν₀ C₀ 4 (by decide +kernel)) (stride_holds ν₀ C₀),rfl⟩
  · change outputRole.Holds ν C R (targetNode R)
    refine ⟨ConcatNative.shape_holds ν C 3 (by decide +kernel),rfl,?_⟩
    intro p ins he
    cases he
    exact ⟨.slice (start_holds ν C) (ConcatNative.shape_holds ν C 4 (by decide +kernel)) (stride_holds ν C),rfl⟩
  · intro he
    cases he

theorem transport {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (base : Nat → GraphNode) (objects : Nat → Object) (boundary : Nat → Prop)
    {H N : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (preRoles base) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail SliceCall.native target)
    (handleLive : H 29372) (nodeBound : target.nnext < 2^64) (handleBound : target.next < 2^64) (stream : Arg) :
    Host.Mlx.Ffi.call target chars!"mlx_slice"
      [.jsPtr (R.a 3126780) 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),.big (Int.ofNat (R.handle 29372)),
        .jsPtr (R.a 3126752) 0 SliceCall.startBytes,.big (Int.ofNat 3),
        .jsPtr (R.a 3126754) 0 SliceCall.stopBytes,.big (Int.ofNat 3),
        .jsPtr (R.a 3126768) 0 SliceCall.strideBytes,.big (Int.ofNat 3),stream] =
      okW (createZero target (targetNode R)) status0 [u64Write (R.a 3126780) 0 (R.handle 29373)] ∧
    Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (postRoles base) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) (fun a => a = 29373 ∨ H a) (fun i => i = 22588 ∨ N i) tail
      final (createZero target (targetNode R)) := by
  have hi := h.arrLive 29372 22587 handleLive SliceCall.source_array
  obtain ⟨node,hn,hr⟩ := h.node_view hi SliceCall.source_input_node
  have hs : Shape.Holds ν C (ConcatNative.shapeRoles 4) node.shape := by
    simpa only [preRoles,ite_true] using hr.target.shape
  have shape : node.shape = [.lit 1,.lit 4,.lit 10240] := Shape.literal_unique (ConcatNative.shape_literal 4)
    hs (ConcatNative.shape_holds ν C 4 (by decide +kernel))
  have dtype : node.dtype = 12 := by simpa only [preRoles,ite_true] using hr.target.dtype
  have metadata : shapesOf target [R.node 22587] = some [([.lit 1,.lit 4,.lit 10240],12)] := by
    simp only [shapesOf,hn,shape,dtype,Option.bind_some,Option.map_some]
  have nodeId := h.nodeId? 29372 22587 handleLive (by decide +kernel) SliceCall.source_array
  have next : target.next = R.handle 29373 := by
    have hh := h.handleMap.head
    rw [SliceCall.source_counter] at hh
    exact hh.symm
  refine ⟨?_,?_⟩
  · simpa only [next,targetNode] using call_slice target
      (.jsPtr (R.a 3126780) 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0)) stream
      (R.a 3126780) 0 (R.handle 29372) (R.node 22587) (R.a 3126752) 0 (R.a 3126754) 0 (R.a 3126768) 0
      (by rfl) nodeId metadata
  · have created : NodeRel (postRoles base) ν₀ ν C₀ C R boundary SliceCall.native.nnext outputNode (targetNode R) := by
      rw [SliceCall.source_node_counter]
      exact created_role base ν₀ ν C₀ C R boundary
    have preserved := h.createZeroRoles outputNode (targetNode R) created
      (fun i ne _ _ p => NodeRel.write_frame (by simpa only [SliceCall.source_node_counter] using ne) p)
      (by rw [SliceCall.source_node_counter]; decide +kernel) nodeBound
      (by rw [SliceCall.source_counter]; decide +kernel) handleBound
    simpa only [SliceCall.source_counter,SliceCall.source_node_counter,final] using preserved

end Host.Load.Run.Full.Ordinary.SliceNative
