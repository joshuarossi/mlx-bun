import host.sim.extract.Basic
namespace Host.Ts.Sim.ExtractSim
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Extract

/-! # A string read through a binding and two own properties

The read `generation.stats.<key>` of the driver (`Host.Load.Stop.statsField`) is a binding
followed by two own data properties. Under the relation, with the binding's cell fixed by the
map, a string the source reads there is read on the target too. -/

section
variable {FR : Map → Nat → LSt → LSt → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St LSt} {S : SSrv} {C : CSrv}

theorem own2_str_map (h : Rel LF FR M ν K s S t C) {env : Env} {nm : Name} {c : Nat}
    (hl : lookupEnv nm env = some c) (hfa : M.a c = c) (k1 k2 x : List Char)
    (hs : ((bindingOf s env nm).bind fun g => (own s g k1).bind fun w => own s w k2) = some (.str x)) :
    ((bindingOf t env nm).bind fun g => (own t g k1).bind fun w => own t w k2) = some (.str x) := by
  unfold bindingOf at hs ⊢
  rw [hl] at hs ⊢
  simp only [Option.bind_some] at hs ⊢
  cases hc : s.cell? c with
  | none => rw [hc] at hs; cases hs
  | some w =>
    have ht := t_cell h hc
    rw [hfa] at ht
    rw [hc] at hs
    rw [ht]
    cases w with
    | none => cases hs
    | some g =>
      have hg : SV s S.tab.length g := s_cell_supp h hc
      simp only [Option.map_some, Option.bind_some, id] at hs ⊢
      rw [own_map h hg k1]
      cases ho : own s g k1 with
      | none => rw [ho] at hs; cases hs
      | some w' =>
        rw [ho] at hs
        simp only [Option.map_some, Option.bind_some] at hs ⊢
        rw [own_map h (own_supp h ho) k2, hs]
        rfl

end
end Host.Ts.Sim.ExtractSim
