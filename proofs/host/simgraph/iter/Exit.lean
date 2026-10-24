import host.simgraph.iter.FinalC
import host.sim.LoopExit
set_option maxRecDepth 1000000
namespace Host.Mlx.SimGraph.Iter
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Host.Ts.Sim.ExtractSim (cachesT nodePair cachesAllB cacheOkB)
open Inference.Models.Qwen

/-! # The EOS exits' graph conclusions

* EOS at the cut of iteration `i` (`egstep_core`, `egstepC_of`): the exit case computes no
  forward; it reads back the time-`i + 1` token (EOS) at the image of `I.read` and never reads
  the time-`i + 2` token. At the halt the graph carries times `1 … i + 2`, and the program's
  final caches are the template start's (`GFC (i + 2)`).
* EOS at the look-ahead token of the final iteration (`fgstep_core_at`, `fgstepEC_of`): as
  the final cases (`fgstep_core`), both tokens are read back (the second is EOS); the
  conclusions depend on the case only through its halt `sF`/`SF`. -/

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env [] leaves typed))

/-! ## EOS at a loop cut -/

/-- **The exit case's graph conclusions**, from `ExitGStep`'s premises: `GF` at the halt for
times `1 … i + 2`, and the time-`i + 2` forward result at the images of the template start's
carriers. -/
theorem egstep_core {okA okB : St Sim.LF.S → SSrv → Bool} {s0 : St Sim.LF.S} {tab0 : List SymE} {cE aN : Nat}
    (P : Sim.LoadP) (ec : Sim.ExitCase okA okB s0 s0 tab0 cE aN []) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat)
    (toks : List NumV) (I : TplInputs) (i : Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hib : i + 2 ≤ 262144)
    (hsA : s0.ffi.mlx.items.get I.read = none) (hpA : (s0.ffi.mlx.nodes.get I.read).isSome = true)
    (hfA : ec.sF.ffi.mlx.items.get I.read = some (.ref 79))
    (hpfA : (ec.sF.ffi.mlx.nodes.get I.read).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : ec.sF.ffi.mlx.tokens = [])
    (h79 : nth? ec.SF.tab 79 = some (.var 14))
    (nx : Nat) (Mp : Sim.Map) (Kc : Sim.Ctx) (t : St Sim.LF.S) (Cs : CSrv)
    (MF : Sim.Map) (KF : Sim.Ctx) (tF : St Sim.LF.S) (CF : CSrv)
    (hGx : Gx M K env leaves typed parameters I i Mp t Cs)
    (hst : Sim.Rel Sim.LF (Sim.LR P (toks.drop i)) Mp
      (Sim.loopVal ρ T (i + 2) i (Sim.cap i) (tk (i + 1)) (tk i) nx) Kc s0 ⟨tab0, []⟩ t Cs)
    (n : Nat) (hrun : runC Sim.LF n t Cs = some (tF, CF)) (fr : Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx)
    (hext : Sim.Ext Mp MF tab0.length)
    (hend : Sim.Rel Sim.LF (Sim.LR P (toks.drop i)) MF
      (Sim.loopVal ρ T (i + 2) i (Sim.cap i) (tk (i + 1)) (tk i) nx) KF ec.sF ec.SF tF CF) :
    GF M K env leaves typed parameters (i + 2) CF.tab tF ∧
      ForwardAt M K env CF.tab leaves typed (hpOf M K env leaves typed parameters CF.tab) (i + 2) hib
        (cachesAt MF.node I.caches) (MF.node I.fed) (Gr CF.tab tF.ffi.mlx) := by
  have hle : Sim.CSrv.Le Cs ⟨CF.tab⟩ := Sim.runC_le _ t Cs tF CF hrun
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr.grows SourceKernels.sources
  have mr0 := hst.ffi.mlx
  have mr1 := hend.ffi.mlx
  -- the popped readback
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped.length = 1 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok] at hpe
    have hpe' : Mp.nv (.ref 79) :: toks.drop i = popped ++ toks.drop i := hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks1 : ks.length ≤ 1 := hpop ▸ hks
  have hslotA : tF.ffi.mlx.items.get (MF.node I.read) = some (MF.nv (.ref 79)) := by
    rw [mr1.items I.read hpfA, hfA]; rfl
  have hfreshA : t.ffi.mlx.items.get (MF.node I.read) = none := by
    rw [hnode, mr0.items I.read hpA, hsA]; rfl
  have hinA : MF.node I.read ∈ ks := by
    rcases hnewk _ _ hslotA with h | ⟨_, h, _⟩
    · rw [hfreshA] at h; cases h
    · exact h
  -- the readback value: the cut's token
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref 79)) = some (F64.ofNat ((firstContext M K env CF.tab leaves typed
      (hpOf M K env leaves typed parameters CF.tab)).run promptToken (i + 1) (by omega)).token.val) := by
    have := hend.srv.num 79 _ h79
    change CSrv.val ⟨CF.tab⟩ (MF.num 79) = _
    rw [this]
    show some (F64.ofNat (tk (i + 1))) = _
    rw [htk (i + 1) (by omega), recurrence_token_table_eq M K env [] CF.tab leaves typed parameters
      (hpOf M K env leaves typed parameters CF.tab) (i + 1) (by omega)]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · intro k h1 h2 hb
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 h2 hb
    exact ⟨cs, out, ForwardAt.grow M K env leaves typed _ _ _ _ hf hgrow ho hc⟩
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
      have := ((firstContext M K env CF.tab leaves typed (hpOf M K env leaves typed parameters CF.tab)).run
        promptToken (i + 1) (by omega)).token.isLt
      omega
  · obtain ⟨hs, htok, hh, hcv, _, hlt, hcb⟩ := hG.cur hib
    rw [hnode]
    exact ForwardAt.grow M K env leaves typed _ _ _ _ ⟨hs, htok, hh, hcv⟩ hgrow hlt hcb

/-- **The exit case's graph step with the program's final caches**: the goal `GFC (i + 2)`. -/
theorem egstepC_of {okA okB : St Sim.LF.S → SSrv → Bool} {s0 : St Sim.LF.S} {tab0 : List SymE} {cE aN : Nat}
    (fixA : List Nat) (ec : Sim.ExitCase okA okB s0 s0 tab0 cE aN []) (ρ : Nat → F64) (T : Nat)
    (tk : Nat → Nat) (toks : List NumV) (i : Nat)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hib : i + 2 ≤ 262144)
    (hsA : s0.ffi.mlx.items.get tplInputs.read = none)
    (hpA : (s0.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hfA : ec.sF.ffi.mlx.items.get tplInputs.read = some (.ref 79))
    (hpfA : (ec.sF.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : ec.sF.ffi.mlx.tokens = [])
    (h79 : nth? ec.SF.tab 79 = some (.var 14))
    (hc : Host.Load.Run.Tpl.cacheCell ∈ fixA)
    (hpres : (ec.sF.heap.get Host.Load.Run.Tpl.cacheCell).isSome = true) {aC : Nat}
    (hbind : bindingOf ec.sF (entryEnv Host.Load.Run.Full.P.s0) chars!"cache" = some (.obj aC))
    (hne : [2673447, 12502, aN].contains aC = false)
    (hok : cachesAllB ec.sF (entryEnv Host.Load.Run.Full.P.s0) cacheOkB = true) {cs : List Cache}
    (hcs : cachesT ec.sF (entryEnv Host.Load.Run.Full.P.s0) = some cs) (hn : cs.map nodePair = tplCaches) :
    Sim.ExitGStep (Gx M K env leaves typed parameters tplInputs) Sim.loadP0 fixA ec ρ T tk toks i
      (fun tF CF => GFC M K env leaves typed parameters (i + 2) CF.tab tF) := by
  intro nx Mp Kc t Cs MF KF tF CF hGx hfixA hst _ _ _ hrun fr hext _ _ hKF hend
  obtain ⟨hgf, hfwd⟩ := egstep_core M K env leaves typed parameters Sim.loadP0 ec ρ T tk toks tplInputs i htk hib
    hsA hpA hfA hpfA hs0tok hsFtok h79 nx Mp Kc t Cs MF KF tF CF hGx hst _ hrun fr hext hend
  have hfix : MF.a Host.Load.Run.Tpl.cacheCell = Host.Load.Run.Tpl.cacheCell := by
    rw [hext.a]; exact hfixA _ hc
  obtain ⟨cs', hcs', hn'⟩ := Host.Load.Run.Tpl.final_cache hend hfix hKF hpres hbind hne hok hcs hn
  refine ⟨hgf, fun hb => ⟨cs', _, hcs', forwardAt_congr M K env leaves typed hfwd ?_⟩⟩
  rw [cachesAt_nodes]
  exact hn'.symm

/-! ## EOS at the final iteration's look-ahead token -/

/-- **The final iteration's graph conclusions at a halt `sF`/`SF`** (`fgstep_core`, for any
case ending there). -/
theorem fgstep_core_at {s0 : St Sim.LF.S} {tab0 : List SymE} (sF : St Sim.LF.S) (SF : SSrv)
    (P : Sim.LoadP) (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat)
    (toks : List NumV) (I : TplInputs)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hT : 2 ≤ T) (hTb : T ≤ 262144) (hne : I.read ≠ I.fed)
    (hsA : s0.ffi.mlx.items.get I.read = none) (hsB : s0.ffi.mlx.items.get I.fed = none)
    (hpA : (s0.ffi.mlx.nodes.get I.read).isSome = true) (hpB : (s0.ffi.mlx.nodes.get I.fed).isSome = true)
    (hfA : sF.ffi.mlx.items.get I.read = some (.ref 79))
    (hfB : sF.ffi.mlx.items.get I.fed = some (.ref tab0.length))
    (hpfA : (sF.ffi.mlx.nodes.get I.read).isSome = true) (hpfB : (sF.ffi.mlx.nodes.get I.fed).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : sF.ffi.mlx.tokens = [])
    (h79 : nth? SF.tab 79 = some (.var 14)) (h17 : nth? SF.tab tab0.length = some (.var 17))
    (hlen : T - 2 < toks.length) (nx : Nat) (Mp : Sim.Map) (Kc : Sim.Ctx) (t : St Sim.LF.S) (Cs : CSrv)
    (MF : Sim.Map) (KF : Sim.Ctx) (tF : St Sim.LF.S) (CF : CSrv)
    (hGx : Gx M K env leaves typed parameters I (T - 2) Mp t Cs)
    (hst : Sim.Rel Sim.LF (Sim.LR P (toks.drop (T - 2))) Mp
      (Sim.loopVal ρ T T (T - 2) (Sim.cap (T - 2)) (tk (T - 1)) (tk (T - 2)) nx) Kc s0 ⟨tab0, []⟩ t Cs)
    (n : Nat) (hrun : runC Sim.LF n t Cs = some (tF, CF)) (fr : Host.Mlx.Ffi.NGrow t.ffi.mlx tF.ffi.mlx)
    (hext : Sim.Ext (Mp.setNum tab0.length toks[T - 2]) MF (tab0.length + 1))
    (hend : Sim.Rel Sim.LF (Sim.LR P (toks.drop (T - 1))) MF
      (Sim.loopVal ρ T T (T - 2) (Sim.cap (T - 2)) (tk (T - 1)) (tk (T - 2)) (tk T)) KF sF SF tF CF) :
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

/-- **An EOS final case's graph step with the program's final caches**: the goal `GFC T`. -/
theorem fgstepEC_of {okA okB : St Sim.LF.S → SSrv → Bool} {s0 : St Sim.LF.S} {tab0 : List SymE} {cE aN : Nat}
    (fixA : List Nat)
    (ec : Sim.ExitCase okA okB s0 (Sim.finalStart s0 tab0.length) (tab0 ++ [.var 17]) cE aN [.num (.ref 79)])
    (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (toks : List NumV)
    (htk : ∀ j (h : j ≤ 262144), tk j = ((firstContext M K env [] leaves typed parameters).run promptToken j h).token.val)
    (hT : 2 ≤ T) (hTb : T ≤ 262144)
    (hsA : s0.ffi.mlx.items.get tplInputs.read = none) (hsB : s0.ffi.mlx.items.get tplInputs.fed = none)
    (hpA : (s0.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hpB : (s0.ffi.mlx.nodes.get tplInputs.fed).isSome = true)
    (hfA : ec.sF.ffi.mlx.items.get tplInputs.read = some (.ref 79))
    (hfB : ec.sF.ffi.mlx.items.get tplInputs.fed = some (.ref tab0.length))
    (hpfA : (ec.sF.ffi.mlx.nodes.get tplInputs.read).isSome = true)
    (hpfB : (ec.sF.ffi.mlx.nodes.get tplInputs.fed).isSome = true)
    (hs0tok : s0.ffi.mlx.tokens = [.ref 79]) (hsFtok : ec.sF.ffi.mlx.tokens = [])
    (h79 : nth? ec.SF.tab 79 = some (.var 14)) (h17 : nth? ec.SF.tab tab0.length = some (.var 17))
    (hc : Host.Load.Run.Tpl.cacheCell ∈ fixA)
    (hpres : (ec.sF.heap.get Host.Load.Run.Tpl.cacheCell).isSome = true) {aC : Nat}
    (hbind : bindingOf ec.sF (entryEnv Host.Load.Run.Full.P.s0) chars!"cache" = some (.obj aC))
    (hne : [2673447, 12502, aN].contains aC = false)
    (hok : cachesAllB ec.sF (entryEnv Host.Load.Run.Full.P.s0) cacheOkB = true) {cs : List Cache}
    (hcs : cachesT ec.sF (entryEnv Host.Load.Run.Full.P.s0) = some cs) (hn : cs.map nodePair = tplCaches) :
    Sim.FinalEGStep (Gx M K env leaves typed parameters tplInputs) Sim.loadP0 fixA ec ρ T tk toks
      (fun tF CF => GFC M K env leaves typed parameters T CF.tab tF) := by
  intro hlen nx Mp Kc t Cs MF KF tF CF hGx hfixA hst _ _ _ hrun fr hext _ _ hKF hend
  obtain ⟨hgf, hfwd⟩ := fgstep_core_at M K env leaves typed parameters ec.sF ec.SF Sim.loadP0 ρ T tk toks tplInputs
    htk hT hTb (by decide) hsA hsB hpA hpB hfA hfB hpfA hpfB hs0tok hsFtok h79 h17 hlen nx Mp Kc t Cs MF KF tF CF hGx
    hst _ hrun fr hext hend
  have hfix : MF.a Host.Load.Run.Tpl.cacheCell = Host.Load.Run.Tpl.cacheCell := by
    rw [hext.a]; exact hfixA _ hc
  obtain ⟨cs', hcs', hn'⟩ := Host.Load.Run.Tpl.final_cache hend hfix hKF hpres hbind hne hok hcs hn
  refine ⟨hgf, fun hb => ⟨cs', _, hcs', forwardAt_congr M K env leaves typed hfwd ?_⟩⟩
  rw [cachesAt_nodes]
  exact hn'.symm

end Host.Mlx.SimGraph.Iter
