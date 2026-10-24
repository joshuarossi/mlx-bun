import host.simgraph.iter.InvL
import host.sim.DecodeAddrHalt
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference.Models.Qwen

/-! # The decode loop's graph steps at a driver's constants, under the frame relation

`CaseFwdL`, `gstep_ofL`, `fgstep_core_atL`, `egstep_coreL` (InvL.lean) name today's template
constants (the token reference 79, the time and token variables 9 and 14, `P.NL = 20000`,
`P.N0 = 22539`, the rope base 5554869888) and read `Rel`. Here they are at the constants `A`
(`Sim.Addr`), under the frames `W` (`RelF`), at any valuations `V` whose time and token variables
hold the cut's time and token (`hVt`, `hVk`):

* `CaseFwdA` (at `addr0`, `CaseFwdL`: `caseFwdA_addr0`), `gstep_ofA` (discharges
  `Sim.LoopGStepA (GxL …)` over `relLW P W`);
* `fgstep_core_atA`, `lgstep_ofA` (discharges `Sim.LastGStepA` with the goal `GFL`),
  `egstep_coreA`, `cgstep_ofA` (`Sim.CutGStepA`, goal `GFL (i + 2)`).

The graph side reads the relation's server and native parts only, never the frames. -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

/-- A loop case's forward result at iteration `i` (`CaseFwdL`) at the constants `A`. -/
def CaseFwdA (A : Sim.Addr) (I : TplInputs) (R : RefRun M K env leaves typed) (L : Nat) (s1 : LSt)
    (S1tab : List SymE) (outT : Nat) (outs : List (Option Nat × Option Nat)) (i : Nat) (hb : L + i + 2 ≤ 262144) :
    Prop :=
  ∀ (tab : List F64) (P : Sim.LoadP) (Mp : Sim.Map) (n : Nat) (y : LSt) (ν : Nat → F64),
    Sim.LoadR P Mp n s1 y → P.NL = A.NL → P.N0 = A.N0 → ν A.tvar = F64.ofNat (L + i + 1) →
    (∀ j e, nth? S1tab j = some e → CSrv.val ⟨tab⟩ (Mp.nv (.ref j)) = some (e.eval ν)) →
    Mp.big (A.rope : Int) = (A.rope : Int) →
    ∀ hs, ChainHolds (firstPipeline M K env tab leaves typed).graph.stages hs (R tab (L + i + 1) (by omega)).cache →
      CapsFor (Sim.capL (L + i + 1)) (stageWeights (weights (firstValues M K env tab))) hs →
      CacheValues M K env (Gr tab y.mlx) (cachesAt Mp.node I.caches) hs →
      (∃ r, evalR M K env (Gr tab y.mlx) (Mp.node I.fed) = some r ∧
        itemUint32 r = some (R tab (L + i + 1) (by omega)).token.val) →
      (∀ t ∈ parameterTensors parameterChoice, evalR M K env (Gr tab y.mlx) t.node = some (firstValues M K env tab t)) →
      ∃ next, (∃ r, evalR M K env (Gr tab y.mlx) (Mp.node outT) = some r ∧
          itemUint32 r = some (R tab (L + i + 2) hb).token.val) ∧
        ChainHolds (firstPipeline M K env tab leaves typed).graph.stages next (R tab (L + i + 2) hb).cache ∧
        CacheValues M K env (Gr tab y.mlx) (cachesAt Mp.node outs) next ∧
        CapsFor (Sim.capL (L + i + 2)) (stageWeights (weights (firstValues M K env tab))) next

theorem caseFwdA_addr0 (I : TplInputs) (R : RefRun M K env leaves typed) (L : Nat) (s1 : LSt) (S1tab : List SymE)
    (outT : Nat) (outs : List (Option Nat × Option Nat)) (i : Nat) (hb : L + i + 2 ≤ 262144) :
    CaseFwdA M K env leaves typed Sim.addr0 I R L s1 S1tab outT outs i hb ↔
      CaseFwdL M K env leaves typed I R L s1 S1tab outT outs i hb := Iff.rfl

/-- **A loop case's graph step** at the constants `A` under the frames `W` (`gstep_ofL`). -/
theorem gstep_ofA (A : Sim.Addr) (W : Nat → Option Sim.WFrame) (Fr : Sim.LoopFramesA A) {ok : St Sim.LF.S → SSrv → Bool}
    {P : Sim.LoadP} {s0 : St Sim.LF.S} {tab0 : List SymE} {fixA : List Nat}
    (hPNL : P.NL = A.NL) (hPN0 : P.N0 = A.N0) (hPE : P.E ≤ A.rope) (hrope : A.rope < 2 ^ 56)
    (c : Sim.LoopCaseA A ok P s0 tab0 fixA) (R : RefRun M K env leaves typed) (L : Nat) (V : Sim.LoopVals)
    (tk : Nat → Nat) (toks : List NumV) (i : Nat) (I : TplInputs) (outT : Nat) (outs : List (Option Nat × Option Nat))
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hVt : ∀ nx, V i nx A.tvar = F64.ofNat (L + i + 1)) (hVk : ∀ nx, V i nx A.kvar = F64.ofNat (tk (i + 1)))
    (hb : L + i + 2 ≤ 262144)
    (fwd : CaseFwdA M K env leaves typed A I R L c.s1.ffi c.S1.tab outT outs i hb)
    (hread : c.σ.node I.read = I.fed) (hfed : c.σ.node I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map c.σ.node, p.2.map c.σ.node)) = outs)
    (hsread : s0.ffi.mlx.items.get I.read = none) (hpread : (s0.ffi.mlx.nodes.get I.read).isSome = true)
    (h1read : c.s1.ffi.mlx.items.get I.read = some (.ref A.tok))
    (h1pread : (c.s1.ffi.mlx.nodes.get I.read).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref A.tok]) (hs1tok : c.s1.ffi.mlx.tokens = [])
    (htokv : nth? tab0 A.tok = some (.var A.kvar))
    (hpout : (c.s1.ffi.mlx.nodes.get outT).isSome = true)
    (hpouts : ∀ p ∈ outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → (c.s1.ffi.mlx.nodes.get j).isSome = true) :
    Sim.LoopGStepA (GxL M K env leaves typed I R L) (Sim.relLW P W) Fr c V toks i := by
  intro _ nx Mp Kc t Cs M1 t1 C1 hGx hst _ _ hhi hrun fr hext hend tab hle1
  have hle0 : Sim.CSrv.Le Cs ⟨tab⟩ := (Sim.runC_le c.n t Cs t1 C1 hrun).trans hle1
  have hG := hGx tab hle0
  have hnode : M1.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 := hst.ffi.mlx
  have mr1 := hend.ffi.mlx
  obtain ⟨hs, htok, hchain, hcv, hcaps, hfedlt, hcb⟩ := hG.cur (by omega)
  have hcv1 : CacheValues M K env (Gr tab t1.ffi.mlx) (cachesAt M1.node I.caches) hs := by
    rw [hnode]; exact cacheValues_grows M K env _ _ _ _ hgrow _ hs hcb hcv
  have hprev1 : ∃ r, evalR M K env (Gr tab t1.ffi.mlx) (M1.node I.fed) = some r ∧
      itemUint32 r = some (R tab (L + i + 1) (by omega)).token.val := by
    obtain ⟨r, hr, hi⟩ := htok
    exact ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hfedlt _ hr, hi⟩
  have hpar1 : ∀ t ∈ parameterTensors parameterChoice,
      evalR M K env (Gr tab t1.ffi.mlx) t.node = some (firstValues M K env tab t) := fun t ht =>
    evalR_grows M K env _ _ _ _ hgrow _ (hG.params t ht).2 _ (hG.params t ht).1
  have hnum : ∀ j e, nth? c.S1.tab j = some e → CSrv.val ⟨tab⟩ (M1.nv (.ref j)) = some (e.eval (V i nx)) :=
    fun j e he => hle1.val (hend.srv.num j e he)
  have hrope1 : M1.big (A.rope : Int) = (A.rope : Int) :=
    hend.bigFixed _ (.inr (.inr ⟨by rw [hhi]; omega, by omega⟩))
  obtain ⟨next, hout, hnext, hcvn, hcapn⟩ := fwd tab _ M1 _ t1.ffi _ hend.ffi hPNL hPN0 (hVt nx) hnum hrope1 hs
    hchain hcaps hcv1 hprev1 hpar1
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped = [Mp.nv (.ref A.tok)] := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hs1tok] at hpe
    exact (List.append_left_inj _).mp hpe.symm
  subst hpop
  have hplen : ks.length ≤ 1 := hks
  have hslot1 : t1.ffi.mlx.items.get (M1.node I.read) = some (M1.nv (.ref A.tok)) := by
    rw [mr1.items I.read h1pread, h1read]; rfl
  have hslot0 : t.ffi.mlx.items.get (M1.node I.read) = none := by
    rw [hnode, mr0.items I.read hpread, hsread]; rfl
  have hks1 : M1.node I.read ∈ ks := by
    rcases hnewk _ _ hslot1 with h | ⟨_, h, _⟩
    · rw [hslot0] at h; cases h
    · exact h
  have hval : CSrv.val ⟨tab⟩ (Mp.nv (.ref A.tok)) = some (F64.ofNat (R tab (L + i) (by omega)).token.val) := by
    show CSrv.val ⟨tab⟩ (Mp.num A.tok) = _
    rw [hle0.val (hst.srv.num A.tok _ htokv)]
    show some (V i nx A.kvar) = _
    rw [hVk nx, htk tab i (by omega)]
  exact gi_nextL M K env leaves typed I R L tab i M1.node c.σ.node t.ffi.mlx t1.ffi.mlx outT outs
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

/-- **The final iteration's graph conclusions at a halt `sF`/`SF`** at the constants `A` under the
frames `W` (`fgstep_core_atL`). -/
theorem fgstep_core_atA (A : Sim.Addr) (W : Nat → Option Sim.WFrame) {s0 : St Sim.LF.S} {tab0 : List SymE}
    (sF : St Sim.LF.S) (SF : SSrv) (P : Sim.LoadP) (R : RefRun M K env leaves typed) (L : Nat) (V : Sim.LoopVals)
    (T : Nat) (tk : Nat → Nat) (toks : List NumV) (I : TplInputs)
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hVk : V (T - 2) (tk T) A.kvar = F64.ofNat (tk (T - 2 + 1))) (hVn : V (T - 2) (tk T) A.nxt = F64.ofNat (tk T))
    (hT : 2 ≤ T) (hTb : L + T - 1 ≤ 262144) (hne : I.read ≠ I.fed)
    (hsA : s0.ffi.mlx.items.get I.read = none) (hsB : s0.ffi.mlx.items.get I.fed = none)
    (hpA : (s0.ffi.mlx.nodes.get I.read).isSome = true) (hpB : (s0.ffi.mlx.nodes.get I.fed).isSome = true)
    (hfA : sF.ffi.mlx.items.get I.read = some (.ref A.tok))
    (hfB : sF.ffi.mlx.items.get I.fed = some (.ref tab0.length))
    (hpfA : (sF.ffi.mlx.nodes.get I.read).isSome = true) (hpfB : (sF.ffi.mlx.nodes.get I.fed).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref A.tok]) (hsFtok : sF.ffi.mlx.tokens = [])
    (h79 : nth? SF.tab A.tok = some (.var A.kvar)) (h17 : nth? SF.tab tab0.length = some (.var A.nxt))
    (hlen : T - 2 < toks.length) (nx : Nat) (Mp : Sim.Map) (Kc : Sim.Ctx) (t : St Sim.LF.S) (Cs : CSrv)
    (MF : Sim.Map) (KF : Sim.Ctx) (tF : St Sim.LF.S) (CF : CSrv)
    (hGx : GxL M K env leaves typed I R L (T - 2) Mp t Cs)
    (hst : Sim.RelF Sim.LF (Sim.LR P (toks.drop (T - 2))) W Mp (V (T - 2) nx) Kc s0 ⟨tab0, []⟩ t Cs)
    (n : Nat) (hrun : runC Sim.LF n t Cs = some (tF, CF)) (fr : Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx)
    (hext : Sim.Ext (Mp.setNum tab0.length toks[T - 2]) MF (tab0.length + 1))
    (hend : Sim.RelF Sim.LF (Sim.LR P (toks.drop (T - 1))) W MF (V (T - 2) (tk T)) KF sF SF tF CF) :
    GFL M K env leaves typed R L T CF.tab tF ∧
      ForwardAtR M K env leaves typed R CF.tab (L + T - 1) hTb (cachesAt MF.node I.caches) (MF.node I.fed)
        (Gr CF.tab tF.ffi.mlx) := by
  have hle : Sim.CSrv.Le Cs ⟨CF.tab⟩ := Sim.runC_le _ t Cs tF CF hrun
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 := hst.ffi.mlx
  have mr1 := hend.ffi.mlx
  have hT2 : L + (T - 2) + 1 = L + T - 1 := by omega
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 1) := by
    rw [List.drop_eq_getElem_cons hlen]
    congr 2
    omega
  have hpop : popped.length = 2 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok] at hpe
    have hpe' : Mp.nv (.ref A.tok) :: toks[T - 2] :: toks.drop (T - 1) = popped ++ toks.drop (T - 1) := by
      rw [← hdrop]; exact hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks2 : ks.length ≤ 2 := hpop ▸ hks
  have hslotA : tF.ffi.mlx.items.get (MF.node I.read) = some (MF.nv (.ref A.tok)) := by
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
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref A.tok)) =
      some (F64.ofNat (R CF.tab (L + (T - 2)) (by omega)).token.val) := by
    have := hend.srv.num A.tok _ h79
    change CSrv.val ⟨CF.tab⟩ (MF.num A.tok) = _
    rw [this]
    show some (V (T - 2) (tk T) A.kvar) = _
    rw [hVk, htk CF.tab (T - 2) (by omega)]
  have hvB : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref tab0.length)) =
      some (F64.ofNat (R CF.tab (L + (T - 2) + 1) (by omega)).token.val) := by
    have := hend.srv.num tab0.length _ h17
    change CSrv.val ⟨CF.tab⟩ (MF.num tab0.length) = _
    rw [this]
    show some (V (T - 2) (tk T) A.nxt) = _
    rw [hVn]
    have e : tk T = (R CF.tab (L + (T - 1)) (by omega)).token.val := by
      have := htk CF.tab (T - 1) (by omega)
      rwa [show T - 1 + 1 = T by omega] at this
    rw [e, ref_token_congr M K env leaves typed R CF.tab (show L + (T - 1) = L + (T - 2) + 1 by omega)]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  rotate_left 2
  · obtain ⟨hs, htok, hh, hcv, _, hlt, hcb⟩ := hG.cur (by omega)
    rw [hnode]
    exact forwardAtR_time M K env leaves typed hT2 _ hTb
      (ForwardAtR.grow M K env leaves typed _ _ _ _ ⟨hs, htok, hh, hcv⟩ hgrow hlt hcb)
  · intro k h1 h2 hb
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 (by omega) hb
    exact ⟨cs, out, ForwardAtR.grow M K env leaves typed _ _ _ _ hf hgrow ho hc⟩
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
        have := (R CF.tab (L + (T - 2)) (by omega)).token.isLt
        omega
      · rw [hslotB] at hk
        cases hk
        obtain ⟨hs, ⟨r, hr, hi⟩, _, _, _, hlt, _⟩ := hG.cur (by omega)
        refine ⟨_, ?_, ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hvB⟩
        have := (R CF.tab (L + (T - 2) + 1) (by omega)).token.isLt
        omega

/-- **A final chain's graph obligation** at the constants `A` under the frames `W`: the goal
`GFL`. -/
theorem lgstep_ofA (A : Sim.Addr) (W : Nat → Option Sim.WFrame) (Fr : Sim.LoopFramesA A) {s0 : St Sim.LF.S}
    {tab0 : List SymE} {fixA : List Nat} {T : Nat} {toks : List NumV} {xs : List Val} (P : Sim.LoadP)
    (hs : Sim.HaltSegA A W P (toks.drop (T - 1)) s0 (Sim.finalStart s0 tab0.length) (tab0 ++ [.var A.nxt]) xs)
    (R : RefRun M K env leaves typed) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (I : TplInputs)
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hVk : V (T - 2) (tk T) A.kvar = F64.ofNat (tk (T - 2 + 1))) (hVn : V (T - 2) (tk T) A.nxt = F64.ofNat (tk T))
    (hT : 2 ≤ T) (hTb : L + T - 1 ≤ 262144) (hne : I.read ≠ I.fed)
    (hsA : s0.ffi.mlx.items.get I.read = none) (hsB : s0.ffi.mlx.items.get I.fed = none)
    (hpA : (s0.ffi.mlx.nodes.get I.read).isSome = true) (hpB : (s0.ffi.mlx.nodes.get I.fed).isSome = true)
    (hfA : hs.case.sF.ffi.mlx.items.get I.read = some (.ref A.tok))
    (hfB : hs.case.sF.ffi.mlx.items.get I.fed = some (.ref tab0.length))
    (hpfA : (hs.case.sF.ffi.mlx.nodes.get I.read).isSome = true)
    (hpfB : (hs.case.sF.ffi.mlx.nodes.get I.fed).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref A.tok]) (hsFtok : hs.case.sF.ffi.mlx.tokens = [])
    (h79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar))
    (h17 : nth? hs.case.SF.tab tab0.length = some (.var A.nxt)) :
    Sim.LastGStepA A (GxL M K env leaves typed I R L) P W Fr fixA hs V tk
      (fun tF CF => GFL M K env leaves typed R L T CF.tab tF) := by
  intro hlen nx Mp Kc t Cs xF hGx _ hst _ _ _ hrun fr hext hν _ _ _ hend
  obtain ⟨hR, -⟩ := hs.rend xF _ _ hend
  rw [hν] at hR
  exact (fgstep_core_atA M K env leaves typed A W hs.case.sF hs.case.SF P R L V T tk toks I htk hVk hVn hT hTb hne
    hsA hsB hpA hpB hfA hfB hpfA hpfB hs0tok hsFtok h79 h17 hlen nx Mp Kc t Cs xF.M xF.K xF.t xF.C hGx hst _ hrun fr
    hext hR).1

/-- **The graph conclusions of a halt at the cut of iteration `i`** at the constants `A` under the
frames `W` (`egstep_coreL`). -/
theorem egstep_coreA (A : Sim.Addr) (W : Nat → Option Sim.WFrame) {s0 : St Sim.LF.S} {tab0 : List SymE}
    (sF : St Sim.LF.S) (SF : SSrv) (P : Sim.LoadP) (R : RefRun M K env leaves typed) (L : Nat) (V : Sim.LoopVals)
    (tk : Nat → Nat) (toks : List NumV) (I : TplInputs) (i : Nat)
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hib : L + i + 1 ≤ 262144)
    (hsA : s0.ffi.mlx.items.get I.read = none) (hpA : (s0.ffi.mlx.nodes.get I.read).isSome = true)
    (hfA : sF.ffi.mlx.items.get I.read = some (.ref A.tok))
    (hpfA : (sF.ffi.mlx.nodes.get I.read).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref A.tok]) (hsFtok : sF.ffi.mlx.tokens = [])
    (h79 : nth? SF.tab A.tok = some (.var A.kvar))
    (nx : Nat) (hVk : V i nx A.kvar = F64.ofNat (tk (i + 1))) (Mp : Sim.Map) (Kc : Sim.Ctx) (t : St Sim.LF.S)
    (Cs : CSrv) (MF : Sim.Map) (KF : Sim.Ctx) (tF : St Sim.LF.S) (CF : CSrv)
    (hGx : GxL M K env leaves typed I R L i Mp t Cs)
    (hst : Sim.RelF Sim.LF (Sim.LR P (toks.drop i)) W Mp (V i nx) Kc s0 ⟨tab0, []⟩ t Cs)
    (n : Nat) (hrun : runC Sim.LF n t Cs = some (tF, CF)) (fr : Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx)
    (hext : Sim.Ext Mp MF tab0.length)
    (hend : Sim.RelF Sim.LF (Sim.LR P (toks.drop i)) W MF (V i nx) KF sF SF tF CF) :
    GFL M K env leaves typed R L (i + 2) CF.tab tF ∧
      ForwardAtR M K env leaves typed R CF.tab (L + i + 1) hib (cachesAt MF.node I.caches) (MF.node I.fed)
        (Gr CF.tab tF.ffi.mlx) := by
  have hle : Sim.CSrv.Le Cs ⟨CF.tab⟩ := Sim.runC_le _ t Cs tF CF hrun
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 := hst.ffi.mlx
  have mr1 := hend.ffi.mlx
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped.length = 1 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok] at hpe
    have hpe' : Mp.nv (.ref A.tok) :: toks.drop i = popped ++ toks.drop i := hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks1 : ks.length ≤ 1 := hpop ▸ hks
  have hslotA : tF.ffi.mlx.items.get (MF.node I.read) = some (MF.nv (.ref A.tok)) := by
    rw [mr1.items I.read hpfA, hfA]; rfl
  have hfreshA : t.ffi.mlx.items.get (MF.node I.read) = none := by
    rw [hnode, mr0.items I.read hpA, hsA]; rfl
  have hinA : MF.node I.read ∈ ks := by
    rcases hnewk _ _ hslotA with h | ⟨_, h, _⟩
    · rw [hfreshA] at h; cases h
    · exact h
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref A.tok)) = some (F64.ofNat (R CF.tab (L + i) (by omega)).token.val) := by
    have := hend.srv.num A.tok _ h79
    change CSrv.val ⟨CF.tab⟩ (MF.num A.tok) = _
    rw [this]
    show some (V i nx A.kvar) = _
    rw [hVk, htk CF.tab i (by omega)]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · intro k h1 h2 hb
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 (by omega) hb
    exact ⟨cs, out, ForwardAtR.grow M K env leaves typed _ _ _ _ hf hgrow ho hc⟩
  · intro k v hk
    rcases hnewk k v hk with hx | ⟨_, hkk, _⟩
    · obtain ⟨token, htk', ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < (t.ffi : LSt).mlx.nnext := by
        by_contra hc
        cases (hG.reads.2 k (Nat.le_of_not_lt hc)).symm.trans hx
      exact ⟨token, htk', ⟨r, evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hν⟩
    · obtain rfl := mem_of_length_le_one hks1 hinA hkk
      rw [hslotA] at hk
      cases hk
      obtain ⟨cs, ⟨hs, ⟨r, hr, hi⟩, _, _⟩, hlt, _⟩ := hG.read (by omega)
      refine ⟨_, ?_, ⟨r, by rw [hnode]; exact evalR_grows M K env _ _ _ _ hgrow _ hlt _ hr, hi⟩, hvA⟩
      have := (R CF.tab (L + i) (by omega)).token.isLt
      omega
  · obtain ⟨hs, htok, hh, hcv, _, hlt, hcb⟩ := hG.cur hib
    rw [hnode]
    exact ForwardAtR.grow M K env leaves typed _ _ _ _ ⟨hs, htok, hh, hcv⟩ hgrow hlt hcb

/-- **A cut halt's graph obligation** at the constants `A` under the frames `W`: the goal
`GFL (i + 2)`. -/
theorem cgstep_ofA (A : Sim.Addr) (W : Nat → Option Sim.WFrame) (Fr : Sim.LoopFramesA A) {s0 : St Sim.LF.S}
    {tab0 : List SymE} {fixA : List Nat} {toks : List NumV} {i : Nat} (P : Sim.LoadP)
    (hs : Sim.HaltSegA A W P (toks.drop i) s0 s0 tab0 []) (R : RefRun M K env leaves typed) (L : Nat)
    (V : Sim.LoopVals) (tk : Nat → Nat) (I : TplInputs)
    (htk : ∀ tab j (h : L + j ≤ 262144), tk (j + 1) = (R tab (L + j) h).token.val)
    (hVk : ∀ nx, V i nx A.kvar = F64.ofNat (tk (i + 1))) (hib : L + i + 1 ≤ 262144)
    (hsA : s0.ffi.mlx.items.get I.read = none) (hpA : (s0.ffi.mlx.nodes.get I.read).isSome = true)
    (hfA : hs.case.sF.ffi.mlx.items.get I.read = some (.ref A.tok))
    (hpfA : (hs.case.sF.ffi.mlx.nodes.get I.read).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref A.tok]) (hsFtok : hs.case.sF.ffi.mlx.tokens = [])
    (h79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar)) :
    Sim.CutGStepA A (GxL M K env leaves typed I R L) P W Fr fixA hs V
      (fun tF CF => GFL M K env leaves typed R L (i + 2) CF.tab tF) := by
  intro nx Mp Kc t Cs xF hGx _ hst _ _ _ hrun fr hext hν _ _ _ hend
  obtain ⟨hR, -⟩ := hs.rend xF _ _ hend
  rw [hν] at hR
  exact (egstep_coreA M K env leaves typed A W hs.case.sF hs.case.SF P R L V tk toks I i htk hib hsA hpA hfA hpfA
    hs0tok hsFtok h79 nx (hVk nx) Mp Kc t Cs xF.M xF.K xF.t xF.C hGx hst _ hrun fr hext hR).1

end Host.Mlx.SimGraph.Iter
