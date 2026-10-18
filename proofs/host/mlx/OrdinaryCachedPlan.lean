import host.ts.renameOrdinary.NativeCallCutStates
import host.mlx.ActualKernelCalls

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

noncomputable section

namespace Host.Load.Run.Full.Ordinary.CachedCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

noncomputable def source : Host.Mlx.Ffi.St := P.RestStream.micro0.micro23.s82.ffi.mlx
noncomputable def trace : Trace := ⟨[15252,15253,15254],[15255,15256,15257],[15255,15256,15257]⟩
noncomputable def inputs : List Nat := [22590,10,11]
noncomputable def m0 : List (Nat × Nat) := trace.ins.zip inputs
noncomputable def s0 : Host.Mlx.Ffi.St := source
noncomputable def N0 (i : Nat) : Prop := i ∈ [22590,10,11,15252,15253,15254,15255,15256,15257]
noncomputable def boundary (i : Nat) : Prop := i ∉ trace.order

noncomputable def d1 : Node := (s0.nodes.get 15255).getD ⟨.zeros,[],[],0⟩
noncomputable def s1 : Host.Mlx.Ffi.St := (s0.addNode ⟨.replayed 1354 d1.prim,d1.ins.map (substOf m0),d1.shape,d1.dtype⟩).2
noncomputable def m1 : List (Nat × Nat) := (15255,s0.nnext)::m0
noncomputable def N1 (i : Nat) : Prop := i = s0.nnext ∨ N0 i

noncomputable def d2 : Node := (s1.nodes.get 15256).getD ⟨.zeros,[],[],0⟩
noncomputable def s2 : Host.Mlx.Ffi.St := (s1.addNode ⟨.replayed 1354 d2.prim,d2.ins.map (substOf m1),d2.shape,d2.dtype⟩).2
noncomputable def m2 : List (Nat × Nat) := (15256,s1.nnext)::m1
noncomputable def N2 (i : Nat) : Prop := i = s1.nnext ∨ N1 i

noncomputable def d3 : Node := (s2.nodes.get 15257).getD ⟨.zeros,[],[],0⟩
noncomputable def s3 : Host.Mlx.Ffi.St := (s2.addNode ⟨.replayed 1354 d3.prim,d3.ins.map (substOf m2),d3.shape,d3.dtype⟩).2
noncomputable def m3 : List (Nat × Nat) := (15257,s2.nnext)::m2
noncomputable def N3 (i : Nat) : Prop := i = s2.nnext ∨ N2 i

noncomputable def roles (base : Nat → GraphNode) (i : Nat) : GraphNode :=
  match i with
  | 22591 => (base 15255).capturedReplay 1354 [22590,10,11]
  | 22592 => (base 15256).capturedReplay 1354 [22590,10,11]
  | 22593 => (base 15257).capturedReplay 1354 [22590,10,11]
  | _ => base i

theorem plan2 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode)
    (nodeInjective : ∀ a b, a < 22591 → b < 22591 → R.node a = R.node b → a = b) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 1354
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N2 s2 m2 [15257] N3 s3 m3 := by
  have hn : s2.nodes.get 15257 = some d3 := by rfl
  have live : N2 15257 := by dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15257 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N2 d3.ins := by change listSupport N2 [15252,15253,15254]; dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s2.nnext) m2 := by dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.kernel d3 live full hn (by rfl) ins keys
  · intro nd' hr
    have mapped : nd'.ins.map (substOf (mapSubst R.node m2)) =
        (d3.ins.map (substOf m2)).map R.node := by
      rw [(hr.base.graph.resolve_left full).2]
      exact subst_inputs_map R.node 22591 nodeInjective m2
        (by dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel) d3.ins
        (by change listSupport (· < 22591) [15252,15253,15254]; dsimp [listSupport]; decide +kernel)
    exact hr.captured_replayed full (by rfl) mapped
  · exact .done _ _ _

theorem plan1 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode)
    (nodeInjective : ∀ a b, a < 22591 → b < 22591 → R.node a = R.node b → a = b) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 1354
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N1 s1 m1 [15256,15257] N3 s3 m3 := by
  have hn : s1.nodes.get 15256 = some d2 := by rfl
  have live : N1 15256 := by dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15256 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N1 d2.ins := by change listSupport N1 [15252,15253,15254]; dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s1.nnext) m1 := by dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.kernel d2 live full hn (by rfl) ins keys
  · intro nd' hr
    have mapped : nd'.ins.map (substOf (mapSubst R.node m1)) =
        (d2.ins.map (substOf m1)).map R.node := by
      rw [(hr.base.graph.resolve_left full).2]
      exact subst_inputs_map R.node 22591 nodeInjective m1
        (by dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel) d2.ins
        (by change listSupport (· < 22591) [15252,15253,15254]; dsimp [listSupport]; decide +kernel)
    exact hr.captured_replayed full (by rfl) mapped
  · exact plan2 base nodeInjective

theorem plan0 {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} (base : Nat → GraphNode)
    (nodeInjective : ∀ a b, a < 22591 → b < 22591 → R.node a = R.node b → a = b) :
    ReplayPlan (NumberRoles ν₀ ν C₀ C) R boundary 1354
      (Host.Mlx.Ffi.Annotated.NodeRel (roles base) ν₀ ν C₀ C R boundary)
      N0 s0 m0 [15255,15256,15257] N3 s3 m3 := by
  have hn : s0.nodes.get 15255 = some d1 := by rfl
  have live : N0 15255 := by dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel
  have full : ¬ boundary 15255 := by dsimp [boundary,trace]; decide +kernel
  have ins : listSupport N0 d1.ins := by change listSupport N0 [15252,15253,15254]; dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel
  have keys : listSupport (fun p : Nat × Nat => p.1 < s0.nnext) m0 := by dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel
  apply ReplayPlan.kernel d1 live full hn (by rfl) ins keys
  · intro nd' hr
    have mapped : nd'.ins.map (substOf (mapSubst R.node m0)) =
        (d1.ins.map (substOf m0)).map R.node := by
      rw [(hr.base.graph.resolve_left full).2]
      exact subst_inputs_map R.node 22591 nodeInjective m0
        (by dsimp [listSupport,N0,N1,N2,N3,s0,s1,s2,s3,m0,m1,m2,m3,inputs,trace,source,St.addNode]; decide +kernel) d1.ins
        (by change listSupport (· < 22591) [15252,15253,15254]; dsimp [listSupport]; decide +kernel)
    exact hr.captured_replayed full (by rfl) mapped
  · exact plan1 base nodeInjective

end Host.Load.Run.Full.Ordinary.CachedCall
