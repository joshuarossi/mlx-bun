import host.simgraph.world.Mach
import host.simgraph.mach.Vals
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Mlx.SimGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
open Host.Mlx.SimGraph.Iter (Gr TplInputs cachesAt cacheAt CachesBelow cachesAt_comp cachesAt_below
  mem_of_length_le_one mem_of_length_le_two)
open Host.Mlx.SimGraph.Mach (MRef CacheValuesV ReadbackValuesV)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # The decode loop's graph side at the route's values

`host.simgraph.world.Mach` restated at a value function `V : Vals` (`host.simgraph.mach.Vals`), instantiated by the
route's values `routeVals`: `GIMV`, `GxV`, `gi_nextV`, `GFV`, the halts' `fgstep_coreV`, `lgstep_ofV`, `lgstepC_ofV`,
`egstep_coreV`, `cgstep_ofV`. The carriers, the templates and the frames are the originals'; only the values read at
the carriers change. -/

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C) (env : FfiEval.Env InKey) (Vs : Mach.Vals)

/-! ## The invariant -/

/-- **The invariant at iteration `i` after a prompt of length `L` at the machine reference `R`**
(absolute time `L + i + 1`), at table `tab`, for the target's native state `x` under the node map
`σ` (`GIL`). -/
structure GIMV (I : TplInputs) (R : MRef) (L : Nat) (tab : List F64) (i : Nat) (σ : Nat → Nat)
    (x : Host.Mlx.Ffi.St) : Prop where
  ok : Vs.Ok x
  hist : ∀ k, L ≤ k → k ≤ L + i + 1 → ∃ cs out,
    Mach.ForwardAtV (Vs.val tab x) R tab k cs out ∧ out < x.nnext ∧ CachesBelow cs x.nnext
  read : ∃ cs, Mach.ForwardAtV (Vs.val tab x) R tab (L + i) cs (σ I.read) ∧ σ I.read < x.nnext ∧
    CachesBelow cs x.nnext
  cur : ∃ tok hs, R tab (L + i + 1) = some (tok, hs) ∧
    (∃ r, Vs.val tab x (σ I.fed) = some r ∧ itemUint32 r = some tok) ∧
    CacheValuesV (Vs.val tab x) (cachesAt σ I.caches) hs ∧
    CapsFor (Sim.capL (L + i + 1)) (stageWeights (weights (firstValues M K env tab))) hs ∧
    σ I.fed < x.nnext ∧ CachesBelow (cachesAt σ I.caches) x.nnext
  params : ∀ t ∈ parameterTensors parameterChoice,
    Vs.val tab x t.node = some (firstValues M K env tab t) ∧ t.node < x.nnext
  reads : ReadbackValuesV (Vs.val tab x) (CSrv.val ⟨tab⟩) x.items ∧ ∀ k, x.nnext ≤ k → x.items.get k = none

/-- **The loop's graph invariant after a prompt of length `L` at the machine reference** (`GxL`),
an invariant of the mlx state (`liftG Wd (GxV …)` over a world). -/
def GxV (I : TplInputs) (R : MRef) (L : Nat) : MlxInv :=
  fun i Mp x Cs => ∀ tab, Sim.CSrv.Le Cs ⟨tab⟩ → GIMV M K env Vs I R L tab i Mp.node x

/-- `GIMV` reads the node map only at the template's carriers. -/
theorem GIMV.congr {I : TplInputs} {R : MRef} {L : Nat} {tab : List F64} {i : Nat} {σ σ' : Nat → Nat}
    {x : Host.Mlx.Ffi.St} (h : GIMV M K env Vs I R L tab i σ x) (hr : σ' I.read = σ I.read) (hf : σ' I.fed = σ I.fed)
    (hc : cachesAt σ' I.caches = cachesAt σ I.caches) : GIMV M K env Vs I R L tab i σ' x where
  ok := h.ok
  hist := h.hist
  read := by rw [hr]; exact h.read
  cur := by rw [hf, hc]; exact h.cur
  params := h.params
  reads := h.reads

theorem forwardAtV_time {ev : Nat → Option Value} {R : MRef} {tab : List F64} {a b : Nat} (e : a = b) {cs : List Cache}
    {out : Nat} (h : Mach.ForwardAtV ev R tab a cs out) : Mach.ForwardAtV ev R tab b cs out := by
  subst e; exact h

/-- `ForwardAtV` reads its caches only through their tensor nodes. -/
theorem forwardAtV_congrC {ev : Nat → Option Value} {R : MRef} {tab : List F64} {time : Nat} {cs cs' : List Cache}
    {out : Nat} (h : Mach.ForwardAtV ev R tab time cs out)
    (hc : cs.map cacheNodePair = cs'.map cacheNodePair) : Mach.ForwardAtV ev R tab time cs' out := by
  obtain ⟨tok, hs, hR, htok, hv⟩ := h
  refine ⟨tok, hs, hR, htok, ?_⟩
  clear hR htok
  unfold CacheValuesV at hv ⊢
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

/-- A forward's result survives growth. -/
theorem forwardAtV_grow {R : MRef} {tab : List F64} {time : Nat} {cs : List Cache} {out : Nat} {x y : Host.Mlx.Ffi.St}
    (h : Mach.ForwardAtV (Vs.val tab x) R tab time cs out) (hok : Vs.Ok x) (hg : Host.Mlx.Ffi.NGrow x y)
    (hout : out < x.nnext) (hlt : CachesBelow cs x.nnext) : Mach.ForwardAtV (Vs.val tab y) R tab time cs out := by
  obtain ⟨tok, hs, hR, ⟨r, hr, ht⟩, hc⟩ := h
  exact ⟨tok, hs, hR, ⟨r, Vs.val_grow hok hg _ _ hout hr, ht⟩,
    hc.mono fun c hc' t ht' u hu => Vs.val_grow hok hg _ _ (hlt c hc' t ht') hu⟩

/-- **One iteration of the invariant** at the machine reference (`gi_nextL`). -/
theorem gi_nextV (I : TplInputs) (R : MRef) (L : Nat) (tab : List F64) (i : Nat)
    (σ σT : Nat → Nat) (x x1 : Host.Mlx.Ffi.St) (outT : Nat) (outs : List (Option Nat × Option Nat))
    (hG : GIMV M K env Vs I R L tab i σ x)
    (hgrow : Host.Mlx.Ffi.NGrow x x1) (hn : x.nnext ≤ x1.nnext)
    (hnew : ∀ k v, x1.items.get k = some v → x.items.get k = some v ∨ (x.items.get k = none ∧ k = σ I.read ∧
      ∃ tok, (∃ hs, R tab (L + i) = some (tok, hs)) ∧ tok < 2 ^ 31 ∧ CSrv.val ⟨tab⟩ v = some (F64.ofNat tok)))
    (hyitems : ∀ k, x1.nnext ≤ k → x1.items.get k = none)
    (hfwd : ∃ tok next, R tab (L + i + 2) = some (tok, next) ∧
      (∃ r, Vs.val tab x1 (σ outT) = some r ∧ itemUint32 r = some tok) ∧
      CacheValuesV (Vs.val tab x1) (cachesAt σ outs) next ∧
      CapsFor (Sim.capL (L + i + 2)) (stageWeights (weights (firstValues M K env tab))) next)
    (hout : σ outT < x1.nnext) (houts : CachesBelow (cachesAt σ outs) x1.nnext)
    (hread : σT I.read = I.fed) (hfed : σT I.fed = outT)
    (hcaches : I.caches.map (fun p => (p.1.map σT, p.2.map σT)) = outs) :
    GIMV M K env Vs I R L tab (i + 1) (fun j => σ (σT j)) x1 where
  ok := Vs.ok_grow hG.ok hgrow
  hist := by
    intro k h1 h2
    by_cases hk2 : k ≤ L + i + 1
    · obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 hk2
      refine ⟨cs, out, forwardAtV_grow Vs hf hG.ok hgrow ho hc, by omega, ?_⟩
      intro c hc' t ht; have := hc c hc' t ht; omega
    · have hk3 : k = L + i + 2 := by omega
      subst hk3
      obtain ⟨tok, next, hR, htok, hc, _⟩ := hfwd
      exact ⟨cachesAt σ outs, σ outT, ⟨tok, next, hR, htok, hc⟩, hout, houts⟩
  read := by
    obtain ⟨tok, hs, hR, htok, hc, _, hf, hcb⟩ := hG.cur
    refine ⟨cachesAt σ I.caches, ?_, ?_, ?_⟩
    · simp only [hread]
      exact forwardAtV_grow Vs ⟨tok, hs, hR, htok, hc⟩ hG.ok hgrow hf hcb
    · simp only [hread]; omega
    · intro c hc' t ht; have := hcb c hc' t ht; omega
  cur := by
    obtain ⟨tok, next, hR, htok, hc, hcaps⟩ := hfwd
    have he : cachesAt (fun j => σ (σT j)) I.caches = cachesAt σ outs := by
      rw [← hcaches, cachesAt_comp]
    refine ⟨tok, next, hR, ?_, by rw [he]; exact hc, hcaps, by simp only [hfed]; exact hout, by rw [he]; exact houts⟩
    simp only [hfed]
    exact htok
  params := by
    intro t ht
    obtain ⟨hv, hlt⟩ := hG.params t ht
    exact ⟨Vs.val_grow hG.ok hgrow _ _ hlt hv, by omega⟩
  reads := by
    refine ⟨?_, hyitems⟩
    intro k v hk
    rcases hnew k v hk with hx | ⟨_, rfl, tok, ⟨hs0, hR0⟩, hb, hν⟩
    · obtain ⟨token, htk, ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < x.nnext := by
        by_contra hc
        rw [hG.reads.2 k (by omega)] at hx
        cases hx
      exact ⟨token, htk, ⟨r, Vs.val_grow hG.ok hgrow _ _ hlt hr, hi⟩, hν⟩
    · obtain ⟨cs, ⟨tok', hs', hR', ⟨r, hr, hi⟩, _⟩, hlt, _⟩ := hG.read
      obtain ⟨rfl, -⟩ := Prod.mk.inj (Option.some.inj (hR'.symm.trans hR0))
      exact ⟨tok', hb, ⟨r, Vs.val_grow hG.ok hgrow _ _ hlt hr, hi⟩, hν⟩

/-! ## The halts -/

section Steps
variable {Wd : Sim.World} (pr : GraphProj Wd) {A : Sim.Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE}

/-- **The halted target's conclusions at the machine reference** (`GFL`): the forward result of
every time `L … L + T - 1` and the memoized readbacks' values. -/
def GFV (R : MRef) (L T : Nat) (tab : List F64) (x : Host.Mlx.Ffi.St) : Prop :=
  (∀ k, L ≤ k → k ≤ L + T - 1 → ∃ cs out, Mach.ForwardAtV (Vs.val tab x) R tab k cs out) ∧
  ReadbackValuesV (Vs.val tab x) (CSrv.val ⟨tab⟩) x.items

theorem GFV.mono {R : MRef} {L T T' : Nat} {tab : List F64} {x : Host.Mlx.Ffi.St} (h : GFV Vs R L T tab x)
    (hT : T' ≤ T) : GFV Vs R L T' tab x :=
  ⟨fun k h1 h2 => h.1 k h1 (by omega), h.2⟩

/-- **The final iteration's graph conclusions at a halt `sF`/`SF`** at the machine reference
(`fgstep_core_atA` over a world): `GFV` at the halt, and the time-`L + T - 1` forward result at
the images of the template start's carriers. -/
theorem fgstep_coreV (sF : St Wd.F.S) (SF : SSrv) (R : MRef) (L : Nat) (V : Sim.LoopVals)
    (T : Nat) (tk : Nat → Nat) (toks : List NumV) (I : TplInputs)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31)
    (hVk : V (T - 2) (tk T) A.kvar = F64.ofNat (tk (T - 2 + 1))) (hVn : V (T - 2) (tk T) A.nxt = F64.ofNat (tk T))
    (hT : 2 ≤ T) (hne : I.read ≠ I.fed)
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hsB : (Wd.toMlx s0.ffi).items.get I.fed = none)
    (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hpB : ((Wd.toMlx s0.ffi).nodes.get I.fed).isSome = true)
    (hfA : (Wd.toMlx sF.ffi).items.get I.read = some (.ref A.tok))
    (hfB : (Wd.toMlx sF.ffi).items.get I.fed = some (.ref tab0.length))
    (hpfA : ((Wd.toMlx sF.ffi).nodes.get I.read).isSome = true)
    (hpfB : ((Wd.toMlx sF.ffi).nodes.get I.fed).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx sF.ffi).tokens = [])
    (h79 : nth? SF.tab A.tok = some (.var A.kvar)) (h17 : nth? SF.tab tab0.length = some (.var A.nxt))
    (hlen : T - 2 < toks.length) {Mp MF : Sim.Map} {t tF : St Wd.F.S} {Cs CF : CSrv}
    (hGx : GxV M K env Vs I R L (T - 2) Mp (Wd.toMlx t.ffi) Cs)
    (hst : Sim.G.LoadR (pr.lp P (toks.drop (T - 2))) (pr.NB P) Mp tab0.length (pr.toLoad s0.ffi) (pr.toLoad t.ffi))
    (hle : Sim.CSrv.Le Cs CF) (fr : Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx tF.ffi))
    (hext : Sim.Ext (Mp.setNum tab0.length toks[T - 2]) MF (tab0.length + 1))
    (hend : Sim.G.LoadR (pr.lp P (toks.drop (T - 1))) (pr.NB P) MF SF.tab.length (pr.toLoad sF.ffi) (pr.toLoad tF.ffi))
    (hnumF : Sim.NumOK MF (V (T - 2) (tk T)) SF CF) :
    GFV Vs R L T CF.tab (Wd.toMlx tF.ffi) ∧
      Mach.ForwardAtV (Vs.val CF.tab (Wd.toMlx tF.ffi)) R CF.tab (L + T - 1) (cachesAt MF.node I.caches) (MF.node I.fed) := by
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr
  have mr0 : Sim.G.MR (pr.lp P (toks.drop (T - 2))) (pr.NB P) Mp tab0.length (Wd.toMlx s0.ffi) (Wd.toMlx t.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hst.mlx
  have mr1 : Sim.G.MR (pr.lp P (toks.drop (T - 1))) (pr.NB P) MF SF.tab.length (Wd.toMlx sF.ffi)
      (Wd.toMlx tF.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hend.mlx
  have hT2 : L + (T - 2) + 1 = L + T - 1 := by omega
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hdrop : toks.drop (T - 2) = toks[T - 2] :: toks.drop (T - 1) := by
    rw [List.drop_eq_getElem_cons hlen]
    congr 2
    omega
  have hpop : popped.length = 2 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok, pr.rest, pr.rest] at hpe
    have hpe' : Mp.nv (.ref A.tok) :: toks[T - 2] :: toks.drop (T - 1) = popped ++ toks.drop (T - 1) := by
      rw [← hdrop]; exact hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks2 : ks.length ≤ 2 := hpop ▸ hks
  have hslotA : (Wd.toMlx tF.ffi).items.get (MF.node I.read) = some (MF.nv (.ref A.tok)) := by
    rw [mr1.items I.read hpfA, hfA]; rfl
  have hslotB : (Wd.toMlx tF.ffi).items.get (MF.node I.fed) = some (MF.nv (.ref tab0.length)) := by
    rw [mr1.items I.fed hpfB, hfB]; rfl
  have hfreshA : (Wd.toMlx t.ffi).items.get (MF.node I.read) = none := by
    rw [hnode, mr0.items I.read hpA, hsA]; rfl
  have hfreshB : (Wd.toMlx t.ffi).items.get (MF.node I.fed) = none := by
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
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref A.tok)) = some (F64.ofNat (tk (T - 2 + 1))) := by
    change CSrv.val ⟨CF.tab⟩ (MF.num A.tok) = _
    rw [hnumF A.tok _ h79]
    show some (V (T - 2) (tk T) A.kvar) = _
    rw [hVk]
  have hvB : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref tab0.length)) = some (F64.ofNat (tk T)) := by
    change CSrv.val ⟨CF.tab⟩ (MF.num tab0.length) = _
    rw [hnumF tab0.length _ h17]
    show some (V (T - 2) (tk T) A.nxt) = _
    rw [hVn]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  rotate_left 2
  · obtain ⟨tok, hs, hR, htok, hcv, _, hlt, hcb⟩ := hG.cur
    rw [hnode]
    exact forwardAtV_time hT2
      (forwardAtV_grow Vs ⟨tok, hs, hR, htok, hcv⟩ hG.ok hgrow hlt hcb)
  · intro k h1 h2
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 (by omega)
    exact ⟨cs, out, forwardAtV_grow Vs hf hG.ok hgrow ho hc⟩
  · intro k v hk
    rcases hnewk k v hk with hx | ⟨_, hkk, _⟩
    · obtain ⟨token, htk', ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < (Wd.toMlx t.ffi).nnext := by
        by_contra hc
        cases (hG.reads.2 k (Nat.le_of_not_lt hc)).symm.trans hx
      exact ⟨token, htk', ⟨r, Vs.val_grow hG.ok hgrow _ _ hlt hr, hi⟩, hν⟩
    · rcases mem_of_length_le_two hks2 hinA hinB hneF hkk with rfl | rfl
      · rw [hslotA] at hk
        cases hk
        obtain ⟨cs, ⟨tok, hs, hR, ⟨r, hr, hi⟩, _⟩, hlt, _⟩ := hG.read
        obtain ⟨hs', hR'⟩ := htk CF.tab (T - 2) (by omega)
        obtain ⟨rfl, -⟩ := Prod.mk.inj (Option.some.inj (hR.symm.trans hR'))
        exact ⟨_, htkb (T - 2) (by omega), ⟨r, by rw [hnode]; exact Vs.val_grow hG.ok hgrow _ _ hlt hr, hi⟩,
          hvA⟩
      · rw [hslotB] at hk
        cases hk
        obtain ⟨tok, hs, hR, ⟨r, hr, hi⟩, _, _, hlt, _⟩ := hG.cur
        obtain ⟨hs', hR'⟩ := htk CF.tab (T - 1) (by omega)
        have e : L + (T - 2) + 1 = L + (T - 1) := by omega
        rw [e] at hR
        obtain ⟨rfl, -⟩ := Prod.mk.inj (Option.some.inj (hR.symm.trans hR'))
        rw [show T - 1 + 1 = T by omega] at hi
        exact ⟨_, by have := htkb (T - 1) (by omega); rwa [show T - 1 + 1 = T by omega] at this,
          ⟨r, by rw [hnode]; exact Vs.val_grow hG.ok hgrow _ _ hlt hr, hi⟩, hvB⟩

/-- **A final chain's graph obligation at the machine reference** (`lgstep_ofA` over a world): the
goal `GFV` at `T`. -/
theorem lgstep_ofV {W : Nat → Option Sim.WFrame} {fixA : List Nat} {T : Nat} {toks : List NumV} {xs : List Val}
    (hs : Sim.HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (I : TplInputs)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31)
    (hVk : V (T - 2) (tk T) A.kvar = F64.ofNat (tk (T - 2 + 1))) (hVn : V (T - 2) (tk T) A.nxt = F64.ofNat (tk T))
    (hT : 2 ≤ T) (hne : I.read ≠ I.fed)
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hsB : (Wd.toMlx s0.ffi).items.get I.fed = none)
    (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hpB : ((Wd.toMlx s0.ffi).nodes.get I.fed).isSome = true)
    (hfA : (Wd.toMlx hs.case.sF.ffi).items.get I.read = some (.ref A.tok))
    (hfB : (Wd.toMlx hs.case.sF.ffi).items.get I.fed = some (.ref tab0.length))
    (hpfA : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.read).isSome = true)
    (hpfB : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.fed).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx hs.case.sF.ffi).tokens = [])
    (h79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar))
    (h17 : nth? hs.case.SF.tab tab0.length = some (.var A.nxt)) :
    LastGStepM pr (fixA := fixA) (GxV M K env Vs I R L) hs V tk
      (fun tF CF => GFV Vs R L T CF.tab (Wd.toMlx tF.ffi)) := by
  intro hlen nx Mp Kc t Cs xF hGx _ hst _ _ _ hle fr hext hν hend
  obtain ⟨hR, -⟩ := hs.rend xF _ _ hend
  rw [hν] at hR
  exact (fgstep_coreV M K env Vs pr hs.case.sF hs.case.SF R L V T tk toks I htk htkb hVk hVn hT hne hsA hsB hpA hpB
    hfA hfB hpfA hpfB hs0tok hsFtok h79 h17 hlen hGx hst hle fr hext (pr.loadR hR) hR.srv.num).1

/-- **A final chain's graph obligation with the program's caches** at the machine reference
(`fgstepC_ofL` over a world): the goal `GFV` at `T`, and the `cache` binding's caches hold the
reference's handles at `L + T - 1`. -/
theorem lgstepC_ofV {W : Nat → Option Sim.WFrame} {fixA : List Nat} {T : Nat} {toks : List NumV} {xs : List Val}
    (hs : Sim.HaltSegW Wd A W P (toks.drop (T - 1)) s0 (Wd.finalStartW s0 tab0.length) (tab0 ++ [.var A.nxt]) xs)
    (R : MRef) (L : Nat) (V : Sim.LoopVals) (tk : Nat → Nat) (I : TplInputs) (je : Host.Ts.Env)
    (htk : ∀ tab j, j ≤ T - 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : ∀ j, j ≤ T - 1 → tk (j + 1) < 2 ^ 31)
    (hVk : V (T - 2) (tk T) A.kvar = F64.ofNat (tk (T - 2 + 1))) (hVn : V (T - 2) (tk T) A.nxt = F64.ofNat (tk T))
    (hT : 2 ≤ T) (hne : I.read ≠ I.fed)
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hsB : (Wd.toMlx s0.ffi).items.get I.fed = none)
    (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hpB : ((Wd.toMlx s0.ffi).nodes.get I.fed).isSome = true)
    (hfA : (Wd.toMlx hs.case.sF.ffi).items.get I.read = some (.ref A.tok))
    (hfB : (Wd.toMlx hs.case.sF.ffi).items.get I.fed = some (.ref tab0.length))
    (hpfA : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.read).isSome = true)
    (hpfB : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.fed).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx hs.case.sF.ffi).tokens = [])
    (h79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar))
    (h17 : nth? hs.case.SF.tab tab0.length = some (.var A.nxt)) (hc : FinalCacheW pr fixA I je hs) :
    LastGStepM pr (fixA := fixA) (GxV M K env Vs I R L) hs V tk
      (fun tF CF => GFV Vs R L T CF.tab (Wd.toMlx tF.ffi) ∧ ∃ cs out,
        Sim.ExtractSim.cachesT (tF.reFfi (pr.toLoad tF.ffi)) je = some cs ∧
          Mach.ForwardAtV (Vs.val CF.tab (Wd.toMlx tF.ffi)) R CF.tab (L + T - 1) cs out) := by
  intro hlen nx Mp Kc t Cs xF hGx hfix hst _ _ _ hle fr hext hν hend
  have hfix' : ∀ a ∈ fixA, xF.M.a a = a := fun a ha => by rw [hext.a]; exact hfix a ha
  obtain ⟨cs, hcs, hn⟩ := hc xF hfix' hend
  obtain ⟨hR, -⟩ := hs.rend xF _ _ hend
  rw [hν] at hR
  obtain ⟨h1, h2⟩ := fgstep_coreV M K env Vs pr hs.case.sF hs.case.SF R L V T tk toks I htk htkb hVk hVn hT hne hsA hsB
    hpA hpB hfA hfB hpfA hpfB hs0tok hsFtok h79 h17 hlen hGx hst hle fr hext (pr.loadR hR) hR.srv.num
  exact ⟨h1, cs, _, hcs, forwardAtV_congrC h2 ((Iter.cachesAt_nodes _ _).trans hn.symm)⟩

/-- **The graph conclusions of a halt at the cut of iteration `i`** at the machine reference
(`egstep_coreA` over a world). -/
theorem egstep_coreV (sF : St Wd.F.S) (SF : SSrv) (R : MRef) (L : Nat) (V : Sim.LoopVals)
    (tk : Nat → Nat) (toks : List NumV) (I : TplInputs) (i : Nat)
    (htk : ∀ tab j, j ≤ i + 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : tk (i + 1) < 2 ^ 31)
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hfA : (Wd.toMlx sF.ffi).items.get I.read = some (.ref A.tok))
    (hpfA : ((Wd.toMlx sF.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx sF.ffi).tokens = [])
    (h79 : nth? SF.tab A.tok = some (.var A.kvar))
    {nx : Nat} (hVk : V i nx A.kvar = F64.ofNat (tk (i + 1))) {Mp MF : Sim.Map} {t tF : St Wd.F.S} {Cs CF : CSrv}
    (hGx : GxV M K env Vs I R L i Mp (Wd.toMlx t.ffi) Cs)
    (hst : Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) Mp tab0.length (pr.toLoad s0.ffi) (pr.toLoad t.ffi))
    (hle : Sim.CSrv.Le Cs CF) (fr : Host.Mlx.Ffi.NGrow (Wd.toMlx t.ffi) (Wd.toMlx tF.ffi))
    (hext : Sim.Ext Mp MF tab0.length)
    (hend : Sim.G.LoadR (pr.lp P (toks.drop i)) (pr.NB P) MF SF.tab.length (pr.toLoad sF.ffi) (pr.toLoad tF.ffi))
    (hnumF : Sim.NumOK MF (V i nx) SF CF) :
    GFV Vs R L (i + 2) CF.tab (Wd.toMlx tF.ffi) ∧
      Mach.ForwardAtV (Vs.val CF.tab (Wd.toMlx tF.ffi)) R CF.tab (L + i + 1) (cachesAt MF.node I.caches) (MF.node I.fed) := by
  have hG := hGx CF.tab hle
  have hnode : MF.node = Mp.node := hext.node
  have hgrow := fr
  have mr0 : Sim.G.MR (pr.lp P (toks.drop i)) (pr.NB P) Mp tab0.length (Wd.toMlx s0.ffi) (Wd.toMlx t.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hst.mlx
  have mr1 : Sim.G.MR (pr.lp P (toks.drop i)) (pr.NB P) MF SF.tab.length (Wd.toMlx sF.ffi) (Wd.toMlx tF.ffi) := by
    rw [← pr.mlx, ← pr.mlx]; exact hend.mlx
  obtain ⟨popped, hpe, ks, hks, hnewk⟩ := fr.frame
  have hpop : popped.length = 1 := by
    rw [mr0.tokensX, mr1.tokensX, hs0tok, hsFtok, pr.rest] at hpe
    have hpe' : Mp.nv (.ref A.tok) :: toks.drop i = popped ++ toks.drop i := hpe
    have := congrArg List.length hpe'
    simp only [List.length_append, List.length_cons] at this
    omega
  have hks1 : ks.length ≤ 1 := hpop ▸ hks
  have hslotA : (Wd.toMlx tF.ffi).items.get (MF.node I.read) = some (MF.nv (.ref A.tok)) := by
    rw [mr1.items I.read hpfA, hfA]; rfl
  have hfreshA : (Wd.toMlx t.ffi).items.get (MF.node I.read) = none := by
    rw [hnode, mr0.items I.read hpA, hsA]; rfl
  have hinA : MF.node I.read ∈ ks := by
    rcases hnewk _ _ hslotA with h | ⟨_, h, _⟩
    · rw [hfreshA] at h; cases h
    · exact h
  have hvA : CSrv.val ⟨CF.tab⟩ (MF.nv (.ref A.tok)) = some (F64.ofNat (tk (i + 1))) := by
    change CSrv.val ⟨CF.tab⟩ (MF.num A.tok) = _
    rw [hnumF A.tok _ h79]
    show some (V i nx A.kvar) = _
    rw [hVk]
  refine ⟨⟨?_, ?_⟩, ?_⟩
  · intro k h1 h2
    obtain ⟨cs, out, hf, ho, hc⟩ := hG.hist k h1 (by omega)
    exact ⟨cs, out, forwardAtV_grow Vs hf hG.ok hgrow ho hc⟩
  · intro k v hk
    rcases hnewk k v hk with hx | ⟨_, hkk, _⟩
    · obtain ⟨token, htk', ⟨r, hr, hi⟩, hν⟩ := hG.reads.1 k v hx
      have hlt : k < (Wd.toMlx t.ffi).nnext := by
        by_contra hc
        cases (hG.reads.2 k (Nat.le_of_not_lt hc)).symm.trans hx
      exact ⟨token, htk', ⟨r, Vs.val_grow hG.ok hgrow _ _ hlt hr, hi⟩, hν⟩
    · obtain rfl := mem_of_length_le_one hks1 hinA hkk
      rw [hslotA] at hk
      cases hk
      obtain ⟨cs, ⟨tok, hs, hR, ⟨r, hr, hi⟩, _⟩, hlt, _⟩ := hG.read
      obtain ⟨hs', hR'⟩ := htk CF.tab i (by omega)
      obtain ⟨rfl, -⟩ := Prod.mk.inj (Option.some.inj (hR.symm.trans hR'))
      exact ⟨_, htkb, ⟨r, by rw [hnode]; exact Vs.val_grow hG.ok hgrow _ _ hlt hr, hi⟩, hvA⟩
  · obtain ⟨tok, hs, hR, htok, hcv, _, hlt, hcb⟩ := hG.cur
    rw [hnode]
    exact forwardAtV_grow Vs ⟨tok, hs, hR, htok, hcv⟩ hG.ok hgrow hlt hcb

/-- **A cut halt's graph obligation at the machine reference** (`cgstep_ofA` over a world): the
goal `GFV (i + 2)`. -/
theorem cgstep_ofV {W : Nat → Option Sim.WFrame} {fixA : List Nat} {toks : List NumV} {i : Nat}
    (hs : Sim.HaltSegW Wd A W P (toks.drop i) s0 s0 tab0 []) (R : MRef) (L : Nat) (V : Sim.LoopVals)
    (tk : Nat → Nat) (I : TplInputs)
    (htk : ∀ tab j, j ≤ i + 1 → ∃ hs, R tab (L + j) = some (tk (j + 1), hs))
    (htkb : tk (i + 1) < 2 ^ 31) (hVk : ∀ nx, V i nx A.kvar = F64.ofNat (tk (i + 1)))
    (hsA : (Wd.toMlx s0.ffi).items.get I.read = none) (hpA : ((Wd.toMlx s0.ffi).nodes.get I.read).isSome = true)
    (hfA : (Wd.toMlx hs.case.sF.ffi).items.get I.read = some (.ref A.tok))
    (hpfA : ((Wd.toMlx hs.case.sF.ffi).nodes.get I.read).isSome = true)
    (hs0tok : (Wd.toMlx s0.ffi).tokens = [.ref A.tok]) (hsFtok : (Wd.toMlx hs.case.sF.ffi).tokens = [])
    (h79 : nth? hs.case.SF.tab A.tok = some (.var A.kvar)) :
    CutGStepM pr (fixA := fixA) (GxV M K env Vs I R L) hs V
      (fun tF CF => GFV Vs R L (i + 2) CF.tab (Wd.toMlx tF.ffi)) := by
  intro nx Mp Kc t Cs xF hGx _ hst _ _ _ hle fr hext hν hend
  obtain ⟨hR, -⟩ := hs.rend xF _ _ hend
  rw [hν] at hR
  exact (egstep_coreV M K env Vs pr hs.case.sF hs.case.SF R L V tk toks I i htk htkb hsA hpA hfA hpfA hs0tok hsFtok
    h79 (hVk nx) hGx hst hle fr hext (pr.loadR hR) hR.srv.num).1

end Steps

end Host.Mlx.SimGraph
