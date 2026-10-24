import host.load.boot.Run
import host.load.boot.Link
import host.load.boot.Ld
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Load Host.Load.Layers Host.Load.Boot

/-! # The prompt boot in the full world, for every unread readback suffix

`P.obRun` checks the boot's chunks in `W` (the load world with the layers' observer) for every prompt
`fw` and unread readback suffix `tail`, so the boot is a run of the full world (`w_full_runS`) from
the booted state with the layers' states fresh (`bootStartF`: `Layers.start`, the empty bridge) to
`ldStT fw tail`: the load world's state at `loadDone` with the bridge of the boot's creates and the
observers' states of the boot's calls. The boot reads no number and no oracle answer (`P.S0_tab`,
`P.S0_oracle`), so at every valuation the concrete run reaches the same state (`boot_full_conc`).
`route_boot`: the route's boot, as `Route.route_final` takes it (`hs`; `hboot`'s run to `loadDone`). -/

set_option maxRecDepth 1000000 in
/-- **The boot in the full world** for every prompt and unread readback suffix. -/
theorem boot_full_tail (fw : List Val) (tail : List NumV) :
    runS full 28172201 (bootStartF (P.at0 fw tail)) P.S0 = some (ldStT fw tail, P.S2818) :=
  w_full_runS 28172201 (obsSt (P.at0 fw tail) P.ob0) P.S0 (obsSt (P.at2818 fw tail) P.ob2818) P.S2818 (P.obRun fw tail)

set_option maxRecDepth 1000000 in
kernel_rfl P.S0_tab : P.S0.tab = Decode.tab
set_option maxRecDepth 1000000 in
kernel_rfl P.S0_oracle : P.S0.oracle = []
set_option maxRecDepth 1000000 in
kernel_rfl P.S2818_tab : P.S2818.tab = Decode.tab

/-- The boot's server instantiates at every valuation: its table is the load's, its oracle empty. -/
theorem boot_inst (ρ : Nat → F64) : Inst ρ P.S0 ⟨Decode.tab.map (SymE.eval ρ)⟩ :=
  ⟨by rw [P.S0_tab], by rw [P.S0_oracle]; intro q hq; cases hq⟩

set_option maxRecDepth 1000000 in
/-- **The concrete boot run**: at every valuation `ρ` of the load's table, the full world's concrete run
of the boot reaches `ldStT fw tail` with the load's table instantiated at `ρ`. -/
theorem boot_full_conc (fw : List Val) (tail : List NumV) (ρ : Nat → F64) :
    runC full 28172201 (bootStartF (P.at0 fw tail)) ⟨Decode.tab.map (SymE.eval ρ)⟩ =
      some (ldStT fw tail, ⟨Decode.tab.map (SymE.eval ρ)⟩) := by
  obtain ⟨C', h1, h2⟩ := run_sim full ρ 28172201 _ _ _ _ _ (boot_inst ρ) (boot_full_tail fw tail)
  have hC : C' = ⟨Decode.tab.map (SymE.eval ρ)⟩ := by
    cases C' with
    | mk t =>
      have h := h2.1
      rw [P.S2818_tab] at h
      exact congrArg CSrv.mk h
  subst hC
  exact h1

/-- **The route's boot** (`Route.route_final`'s `s`, `hs` and `hboot`'s run): booting the prompt route for
`π` in the world with the native readbacks `.ref 1, .ref 2, τ` (`worldTail τ`; the route's
`routeWorld T tk` is `worldTail (machReads T tk)`) reaches `P.at0 (π.map natV) τ`, and the full world's
concrete run from its layers' initial states, at any valuation `ρ` (the route's `machVal T tk`), reaches
`loadDone` (`ldStT`). -/
theorem route_boot (π : List Nat) (τ : List NumV) (ρ : Nat → F64) :
    bootL (RoutePrompt.cx π) (Run.Tail.worldTail τ) 2000 = some (P.at0 (π.map natV) τ) ∧
      runC full 28172201 (bootStartF (P.at0 (π.map natV) τ)) ⟨Decode.tab.map (SymE.eval ρ)⟩ =
        some (ldStT (π.map natV) τ, ⟨Decode.tab.map (SymE.eval ρ)⟩) :=
  ⟨boot_tail (π.map natV) τ, boot_full_conc (π.map natV) τ ρ⟩

/-! ## The original world's instance -/

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager P.at0_base : ∀ fw : List Val, P.at0 fw P.tokenBase = P.a0 fw
set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager P.at2818_base : ∀ fw : List Val, P.at2818 fw P.tokenBase = P.a2818 fw

end Host.Load.Run.Prompt
