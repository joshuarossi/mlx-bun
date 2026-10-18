import host.mlx.OrdinaryConcatCut
import host.mlx.NativeOutputs
import host.mlx.ReplayObjects
import host.mlx.AnnotatedInference

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def nodeWrite (roles : Nat → GraphNode) (index : Nat) (value : GraphNode) : Nat → GraphNode :=
  fun i => if i = index then value else roles i

theorem NodeRel.write_frame {roles : Nat → GraphNode} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {boundary : Nat → Prop} {slot i : Nat} {value : GraphNode} {x y : Node}
    (ne : i ≠ slot) (h : NodeRel roles ν₀ ν C₀ C R boundary i x y) :
    NodeRel (nodeWrite roles slot value) ν₀ ν C₀ C R boundary i x y := by
  exact ⟨by simpa only [nodeWrite,ite_eq_right ne] using h.source,
    by simpa only [nodeWrite,ite_eq_right ne] using h.target,
    by simpa only [nodeWrite,ite_eq_right ne] using h.cut⟩

end Host.Mlx.Ffi.Annotated

namespace Host.Mlx.Ffi.NativeRoles
open Host.Ts Host.Ts.Owned

theorem Live.withNodes {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel NodeRel' : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s')
    (nodes : ∀ i, N i → OptionR (NodeRel' i) (s.nodes.get i) (s'.nodes.get (R.node i))) :
    Live NR R NodeRel' ObjRel H N tail s s' := {h with nodes := nodes}

theorem Live.createZeroRoles {NR : NumV → NumV → Prop} {R : Ren}
    {NodeRel NodeRel' : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
    {H N : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : Live NR R NodeRel ObjRel H N tail s s') (n n' : Node)
    (created : NodeRel' s.nnext n n')
    (frame : ∀ i, i ≠ s.nnext → ∀ x y, NodeRel i x y → NodeRel' i x y)
    (ns : s.nnext < 2^64) (nt : s'.nnext < 2^64) (hs : s.next < 2^64) (ht : s'.next < 2^64) :
    Live NR R NodeRel' ObjRel (fun a => a = s.next ∨ H a) (fun i => i = s.nnext ∨ N i) tail
      (NativeRoles.createZero s n) (NativeRoles.createZero s' n') := by
  have before : Live NR R NodeRel' ObjRel H N tail s s' := h.withNodes (fun i hi =>
    (h.nodes i hi).mono (frame i (Nat.ne_of_lt (h.liveNodeBound i hi))))
  exact before.createZero n n' created ns nt hs ht

theorem call_concat_axis1 (s : St) (out stream : Arg) (b off vec i j : Nat) (first : Node)
    (hv : s.obj? vec = some (.vec [i,j]))
    (hf : s.nodes.get i = some first) (hshape : len first.shape = 3)
    (ho : slotOf out = some (b,off,0))
    (hi : shapesOf s [i,j] = some [([.lit 1,.lit 3,.lit 10240],12),([.lit 1,.lit 1,.lit 10240],12)]) :
    Ffi.call s chars!"mlx_concatenate_axis" [out,.big (Int.ofNat vec),.num one,stream] =
      okW (createZero s ⟨.concat 1,[i,j],[.lit 1,.lit 4,.lit 10240],12⟩)
        status0 [u64Write b off s.next] := by
  have sy : symOf chars!"mlx_concatenate_axis" = some .concat := by decide +kernel
  have ha : argInt (.num one) = some 1 := by decide +kernel
  have inf : infer (.concat 1) [([.lit 1,.lit 3,.lit 10240],12),([.lit 1,.lit 1,.lit 10240],12)] =
      M.pure (some (.node [.lit 1,.lit 4,.lit 10240] 12)) := rfl
  unfold Ffi.call
  rw [sy]
  simp only [argNat_big_nat,Option.bind_some,hv,ha,hf,hshape]
  exact opOut_node_zero s out b off (.concat 1) [i,j] _ _ 12 ho hi inf

end Host.Mlx.Ffi.NativeRoles

namespace Host.Load.Run.Full.Ordinary.ConcatNative
open Host.Ts Host.Ts.Owned
open Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def shapeRoles (middle : Int) : Shape :=
  [.literal (.lit (F64.ofInt 1)),.literal (.lit (F64.ofInt middle)),.literal (.lit (F64.ofInt 10240))]

theorem shape_literal (middle : Int) : (shapeRoles middle).Literal :=
  ⟨⟨_,rfl⟩,⟨⟨_,rfl⟩,⟨⟨_,rfl⟩,True.intro⟩⟩⟩

theorem shape_holds (ν : Nat → F64) (C : CSrv) (middle : Int)
    (hm : F64.toInt? (F64.ofInt middle) = some middle) :
    Shape.Holds ν C (shapeRoles middle) [.lit 1,.lit middle,.lit 10240] :=
  .cons (.literal _ _ rfl (by change F64.toInt? (F64.ofInt 1) = some 1; decide +kernel))
    (.cons (.literal _ _ rfl hm)
    (.cons (.literal _ _ rfl (by change F64.toInt? (F64.ofInt 10240) = some 10240; decide +kernel)) .nil))

def preRoles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  if i = 20208 then {base i with shape := shapeRoles 3, dtype := 12}
  else if i = 22582 then {base i with shape := shapeRoles 1, dtype := 12} else base i

def outputRole : GraphNode := ⟨shapeRoles 4,12,some (.concat 1,[20208,22582])⟩
def postRoles (base : Nat → GraphNode) : Nat → GraphNode := nodeWrite (preRoles base) 22587 outputRole

noncomputable def outputNode : Node := ⟨.concat 1,[20208,22582],[.lit 1,.lit 4,.lit 10240],12⟩
noncomputable def targetNode (R : Ren) : Node := ⟨.concat 1,[20208,22582].map R.node,[.lit 1,.lit 4,.lit 10240],12⟩
noncomputable def final : Host.Mlx.Ffi.St := createZero ConcatCall.native outputNode

theorem source_metadata : shapesOf ConcatCall.native [20208,22582] =
    some [([.lit 1,.lit 3,.lit 10240],12),([.lit 1,.lit 1,.lit 10240],12)] := by
  simp only [shapesOf,ConcatCall.source_first,ConcatCall.source_second,Option.bind_some,Option.map_some,
    ConcatCall.source_first_shape,ConcatCall.source_second_shape,ConcatCall.source_first_dtype,
    ConcatCall.source_second_dtype]

theorem source_native_call : Host.Mlx.Ffi.call ConcatCall.native chars!"mlx_concatenate_axis"
    [.jsPtr 3126700 0 ConcatCall.actualBytes,.big (Int.ofNat 29371),.num one,.big (Int.ofNat 2)] =
    okW final status0 [u64Write 3126700 0 29372] := by
  simpa only [final,outputNode,ConcatCall.source_counter] using call_concat_axis1 ConcatCall.native
    (.jsPtr 3126700 0 ConcatCall.actualBytes) (.big (Int.ofNat 2)) 3126700 0 29371 20208 22582 ConcatCall.firstNode
    ConcatCall.source_vector ConcatCall.source_first (by rw [ConcatCall.source_first_shape]; rfl)
    (by rw [ConcatCall.source_bytes]; rfl) source_metadata


theorem created_role (base : Nat → GraphNode) (ν₀ ν : Nat → F64) (C₀ C : CSrv)
    (R : Ren) (boundary : Nat → Prop) :
    NodeRel (postRoles base) ν₀ ν C₀ C R boundary 22587 outputNode (targetNode R) := by
  constructor
  · change outputRole.Holds ν₀ C₀ Owned.Annotated.identity outputNode
    refine ⟨shape_holds ν₀ C₀ 4 (by decide +kernel),rfl,?_⟩
    intro p ins he
    cases he
    exact ⟨.concat 1,rfl⟩
  · change outputRole.Holds ν C R (targetNode R)
    refine ⟨shape_holds ν C 4 (by decide +kernel),rfl,?_⟩
    intro p ins he
    cases he
    exact ⟨.concat 1,rfl⟩
  · intro he
    cases he

/-- This fixed-window concatenation derives the target shape inference from
its selected input-node annotations, and records the fresh node's full graph. -/
theorem transport {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (base : Nat → GraphNode) (objects : Nat → Object) (boundary : Nat → Prop)
    {H N : Nat → Prop} {tail : List NumV} {target : Host.Mlx.Ffi.St}
    (h : Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (preRoles base) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) H N tail ConcatCall.native target)
    (vectorLive : H 29371) (firstLive : N 20208) (secondLive : N 22582)
    (nodeBound : target.nnext < 2^64) (handleBound : target.next < 2^64) (stream : Arg) :
    Host.Mlx.Ffi.call target chars!"mlx_concatenate_axis"
        [.jsPtr (R.a 3126700) 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0),
          .big (Int.ofNat (R.handle 29371)),.num one,stream] =
      okW (createZero target (targetNode R)) status0 [u64Write (R.a 3126700) 0 (R.handle 29372)] ∧
    Live (NumberRoles ν₀ ν C₀ C) R (NodeRel (postRoles base) ν₀ ν C₀ C R boundary)
      (ObjectRel objects ν₀ ν C₀ C R) (fun a => a = 29372 ∨ H a)
      (fun i => i = 22587 ∨ N i) tail final (createZero target (targetNode R)) := by
  have weak := h.mono (fun _ _ p => p) (fun _ _ _ p => p.base) (fun _ _ _ p => p.base)
  have hv := weak.vec_view 29371 vectorLive [20208,22582] ConcatCall.source_vector
  obtain ⟨first,hfirst,hrfirst⟩ := h.node_view firstLive ConcatCall.source_first
  obtain ⟨second,hsecond,hrsecond⟩ := h.node_view secondLive ConcatCall.source_second
  have hfs : Shape.Holds ν C (shapeRoles 3) first.shape := by
    simpa only [preRoles,ite_true] using hrfirst.target.shape
  have hss : Shape.Holds ν C (shapeRoles 1) second.shape := by
    simpa only [preRoles,ite_eq_right (by decide : 22582 ≠ 20208),ite_true] using hrsecond.target.shape
  have firstShape : first.shape = [.lit 1,.lit 3,.lit 10240] :=
    Shape.literal_unique (shape_literal 3) hfs (shape_holds ν C 3 (by decide +kernel))
  have secondShape : second.shape = [.lit 1,.lit 1,.lit 10240] :=
    Shape.literal_unique (shape_literal 1) hss (shape_holds ν C 1 (by decide +kernel))
  have firstDtype : first.dtype = 12 := by
    simpa only [preRoles,ite_true] using hrfirst.target.dtype
  have secondDtype : second.dtype = 12 := by
    simpa only [preRoles,ite_eq_right (by decide : 22582 ≠ 20208),ite_true] using hrsecond.target.dtype
  have metadata : shapesOf target ([20208,22582].map R.node) =
      some [([.lit 1,.lit 3,.lit 10240],12),([.lit 1,.lit 1,.lit 10240],12)] := by
    simp only [List.map_cons,List.map_nil,shapesOf,hfirst,hsecond,Option.bind_some,Option.map_some,
      firstShape,secondShape,firstDtype,secondDtype]
  have next : target.next = R.handle 29372 := by
    have hh := h.handleMap.head
    rw [ConcatCall.source_counter] at hh
    exact hh.symm
  refine ⟨?_,?_⟩
  · simpa only [next,List.map_cons,List.map_nil,targetNode] using call_concat_axis1 target
      (.jsPtr (R.a 3126700) 0 (cellParts .u64 (.big (Int.ofNat 0)) 8 0)) stream
      (R.a 3126700) 0 (R.handle 29371) (R.node 20208) (R.node 22582) first hv hfirst
      (by rw [firstShape]; rfl) (by rfl) metadata
  · have created : NodeRel (postRoles base) ν₀ ν C₀ C R boundary ConcatCall.native.nnext
        outputNode (targetNode R) := by
      rw [ConcatCall.source_node_counter]
      exact created_role base ν₀ ν C₀ C R boundary
    have preserved := h.createZeroRoles outputNode (targetNode R) created
      (fun i ne _ _ p => NodeRel.write_frame (by simpa only [ConcatCall.source_node_counter] using ne) p)
      (by rw [ConcatCall.source_node_counter]; decide +kernel) nodeBound
      (by rw [ConcatCall.source_counter]; decide +kernel) handleBound
    simpa only [ConcatCall.source_counter,ConcatCall.source_node_counter,final] using preserved

end Host.Load.Run.Full.Ordinary.ConcatNative
