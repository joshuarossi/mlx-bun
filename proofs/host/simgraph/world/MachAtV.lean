import host.simgraph.world.MachV

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Mlx.SimGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Host.Mlx.SimGraph.Iter (Gr TplInputs cachesAt cacheAt CachesBelow cachesAt_comp cachesAt_below
  mem_of_length_le_one mem_of_length_le_two)
open Host.Mlx.SimGraph.Mach (MRef CacheValuesV)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey) (Vs : Mach.Vals)
section Steps
variable {Wd : Sim.World} (pr : GraphProj Wd) {A : Sim.Addr} {P : Wd.Par}
  {s0 : St Wd.F.S} {tab0 : List SymE}

/-- A case forward obligation at the fixed prefix selected by its world. -/
def CaseFwdAtV (A : Sim.Addr) (I : TplInputs) (R : MRef) (L : Nat) (s1 : Wd.F.S) (S1tab : List SymE) (outT : Nat)
    (outs : List (Option Nat × Option Nat)) (i NB : Nat) : Prop :=
  ∀ (tab : List F64) (P' : Sim.LoadP) (Mp : Sim.Map) (n : Nat) (y : Wd.F.S) (ν : Nat → F64),
    Sim.G.LoadR P' NB Mp n (pr.toLoad s1) (pr.toLoad y) → P'.NL = A.NL → P'.N0 = A.N0 →
    ν A.tvar = F64.ofNat (L + i + 1) →
    (∀ j e, nth? S1tab j = some e → CSrv.val ⟨tab⟩ (Mp.nv (.ref j)) = some (e.eval ν)) →
    Mp.big (A.rope : Int) = (A.rope : Int) →
    ∀ tok hs tok' hs', R tab (L + i + 1) = some (tok, hs) → R tab (L + i + 2) = some (tok', hs') → tok < 2 ^ 31 →
      CapsFor (Sim.capL (L + i + 1)) (stageWeights (weights (firstValues M K env tab))) hs →
      CacheValuesV (Vs.val tab (Wd.toMlx y)) (cachesAt Mp.node I.caches) hs →
      (∃ r, Vs.val tab (Wd.toMlx y) (Mp.node I.fed) = some r ∧ itemUint32 r = some tok) →
      (∀ t ∈ parameterTensors parameterChoice,
        Vs.val tab (Wd.toMlx y) t.node = some (firstValues M K env tab t)) →
      (∃ r, Vs.val tab (Wd.toMlx y) (Mp.node outT) = some r ∧ itemUint32 r = some tok') ∧
        CacheValuesV (Vs.val tab (Wd.toMlx y)) (cachesAt Mp.node outs) hs' ∧
        CapsFor (Sim.capL (L + i + 2)) (stageWeights (weights (firstValues M K env tab))) hs'

/-- The graph step only uses the world's selected fixed prefix. -/
theorem gstep_coreAtV (hPNL : ∀ r, (pr.lp P r).NL = A.NL) (hPN0 : ∀ r, (pr.lp P r).N0 = A.N0)
    (hPE : Wd.E P ≤ A.rope) (hrope : A.rope < 2 ^ 56)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (toks : List NumV) (i : Nat) (I : TplInputs)
    (outT : Nat) (outs : List (Option Nat × Option Nat)) (s1 : St Wd.F.S) (S1 : SSrv) (σc : Sim.Map)
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (fwd : CaseFwdAtV M K env Vs pr A I R L s1.ffi S1.tab outT outs i (pr.NB P))
    (hread : σc.node I.read = I.fed) (hfed : σc.node I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map σc.node, p.2.map σc.node)) = outs)
    (hsread : (Wd.toMlx s0.ffi).items.get I.read = none)
    (hpread : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (h1read : (Wd.toMlx s1.ffi).items.get I.read = some (.ref A.tok))
    (h1pread : ((Wd.toMlx s1.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hs1tok : (Wd.toMlx s1.ffi).tokens = [])
    (htokv : nth? tab0 A.tok = some (.var A.kvar))
    (hpout : ((Wd.toMlx s1.ffi).nodes.get outT).isSome = true)
    (hpouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → ((Wd.toMlx s1.ffi).nodes.get j).isSome = true)
    {nx : Nat} (hVk : V i nx A.kvar = F64.ofNat (tk (i + 1))) {ν1 : Nat → F64}
    (hVt1 : ν1 A.tvar = F64.ofNat (L + i + 1))
    {Mp M1 : Sim.Map} {Kc : Sim.Ctx} {t t1 : St Wd.F.S} {Cs C1 : CSrv}
    (hG : GxV M K env Vs I R L i Mp (Wd.toMlx t.ffi) Cs)
    (hst : Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) Mp tab0.length (pr.toLoad s0.ffi) (pr.toLoad t.ffi))
    (hnum0 : Sim.NumOK Mp (V i nx) ⟨tab0, []⟩ Cs) (hhi : Kc.hi = Wd.E P) (hle : Sim.CSrv.Le Cs C1)
    (fr : Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx t1.ffi))
    (hcar : M1.node I.read = Mp.node I.read ∧ M1.node I.fed = Mp.node I.fed ∧
      cachesAt M1.node I.caches = cachesAt Mp.node I.caches)
    (hend : Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) M1 S1.tab.length (pr.toLoad s1.ffi) (pr.toLoad t1.ffi))
    (hnum1 : Sim.NumOK M1 ν1 S1 C1) (hbig : ∀ j, Sim.BigFixed Kc.lo Kc.hi j → M1.big j = j)
    (n : Nat) (v : NumV) (a b d : Nat) :
    GxV M K env Vs I R L (i + 1) (((M1.setNum n v).after σc).rebig a b d) (Wd.toMlx t1.ffi) C1 := by
  intro tab hle1
  have hle0 : Sim.CSrv.Le Cs ⟨tab⟩ := hle.trans hle1
  obtain ⟨hcr, hcf, hcc⟩ := hcar
  have hG1 : GIMV M K env Vs I R L tab i M1.node (Wd.toMlx t.ffi) := (hG tab hle0).congr M K env Vs hcr hcf hcc
  have hgrow := fr
  have mr0 : Sim.G.MR (pr.lp P (toks.drop i)) (pr.NB P) Mp tab0.length (Wd.toMlx s0.ffi) (Wd.toMlx t.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hst.mlx
  have mr1 : Sim.G.MR (pr.lp P (toks.drop i)) (pr.NB P) M1 S1.tab.length (Wd.toMlx s1.ffi) (Wd.toMlx t1.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hend.mlx
  obtain ⟨tok, hs, hR1, htok, hcv, hcaps, hfedlt, hcb⟩ := hG1.cur
  obtain ⟨hs1', hR1'⟩ := htk tab (i + 1) (by omega)
  have etok : tok = tk (i + 1 + 1) := (Prod.mk.inj (Option.some.inj (hR1.symm.trans hR1'))).1
  obtain ⟨hs2, hR2⟩ := htk tab (i + 2) (by omega)
  have hcv1 : CacheValuesV (Vs.val tab (Wd.toMlx t1.ffi)) (cachesAt M1.node I.caches) hs :=
    hcv.mono fun c hc v hv u hu => Vs.val_grow hG1.ok hgrow _ _ (hcb c hc v hv) hu
  have hprev1 : ∃ r, Vs.val tab (Wd.toMlx t1.ffi) (M1.node I.fed) = some r ∧ itemUint32 r = some tok := by
    obtain ⟨r, hr, hi⟩ := htok
    exact ⟨r, Vs.val_grow hG1.ok hgrow _ _ hfedlt hr, hi⟩
  have hpar1 : ∀ t ∈ parameterTensors parameterChoice,
      Vs.val tab (Wd.toMlx t1.ffi) t.node = some (firstValues M K env tab t) := fun t ht =>
    Vs.val_grow hG1.ok hgrow _ _ (hG1.params t ht).2 (hG1.params t ht).1
  have hnum : ∀ j e, nth? S1.tab j = some e → CSrv.val ⟨tab⟩ (M1.nv (.ref j)) = some (e.eval ν1) :=
    fun j e he => hle1.val (hnum1 j e he)
  have hrope1 : M1.big (A.rope : Int) = (A.rope : Int) :=
    hbig _ (.inr (.inr ⟨by rw [hhi]; omega, by omega⟩))
  obtain ⟨hout, hcvn, hcapn⟩ := fwd tab _ M1 _ t1.ffi _ hend (hPNL _) (hPN0 _) hVt1 hnum hrope1 tok hs _ hs2 hR1
    hR2 (by rw [etok]; exact htkb (i + 1) (by omega)) hcaps hcv1 hprev1 hpar1
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped = [Mp.nv (.ref A.tok)] := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hs1tok] at hpe
    exact (List.append_left_inj _).mp hpe.symm
  subst hpop
  have hplen : ks.length ≤ 1 := hks
  have hslot1 : (Wd.toMlx t1.ffi).items.get (M1.node I.read) = some (M1.nv (.ref A.tok)) := by
    rw [mr1.items I.read h1pread, h1read]; rfl
  have hslot0 : (Wd.toMlx t.ffi).items.get (M1.node I.read) = none := by
    rw [hcr, mr0.items I.read hpread, hsread]; rfl
  have hks1 : M1.node I.read ∈ ks := by
    rcases hnewk _ _ hslot1 with h | ⟨_, h, _⟩
    · rw [hslot0] at h; cases h
    · exact h
  have hval : CSrv.val ⟨tab⟩ (Mp.nv (.ref A.tok)) = some (F64.ofNat (tk (i + 1))) := by
    show CSrv.val ⟨tab⟩ (Mp.num A.tok) = _
    rw [hle0.val (hnum0 A.tok _ htokv)]
    show some (V i nx A.kvar) = _
    rw [hVk]
  obtain ⟨hs0', hR0⟩ := htk tab i (by omega)
  exact gi_nextV M K env Vs I R L tab i M1.node σc.node (Wd.toMlx t.ffi) (Wd.toMlx t1.ffi) outT outs hG1 hgrow fr.nnext
    (fun k v hk => by
      rcases hnewk k v hk with h | ⟨hx, hk', hv⟩
      · exact .inl h
      · refine .inr ⟨hx, mem_of_length_le_one hplen hks1 hk', tk (i + 1), ⟨hs0', hR0⟩, htkb i (by omega), ?_⟩
        rw [List.mem_singleton] at hv
        rw [hv]
        exact hval)
    mr1.yitems ⟨_, hs2, hR2, hout, hcvn, hcapn⟩ (mr1.nimg outT hpout)
    (cachesAt_below _ _ _ fun p hp j hj => mr1.nimg j (hpouts p hp j hj)) hread hfed hcaches

/-- The same graph step through the existing compaction chain. -/
theorem gstep_ofGAtV (hPNL : ∀ r, (pr.lp P r).NL = A.NL) (hPN0 : ∀ r, (pr.lp P r).N0 = A.N0)
    (hPE : Wd.E P ≤ A.rope) (hrope : A.rope < 2 ^ 56) {fixA : List Nat} {W : Nat → Option Sim.WFrame}
    {Fr : Sim.LoopFramesA A} (e : Sim.Prefill.IterEndW Wd A P s0 tab0 fixA) (g : Sim.Prefill.GhostP)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (toks : List NumV) (i : Nat) (I : TplInputs)
    (outT : Nat) (outs : List (Option Nat × Option Nat))
    (htk : ∀ tab j, j ≤ i + 2 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ i + 2 → tk (j + 1) < 2 ^ 31)
    (hVt : ∀ nx, V i nx A.tvar = F64.ofNat (L + i + 1)) (hVk : ∀ nx, V i nx A.kvar = F64.ofNat (tk (i + 1)))
    (htv : ∃ j, nth? tab0 j = some (.var A.tvar))
    (hcarR : I.read < (Wd.toMlx s0.ffi).nnext) (hcarF : I.fed < (Wd.toMlx s0.ffi).nnext)
    (hcarC : ∀ p ∈ I.caches, ∀ j, (p.1 = some j ∨ p.2 = some j) → j < (Wd.toMlx s0.ffi).nnext)
    (fwd : CaseFwdAtV M K env Vs pr A I R L e.s1.ffi e.S1.tab outT outs i (pr.NB P))
    (hread : e.σ.node I.read = I.fed) (hfed : e.σ.node I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map e.σ.node, p.2.map e.σ.node)) = outs)
    (hsread : (Wd.toMlx s0.ffi).items.get I.read = none)
    (hpread : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (h1read : (Wd.toMlx e.s1.ffi).items.get I.read = some (.ref A.tok))
    (h1pread : ((Wd.toMlx e.s1.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hs1tok : (Wd.toMlx e.s1.ffi).tokens = [])
    (htokv : nth? tab0 A.tok = some (.var A.kvar))
    (hpout : ((Wd.toMlx e.s1.ffi).nodes.get outT).isSome = true)
    (hpouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → ((Wd.toMlx e.s1.ffi).nodes.get j).isSome = true) :
    Sim.Prefill.LoopGStepGW (liftG Wd (GxV M K env Vs I R L)) W Fr e g V toks i := by
  intro _ nx Mp Kc t Cs n x1 hG hst _ _ hhi hrun hgh hend
  obtain ⟨j0, hj0⟩ := htv
  have hVt1 : x1.ν A.tvar = F64.ofNat (L + i + 1) := (hgh.tab j0 _ hj0).trans (hVt nx)
  have hhi1 : x1.K.hi = Wd.E P := hgh.hi.trans hhi
  exact gstep_coreAtV M K env Vs pr hPNL hPN0 hPE hrope R L V tk toks i I outT outs e.s1 e.S1 e.σ htk htkb fwd hread hfed
    hcaches hsread hpread h1read h1pread hs0tok hs1tok htokv hpout hpouts (hVk nx) hVt1 hG (pr.loadR hst)
    hst.srv.num hhi1 (Sim.runC_le _ _ _ _ _ hrun) hgh.grows
    ⟨hgh.node _ hcarR, hgh.node _ hcarF, cachesAt_congrM fun p hp j hj => hgh.node j (hcarC p hp j hj)⟩
    (pr.loadR hend) hend.srv.num hend.bigFixed _ _ _ _ _

end Steps
end Host.Mlx.SimGraph
