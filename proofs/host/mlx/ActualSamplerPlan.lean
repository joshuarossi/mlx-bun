import host.mlx.ActualShapelessPlan

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Sampler
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

def source : Host.Mlx.Ffi.St := firstChoice.graph
def trace : Trace := ⟨[17766],[17771],[17767,17768,17769,17770,17771]⟩
def inputs : List Nat := [17765]
def m0 : List (Nat × Nat) := trace.ins.zip inputs
def s0 : Host.Mlx.Ffi.St := source
def N0 (i : Nat) : Prop := i ∈ [17765,17766,17767,17768,17769,17770,17771]
def boundary (i : Nat) : Prop := i ∉ trace.order

def d1 : Node := (s0.nodes.get 17767).getD ⟨.zeros,[],[],0⟩
def s1 : Host.Mlx.Ffi.St := (s0.addNode ⟨.replayed 21993 d1.prim,d1.ins.map (substOf m0),(([1,1] : List Int).map Dim.lit),12⟩).2
def m1 : List (Nat × Nat) := (17767,s0.nnext)::m0
def N1 (i : Nat) : Prop := i = s0.nnext ∨ N0 i

def d2 : Node := (s1.nodes.get 17768).getD ⟨.zeros,[],[],0⟩
def s2 : Host.Mlx.Ffi.St := (s1.addNode ⟨.replayed 21993 d2.prim,d2.ins.map (substOf m1),d2.shape,d2.dtype⟩).2
def m2 : List (Nat × Nat) := (17768,s1.nnext)::m1
def N2 (i : Nat) : Prop := i = s1.nnext ∨ N1 i

def d3 : Node := (s2.nodes.get 17769).getD ⟨.zeros,[],[],0⟩
def s3 : Host.Mlx.Ffi.St := (s2.addNode ⟨.replayed 21993 d3.prim,d3.ins.map (substOf m2),d3.shape,d3.dtype⟩).2
def m3 : List (Nat × Nat) := (17769,s2.nnext)::m2
def N3 (i : Nat) : Prop := i = s2.nnext ∨ N2 i

def d4 : Node := (s3.nodes.get 17770).getD ⟨.zeros,[],[],0⟩
def s4 : Host.Mlx.Ffi.St := (s3.addNode ⟨.replayed 21993 d4.prim,d4.ins.map (substOf m3),d4.shape,d4.dtype⟩).2
def m4 : List (Nat × Nat) := (17770,s3.nnext)::m3
def N4 (i : Nat) : Prop := i = s3.nnext ∨ N3 i

def d5 : Node := (s4.nodes.get 17771).getD ⟨.zeros,[],[],0⟩
def s5 : Host.Mlx.Ffi.St := (s4.addNode ⟨.replayed 21993 d5.prim,d5.ins.map (substOf m4),(([1] : List Int).map Dim.lit),3⟩).2
def m5 : List (Nat × Nat) := (17771,s4.nnext)::m4
def N5 (i : Nat) : Prop := i = s4.nnext ∨ N4 i

def roles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  match i with
  | 17765 | 17766 => ⟨closedShape [1,248320],12,none⟩
  | 17767 => ⟨closedShape [1,1],12,some (.logsumexp 1 true,[17766])⟩
  | 17777 => ⟨closedShape [1,1],12,some (.replayed 21993 (.logsumexp 1 true),[17765])⟩
  | 17768 => { base 17768 with shape := closedShape [1,243], dtype := 10 }
  | 17778 => ({ base 17768 with shape := closedShape [1,243], dtype := 10 } : GraphNode).capturedReplay 21993 [17765,17777]
  | 17769 => { base 17769 with shape := closedShape [1,243], dtype := 3 }
  | 17779 => ({ base 17769 with shape := closedShape [1,243], dtype := 3 } : GraphNode).capturedReplay 21993 [17765,17777]
  | 17770 => { base 17770 with shape := closedShape [1], dtype := 3 }
  | 17780 => ({ base 17770 with shape := closedShape [1], dtype := 3 } : GraphNode).capturedReplay 21993 [17778,17779]
  | 17771 => ⟨closedShape [1],3,some (.reshape (closedShape [1]),[17770])⟩
  | 17781 => ⟨closedShape [1],3,some (.replayed 21993 (.reshape (closedShape [1])),[17780])⟩
  | _ => base i

theorem infer_logsumexp : infer (.logsumexp 1 true) (literalMetadata [([1,248320],12)]) =
    M.pure (some (Out.node ([1,1].map Dim.lit) 12)) := by rfl

theorem infer_reshape : infer (.reshape [.lit 1]) (literalMetadata [([1],3)]) =
    M.pure (some (Out.node ([1].map Dim.lit) 3)) := InferenceRoles.reshape_singleton_one 3

theorem plan4 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode)
    (_nodeInjective : ∀ a b, a < 17777 → b < 17777 → R.node a = R.node b → a = b) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 21993
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N4 s4 m4 [17771] N5 s5 m5 := by
  have hn : s4.nodes.get 17771 = some d5 := by rfl
  have live : N4 17771 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 17771 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N4 d5.ins := by change listSupport N4 [17770]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s4.nnext) m4 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N4 (d5.ins.map (substOf m4)) := by change listSupport N4 [17780]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d5 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([1],3)]) (([1] : List Int).map Dim.lit) 3 (by rfl) (by change infer (.reshape [.lit 1]) (literalMetadata [([1],3)]) = _; exact infer_reshape)
  · intro H tail target h nd' metadata' hr _ read
    apply literal_node_transport h 17771 21993 d5 nd' m4 metadata' hr full
      (.reshape (closedShape [1])) [17770] (by rfl) (by
        intro p hp
        cases hp with
        | reshape hs =>
          have he := Shape.literal_unique (closedShape_literal [1]) hs
            (closedShape_holds ν C [1] (by dsimp [listSupport]; decide +kernel))
          rw [he]
          rfl) sub
      (by change listSupport (· < s4.nnext) [17770]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel)
      keys [([1],3)] [1] 3
      (by dsimp [listSupport]; decide +kernel) (by dsimp [listSupport]; decide +kernel)
      (by rfl) (by change inputRoles (roles base) [17780] = _; simp only [inputRoles,List.map_cons,List.map_nil]; change [(((roles base 17780).shape),(roles base 17780).dtype)] = _; simp only [roles,GraphNode.capturedReplay_shape,GraphNode.capturedReplay_dtype]; rfl) (by change infer (.reshape [.lit 1]) (literalMetadata [([1],3)]) = _; exact infer_reshape) (by rfl) read
  · exact .done _ _ _

theorem plan3 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode)
    (_nodeInjective : ∀ a b, a < 17777 → b < 17777 → R.node a = R.node b → a = b) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 21993
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N3 s3 m3 [17770,17771] N5 s5 m5 := by
  have hn : s3.nodes.get 17770 = some d4 := by rfl
  have live : N3 17770 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 17770 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N3 d4.ins := by change listSupport N3 [17768,17769]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s3.nnext) m3 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.kernel d4 live full hn (by rfl) ins keys
  · intro nd' hr
    have mapped : nd'.ins.map (substOf (mapSubst R.node m3)) =
        (d4.ins.map (substOf m3)).map R.node := by
      rw [(hr.base.graph.resolve_left full).2]
      exact subst_inputs_map R.node 17777 _nodeInjective m3
        (by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel) d4.ins
        (by change listSupport (· < 17777) [17768,17769]; dsimp [listSupport]; decide +kernel)
    exact hr.captured_replayed full (by rfl) mapped
  · exact plan4 base _nodeInjective

theorem plan2 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode)
    (_nodeInjective : ∀ a b, a < 17777 → b < 17777 → R.node a = R.node b → a = b) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 21993
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N2 s2 m2 [17769,17770,17771] N5 s5 m5 := by
  have hn : s2.nodes.get 17769 = some d3 := by rfl
  have live : N2 17769 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 17769 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N2 d3.ins := by change listSupport N2 [17766,17767]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s2.nnext) m2 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.kernel d3 live full hn (by rfl) ins keys
  · intro nd' hr
    have mapped : nd'.ins.map (substOf (mapSubst R.node m2)) =
        (d3.ins.map (substOf m2)).map R.node := by
      rw [(hr.base.graph.resolve_left full).2]
      exact subst_inputs_map R.node 17777 _nodeInjective m2
        (by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel) d3.ins
        (by change listSupport (· < 17777) [17766,17767]; dsimp [listSupport]; decide +kernel)
    exact hr.captured_replayed full (by rfl) mapped
  · exact plan3 base _nodeInjective

theorem plan1 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode)
    (_nodeInjective : ∀ a b, a < 17777 → b < 17777 → R.node a = R.node b → a = b) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 21993
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N1 s1 m1 [17768,17769,17770,17771] N5 s5 m5 := by
  have hn : s1.nodes.get 17768 = some d2 := by rfl
  have live : N1 17768 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 17768 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N1 d2.ins := by change listSupport N1 [17766,17767]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s1.nnext) m1 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.kernel d2 live full hn (by rfl) ins keys
  · intro nd' hr
    have mapped : nd'.ins.map (substOf (mapSubst R.node m1)) =
        (d2.ins.map (substOf m1)).map R.node := by
      rw [(hr.base.graph.resolve_left full).2]
      exact subst_inputs_map R.node 17777 _nodeInjective m1
        (by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel) d2.ins
        (by change listSupport (· < 17777) [17766,17767]; dsimp [listSupport]; decide +kernel)
    exact hr.captured_replayed full (by rfl) mapped
  · exact plan2 base _nodeInjective

theorem plan0 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode)
    (_nodeInjective : ∀ a b, a < 17777 → b < 17777 → R.node a = R.node b → a = b) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 21993
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N0 s0 m0 [17767,17768,17769,17770,17771] N5 s5 m5 := by
  have hn : s0.nodes.get 17767 = some d1 := by rfl
  have live : N0 17767 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 17767 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N0 d1.ins := by change listSupport N0 [17766]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s0.nnext) m0 := by dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  have sub : listSupport N0 (d1.ins.map (substOf m0)) := by change listSupport N0 [17765]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.node d1 live full hn (by rfl) (by rfl) (by decide +kernel) ins sub keys
    (literalMetadata [([1,248320],12)]) (([1,1] : List Int).map Dim.lit) 12 (by rfl) (by change infer (.logsumexp 1 true) (literalMetadata [([1,248320],12)]) = _; exact infer_logsumexp)
  · intro H tail target h nd' metadata' hr _ read
    apply literal_node_transport h 17767 21993 d1 nd' m0 metadata' hr full
      (.logsumexp 1 true) [17766] (by rfl) (by intro p hp; cases hp; rfl) sub
      (by change listSupport (· < s0.nnext) [17766]; dsimp [listSupport,N0,N1,N2,N3,N4,N5,s0,s1,s2,s3,s4,s5,m0,m1,m2,m3,m4,m5,inputs,trace,source,St.addNode]; decide +kernel)
      keys [([1,248320],12)] [1,1] 12
      (by dsimp [listSupport]; decide +kernel) (by dsimp [listSupport]; decide +kernel)
      (by rfl) (by rfl) (by change infer (.logsumexp 1 true) (literalMetadata [([1,248320],12)]) = _; exact infer_logsumexp) (by rfl) read
  · exact plan1 base _nodeInjective

end Host.Load.Run.Full.Sampler
