import host.mlx.NativeReadback

set_option Elab.async false

namespace Host.Mlx.Ffi.NativeRoles.Live
open Host.Ts Host.Ts.Owned

variable {NR : NumV → NumV → Prop} {R : Ren}
  {NodeRel : Nat → Node → Node → Prop} {ObjRel : Nat → Obj → Obj → Prop}
  {H N : Nat → Prop} {tail : List NumV} {s s' : St}

/-- Input metadata is read from the selected related graph nodes. Failure
cases remain those of the original `shapesOf` function. -/
theorem shapesOf (h : Live NR R NodeRel ObjRel H N tail s s')
    (nodeMeta : ∀ i n n', NodeRel i n n' →
      Parametric.ShapeR NR n.shape n'.shape ∧ n'.dtype = n.dtype) :
    ∀ (ins : List Nat) (inputs : List (List Dim × Nat)),
      listSupport N ins → Ffi.shapesOf s ins = some inputs →
      ∃ inputs', Ffi.shapesOf s' (ins.map R.node) = some inputs' ∧
        ListR (fun a b : List Dim × Nat => Parametric.ShapeR NR a.1 b.1 ∧ b.2 = a.2)
          inputs inputs' := by
  intro ins
  induction ins with
  | nil =>
    intro inputs _ hs
    have he : [] = inputs := Option.some.inj hs
    subst inputs
    exact ⟨[], rfl, .nil⟩
  | cons i ins ih =>
    intro inputs hl hs
    cases hn : s.nodes.get i with
    | none => simp only [Ffi.shapesOf, hn, Option.bind_none] at hs; cases hs
    | some n =>
      obtain ⟨n', hn', hr⟩ := h.node_view hl.1 hn
      cases ht : Ffi.shapesOf s ins with
      | none => simp only [Ffi.shapesOf, hn, Option.bind_some, ht, Option.map_none] at hs; cases hs
      | some rest =>
        have he : (n.shape, n.dtype) :: rest = inputs := by
          exact Option.some.inj (by simpa only [Ffi.shapesOf, hn, Option.bind_some, ht, Option.map_some] using hs)
        subst inputs
        obtain ⟨rest', ht', hr'⟩ := ih rest hl.2 ht
        refine ⟨(n'.shape, n'.dtype) :: rest', ?_, .cons (nodeMeta i n n' hr) hr'⟩
        simp only [List.map_cons, Ffi.shapesOf, hn', Option.bind_some, ht', Option.map_some]

/-- Resolving a live vector of array handles gives the corresponding mapped
producer list. Handle roles are independent of integer-valued numeric data. -/
theorem nodesOf (h : Live NR R NodeRel ObjRel H N tail s s') :
    ∀ (handles nodes : List Nat), listSupport H handles →
      Ffi.nodesOf s handles = some nodes →
      Ffi.nodesOf s' (handles.map R.handle) = some (nodes.map R.node) := by
  intro handles
  induction handles with
  | nil =>
    intro nodes _ hs
    have he : [] = nodes := Option.some.inj hs
    subst nodes
    rfl
  | cons a handles ih =>
    intro nodes hl hs
    cases hn : s.nodeId? a with
    | none => simp only [Ffi.nodesOf, hn, Option.bind_none] at hs; cases hs
    | some i =>
      have hne : a ≠ 0 := by
        intro hz; subst a
        have : (none : Option Nat) = some i := hn
        cases this
      have hk : s.arrs.get a = some i := by
        unfold St.nodeId? at hn
        cases hb : Nat.beq a 0
        · rw [hb] at hn
          exact hn
        · have : a = 0 := Nat.eq_of_beq_eq_true hb
          exact False.elim (hne this)
      have hn' := h.nodeId? a i hl.1 hne hk
      cases ht : Ffi.nodesOf s handles with
      | none => simp only [Ffi.nodesOf, hn, Option.bind_some, ht, Option.map_none] at hs; cases hs
      | some rest =>
        have he : i :: rest = nodes := by
          exact Option.some.inj (by simpa only [Ffi.nodesOf, hn, Option.bind_some, ht, Option.map_some] using hs)
        subst nodes
        have ht' := ih rest hl.2 ht
        simp only [List.map_cons, Ffi.nodesOf, hn', Option.bind_some, ht', Option.map_some]

end Host.Mlx.Ffi.NativeRoles.Live
