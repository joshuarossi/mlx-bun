import host.sim.compose.a4b.SetupEarlyGlueData
import host.sim.full.BigJs
import host.sim.template.a4pre_setup_early_r0.SiteL0
import host.sim.template.a4pre_setup_early_r0.SiteR0
import host.sim.template.a4pre_setup_early_r0.SiteD0
import host.sim.template.a4pre_setup_early_r0.SiteZ0
import host.sim.template.a4pre_setup_early_r0.st0.Tpl
import host.sim.compose.CallLink

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupChunk
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl

kernel_rfl stageOracle : goodLin setup_early.r0.ps (varsOf setup_early.r0.V [(9, .L)])
  PRE_setup_early_r0.st0.S0.oracle = true
kernel_rfl canonicalTable : PRE_setup_early_r0.S6.tab =
  [.var 0, .var 1, .var 2, .var 3, .var 4, .var 5, .var 6, .var 7, .var 8, .var 9]
kernel_rfl bridge5 : bridgeOf PRE_setup_early_r0.s5.ffi = bridgeOf PRE_setup_early_r0.s4.ffi
kernel_rfl bridge6 : bridgeOf PRE_setup_early_r0.s6.ffi = bridgeOf PRE_setup_early_r0.s4.ffi
kernel_rfl sourcePromptEmpty : arrOf PRE_setup_early_r0.s0 2665 = []

/-- Check trie values directly, avoiding a materialized address list. -/
def trieAll {α : Type} (p : α → Bool) : Trie α → Bool
  | .nil => true
  | .node v a b c d => (match v with | none => true | some x => p x) &&
    trieAll p a && trieAll p b && trieAll p c && trieAll p d

theorem trieAll_get {α : Type} {p : α → Bool} : ∀ (t : Trie α) {n : Nat} {x : α},
    trieAll p t = true → t.get n = some x → p x = true
  | .nil, _, _, _, hg => by cases hg
  | .node v a b c d, n, x, hall, hg => by
    simp only [trieAll, Bool.and_eq_true] at hall
    obtain ⟨⟨⟨⟨hv, ha⟩, hb⟩, hc⟩, hd⟩ := hall
    rw [Trie.get_node] at hg
    by_cases hn : n = 0
    · subst hn
      simp only [ite_true] at hg
      rw [hg] at hv
      exact hv
    · simp only [hn, ite_false] at hg
      have hm : n % 4 = 0 ∨ n % 4 = 1 ∨ n % 4 = 2 ∨ n % 4 = 3 := by omega
      rcases hm with hm | hm | hm | hm
      · rw [show Trie.pick (n % 4) a b c d = a by rw [hm]; rfl] at hg
        exact trieAll_get a ha hg
      · rw [show Trie.pick (n % 4) a b c d = b by rw [hm]; rfl] at hg
        exact trieAll_get b hb hg
      · rw [show Trie.pick (n % 4) a b c d = c by rw [hm]; rfl] at hg
        exact trieAll_get c hc hg
      · rw [show Trie.pick (n % 4) a b c d = d by rw [hm]; rfl] at hg
        exact trieAll_get d hd hg

def heapAll (p : HObj → Bool) (h : PTrie HObj) : Bool := trieAll (trieAll (trieAll p)) h.root

theorem heapAll_get {p : HObj → Bool} {h : PTrie HObj} (hall : heapAll p h = true)
    {a : Nat} {o : HObj} (hg : h.get a = some o) : p o = true := by
  rw [Host.Ts.PTrie.get_eq] at hg
  cases h1 : h.root.get (a / 4096) with
  | none => simp [h1, Host.Ts.PTrie.orNil_none] at hg
  | some g =>
    simp only [h1, Host.Ts.PTrie.orNil_some] at hg
    cases h2 : g.get ((a / 64) % 64) with
    | none => simp [h2, Host.Ts.PTrie.orNil_none] at hg
    | some page =>
      simp only [h2, Host.Ts.PTrie.orNil_some] at hg
      exact trieAll_get page (trieAll_get g (trieAll_get h.root hall h1) h2) hg

theorem trieAll_node {α : Type} {p : α → Bool} {v : Option α} {a b c d : Trie α}
    (hv : (match v with | none => true | some x => p x) = true)
    (ha : trieAll p a = true) (hb : trieAll p b = true) (hc : trieAll p c = true) (hd : trieAll p d = true) :
    trieAll p (.node v a b c d) = true := by
  simp only [trieAll, hv, ha, hb, hc, hd, Bool.and_self]

noncomputable def objectCheck (o : HObj) : Bool :=
  (noBigHobjP (fun i => !Conv.oldBigB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) i) o &&
    Conv.noRegHobjB (fun r => !Conv.oldRegB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) r) o) &&
  noBigHobjP (jsShiftBadB PRE_setup_early_r0.kappa0) o


end Host.Ts.Sim.Compose.SetupChunk
