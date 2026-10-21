import host.simgraph.iter.GStep
import host.sim.LoopFinal
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference.Models.Qwen

/-! # The final iteration's graph conclusions

At the halted end `tF` with server table `tab`, the native graph carries the forward
result of every time `1 … T` and every memoized readback is its node's token
(`GF`). `fgstep_core` derives `GF` and the time-`T` forward result at the images of the
template start's carriers from `FinalGStep`'s premises (`FinalG` wraps it as `FinalGStep`),
from the invariant at `T - 2`: the final case computes no new forward; it reads back
the time-`T - 1` token at the image of `I.read` (template reference `79`, variable
`v14`) and the time-`T` token at the image of `I.fed` (the look-ahead reference
`tab0.length`, variable `v17`). -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-- **The general theorem's graph conclusions** at the end state `tF`, read at table `tab`. -/
def GF (T : Nat) (tab : List F64) (tF : St Sim.LF.S) : Prop :=
  (∀ k (_ : 1 ≤ k) (_ : k ≤ T) (hb : k ≤ 262144), ∃ cs out,
    ForwardAt M K env tab leaves typed (hpOf M K env leaves typed parameters tab) k hb cs out (Gr tab tF.ffi.mlx)) ∧
  ReadbackValues M K env (CSrv.val ⟨tab⟩) (Gr tab tF.ffi.mlx) tF.ffi.mlx.items

theorem mem_of_length_le_two {ks : List Nat} {a b k : Nat} (hl : ks.length ≤ 2) (ha : a ∈ ks) (hb : b ∈ ks)
    (hab : a ≠ b) (hk : k ∈ ks) : k = a ∨ k = b := by
  match ks, hl, ha, hb, hk with
  | [x], _, ha, hb, _ =>
    rw [List.mem_singleton] at ha hb
    exact absurd (ha.trans hb.symm) hab
  | [x, y], _, ha, hb, hk =>
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha hb hk
    rcases ha with rfl | rfl <;> rcases hb with rfl | rfl <;> rcases hk with rfl | rfl <;> simp_all

theorem run_token_congr (tab : List F64) (hp : TokenSequenceRanges.Parameters (firstPipeline M K env tab leaves typed))
    {a b : Nat} (h : a = b) (ha : a ≤ 262144) (hb : b ≤ 262144) :
    ((firstContext M K env tab leaves typed hp).run promptToken a ha).token =
      ((firstContext M K env tab leaves typed hp).run promptToken b hb).token := by
  subst h; rfl

/-- `ForwardAt` reads its caches only through their tensor nodes. -/
theorem forwardAt_congr {tab : List F64} {hp : TokenSequenceRanges.Parameters (firstPipeline M K env tab leaves typed)}
    {time : Nat} {hb : time ≤ 262144} {cs cs' : List Cache} {out : Nat} {G : Nat → Option (RNode Int InKey)}
    (h : ForwardAt M K env tab leaves typed hp time hb cs out G) (hc : cs.map cacheNodePair = cs'.map cacheNodePair) :
    ForwardAt M K env tab leaves typed hp time hb cs' out G := by
  obtain ⟨hs, htok, hh, hv⟩ := h
  refine ⟨hs, htok, hh, ?_⟩
  clear hh htok
  unfold CacheValues at hv ⊢
  induction hv generalizing cs' with
  | nil =>
    cases cs' with
    | nil => exact .nil
    | cons _ _ => cases hc
  | @cons c h cs hs hx _ ih =>
    cases cs' with
    | nil => cases hc
    | cons c' cs' =>
      simp only [List.map_cons, List.cons.injEq] at hc
      obtain ⟨hc1, hc2⟩ := hc
      obtain ⟨ta, tb, a, b, h1, h2, h3, h4, h5⟩ := hx
      simp only [cacheNodePair, Prod.mk.injEq, h1, h2, Option.map_some] at hc1
      obtain ⟨ha, hb'⟩ := hc1
      obtain ⟨ta', h1', hta⟩ := Option.map_eq_some_iff.mp ha.symm
      obtain ⟨tb', h2', htb⟩ := Option.map_eq_some_iff.mp hb'.symm
      exact .cons ⟨ta', tb', a, b, h1', h2', h3, hta ▸ h4, htb ▸ h5⟩ (ih hc2)

theorem forwardAt_time {tab : List F64} {hp : TokenSequenceRanges.Parameters (firstPipeline M K env tab leaves typed)}
    {a b : Nat} (e : a = b) (ha : a ≤ 262144) (hb : b ≤ 262144) {cs : List Cache} {out : Nat}
    {G : Nat → Option (RNode Int InKey)} (h : ForwardAt M K env tab leaves typed hp a ha cs out G) :
    ForwardAt M K env tab leaves typed hp b hb cs out G := by
  subst e; exact h

/-- **The final case's graph conclusions**, from `FinalGStep`'s premises: `GF` at the halt,
and the time-`T` forward result at the images of the template start's carriers. -/
theorem fgstep_core {okA okB : St Sim.LF.S → SSrv → Bool} {s0 : St Sim.LF.S} {tab0 : List SymE} {cE aN : Nat}
    (P : Sim.LoadP) (fc : Sim.FinalCase okA okB s0 tab0 cE aN) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat)
    (toks : List NumV) (I : TplInputs)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hT : 2 ≤ T) (hTb : T ≤ 262144) (hne : I.read ≠ I.fed)
    (hsA : s0.ffi.mlx.items.get I.read = none) (hsB : s0.ffi.mlx.items.get I.fed = none)
    (hpA : (s0.ffi.mlx.nodes.get I.read).isSome = true) (hpB : (s0.ffi.mlx.nodes.get I.fed).isSome = true)
    (hfA : fc.sF.ffi.mlx.items.get I.read = some (.ref 79))
    (hfB : fc.sF.ffi.mlx.items.get I.fed = some (.ref tab0.length))
    (hpfA : (fc.sF.ffi.mlx.nodes.get I.read).isSome = true) (hpfB : (fc.sF.ffi.mlx.nodes.get I.fed).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : fc.sF.ffi.mlx.tokens = [])
    (h79 : nth? fc.SF.tab 79 = some (.var 14)) (h17 : nth? fc.SF.tab tab0.length = some (.var 17))
    (hlen : T - 2 < toks.length) (nx : Nat) (Mp : Sim.Map) (Kc : Sim.Ctx) (t : St Sim.LF.S) (Cs : CSrv)
    (MF : Sim.Map) (KF : Sim.Ctx) (tF : St Sim.LF.S) (CF : CSrv)
    (hGx : Gx M K env leaves typed parameters I (T - 2) Mp t Cs)
    (hst : Sim.Rel Sim.LF (Sim.LR P (toks.drop (T - 2))) Mp
      (Sim.loopVal ρ T T (T - 2) (Sim.cap (T - 2)) (tk (T - 1)) (tk (T - 2)) nx) Kc s0 ⟨tab0, []⟩ t Cs)
    (n : Nat) (hrun : runC Sim.LF n t Cs = some (tF, CF)) (fr : Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx)
    (hext : Sim.Ext (Mp.setNum tab0.length toks[T - 2]) MF (tab0.length + 1))
    (hend : Sim.Rel Sim.LF (Sim.LR P (toks.drop (T - 1))) MF
      (Sim.loopVal ρ T T (T - 2) (Sim.cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)) KF fc.sF fc.SF tF CF) :
    GF M K env leaves typed parameters T CF.tab tF ∧
      ForwardAt M K env CF.tab leaves typed (hpOf M K env leaves typed parameters CF.tab) T hTb
        (cachesAt MF.node I.caches) (MF.node I.fed) (Gr CF.tab tF.ffi.mlx) := by
  have hle : Sim.CSrv.Le Cs ⟨CF.tab⟩ := Sim.runC_le _ t Cs tF CF hrun
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 := hst.ffi.mlx
  have mr1 := hend.ffi.mlx
  have hT2 : T - 2 + 2 = T := by omega
  -- the popped readbacks
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 1) := by
    rw [List.drop_eq_getElem_cons hlen]
    congr 2
    omega
  have hpop : popped.length = 2 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok] at hpe
    have hpe' : Mp.nv (.ref 79) :: toks[T - 2] :: toks.drop (T - 1) = popped ++ toks.drop (T - 1) := by
      rw [← hdrop]; exact hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks2 : ks.length ≤ 2 := hpop ▸ hks
  have hslotA : tF.ffi.mlx.items.get (MF.node I.read) = some (MF.nv (.ref 79)) := by
    rw [mr1.items I.read hpfA, hfA]; rfl
  have hslotB : tF.ffi.mlx.items.get (MF.node I.fed) = some (MF.nv (.ref tab0.length)) := by
    rw [mr1.items I.fed hpfB, hfB]; rfl
  have hfreshA : t.ffi.mlx.items.get (MF.node I.read) = none := by
    rw [hnode, mr0.items I.read hpA, hsA]; rfl
  have hfreshB : t.ffi.mlx.items.get (MF.node I.fed) = none := by
    rw [hnode, mr0.items I.fed hpB, hsB]; rfl
  have hinA : MF.node I.read ∈ ks := by
    rcases hnewk _ _ hslotA with h | ⟨_, h, _⟩
    · rw [hfreshA] at h; cases h
    · exact h
  have hinB : MF.node I.fed ∈ ks := by
    rcases hnewk _ _ hslotB with h | ⟨_, h, _⟩
    · rw [hfreshB] at h; cases h
    · exact h
  have hneF : MF.node I.read ≠ MF.node I.fed := fun h => hne (mr1.ninj _ _ hpfA hpfB h)
  -- the readback values
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref 79)) = some (F64.ofNat ((firstContext M K env CF.tab leaves typed
      (hpOf M K env leaves typed parameters CF.tab)).run promptToken (T - 2 + 1) (by omega)).token.val) := by
    have := hend.srv.num 79 _ h79
    change CSrv.val ⟨CF.tab⟩ (MF.num 79) = _
    rw [this]
    show some (F64.ofNat (tk (T - 1))) = _
    rw [htk (T - 1) (by omega), recurrence_token_table_eq M K env [] CF.tab leaves typed parameters
      (hpOf M K env leaves typed parameters CF.tab) (T - 1) (by omega),
      run_token_congr M K env leaves typed CF.tab _ (show T - 1 = T - 2 + 1 by omega)]
  have hvB : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref tab0.length)) = some (F64.ofNat ((firstContext M K env CF.tab leaves
      typed (hpOf M K env leaves typed parameters CF.tab)).run promptToken (T - 2 + 2) (by omega)).token.val) := by
    have := hend.srv.num tab0.length _ h17
    change CSrv.val ⟨CF.tab⟩ (MF.num tab0.length) = _
    rw [this]
    show some (F64.ofNat (tk T)) = _
    rw [htk T hTb, recurrence_token_table_eq M K env [] CF.tab leaves typed parameters
      (hpOf M K env leaves typed parameters CF.tab) T hTb,
      run_token_congr M K env leaves typed CF.tab _ (show T = T - 2 + 2 by omega)]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  rotate_left 2
  · obtain ⟨hs, htok, hh, hcv, _, hlt, hcb⟩ := hG.cur (by omega)
    rw [hnode]
    exact forwardAt_time M K env leaves typed hT2 _ hTb
      (ForwardAt.grow M K env leaves typed _ _ _ _ ⟨hs, htok, hh, hcv⟩ hgrow hlt hcb)
  · intro k h1 h2 hb
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 (by omega) hb
    exact ⟨cs, out, ForwardAt.grow M K env leaves typed _ _ _ _ hf hgrow ho hc⟩
  · intro k v hk
    rcases hnewk k v hk with hx | ⟨_, hkk, _⟩
    · obtain ⟨token, htk', ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < (t.ffi : LSt).mlx.nnext := by
        by_contra hc
        cases (hG.reads.2 k (Nat.le_of_not_lt hc)).symm.trans hx
      exact ⟨token, htk', ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩
    · rcases mem_of_length_le_two hks2 hinA hinB hneF hkk with rfl | rfl
      · rw [hslotA] at hk
        cases hk
        obtain ⟨cs, ⟨hs, ⟨r, hr, hi⟩, _, _⟩, hlt, _⟩ := hG.read (by omega)
        refine ⟨_, ?_, ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hvA⟩
        have := ((firstContext M K env CF.tab leaves typed (hpOf M K env leaves typed parameters CF.tab)).run
          promptToken (T - 2 + 1) (by omega)).token.isLt
        omega
      · rw [hslotB] at hk
        cases hk
        obtain ⟨hs, ⟨r, hr, hi⟩, _, _, _, hlt, _⟩ := hG.cur (by omega)
        refine ⟨_, ?_, ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hvB⟩
        have := ((firstContext M K env CF.tab leaves typed (hpOf M K env leaves typed parameters CF.tab)).run
          promptToken (T - 2 + 2) (by omega)).token.isLt
        omega

end Host.Mlx.SimGraph.Iter
