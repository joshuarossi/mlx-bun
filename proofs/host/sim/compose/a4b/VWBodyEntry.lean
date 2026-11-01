import host.sim.compose.a4b.VWBodyCut
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The chain's later variables at the row's quantities, before the table mentions them. -/
def bindAll (i : Cls.Inst) (ν : Nat → F64) : List (Nat × Q) → Nat → F64
  | [] => ν
  | p :: m => upd (bindAll i ν m) p.1 (F64.ofNat (i.get p.2))

theorem bindAll_off {i : Cls.Inst} {ν : Nat → F64} {j : Nat} :
    ∀ {m : List (Nat × Q)}, (∀ p ∈ m, p.1 ≠ j) → bindAll i ν m j = ν j
  | [], _ => rfl
  | p :: m, h => by
    change upd (bindAll i ν m) p.1 _ j = _
    rw [upd_other _ _ (fun e => h p List.mem_cons_self e.symm)]
    exact bindAll_off (fun q hq => h q (List.mem_cons_of_mem _ hq))

theorem bindAll_on {i : Cls.Inst} {ν : Nat → F64} :
    ∀ {m : List (Nat × Q)} {p : Nat × Q}, (m.map Prod.fst).Nodup → p ∈ m →
      bindAll i ν m p.1 = F64.ofNat (i.get p.2)
  | q :: m, p, hn, hp => by
    change upd (bindAll i ν m) q.1 _ p.1 = _
    have hn' := List.nodup_cons.mp hn
    rcases List.mem_cons.mp hp with rfl | hp
    · exact upd_self _ _ _
    · have hne : p.1 ≠ q.1 := fun e => hn'.1 (e ▸ List.mem_map_of_mem hp)
      rw [upd_other _ _ hne]
      exact bindAll_on hn'.2 hp

theorem eval_bindAll {i : Cls.Inst} {ν : Nat → F64} (e : SymE) :
    ∀ {m : List (Nat × Q)}, (∀ p ∈ m, e.noVar p.1 = true) → e.eval (bindAll i ν m) = e.eval ν
  | [], _ => rfl
  | p :: m, h => by
    change e.eval (upd (bindAll i ν m) p.1 _) = _
    rw [SymE.eval_upd _ _ _ e (h p List.mem_cons_self)]
    exact eval_bindAll e (fun q hq => h q (List.mem_cons_of_mem _ hq))

/-- **The entry to the chain's map.** The table at the start mentions none of `rest`, so binding them
to the row's quantities keeps the relation; every later check reads one map. -/
theorem bindRest {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {x0 : SegInst FF}
    {Θ : List Nat × List SymE} {O : BodyOff} (hJ : O.J = 0)
    {m rest : List (Nat × Q)} {s : St FF.S} {S : SSrv}
    (hfree : ∀ e ∈ S.tab, ∀ p ∈ rest, e.noVar p.1 = true) (hnd : (rest.map Prod.fst).Nodup)
    (hdisj : ∀ p ∈ rest, ∀ q ∈ m, q.1 ≠ p.1) (hlow : ∀ p ∈ rest, 9 ≤ p.1)
    (hbound : ∀ p ∈ rest, i.get p.2 ≤ 2 ^ 20) :
    CutConv (bodyCut NB T tk π i x0 Θ O m s S) (bodyCut NB T tk π i x0 Θ O (m ++ rest) s S) := by
  rintro x ⟨K0, hr, hb, hnat, hip, hins, hmap, -⟩ hB
  let y : SegInst FF := { x with ν := bindAll i x.ν rest }
  have hrel : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] y.M y.ν y.K s ⟨S.tab, []⟩ y.t y.C := by
    refine hr.withTab (by simp) ⟨fun j e he => ?_, fun _ h => nomatch h⟩
    rw [hr.srv.num j e he]
    exact (eval_bindAll e (hfree e (nth?_mem_some he))).symm
  have hval : VBOkF loopVB y.ν := by
    intro j
    change ∃ k ≤ 2 ^ 20, bindAll i x.ν rest j = F64.ofNat k
    by_cases hj : ∃ p ∈ rest, p.1 = j
    · obtain ⟨p, hp, rfl⟩ := hj
      exact ⟨_, hbound p hp, bindAll_on hnd hp⟩
    · have hoff : ∀ p ∈ rest, p.1 ≠ j := fun p hp e => hj ⟨p, hp, e⟩
      rw [bindAll_off hoff]
      exact hb.valuation j
  have hmap' : MapOk y.ν i (m ++ rest) := by
    apply Conv.mapOk_iff'.2
    intro p hp
    rcases List.mem_append.mp hp with hp | hp
    · change bindAll i x.ν rest p.1 = _
      rw [bindAll_off (fun q hq => hdisj q hq p hp)]
      exact (Conv.mapOk_iff'.1 hmap) p hp
    · exact bindAll_on hnd hp
  have hbook : BodyBook i π K0 y O.D :=
    { hb with valuation := hval }
  have hins' : setupInputs T tk y := by
    refine ⟨fun j hj => ?_, hins.2⟩
    change bindAll i x.ν rest j = _
    rw [bindAll_off (fun p hp => by have := hlow p hp; omega)]
    exact hins.1 j hj
  exact ⟨y, rfl, rfl, ⟨K0, hrel, hbook, hnat, hip, hins', hmap', by
    rw [hJ]
    simp only [List.take_zero]
    exact DefsOk.nil⟩, hB⟩

/-- A forward's end at its de-canonicalized table: the next chain's start, no canonical results left. -/
theorem endConv {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {x0 : SegInst FF}
    {vs : List Nat} {es : List SymE} {O : BodyOff} {m m' : List (Nat × Q)} {s s' : St FF.S} {S S' : SSrv}
    (hJv : vs.take O.J = vs) (hJe : es.take O.J = es) (hs : s' = s)
    (htab : S.tab.map (·.subst (Conv.compactθ vs es)) = S'.tab) (hm : ∀ p ∈ m', p ∈ m) :
    CutConv (bodyCut NB T tk π i x0 (vs, es) O m s S)
      (bodyCut NB T tk π i x0 ([], []) { O with J := 0 } m' s' S') := by
  subst hs
  rintro x ⟨K0, hr, hb, hnat, hip, hins, hmap, hdf⟩ hB
  have hdf' : DefsOk vs es x.ν := by
    change DefsOk (vs.take O.J) (es.take O.J) x.ν at hdf
    rwa [hJv, hJe] at hdf
  have h := hr.decanon hdf'.nth
  have e : (⟨(⟨S.tab, []⟩ : SSrv).tab.map (·.subst (Conv.compactθ vs es)), (⟨S.tab, []⟩ : SSrv).oracle⟩ : SSrv) =
      ⟨S'.tab, []⟩ := congrArg (fun tab => (⟨tab, []⟩ : SSrv)) htab
  rw [e] at h
  exact ⟨x, rfl, rfl, ⟨K0, h, hb, hnat, hip, hins, MapOk.sub hmap hm, DefsOk.nil⟩, hB⟩

/-- **A forward at the graph's hypothesis.** Its run from every start, kept by the trail, and what the
graph concludes from the trail's facts: the retained property across the forward. -/
theorem forwardMem {A ret : ICut FF} {n : Nat} {Mem Mem' : SegInst FF → Prop}
    (hstep : ∀ x0, CutStep (withMem (BodyTrail x0) A) (withMem (BodyTrail x0) ret) n)
    (hfwd : ∀ x y, A.R x A.s0 ⟨A.tab0, []⟩ → A.B x → ret.R y ret.s0 ⟨ret.tab0, []⟩ →
      (∀ k, k < bodyN0 → y.M.node k = x.M.node k) → runC FF n x.t x.C = some (y.t, y.C) →
      Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens →
      Mem x → Mem' y) :
    CutStep (withMem Mem A) (withMem Mem' ret) n := by
  rintro t C ⟨x, rfl, rfl, hR, hB, hm⟩
  obtain ⟨t', C', hrun, y, rfl, rfl, hR', hB', htr⟩ :=
    hstep x x.t x.C ⟨x, rfl, rfl, hR, hB, BodyTrail.refl x⟩
  exact ⟨_, _, hrun, y, rfl, rfl, hR', hB', hfwd x y hR hB hR' htr.1 hrun htr.2.1 htr.2.2 hm⟩

end Host.Ts.Sim.Compose.VWFirst
