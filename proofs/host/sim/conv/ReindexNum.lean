import host.sim.full.RestrictNum

namespace Host.Ts.Sim
open Host.Ts

/-- The old reference's position after inserting an entry at `cut`. -/
def skipNum (cut i : Nat) : Nat := if i < cut then i else i + 1

/-- Remove one source table entry from a map; all nonnumeric names stay the same. -/
def Map.skipNum (M : Map) (cut : Nat) : Map :=
  { M with num := fun i => M.num (Sim.skipNum cut i) }

theorem Map.skipNum_ext (M : Map) (cut : Nat) : Ext M (M.skipNum cut) cut :=
  ⟨rfl, rfl, rfl, rfl, fun i hi => by simp only [Map.skipNum, Sim.skipNum, ite_eq_left hi]⟩

/-- Transfer a server relation along any source-reference reindexing. -/
theorem Srv.reindexNum {M M' : Map} {ν ν' : Nat → F64} {S S' : SSrv} {C : CSrv}
    (h : Srv M ν S C) (ρ : Nat → Nat) (hnum : ∀ i, M'.num i = M.num (ρ i))
    (htab : ∀ i e, nth? S'.tab i = some e →
      ∃ q, nth? S.tab (ρ i) = some q ∧ q.eval ν = e.eval ν')
    (hgood : Good ν' S'.oracle) : Srv M' ν' S' C := by
  refine ⟨fun i e he => ?_, hgood⟩
  obtain ⟨q, hq, hval⟩ := htab i e he
  rw [hnum i, h.num (ρ i) q hq, hval]

/-- Restrict a server after deleting one source table entry. -/
theorem Srv.skipNum {M : Map} {ν ν' : Nat → F64} {S S' : SSrv} {C : CSrv}
    (h : Srv M ν S C) (cut : Nat)
    (htab : ∀ i e, nth? S'.tab i = some e →
      ∃ q, nth? S.tab (Sim.skipNum cut i) = some q ∧ q.eval ν = e.eval ν')
    (hgood : Good ν' S'.oracle) : Srv (M.skipNum cut) ν' S' C :=
  h.reindexNum (Sim.skipNum cut) (fun _ => rfl) htab hgood

namespace Full

/-- Delete a source number entry outside the native closed prefix, including under `FRJ`. -/
theorem fullRXDJ_skipNum {P : LoadP} {NB n k n' cut : Nat} {M : Map} {x y : FF.S}
    (h : Disp.FRJ (FullRXD P NB) M n x y) (hc : NumClosed k x) (hcut : k ≤ cut) (hle : k ≤ n') :
    Disp.FRJ (FullRXD P NB) (M.skipNum cut) n' x y :=
  fullRXDJ_restrictNum h hc ((Map.skipNum_ext M cut).mono hcut) hle

end Full
end Host.Ts.Sim
