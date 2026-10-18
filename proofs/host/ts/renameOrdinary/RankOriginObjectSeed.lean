import host.ts.renameOrdinary.RankOriginObjectFacts
import host.ts.renameOrdinary.RankOriginInitializedShape

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.ObjectSeed
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

noncomputable def objects : Nat → Object := Initial.objectRoles NativeSeed.native
noncomputable def roots : Nat → Prop := NativeSeed.nodes
noncomputable def roles (i : Nat) : GraphNode :=
  if i < NativeSeed.native.nnext then NativeSeed.roles i else ⟨[],0,some (.zeros,[])⟩

theorem roles_live (i : Nat) (held : NativeSeed.nodes i) : roles i = NativeSeed.roles i :=
  ite_eq_left held

theorem old_graph_none (i : Nat) : (NativeSeed.roles i).graph = none := by
  unfold NativeSeed.roles Geometry.entryRoles
  split
  · rfl
  · unfold Initial.nodeRoles
    split <;> rfl

theorem object_annotation (ν : Nat → F64) (C : CSrv) (i : Nat) (object : Host.Mlx.Ffi.Obj)
    (read : NativeSeed.native.objs.get i = some object) :
    (objects i).Holds ν C identity object :=
  Initial.objectRoles_holds NativeSeed.native source_objects ν C i object read

theorem producer_policy : ProducerAnnotations roots NativeSeed.handles NativeSeed.nodes roles objects := by
  constructor
  · intro i _
    exact Initial.objectRoles_supported NativeSeed.native source_objects i
  · intro i noGraph
    by_cases held : i < NativeSeed.native.nnext
    · exact held
    · simp only [roles,ite_eq_right held] at noGraph
      cases noGraph
  · intro i held primitive inputs graph
    rw [roles_live i held,old_graph_none] at graph
    cases graph

/-- Upgrade the retained initialized equality to fixed indexed object roles.
Every callback/config/vector role and producer dependency is checked against
the actual initialized store. The source store frame is an equality fact;
no target annotation or producer policy is assumed. -/
theorem annotate_live (ν : Nat → F64) (C : CSrv) (s₀ s : LSt)
    (native : InitializedShape.nativeFrame ν C identity s₀ s)
    (sourceObjects : s₀.mlx.objs = NativeSeed.native.objs) :
    Live (NumberRoles ν ν C C) identity (NodeRel roles ν ν C C identity NativeSeed.boundary)
      (ObjectRel objects ν ν C C identity) NativeSeed.handles NativeSeed.nodes [] s₀.mlx s.mlx := by
  refine { native with objs := ?_,nodes := ?_ }
  · intro i held
    have paired := native.objs i held
    cases targetRead : s.mlx.objs.get (identity.handle i) with
    | none =>
      rw [targetRead] at paired
      cases read : s₀.mlx.objs.get i with
      | none => exact .none
      | some object => rw [read] at paired; cases paired
    | some target =>
      rw [targetRead] at paired
      cases read : s₀.mlx.objs.get i with
      | none => rw [read] at paired; cases paired
      | some object =>
        rw [read] at paired
        have same : object = target := by cases paired with | some equal => exact equal
        rw [← same]
        have sourceRead : NativeSeed.native.objs.get i = some object := by
          rw [← sourceObjects]; exact read
        exact .some ⟨object_annotation ν C i object sourceRead,object_annotation ν C i object sourceRead⟩
  · intro i held
    have paired := native.nodes i held
    apply paired.mono
    intro source target relation
    exact ⟨by simpa only [roles_live i held] using relation.source,
      by simpa only [roles_live i held] using relation.target,
      fun _ => True.intro⟩

end Host.Load.Run.Full.Ordinary.RankOrigin.ObjectSeed
