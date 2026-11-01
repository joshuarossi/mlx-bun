import host.sim.compose.a4b.VWG2
import host.sim.compose.a4b.SetupCommonStart
import host.sim.compose.Rebind
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl tokens41 : (mlxOf PRE_first_tail_x15_r0.s41.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl bodyFresh10 : PRE_first_tail_x15_r0.S41.tab.all (·.noVar 10) = true

/-- The native nodes every VW forward starts with. -/
abbrev bodyN0 : Nat := 15236
kernel_rfl bodyN0Eq : (mlxOf PRE_first_tail_x15_r0.s41.ffi).nnext = bodyN0

/-- What a body boundary keeps from the forward's start `x0`: the nodes it saw are where they were,
the native state has only grown, the token queue is untouched. A forward's compactions move only
nodes made during the forward, so this is what its end knows about its start. -/
def BodyTrail (x0 x : SegInst FF) : Prop :=
  (∀ k, k < bodyN0 → x.M.node k = x0.M.node k) ∧
    Host.Mlx.Ffi.NGrow (mlxOf x0.t.ffi) (mlxOf x.t.ffi) ∧ (mlxOf x.t.ffi).tokens = (mlxOf x0.t.ffi).tokens ∧
    x.M.a 12504 = x0.M.a 12504

theorem BodyTrail.refl (x : SegInst FF) : BodyTrail x x :=
  ⟨fun _ _ => rfl, Host.Mlx.Ffi.NGrow.refl _, rfl, rfl⟩

theorem BodyTrail.step {x0 x y : SegInst FF} (h : BodyTrail x0 x)
    (hn : ∀ k, k < bodyN0 → y.M.node k = x.M.node k) (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi))
    (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens) (ha : y.M.a 12504 = x.M.a 12504) : BodyTrail x0 y :=
  ⟨fun k hk => (hn k hk).trans (h.1 k hk), h.2.1.trans hg, ht.trans h.2.2.1, ha.trans h.2.2.2⟩

/-- A chain started from `s1` with the queue it already holds starts at `s1`. -/
theorem startEqOf {s s1 : St FF.S} {l : List NumV} (ht : (mlxOf s1.ffi).tokens = l)
    (h : s = s1.setFfi (fullSetTokens s1.ffi l)) : s = s1 := by
  have hf : fullSetTokens s1.ffi l = s1.ffi :=
    (congrArg (fullSetTokens s1.ffi) ht.symm).trans (SetupCommon.fullSetTokens_self s1.ffi)
  exact h.trans ((congrArg (fun z : FF.S => s1.setFfi z) hf).trans rfl)

/-- A VW chain's start is the prefix's end. -/
theorem bodyStartEqOf {s : St FF.S}
    (h : s = PRE_first_tail_x15_r0.s41.setFfi (fullSetTokens PRE_first_tail_x15_r0.s41.ffi [.ref 1, .ref 2])) :
    s = PRE_first_tail_x15_r0.s41 :=
  startEqOf tokens41 h

def bodyMap : List (Nat × Q) := [(9, .L), (10, .n)]

noncomputable def bodyStartCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst)
    (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K s S x.t x.C ∧
    ForwardBook i π K0 x 3571 ∧ InputAt (π.take i.n) (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν i bodyMap ∧
    Disp.KpJ (VWFrames.typedJ (tokenBytes (π.take i.n)) (π.take i.n).length) VWFrames.bodyD0 x.K
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt 0 0 s x.t

theorem toBody {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {x0 : SegInst FF}
    {s : St FF.S} {S : SSrv} (hs : s = PRE_first_tail_x15_r0.s41)
    (htab : S.tab = PRE_first_tail_x15_r0.S41.tab.map (·.subst (fun v => if v = 1087 then .var 10 else .var v)))
    (hn : i.n ≤ loopVB 10) :
    CutConv (withMem (BodyTrail x0) (forwardCut NB T tk π i)) (withMem (BodyTrail x0) (bodyStartCut NB T tk π i s S)) := by
  rintro x ⟨K0, hr, hb, hip, hins, hmap⟩ ⟨⟨hfresh, hids, hnat⟩, htr⟩
  have hv : x.ν 1087 = F64.ofNat i.n := hmap.2.1
  have hval := bindQuantity (v := 10) (c := i.n) (q := Q.n) hb.valuation hmap
    (by
      intro p hp
      simp only [npsMap, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> decide) rfl hn
  let y : SegInst FF := { x with ν := upd x.ν 10 (F64.ofNat i.n) }
  have hrel := hr.rebindVar (old := 1087) (fresh := 10) (by decide)
    (fun e he => List.all_eq_true.mp bodyFresh10 e he) (newOracle := []) (fun _ h => nomatch h)
  rw [hv] at hrel
  have ep : ((s : St FF.S), (⟨S.tab, []⟩ : SSrv)) =
      (PRE_first_tail_x15_r0.s41,
        ⟨PRE_first_tail_x15_r0.S41.tab.map (·.subst (fun v => if v = 1087 then .var 10 else .var v)), []⟩) :=
    Prod.ext hs (congrArg (fun tab => (⟨tab, []⟩ : SSrv)) htab)
  have hrel' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] y.M y.ν y.K
      s ⟨S.tab, []⟩ y.t y.C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF
      (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] y.M y.ν y.K p.1 p.2 y.t y.C) ep).mpr hrel
  have book : ForwardBook i π K0 y 3571 := by
    refine ⟨hb.length, hb.vocab, hval.1, ?_, hb.context, hb.incoming, hb.incomingPrompt, hb.incomingMemo,
      hb.frames, hb.offset, hb.lo, hb.hi, hb.inputEvent⟩
    change upd x.ν 10 (F64.ofNat i.n) 1087 = _
    rw [upd_other _ _ (by decide)]
    exact hb.rows
  have inputs : setupInputs T tk y := by
    refine ⟨?_, hins.2⟩
    intro j hj
    change upd x.ν 10 (F64.ofNat i.n) j = _
    rw [upd_other _ _ (by omega)]
    exact hins.1 j hj
  have hmap' : MapOk y.ν i bodyMap := MapOk.sub hval.2 (by
    intro p hp
    simp only [bodyMap, List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl <;> simp [npsMap])
  have hk : Disp.KpJ (VWFrames.typedJ (tokenBytes (π.take i.n)) (π.take i.n).length) VWFrames.bodyD0 y.K :=
    ⟨hb.context.1, Nat.le_trans hb.context.2 (by decide)⟩
  have hnat' : NativeAt 0 0 s y.t := by
    rw [hs]
    exact hnat
  exact ⟨y, rfl, rfl, ⟨K0, hrel', book, hip, inputs, hmap', hk⟩, ⟨hfresh, hids, hnat'⟩, htr⟩

end Host.Ts.Sim.Compose.VWFirst
