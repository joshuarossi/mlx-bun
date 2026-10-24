import host.load.boot.ane.Check
import host.load.boot.ld.Rel
namespace Host.Load.Run.Prompt
open Host.Ts Host.Load Host.Load.Boot Host.Load.Extract

/-! # The buckets for every prompt and readback suffix

`loadDone`'s state for the prompt `fw` and the unread readbacks `τ` is the template with the prompt array
`promptObj fw` and the load state `Ld.Y τ` (`Ld.frameT`): it agrees with the poisoned template except at the
prompt array, its host and graph are the template's (`aneSp_at`), so its buckets are the template's
(`aneX_any`, by `aneX_tr`; no kernel evaluation with the prompt free). -/

theorem obj_reFfi {S T : Type} (s : St S) (x : T) (a : Nat) : (s.reFfi x).obj? a = s.obj? a := rfl
theorem cell_reFfi {S T : Type} (s : St S) (x : T) (a : Nat) : (s.reFfi x).cell? a = s.cell? a := rfl

theorem obj_setObj_ne {S : Type} (s : St S) (o : Obj) {a : Nat} (ha : a ≠ 2665) : (s.setObj 2665 o).obj? a = s.obj? a := by
  unfold St.obj? St.setObj
  rw [PTrie.get_set_ne _ _ _ (by decide) _ ha]

theorem cell_setObj {S : Type} (s : St S) (o : Obj) (c : Nat) (h : s.cell? 2665 = none) :
    (s.setObj 2665 o).cell? c = s.cell? c := by
  by_cases hc : c = 2665
  · subst hc
    rw [h]
    unfold St.cell? St.setObj
    rw [PTrie.get_set_self _ _ _ (by decide)]
  · unfold St.cell? St.setObj
    rw [PTrie.get_set_ne _ _ _ (by decide) _ hc]

theorem aneSp_at (fw : List Val) (τ : List NumV) : Tr aneSp (P.at2818 fw τ) := by
  rw [Ld.frameT fw τ]
  refine ⟨fun a ha => ?_, fun c => ?_, aneSp_tpl.poison, ?_, ?_, ?_⟩
  · rw [obj_reFfi, obj_setObj_ne _ _ ha]
    unfold aneSp
    rw [obj_setObj_ne _ _ ha]
  · rw [cell_reFfi, cell_setObj _ _ _ ane_tpl_cell]
    unfold aneSp
    rw [cell_setObj _ _ _ ane_tpl_cell]
  · show (Ld.Y τ).host = (Ld.Y []).host
    rw [Ld.Y_host, Ld.Y_host]
  · show (Ld.Y τ).mlx.arrs = (Ld.Y []).mlx.arrs
    rw [Ld.Y_mlx, Ld.Y_mlx]
  · show (Ld.Y τ).mlx.nodes = (Ld.Y []).mlx.nodes
    rw [Ld.Y_mlx, Ld.Y_mlx]

/-- **The Neural Engine buckets at `loadDone` are the template's**, every prompt and readback suffix. -/
theorem aneX_any (fw : List Val) (τ : List NumV) :
    aneX (P.at2818 fw τ) aneModel = aneX (P.at2818 [] []) aneModel := by
  obtain ⟨D, hD, _⟩ := aneSp_check
  rw [aneX_tr (aneSp_at fw τ) aneSp_units hD, aneX_tr aneSp_tpl aneSp_units hD]

end Host.Load.Run.Prompt
