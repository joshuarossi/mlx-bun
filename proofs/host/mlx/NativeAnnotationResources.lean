import host.mlx.NativeAnnotationRebase

set_option Elab.async false

namespace Host.Mlx.Ffi.Annotated
open Host.Ts Host.Ts.Owned

def Primitive.rename (K : Ren) : Primitive → Primitive
  | .data bytes => .data (bytes.map (Owned.Annotated.Byte.rename K))
  | .rope dims tr base scale offset => .rope dims tr (base.rename K) scale offset
  | .kernel k c out => .kernel (K.handle k) c out
  | .replayed cls p => .replayed (K.handle cls) (p.rename K)
  | p => p

/-- Renaming resource annotations composes the actual resource maps; ordinary
numbers, dimension meanings, labels, and dtype codes are unchanged. -/
theorem Primitive.holds_rename {ν : Nat → F64} {C : CSrv}
    (R K : Ren) (r : Primitive) (p : Prim) :
    (r.rename K).Holds ν C R p ↔ r.Holds ν C (Owned.Annotated.composeResources R K) p := by
  induction r generalizing p <;> simp only [Primitive.rename]
  case replayed cls r ih =>
    constructor <;> intro h <;> cases h <;> constructor
    · exact (ih _).mp (by assumption)
    · exact (ih _).mpr (by assumption)
  case data bytes =>
    have hb := list_map_holds (Owned.Annotated.Byte.rename K) (Owned.Annotated.Byte.Holds ν C R)
      (Owned.Annotated.Byte.Holds ν C (Owned.Annotated.composeResources R K))
      (Owned.Annotated.Byte.holds_rename R K) bytes
    constructor <;> intro h <;> cases h <;> constructor
    · exact (hb _).mp (by assumption)
    · exact (hb _).mpr (by assumption)
  all_goals constructor <;> intro h <;> cases h <;> constructor
  all_goals first
    | assumption
    | exact (Owned.Annotated.Tree.holds_rename R K _ _).mp (by assumption)
    | exact (Owned.Annotated.Tree.holds_rename R K _ _).mpr (by assumption)

def GraphNode.rename (K : Ren) (r : GraphNode) : GraphNode :=
  { shape := r.shape, dtype := r.dtype,
    graph := r.graph.map fun (p,ins) => (p.rename K,ins.map K.node) }

theorem GraphNode.holds_rename {ν : Nat → F64} {C : CSrv}
    (R K : Ren) (r : GraphNode) (n : Node) :
    (r.rename K).Holds ν C R n ↔ r.Holds ν C (Owned.Annotated.composeResources R K) n := by
  constructor
  · intro h
    refine ⟨h.shape,h.dtype,?_⟩
    intro p ins hp
    have hm : (r.rename K).graph = some (p.rename K,ins.map K.node) := by
      simp only [GraphNode.rename,hp,Option.map_some]
    have hg := h.graph _ _ hm
    refine ⟨(Primitive.holds_rename R K _ _).mp hg.1,?_⟩
    simpa only [List.map_map,Function.comp_def,Owned.Annotated.composeResources] using hg.2
  · intro h
    refine ⟨h.shape,h.dtype,?_⟩
    intro p ins hp
    cases hg : r.graph with
    | none => simp only [GraphNode.rename,hg,Option.map_none] at hp; cases hp
    | some pair =>
      obtain ⟨p₀,ins₀⟩ := pair
      simp only [GraphNode.rename,hg,Option.map_some,Option.some.injEq,Prod.mk.injEq] at hp
      obtain ⟨rfl,rfl⟩ := hp
      have hh := h.graph _ _ hg
      refine ⟨(Primitive.holds_rename R K _ _).mpr hh.1,?_⟩
      simpa only [List.map_map,Function.comp_def,Owned.Annotated.composeResources] using hh.2

theorem Primitive.rebase {ν : Nat → F64} {C : CSrv}
    (R K : Ren) (θ : Nat → SymE) (r : Primitive) (p : Prim) :
    ((r.rename K).subst θ).Holds ν C R p ↔
      r.Holds (Owned.Annotated.nextValuation θ ν) C (Owned.Annotated.composeResources R K) p := by
  rw [Primitive.holds_subst,Primitive.holds_rename]

theorem GraphNode.rebase {ν : Nat → F64} {C : CSrv}
    (R K : Ren) (θ : Nat → SymE) (r : GraphNode) (n : Node) :
    ((r.rename K).subst θ).Holds ν C R n ↔
      r.Holds (Owned.Annotated.nextValuation θ ν) C (Owned.Annotated.composeResources R K) n := by
  rw [GraphNode.holds_subst,GraphNode.holds_rename]

end Host.Mlx.Ffi.Annotated
