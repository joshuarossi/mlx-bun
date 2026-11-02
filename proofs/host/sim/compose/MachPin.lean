import host.sim.compose.MachV
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open _root_.Host.Load _root_.Host.Load.Extract _root_.Host.Load.Program _root_.Host.Load.Run.Full
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph _root_.Host.Ts
open _root_.Host.Mlx.SimGraph.Iter (TplInputs)
open _root_.Host.Mlx.SimGraph.Mach (MRef Vals)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # A decode end's table with its pinned variables read as their values

A decode template can hold dims as variables with one value at every run. `CaseTplAtM` and `CaseFwdAtV` hold for every valuation, so an
end's graph facts are stated at `pinTab pin` of its table, which holds those values as literals. `loopG_ofAtP`: `loopG_ofAtV` from such a
forward, at a template that holds each pinned variable and a valuation that gives it its value. `pin_num`: the graph facts' end, the table's
numbers at a valuation with the pins. -/

/-- A pinned variable as its value. -/
def pinθ (pin : Nat → Option Nat) : Nat → SymE := fun q =>
  match pin q with
  | some k => .lit (F64.ofNat k)
  | none => .var q

/-- A table with its pinned variables read as their values. -/
def pinTab (pin : Nat → Option Nat) (tab : List SymE) : List SymE := tab.map (SymE.subst (pinθ pin))

/-- A valuation with the pins. -/
def pinVal (pin : Nat → Option Nat) (ν : Nat → F64) : Nat → F64 := fun q =>
  match pin q with
  | some k => F64.ofNat k
  | none => ν q

section
variable {pin : Nat → Option Nat} {ν : Nat → F64}

theorem pin_eval (e : SymE) : (e.subst (pinθ pin)).eval ν = e.eval (pinVal pin ν) := by
  rw [SymE.eval_subst]
  congr 1
  funext q
  unfold pinθ pinVal
  cases pin q <;> rfl

theorem pinVal_pin {q k : Nat} (h : pin q = some k) : pinVal pin ν q = F64.ofNat k := by
  unfold pinVal
  rw [h]

theorem pinVal_free {q : Nat} (h : pin q = none) : pinVal pin ν q = ν q := by
  unfold pinVal
  rw [h]

theorem pinVal_self (h : ∀ q k, pin q = some k → ν q = F64.ofNat k) : pinVal pin ν = ν := by
  funext q
  cases hq : pin q with
  | none => exact pinVal_free hq
  | some k => rw [pinVal_pin hq, h q k hq]

theorem nth?_pinTab {l : List SymE} {i : Nat} {e' : SymE} (h : nth? (pinTab pin l) i = some e') :
    ∃ e, nth? l i = some e ∧ e' = e.subst (pinθ pin) := by
  induction l generalizing i with
  | nil => cases h
  | cons a l ih =>
    cases i with
    | zero => exact ⟨a, rfl, (Option.some.inj h).symm⟩
    | succ i => exact ih h

theorem nth?_pinTab_of {l : List SymE} {i : Nat} {e : SymE} (h : nth? l i = some e) :
    nth? (pinTab pin l) i = some (e.subst (pinθ pin)) := by
  induction l generalizing i with
  | nil => cases h
  | cons a l ih =>
    cases i with
    | zero => cases h; rfl
    | succ i => exact ih h

/-- **The numbers of the table** at the valuation with the pins, from those of its pinned form. -/
theorem pin_num {v : Nat → Option F64} {l : List SymE}
    (h : ∀ j e, nth? (pinTab pin l) j = some e → v j = some (e.eval ν)) :
    ∀ j e, nth? l j = some e → v j = some (e.eval (pinVal pin ν)) := fun j e he => by
  rw [h j _ (nth?_pinTab_of he), pin_eval]

end

section
variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey) (Vs : Vals)
  {Wd : World} (pr : GraphProj Wd)
variable {A : Sim.Addr} {P : Wd.Par} {W : Nat → Option Sim.WFrame} {Fr : Sim.LoopFramesA A} {s0 : St Wd.F.S}
  {tab0 : List SymE} {fixA : List Nat} {I : TplInputs} {R : MRef} {L : Nat} {ρ : Nat → F64} {T : Nat}
  {tk : Nat → Nat} {toks : List NumV}

/-- `loopG_ofAtV` from the forward at the pinned table. -/
theorem loopG_ofAtP (pin : Nat → Option Nat) (st : StartGM pr A P s0 tab0 I) {e : Prefill.IterEndW Wd A P s0 tab0 fixA}
    (g : Prefill.GhostP) (en : EndGM I e) (hAt : A.tvar = 9) (hAk : A.kvar = 14) {i : Nat}
    (hpT : ∀ q k, pin q = some k → ∃ j, nth? tab0 j = some (.var q))
    (hpρ : ∀ q k, pin q = some k → 17 < q ∧ ρ q = F64.ofNat k)
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (fwd : CaseFwdAtV M K env Vs pr A I R L e.s1.ffi (pinTab pin e.S1.tab) en.outT en.outs i (pr.NB P)) :
    Prefill.LoopGStepGW (liftG Wd (GxV M K env Vs I R L)) W Fr e g (Sim.valL ρ T tk L) toks i := by
  intro _ nx Mp Kc t Cs n x1 hG hst _ _ hhi hrun hgh hend
  obtain ⟨j0, hj0⟩ := st.htv
  have hVt1 : x1.ν A.tvar = F64.ofNat (L + i + 1) := (hgh.tab j0 _ hj0).trans (by rw [hAt]; rfl)
  have hhi1 : x1.K.hi = Wd.E P := hgh.hi.trans hhi
  have hpin : ∀ q k, pin q = some k → x1.ν q = F64.ofNat k := fun q k hq => by
    obtain ⟨j, hj⟩ := hpT q k hq
    obtain ⟨hq17, hρq⟩ := hpρ q k hq
    have ht := hgh.tab j _ hj
    simp only [SymE.eval] at ht
    rw [ht, ← hρq]
    exact Sim.loopVal_rest q (by omega) (.inr hq17)
  have hE : pinVal pin x1.ν = x1.ν := pinVal_self hpin
  have hnum1 : Sim.NumOK x1.M x1.ν ⟨pinTab pin e.S1.tab, e.S1.oracle⟩ x1.C := fun j e' he' => by
    obtain ⟨e0, he0, rfl⟩ := nth?_pinTab he'
    rw [pin_eval, hE]
    exact hend.srv.num j e0 he0
  have hload : Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) x1.M
      (SSrv.tab ⟨pinTab pin e.S1.tab, e.S1.oracle⟩).length (pr.toLoad e.s1.ffi) (pr.toLoad x1.t.ffi) := by
    show Sim.G.LoadR _ _ _ (pinTab pin e.S1.tab).length _ _
    rw [show (pinTab pin e.S1.tab).length = e.S1.tab.length from List.length_map _]
    exact pr.loadR hend
  exact gstep_coreAtV M K env Vs pr st.hPNL st.hPN0 st.hPE st.hrope R L (Sim.valL ρ T tk L) tk toks i I en.outT en.outs e.s1
    ⟨pinTab pin e.S1.tab, e.S1.oracle⟩ e.σ htk htkb fwd en.read en.fed en.caches st.sread st.pread en.h1read en.h1pread
    st.s0tok en.s1tok st.tokv en.pout en.pouts (by rw [hAk]; rfl) hVt1 hG (pr.loadR hst) hst.srv.num hhi1
    (Sim.runC_le _ _ _ _ _ hrun) hgh.grows
    ⟨hgh.node _ st.carR, hgh.node _ st.carF, cachesAt_congrM fun p hp j hj => hgh.node j (st.carC p hp j hj)⟩
    hload hnum1 hend.bigFixed _ _ _ _ _

end

end Host.Ts.Sim.Compose
