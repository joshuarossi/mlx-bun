import host.sim.conv.Site
import host.sim.LoadIter
import host.sim.dispatch.OkLast
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill

/-! # A glue piece of a route chain as a cut step

A route chain's glue piece `k` is a checked run of its template (`tpl_chain`'s `X.runSeg<k>`:
`runOk F ok n s<a> S<a> = some (s<b>, S<b>)`), and, before a call, the one step into the call state
(`X.stepA<k>`). Under the world's one-step simulation (`Disp.StepSimXLB`, e.g. `Full.fullStepSimXLB`)
it takes the caller's cut at its start to the caller's cut at its end (`relB` at the template states,
the pair's predicate and bookkeeping transported by `hQ`):

* `cut_glue`: the segment, ending at `s<b>` (the chain's end or a halt-free state);
* `cut_glueCall`: the segment and the step into the call state `s<c>`.

The segment's start server holds the oracle the run consumes (`hg`); the pair's map extends, its
valuation and context are kept; at its end (`noRetBlock`: not a value returned into a statement-list
frame) the run's relation is `RelB`. `runOk_ok_end`: a checked run's unhalted end is accepted. -/

section
variable {F : Ffi} {ok : St F.S → SSrv → Bool}

/-- **A checked run's unhalted end state is accepted.** -/
theorem runOk_ok_end : ∀ (n : Nat) {s s' : St F.S} {S S' : SSrv}, runOk F ok (n + 1) s S = some (s', S') →
    isHalt s'.ctl = false → ok s' S' = true
  | n, s, s', S, S', h, hh => by
    rw [runOk_succ] at h
    cases hs : isHalt s.ctl
    · simp only [hs, Bool.cond_false] at h
      cases hst : interpS (step F s).run S with
      | none => simp [hst] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hst] at h
        cases hk : ok s1 S1
        · simp [hk] at h
        · simp only [hk, Bool.cond_true, St.rebuild_eq] at h
          cases n with
          | zero =>
            simp only [runOk_zero, Option.some.injEq, Prod.mk.injEq] at h
            obtain ⟨rfl, rfl⟩ := h
            exact hk
          | succ n => exact runOk_ok_end n h hh
    · simp only [hs, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      rw [hs] at hh
      cases hh

end

/-- A state `RelDB` cannot relate: not a value returned into a statement-list frame. -/
def noRetBlock {S : Type} (s : St S) : Bool :=
  match s.ctl, s.stack with
  | .ret _, .s (.block _ _) :: _ => false
  | _, _ => true

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {ok : St F.S → SSrv → Bool}
  {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}

/-- **The checked run's relation is `RelB`** at a state `RelDB` cannot relate. -/
theorem _root_.Host.Ts.Sim.RelXB.rel_noRet {r : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S}
    {S : SSrv} {C : CSrv} (h : RelXB F FR W r M ν K s S t C) (hs : noRetBlock s = true) : RelB F FR W r M ν K s S t C := by
  rcases h with h | ⟨_, _, rs, env, fs, hc, _, hst, _⟩
  · exact h
  · simp [noRetBlock, hc, hst] at hs

/-- **A glue segment as a cut step** (`runOk_simXVB`; see the module doc), into any cut `J` the reached
pair is in (`hQ`). -/
theorem cut_glue (hsim : Disp.StepSimXLB F FR ok Kp W [] VBOk) {sa sb : St F.S} {Sa Sb : SSrv} {n : Nat}
    (hok : ok sa Sa = true) (hrun : runOk F ok n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true) {Q B : SegInst F → Prop} {J : ICut F}
    (hKν : ∀ c, Q c → B c → Kp c.K ∧ VBOk c.ν) (hg : ∀ c, Q c → B c → Good c.ν Sa.oracle)
    (hQ : ∀ (c : SegInst F) (M' : Map) (t' : St F.S) (C' : CSrv), Q c → B c → RelB F FR W [] c.M c.ν c.K sa Sa c.t c.C →
      Ext c.M M' Sa.tab.length → runC F n c.t c.C = some (t', C') → RelB F FR W [] M' c.ν c.K sb Sb t' C' →
      J.R ⟨M', c.ν, c.K, t', C'⟩ J.s0 ⟨J.tab0, []⟩ ∧ J.B ⟨M', c.ν, c.K, t', C'⟩) :
    CutStep ((Cut.mk sa Sa.tab (Conv.relB F FR W [] Q)).with B) J n := by
  rintro t C ⟨c, rfl, rfl, ⟨hc, hq⟩, hb⟩
  obtain ⟨hK, hν⟩ := hKν c hq hb
  have hc' : RelB F FR W [] c.M c.ν c.K sa Sa c.t c.C := hc.withOracle (hg c hq hb)
  obtain ⟨M', t', C', hr, he, hx⟩ := Disp.runOk_simXVB F FR ok Kp W [] VBOk hsim.xv (fun _ _ _ => .inl rfl) c.ν c.K
    hK hν n c.M sa Sa c.t c.C sb Sb (.inl hc') hok hrun
  obtain ⟨hR, hB⟩ := hQ c M' t' C' hq hb hc' he hr (hx.rel_noRet htop)
  exact ⟨t', C', hr, ⟨M', c.ν, c.K, t', C'⟩, rfl, rfl, hR, hB⟩

/-- **A glue segment and the step into the next call as a cut step** (the segment's run, then the
simulation's step from its accepted end; see the module doc), into any cut `J` the reached pair is in. -/
theorem cut_glueCall (hsim : Disp.StepSimXLB F FR ok Kp W [] VBOk) {sa sb sc : St F.S} {Sa Sb Sc : SSrv}
    {n : Nat} (hok : ok sa Sa = true) (hrun : runOk F ok n sa Sa = some (sb, Sb)) (hokb : ok sb Sb = true)
    (hhalt : isHalt sb.ctl = false) (hstep : interpS (step F sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true) {Q B : SegInst F → Prop} {J : ICut F}
    (hKν : ∀ c, Q c → B c → Kp c.K ∧ VBOk c.ν) (hg : ∀ c, Q c → B c → Good c.ν Sa.oracle)
    (hQ : ∀ (c : SegInst F) (M' : Map) (t' : St F.S) (C' : CSrv), Q c → B c → RelB F FR W [] c.M c.ν c.K sa Sa c.t c.C →
      Ext c.M M' Sa.tab.length → runC F (n + 1) c.t c.C = some (t', C') → RelB F FR W [] M' c.ν c.K sc Sc t' C' →
      J.R ⟨M', c.ν, c.K, t', C'⟩ J.s0 ⟨J.tab0, []⟩ ∧ J.B ⟨M', c.ν, c.K, t', C'⟩) :
    CutStep ((Cut.mk sa Sa.tab (Conv.relB F FR W [] Q)).with B) J (n + 1) := by
  rintro t C ⟨c, rfl, rfl, ⟨hc, hq⟩, hb⟩
  obtain ⟨hK, hν⟩ := hKν c hq hb
  have hc' : RelB F FR W [] c.M c.ν c.K sa Sa c.t c.C := hc.withOracle (hg c hq hb)
  obtain ⟨M1, t1, C1, hr1, he1, hx1⟩ := Disp.runOk_simXVB F FR ok Kp W [] VBOk hsim.xv (fun _ _ _ => .inl rfl) c.ν
    c.K hK hν n c.M sa Sa c.t c.C sb Sb (.inl hc') hok hrun
  obtain ⟨M2, t2, C2, ht2, he2, hx2⟩ := hsim M1 c.ν c.K sb Sb t1 C1 sc Sc hK hν hx1 hhalt (.inl rfl) hokb hstep
  have hth : isHalt t1.ctl = false := by rw [hx1.isHalt, hhalt]
  have hr : runC F (n + 1) c.t c.C = some (t2, C2) := runC_trans hr1 (runC_one hth ht2)
  obtain ⟨hR, hB⟩ := hQ c M2 t2 C2 hq hb hc' (he1.trans he2 (interpS_runOk_len hrun)) hr (hx2.rel_noRet htop)
  exact ⟨t2, C2, hr, ⟨M2, c.ν, c.K, t2, C2⟩, rfl, rfl, hR, hB⟩

end

end Host.Ts.Sim.Compose
