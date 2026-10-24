import host.sim.conv.Call
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage

/-! # Site instances of a stage

A **site instance** of a stage at a call site is the stage template cut at that site with the
caller's own entries kept: its start is the caller's template state at the call with no frames
(`{s with stack := []}`, the caller's frames the target-only stack base), its server the
caller's. Its checked run therefore holds the caller-only heap and native entries as template
entries the stage never touches, and the existing simulation (`Disp.StepSimXLB`) re-establishes
the caller's whole relation after the return, its frames `W`, context `K` and native relation
included (`site_run`): no frame theorem of the interpreter is needed.

* `StageTpl.runB`: a stage template's checked run under a target-only stack base, keeping the
  call's map, valuation and context (`StageTpl.holdsU` with its witnesses kept).
* `RelB.toBase`, `RelB.ofBase`: the caller's frames into, and back out of, the stack base.
* `site_run`: the call by a site instance, from the caller's relation at the call to the caller's
  relation at the instance's return state under the caller's frames.
* `site_kept`: what `StageTpl.HoldsZ` asked, at a site instance: every target entry at the image
  of an unframed template entry the stage leaves (`StageFoot`) is unchanged; `G.site_keptN`
  (`host.sim.conv.NativeMerge`) the same for the native handle tables and readback items
  (`NFrozen`'s `arrs`/`objs`/`items`). At a site instance the caller-only entries are template
  entries, so these are what `HoldsZ`'s frozen clause and `NFrozen` asked; `site_run` needs neither
  (no merge: the caller's relation comes back whole).
* `site_class`: **the projection to the class**: the class template `Tc` (proven once per class:
  contract, graph facts) pulled back into the site instance's start (`Iso`, the conversion
  checks) runs to the same target state in the same number of steps, so its end relation, and
  every fact derived from it, holds at the site's return. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {ok : St F.S → SSrv → Bool}
  {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {stk r : List Frame}

/-- **A stage template's run under a stack base**, keeping the call's map, valuation and context. -/
theorem _root_.Host.Ts.Sim.Stage.StageTpl.runB (T : StageTpl F ok) (hsim : Disp.StepSimXLB F FR ok Kp W r VBOk)
    (hloc : ∀ s S, ok s S = true → Disp.localB s = true) (hK : Kp K) (hν : VBOk ν)
    (h : RelB F FR W r M ν K T.s0 T.S0 t C) :
    ∃ M' t' C', runC F (T.n + 1) t C = some (t', C') ∧ Ext M M' T.S0.tab.length ∧
      RelB F FR W r M' ν K T.s2 T.S2 t' C' := by
  obtain ⟨M1, t1, C1, hr1, he1, hx1⟩ := Disp.runOk_simXVB F FR ok Kp W r VBOk hsim.xv
    (fun s S hs => .inr (hloc s S hs)) ν K hK hν T.n M T.s0 T.S0 t C T.s1 T.S1 (.inl h) T.ok0 T.run
  obtain ⟨M2, t2, C2, ht2, he2, hx2⟩ :=
    hsim M1 ν K T.s1 T.S1 t1 C1 T.s2 T.S2 hK hν hx1 T.halt (.inr (hloc _ _ T.ok1)) T.ok1 T.last
  have hth : isHalt t1.ctl = false := by rw [hx1.isHalt, T.halt]
  exact ⟨M2, t2, C2, runC_trans hr1 (runC_one hth ht2), he1.trans he2 (interpS_runOk_len T.run),
    RelXB.rel_frame' hx2 T.top⟩

/-- The source's frames as part of the target-only stack base. -/
theorem _root_.Host.Ts.Sim.RelB.toBase (h : RelB F FR W stk M ν K s S t C) :
    RelB F FR W (s.stack.map M.frame ++ stk) M ν K { s with stack := [] } S t C :=
  { h with
    stack := by rw [h.stack]; rfl
    stackSupp := fun f hf => nomatch hf }

/-- Frames out of the stack base back onto the source's stack. -/
theorem _root_.Host.Ts.Sim.RelB.ofBase {M' : Map} {s2 t' : St F.S} {S2 : SSrv} {C' : CSrv} {rs : List Frame}
    (h : RelB F FR W (rs.map M.frame ++ stk) M' ν K s2 S2 t' C')
    (hrs : ∀ f ∈ rs, Supp.frame (Present s2) S2.tab.length f) (hag : ∀ f ∈ rs, M'.frame f = M.frame f) :
    RelB F FR W stk M' ν K { s2 with stack := s2.stack ++ rs } S2 t' C' :=
  { h with
    stack := by
      rw [h.stack]
      show s2.stack.map M'.frame ++ (rs.map M.frame ++ stk) = (s2.stack ++ rs).map M'.frame ++ stk
      rw [List.map_append, List.append_assoc, List.map_congr_left hag]
    stackSupp := fun f hf => by
      rcases List.mem_append.1 hf with hf | hf
      · exact h.stackSupp f hf
      · exact hrs f hf }

/-- The start's present addresses stay present at the end (from the template's footprint facts). -/
theorem StageFoot.present {S' : Type} {wr : List Nat} {s0 s2 : St S'} (hf : StageFoot wr s0 s2) {b : Nat}
    (hb : Present s0 b) : Present s2 b := by
  by_cases hw : b ∈ wr
  · exact hf.wrP b hw
  · unfold Present at hb ⊢; rw [hf.same b hw]; exact hb

/-- **The call by a site instance.** The site instance's start is the caller's state at the call with
no frames and the caller's server; its checked run (under the caller's world, frames and
acceptance) takes the caller's relation at the call to the caller's relation at its return state
with the caller's frames back on the stack: the caller-only entries, the frames `W` and the
native relation are re-established by the simulation itself. -/
theorem site_run (T : StageTpl F ok) {wr : List Nat} (hs0 : T.s0 = { s with stack := [] }) (hS0 : T.S0 = S)
    (hsim : ∀ r, Disp.StepSimXLB F FR ok Kp W r VBOk) (hloc : ∀ s S, ok s S = true → Disp.localB s = true)
    (hK : Kp K) (hν : VBOk ν) (hfoot : StageFoot wr T.s0 T.s2) (h : RelB F FR W stk M ν K s S t C) :
    ∃ M' t' C', runC F (T.n + 1) t C = some (t', C') ∧ Ext M M' S.tab.length ∧
      RelB F FR W stk M' ν K { T.s2 with stack := T.s2.stack ++ s.stack } T.S2 t' C' := by
  have h0 : RelB F FR W (s.stack.map M.frame ++ stk) M ν K T.s0 T.S0 t C := by
    rw [hs0, hS0]; exact h.toBase
  obtain ⟨M', t', C', hrun, he, h2⟩ := T.runB (hsim _) hloc hK hν h0
  rw [hS0] at he
  have hlen : S.tab.length ≤ T.S2.tab.length := by
    have := Nat.le_trans (interpS_runOk_len T.run) (interpS_len _ _ _ _ T.last); rw [hS0] at this; exact this
  have hP : ∀ b, Present s b → Present T.s2 b := fun b hb =>
    hfoot.present (by rw [hs0]; exact hb)
  refine ⟨M', t', C', hrun, he, h2.ofBase (fun f hf => Supp.frame_mono hP hlen (h.stackSupp f hf))
    (fun f hf => Map.frame_agree he.agree' (h.stackSupp f hf))⟩

/-- **Frozenness at a site instance** (`StageTpl.HoldsZ`'s frozen part): a target entry at the image of
an unframed template entry the stage leaves is unchanged by the run. -/
theorem site_kept {T : StageTpl F ok} {wr : List Nat} {M' : Map} {t' : St F.S} {C' : CSrv}
    (h0 : RelB F FR W r M ν K T.s0 T.S0 t C) (h2 : RelB F FR W r M' ν K T.s2 T.S2 t' C')
    (he : Ext M M' T.S0.tab.length) (hfoot : StageFoot wr T.s0 T.s2) {a : Nat} (ha : Present T.s0 a)
    (hw : a ∉ wr) (hfr : K.fr a = none) : t'.heap.get (M.a a) = t.heap.get (M.a a) := by
  obtain ⟨o, hg⟩ := Present.get ha
  have hg2 : T.s2.heap.get a = some o := by rw [hfoot.same a hw]; exact hg
  rw [h0.get hg hfr, ← he.a, h2.get hg2 hfr, Map.hobj_agree he.agree' (h0.heapSupp a o hg)]

end

/-! ## As a cut step -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {ok : St F.S → SSrv → Bool}
  {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop} {stk : List Frame} {s : St F.S} {tab : List SymE}
  {Q : SegInst F → Prop}

/-- The relation at a server with another oracle the valuation answers. -/
theorem _root_.Host.Ts.Sim.RelB.withOracle {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv}
    {C : CSrv} {stk : List Frame} (h : RelB F FR W stk M ν K s S t C) {o : List Ans} (hg : Good ν o) :
    RelB F FR W stk M ν K s ⟨S.tab, o⟩ t C :=
  { h with srv := ⟨h.srv.num, hg⟩ }

/-- **A site instance as a cut step**: the caller's cut at the call into the caller's cut at the
instance's return state (the caller's frames back on the stack), `T.n + 1` target steps; the
caller's family `Q'` and bookkeeping `B'` after the call from `hQ`, which sees the caller pair, an
extension of its map on the call's table, its valuation and context, the run, and the relation. (The
decode iteration's ghost: `site_ghost`.) -/
theorem cut_site (T : StageTpl F ok) {wr : List Nat} (hs0 : T.s0 = { s with stack := [] })
    (htab : T.S0.tab = tab) (hsim : ∀ r, Disp.StepSimXLB F FR ok Kp W r VBOk)
    (hloc : ∀ s S, ok s S = true → Disp.localB s = true) (hfoot : StageFoot wr T.s0 T.s2)
    {B Q' B' : SegInst F → Prop}
    (hKν : ∀ c, Q c → B c → Kp c.K ∧ VBOk c.ν) (hg : ∀ c, Q c → B c → Good c.ν T.S0.oracle)
    (hQ : ∀ (c : SegInst F) (M' : Map) (t' : St F.S) (C' : CSrv), Q c → B c →
      Ext c.M M' tab.length → runC F (T.n + 1) c.t c.C = some (t', C') →
      RelB F FR W stk M' c.ν c.K { T.s2 with stack := T.s2.stack ++ s.stack } T.S2 t' C' →
      Q' ⟨M', c.ν, c.K, t', C'⟩ ∧ B' ⟨M', c.ν, c.K, t', C'⟩) :
    Prefill.CutStep ((Prefill.Cut.mk s tab (relB F FR W stk Q)).with B)
      ((Prefill.Cut.mk { T.s2 with stack := T.s2.stack ++ s.stack } T.S2.tab (relB F FR W stk Q')).with B')
      (T.n + 1) := by
  rintro t C ⟨c, rfl, rfl, ⟨hc, hq⟩, hb⟩
  obtain ⟨hK, hν⟩ := hKν c hq hb
  have hc' : RelB F FR W stk c.M c.ν c.K s T.S0 c.t c.C := by
    have := hc.withOracle (hg c hq hb)
    rw [← htab] at this
    exact this
  obtain ⟨M', t', C', hrun, he, h2⟩ := site_run T hs0 rfl hsim hloc hK hν hfoot hc'
  rw [htab] at he
  obtain ⟨hq', hb'⟩ := hQ c M' t' C' hq hb he hrun h2
  exact ⟨t', C', hrun, ⟨M', c.ν, c.K, t', C'⟩, rfl, rfl,
    ⟨h2.withOracle (fun q hq => nomatch hq), hq'⟩, hb'⟩

end

/-! ## The projection to the class template -/

section
variable {F : Ffi} {FR FRc : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {W W0 : Nat → Option WFrame} {ok okc : St F.S → SSrv → Bool}
  {Kpc : Ctx → Prop} {VBc : (Nat → F64) → Prop} {M σ : Map} {ν : Nat → F64} {θ : Nat → SymE} {K : Ctx}
  {t t' : St F.S} {C C' : CSrv} {r : List Frame}

/-- **A site instance projects to its class.** The class template `Tc`'s start held by the site
instance `Ts`'s start under `σ` (`Iso`, no caller frames between them), and the same number of
steps: the site's run to `t'` is the class run, so `Tc`'s end relation holds at `t'` (under the
isolated map, valuation and context), and with it every fact proven once for the class. -/
theorem site_class (Tc : StageTpl F okc) (Ts : StageTpl F ok)
    (hsimc : Disp.StepSimXLB F FRc okc Kpc W0 r VBc) (hlocc : ∀ s S, okc s S = true → Disp.localB s = true)
    (hn : Tc.n = Ts.n)
    (hFS : ∀ x y z, FS σ x y → FR M Ts.S0.tab.length y z → FRc (M.after σ) Tc.S0.tab.length x z)
    (hiso : Iso F FS σ θ K [] Tc.s0 Tc.S0 Ts.s0 Ts.S0)
    (hKc : Kpc (isoCtx K Tc.s0 t)) (hνc : VBc (Shift.valuation θ ν)) (hg : Good (Shift.valuation θ ν) Tc.S0.oracle)
    (hroom : t.next - Tc.s0.next < Sim.bound)
    (h : RelB F FR W r M ν K Ts.s0 Ts.S0 t C) (hrun : runC F (Ts.n + 1) t C = some (t', C')) :
    ∃ M2, Ext (M.after σ) M2 Tc.S0.tab.length ∧
      RelB F FRc W0 r M2 (Shift.valuation θ ν) (isoCtx K Tc.s0 t) Tc.s2 Tc.S2 t' C' := by
  have h0 : RelB F FRc W0 r (M.after σ) (Shift.valuation θ ν) (isoCtx K Tc.s0 t) Tc.s0 Tc.S0 t C := by
    have := isolate (W0 := W0) hFS h hiso hg hroom
    simpa using this
  obtain ⟨M2, t2, C2, hrun2, he, h2⟩ := Tc.runB hsimc hlocc hKc hνc h0
  rw [hn, hrun] at hrun2
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Option.some.inj hrun2)
  exact ⟨M2, he, h2⟩

end

end Host.Ts.Sim.Conv
