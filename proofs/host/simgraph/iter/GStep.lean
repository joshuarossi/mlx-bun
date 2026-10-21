import host.simgraph.iter.Inv
import host.sim.LoopInv
import host.sim.extract.Grow
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference.Models.Qwen

/-! # A loop case's graph step from its forward result

`gstep_of` discharges `LoopGStep (Gx …)` for a checked loop case `c` from
* the growth of the target's native state along the case's run (`LoopGStep`'s
  `Host.Mlx.Ffi.NGrow` premise);
* the case's forward result `CaseFwd` (its `forward_iter`, with the iteration's
  inputs built from the template's carriers);
* facts of the template: the restart map's nodes (`σ.node read = fed`,
  `σ.node fed = outT`, the cache inputs to `outs`), the readback slot `I.read` (empty
  at the start, holding `ref 79` at the end), the token queues, and the current token's
  table entry `var 14`. -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- A loop case's forward result at iteration `i` (time `i + 2`) on any target related
to the case's end state `s1` (table `S1tab`): the next token at the image of `outT`, the
next caches at the images of `outs` with capacity `capOf (i + 1)`. -/
def CaseFwd (I : TplInputs) (s1 : LSt) (S1tab : List SymE) (outT : Nat) (outs : List (Option Nat × Option Nat))
    (i : Nat) (hb : i + 3 ≤ 262144) : Prop :=
  ∀ (tab : List F64) (P : Sim.LoadP) (Mp : Sim.Map) (n : Nat) (y : LSt) (ν : Nat → F64),
    Sim.LoadR P Mp n s1 y → P.NL = 20000 → P.N0 = 22539 → ν 9 = F64.ofNat (i + 2) →
    (∀ j e, nth? S1tab j = some e → CSrv.val ⟨tab⟩ (Mp.nv (.ref j)) = some (e.eval ν)) →
    Mp.big 5554869888 = 5554869888 →
    ∀ hs, ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs
        ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run promptToken (i + 2)
          (by omega)).cache →
      CapsFor (capOf i) (stageWeights (weights (firstValues M K env tab))) hs →
      CacheValues M K env (Gr tab y.mlx) (cachesAt Mp.node I.caches) hs →
      (∃ r, evalR M K env (Gr tab y.mlx) (Mp.node I.fed) = some r ∧
        itemUint32 r = some ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
          promptToken (i + 2) (by omega)).token.val) →
      (∀ t ∈ parameterTensors parameterChoice, evalR M K env (Gr tab y.mlx) t.node = some (firstValues M K env tab t)) →
      ∃ next, (∃ r, evalR M K env (Gr tab y.mlx) (Mp.node outT) = some r ∧
          itemUint32 r = some ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
            promptToken (i + 3) hb).token.val) ∧
        ChainHolds (firstPipeline M K env tab leaves typed).graph.stages next
          ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run promptToken (i + 3) hb).cache ∧
        CacheValues M K env (Gr tab y.mlx) (cachesAt Mp.node outs) next ∧
        CapsFor (capOf (i + 1)) (stageWeights (weights (firstValues M K env tab))) next

theorem mem_of_length_le_one {ks : List Nat} {a k : Nat} (hl : ks.length ≤ 1) (ha : a ∈ ks) (hk : k ∈ ks) :
    k = a := by
  match ks, hl, ha, hk with
  | [b], _, ha, hk =>
    rw [List.mem_singleton] at ha hk
    rw [ha, hk]

/-- **A loop case's graph step.** -/
theorem gstep_of {ok : St Sim.LF.S → SSrv → Bool} {P : Sim.LoadP} {s0 : St Sim.LF.S} {tab0 : List SymE}
    {fixA : List Nat} (hPNL : P.NL = 20000) (hPN0 : P.N0 = 22539) (hPE : P.E ≤ 5554869888)
    (c : Sim.LoopCase ok P s0 tab0 fixA) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV)
    (i : Nat) (I : TplInputs) (outT : Nat) (outs : List (Option Nat × Option Nat))
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hb : i + 3 ≤ 262144)
    (fwd : CaseFwd M K env leaves typed parameters I c.s1.ffi c.S1.tab outT outs i hb)
    (hread : c.σ.node I.read = I.fed) (hfed : c.σ.node I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map c.σ.node, p.2.map c.σ.node)) = outs)
    (hsread : s0.ffi.mlx.items.get I.read = none) (hpread : (s0.ffi.mlx.nodes.get I.read).isSome = true)
    (h1read : c.s1.ffi.mlx.items.get I.read = some (.ref 79)) (h1pread : (c.s1.ffi.mlx.nodes.get I.read).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hs1tok : c.s1.ffi.mlx.tokens = [])
    (h79 : nth? tab0 79 = some (.var 14))
    (hpout : (c.s1.ffi.mlx.nodes.get outT).isSome = true)
    (hpouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → (c.s1.ffi.mlx.nodes.get j).isSome = true) :
    Sim.LoopGStep (Gx M K env leaves typed parameters I) c ρ T tk toks i := by
  intro _ nx Mp Kc t Cs M1 t1 C1 hGx hst _ _ hhi hrun fr hext hend tab hle1
  have hle0 : Sim.CSrv.Le Cs ⟨tab⟩ := (Sim.runC_le c.n t Cs t1 C1 hrun).trans hle1
  have hG := hGx tab hle0
  have hnode : M1.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 := hst.ffi.mlx
  have mr1 := hend.ffi.mlx
  -- the iteration's current state, lifted to the end
  obtain ⟨hs, htok, hchain, hcv, hcaps, hfedlt, hcb⟩ := hG.cur (by omega)
  have hcv1 : CacheValues M K env (Gr tab t1.ffi.mlx) (cachesAt M1.node I.caches) hs := by
    rw [hnode]; exact cacheValues_grows M K env _ _ _ _ hgrow _ hs hcb hcv
  have hprev1 : ∃ r, evalR M K env (Gr tab t1.ffi.mlx) (M1.node I.fed) = some r ∧
      itemUint32 r = some ((firstContext M K env tab leaves typed (hpOf M K env leaves typed parameters tab)).run
        promptToken (i + 2) (by omega)).token.val := by
    obtain ⟨r, hr, hi⟩ := htok
    exact ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hfedlt _ hr, hi⟩
  have hpar1 : ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (Gr tab t1.ffi.mlx) t.node = some (firstValues M K env tab t) := fun t ht =>
    evalR_grows M K env _ _ _ _ hgrow _ (hG.params t ht).2 _ (hG.params t ht).1
  have hnum : ∀ j e, nth? c.S1.tab j = some e → CSrv.val ⟨tab⟩ (M1.nv (.ref j)) = some
      (e.eval (Sim.loopVal ρ T (i + 2) i (Sim.cap i) (tk (i + 1)) (tk i) nx)) := fun j e he =>
    hle1.val (hend.srv.num j e he)
  have hrope : M1.big 5554869888 = 5554869888 :=
    hend.bigFixed _ (.inr (.inr ⟨by rw [hhi]; omega, by decide⟩))
  obtain ⟨next, hout, hnext, hcvn, hcapn⟩ := fwd tab _ M1 _ t1.ffi _ hend.ffi hPNL hPN0 rfl hnum hrope hs hchain hcaps
    hcv1 hprev1 hpar1
  -- the one popped readback: the value of time `i + 1`, at the image of the readback slot
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped = [Mp.nv (.ref 79)] := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hs1tok] at hpe
    exact (List.append_left_inj _).mp hpe.symm
  subst hpop
  have hplen : ks.length ≤ 1 := hks
  have hslot1 : t1.ffi.mlx.items.get (M1.node I.read) = some (M1.nv (.ref 79)) := by
    rw [mr1.items I.read h1pread, h1read]; rfl
  have hslot0 : t.ffi.mlx.items.get (M1.node I.read) = none := by
    rw [hnode, mr0.items I.read hpread, hsread]; rfl
  have hks1 : M1.node I.read ∈ ks := by
    rcases hnewk _ _ hslot1 with h | ⟨_, h, _⟩
    · rw [hslot0] at h; cases h
    · exact h
  have hval : CSrv.val ⟨tab⟩ (Mp.nv (.ref 79)) = some (F64.ofNat ((firstContext M K env tab leaves typed
      (hpOf M K env leaves typed parameters tab)).run promptToken (i + 1) (by omega)).token.val) := by
    show CSrv.val ⟨tab⟩ (Mp.num 79) = _
    rw [hle0.val (hst.srv.num 79 _ h79)]
    show some (F64.ofNat (tk (i + 1))) = _
    rw [htk (i + 1) (by omega), recurrence_token_table_eq M K env [] tab leaves typed parameters
      (hpOf M K env leaves typed parameters tab) (i + 1) (by omega)]
  exact gi_next M K env leaves typed parameters I tab i M1.node c.σ.node t.ffi.mlx t1.ffi.mlx outT outs
    (by rw [hnode]; exact hG) hgrow fr.nnext hb
    (fun k v hk => by
      rcases hnewk k v hk with h | ⟨hx, hk', hv⟩
      · exact .inl h
      · refine .inr ⟨hx, mem_of_length_le_one hplen hks1 hk', ?_⟩
        rw [List.mem_singleton] at hv
        rw [hv]
        exact hval)
    mr1.yitems ⟨next, hout, hnext, hcvn, hcapn⟩ (mr1.nimg outT hpout)
    (cachesAt_below _ _ _ fun p hp j hj => mr1.nimg j (hpouts p hp j hj)) hread hfed hcaches

end Host.Mlx.SimGraph.Iter
