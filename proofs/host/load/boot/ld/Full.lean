import host.load.boot.ld.Rel
import host.load.boot.Ld
import host.load.boot.FullR
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Layers Host.Load.Boot Host.Ts.Sim.Full
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The relation at `loadDone` in the full world across readback suffixes

`Ld.rel_full`: the full world's template at `loadDone` (`ldStT [] []`) and the target for the prompt `fw`
and the unread readback suffix `τ` (`ldStT fw τ`) are related (`Rel full`, the prompt array framed)
under the full world's native relation with the remaining readbacks `τ` (`FLR P0 NB τ`, A1's
`Full.fullWorld`'s): its load-world part is `Ld.loadR`, the bridge is the boot's on both sides and
inactive, the layers' states are the boot's on both sides and no trace is pending (`Ld.fullR`). -/

/-- `Rel` for states with other native states, given the native relation of those. -/
theorem Rel.reFfi {F F' : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {FR' : Map → Nat → F'.S → F'.S → Prop}
    {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {x y : F'.S}
    (h : Rel F FR M ν K s S t C) (hffi : FR' M S.tab.length x y) : Rel F' FR' M ν K (s.reFfi x) S (t.reFfi y) C :=
  ⟨h.srv, h.heap, h.next, h.offset, h.room, h.bigFixed, h.bigExt, h.band, h.intr, h.bound, h.inj, h.presentBound,
    h.framedPresent, h.ctl, h.stack, h.jobs, h.stores, hffi, h.trace, h.heapSupp, h.ctlSupp, h.stackSupp, h.jobsSupp,
    h.storesSupp, h.traceSupp⟩

kernel_rfl Ld.objs_ld : Ld.X0.objs = ldMlx.objs
kernel_rfl Ld.next_ld : Ld.X0.next = ldMlx.next

theorem Ld.freedR (τ : List NumV) : FreedR Map.id Ld.X0 (Ld.Yn τ) P.obfr2818 P.obfr2818 :=
  ⟨fun h hh => by rw [Ld.objs_ld]; exact freedR_ld.obj h hh, fun _ _ => by rw [Map.handle_id],
    fun h hh => by show h < Ld.X0.next; rw [Ld.next_ld]; exact freedR_ld.lt h hh⟩

theorem Ld.krecR (n : Nat) (τ : List NumV) : KRecR Map.id n Ld.X0 (Ld.Yn τ) P.obkr2818 P.obkr2818 :=
  have k := krecR_ld n
  { flagsObj := fun h hh => by rw [Ld.objs_ld]; exact k.flagsObj h hh
    targsObj := fun h hh => by rw [Ld.objs_ld]; exact k.targsObj h hh
    flags := fun h _ => by rw [Map.handle_id]
    targs := fun h hh => k.targs h (by rw [← Ld.objs_ld]; exact hh)
    flagsLt := fun h hh => by show h < Ld.X0.next; rw [Ld.next_ld]; exact k.flagsLt h hh
    targsLt := fun h hh => by show h < Ld.X0.next; rw [Ld.next_ld]; exact k.targsLt h hh
    cl := k.cl }

/-- **The full world's native relation at `loadDone`**, for every unread readback suffix. -/
theorem Ld.fullR (P0 : LoadP) (NB : Nat) (hlo : 0 < P0.lo ∧ P0.lo ≤ 18151) (hE : 18151 ≤ P0.E ∧ P0.E < 2 ^ 46)
    (hN : P0.NL = 15235 ∧ P0.N0 = 15235) (hNE : 15235 ≤ P0.NE ∧ P0.NE < 2 ^ 61) (hNB : NB ≤ P0.NL) (τ : List NumV) :
    FLR P0 NB τ Map.id Ld.S0.tab.length (toFull (Ld.Xl, P.ob2818)) (toFull (Ld.Y τ, P.ob2818)) where
  load := Ld.loadR P0 NB hlo hE hN hNE hNB τ
  bridge := ⟨rfl, replay_active _⟩
  live := fun fx hx => by
    have e : fx = P.obfr2818 := (Option.some.inj hx).symm
    refine ⟨fx, hx, ?_⟩
    rw [e]
    show FreedR Map.id Ld.X0 (Ld.Y τ).mlx P.obfr2818 P.obfr2818
    rw [Ld.Y_mlx]; exact Ld.freedR τ
  kern := fun kx hx => by
    have e : kx = P.obkr2818 := (Option.some.inj hx).symm
    refine ⟨kx, hx, ?_⟩
    rw [e]
    show KRecR Map.id Ld.S0.tab.length Ld.X0 (Ld.Y τ).mlx P.obkr2818 P.obkr2818
    rw [Ld.Y_mlx]; exact Ld.krecR _ τ
  pend := by
    show G.PendReg Map.id Ld.X0 (Ld.Y τ).mlx
    rw [Ld.Y_mlx]
    exact ⟨fun p hp => (by rw [Ld.pending_val] at hp; cases hp), fun _ _ => rfl⟩

theorem Ld.ldStT_tpl : ldStT [] [] = (P.at2818 [] []).reFfi (toFull (Ld.Xl, P.ob2818)) := rfl

theorem Ld.ldStT_tgt (fw : List Val) (τ : List NumV) :
    ldStT fw τ = ((P.at2818 [] []).setObj 2665 (promptObj fw)).reFfi (toFull (Ld.Y τ, P.ob2818)) := by
  unfold ldStT
  rw [Ld.frameT fw τ]
  rfl

/-- **The relation at `loadDone` in the full world**, under A1's `FLR` at the remaining readbacks `τ`. -/
theorem Ld.rel_full (P0 : LoadP) (NB : Nat) (hlo : 0 < P0.lo ∧ P0.lo ≤ 18151) (hE : 18151 ≤ P0.E ∧ P0.E < 2 ^ 46)
    (hN : P0.NL = 15235 ∧ P0.N0 = 15235) (hNE : 15235 ≤ P0.NE ∧ P0.NE < 2 ^ 61) (hNB : NB ≤ P0.NL)
    (ρ : Nat → F64) (lo hi : Nat) (hhi : hi ≤ 2 ^ 56) (fw : List Val) (τ : List NumV) :
    Rel full (FLR P0 NB τ) Map.id ρ (FrameRel.ctx (ldStT [] []) 2665 fw lo hi) (ldStT [] []) P.S2818 (ldStT fw τ)
      ⟨P.S2818.tab.map (SymE.eval ρ)⟩ := by
  have h := Ld.rel_load P0 NB hlo hE hN hNE hNB ρ lo hi hhi fw τ
  rw [Ld.frameT fw τ] at h
  rw [Ld.ldStT_tpl, Ld.ldStT_tgt]
  exact Rel.reFfi h (Ld.fullR P0 NB hlo hE hN hNE hNB τ)

end Host.Load.Run.Prompt
