import host.ts.renameOrdinary.RankOriginCacheEntry
import host.mlx.NativeAnnotationPolicy
import host.mlx.NativeKvAppendGeometry
import host.mlx.NativeKvViewGeometry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles
variable (capacityMeaning : SymE)

def fixedDimension (n : Int) : Dimension := .literal (.lit (F64.ofInt n))
def literalCapacityRole : GraphNode :=
  ⟨[fixedDimension 1,fixedDimension 4,fixedDimension 256,fixedDimension 256],12,none⟩
def capacityShape : Shape :=
  [fixedDimension 1,fixedDimension 4,.literal capacityMeaning,fixedDimension 256]
def capacityRole : GraphNode := ⟨capacityShape capacityMeaning,12,none⟩
def cacheRoles (base : Nat → GraphNode) (producer : Nat) : GraphNode :=
  if producer ∈ producers then capacityRole capacityMeaning else base producer

theorem cache_roles_other (base : Nat → GraphNode) (producer : Nat) (unselected : producer ∉ producers) :
    cacheRoles capacityMeaning base producer = base producer := ite_eq_right unselected

theorem initial_role_selected (producer : Nat) (selected : producer ∈ producers) :
    NativeSeed.roles producer = literalCapacityRole := by
  simp only [producers,occurrences,List.map_cons,List.map_nil,List.mem_cons,List.not_mem_nil,or_false] at selected
  rcases selected with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals host_kernel_rfl

private theorem literal_retag {ν : Nat → F64} {C : CSrv} {a b : SymE} {dimension : Dim}
    (same : a.eval ν = b.eval ν) (held : (Dimension.literal a).Holds ν C dimension) :
    (Dimension.literal b).Holds ν C dimension := by
  cases held with
  | literal _ integer value exactInteger =>
    refine .literal b integer ?_ ?_
    · simpa only [NumDenote,same] using value
    · rw [← same]
      exact exactInteger

private theorem capacity_shape_retag {ν : Nat → F64} {C : CSrv} {dimensions : List Dim}
    (capacity : capacityMeaning.eval ν = F64.ofInt 256) (held : Shape.Holds ν C literalCapacityRole.shape dimensions) :
    Shape.Holds ν C (capacityShape capacityMeaning) dimensions := by
  cases held with | cons first rest =>
    cases rest with | cons second rest =>
      cases rest with | cons third rest =>
        cases rest with | cons fourth rest =>
          cases rest
          exact .cons first (.cons second (.cons (literal_retag (by exact capacity.symm) third) (.cons fourth .nil)))

theorem capacity_role_retag {ν : Nat → F64} {C : CSrv} {R : Ren} {node : Node}
    (capacity : capacityMeaning.eval ν = F64.ofInt 256) (held : literalCapacityRole.Holds ν C R node) :
    (capacityRole capacityMeaning).Holds ν C R node := by
  refine ⟨capacity_shape_retag capacityMeaning capacity held.shape,held.dtype,?_⟩
  intro p ins impossible
  cases impossible

theorem cache_roles_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {producer : Nat} {node : Node} {base : Nat → GraphNode}
    (selectedRoles : ∀ producer ∈ producers, base producer = literalCapacityRole)
    (capacity : capacityMeaning.eval ν = F64.ofInt 256) (held : (base producer).Holds ν C R node) :
    (cacheRoles capacityMeaning base producer).Holds ν C R node := by
  by_cases selected : producer ∈ producers
  · rw [cacheRoles,ite_eq_left selected]
    rw [selectedRoles producer selected] at held
    exact capacity_role_retag capacityMeaning capacity held
  · simpa only [cache_roles_other capacityMeaning base producer selected] using held

theorem cache_roles_graph (base : Nat → GraphNode)
    (selectedRoles : ∀ producer ∈ producers, base producer = literalCapacityRole) (producer : Nat) :
    (cacheRoles capacityMeaning base producer).graph = (base producer).graph := by
  by_cases selected : producer ∈ producers
  · rw [cacheRoles,ite_eq_left selected,selectedRoles producer selected]
    rfl
  · rw [cache_roles_other capacityMeaning base producer selected]

/-- Only the checked cache-producer occurrences acquire the capacity role.
All source/target states, resource maps, other graph roles, indexed objects,
tokens, counters and numeric tables are retained from the current relation. -/
theorem annotate_live {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    {base : Nat → GraphNode} {boundary : Nat → Prop} {objects : Nat → Object} {H N : Nat → Prop}
    {tail : List NumV} {source target : Host.Mlx.Ffi.St}
    (selectedRoles : ∀ producer ∈ producers, base producer = literalCapacityRole)
    (held : Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel base ν₀ ν C₀ C R boundary) (ObjectRel objects ν₀ ν C₀ C R)
      H N tail source target)
    (sourceCapacity : capacityMeaning.eval ν₀ = F64.ofInt 256) (targetCapacity : capacityMeaning.eval ν = F64.ofInt 256) :
    Live (NumberRoles ν₀ ν C₀ C) R
      (NodeRel (cacheRoles capacityMeaning base) ν₀ ν C₀ C R boundary) (ObjectRel objects ν₀ ν C₀ C R)
      H N tail source target := by
  refine {held with nodes := ?_}
  intro producer supported
  apply (held.nodes producer supported).mono
  intro sourceNode targetNode relation
  refine ⟨cache_roles_holds capacityMeaning selectedRoles sourceCapacity relation.source,cache_roles_holds capacityMeaning selectedRoles targetCapacity relation.target,?_⟩
  intro noGraph
  exact relation.cut ((cache_roles_graph capacityMeaning base selectedRoles producer).symm.trans noGraph)

theorem annotate_policy {roots H N : Nat → Prop} {base : Nat → GraphNode} {objects : Nat → Object}
    (selectedRoles : ∀ producer ∈ producers, base producer = literalCapacityRole)
    (policy : ProducerAnnotations roots H N base objects) :
    ProducerAnnotations roots H N (cacheRoles capacityMeaning base) objects := by
  refine ⟨policy.objects,?_,?_⟩
  · intro producer noGraph
    exact policy.roots producer ((cache_roles_graph capacityMeaning base selectedRoles producer).symm.trans noGraph)
  · intro producer supported primitive inputs graph
    exact policy.nodes producer supported primitive inputs ((cache_roles_graph capacityMeaning base selectedRoles producer).symm.trans graph)

end Host.Load.Run.Full.Ordinary.RankOrigin.CacheEntry
