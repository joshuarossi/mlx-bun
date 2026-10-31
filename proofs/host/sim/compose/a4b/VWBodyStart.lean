import host.sim.compose.a4b.VWG2
import host.sim.compose.a4b.SetupCommonStart
import host.sim.compose.Rebind
import host.sim.template.a4pre_first_tail_x15_r0_body.S0Eq
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl tokens41 : (mlxOf PRE_first_tail_x15_r0.s41.ffi).tokens = [.ref 1, .ref 2]
kernel_rfl bodyFresh10 : PRE_first_tail_x15_r0.S41.tab.all (·.noVar 10) = true

theorem bodyStartEq : (PRE_first_tail_x15_r0_body.s0 : St FF.S) = PRE_first_tail_x15_r0.s41 := by
  have hf : fullSetTokens PRE_first_tail_x15_r0.s41.ffi [.ref 1, .ref 2] = PRE_first_tail_x15_r0.s41.ffi :=
    (congrArg (fullSetTokens PRE_first_tail_x15_r0.s41.ffi) tokens41.symm).trans
      (SetupCommon.fullSetTokens_self PRE_first_tail_x15_r0.s41.ffi)
  have h : (PRE_first_tail_x15_r0_body.s0 : St FF.S) = PRE_first_tail_x15_r0.s41.setFfi
      (fullSetTokens PRE_first_tail_x15_r0.s41.ffi [.ref 1, .ref 2]) := PRE_first_tail_x15_r0_body.s0_tok
  exact h.trans ((congrArg (fun z : FF.S => (PRE_first_tail_x15_r0.s41 : St FF.S).setFfi z) hf).trans rfl)

def bodyMap : List (Nat × Q) := [(9, .L), (10, .n)]

noncomputable def bodyStartCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) : ICut FF where
  s0 := PRE_first_tail_x15_r0_body.s0
  tab0 := PRE_first_tail_x15_r0_body.S0.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K s S x.t x.C ∧
    ForwardBook i π K0 x 3571 ∧ InputAt (π.take i.n) (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν i bodyMap ∧
    Disp.KpJ (VWFrames.typedJ (tokenBytes (π.take i.n)) (π.take i.n).length) VWFrames.bodyD0 x.K
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt 0 0 PRE_first_tail_x15_r0_body.s0 x.t

theorem toBody {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} (hn : i.n ≤ loopVB 10) :
    CutConv (forwardCut NB T tk π i) (bodyStartCut NB T tk π i) := by
  rintro x ⟨K0, hr, hb, hip, hins, hmap⟩ ⟨hfresh, hids, hnat⟩
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
  have ep : ((PRE_first_tail_x15_r0_body.s0 : St FF.S), (⟨PRE_first_tail_x15_r0_body.S0.tab, []⟩ : SSrv)) =
      (PRE_first_tail_x15_r0.s41,
        ⟨PRE_first_tail_x15_r0.S41.tab.map (·.subst (fun v => if v = 1087 then .var 10 else .var v)), []⟩) :=
    Prod.ext bodyStartEq (congrArg (fun tab => (⟨tab, []⟩ : SSrv)) PRE_first_tail_x15_r0_body.s0_tab)
  have hrel' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] y.M y.ν y.K
      PRE_first_tail_x15_r0_body.s0 ⟨PRE_first_tail_x15_r0_body.S0.tab, []⟩ y.t y.C :=
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
  have hnat' : NativeAt 0 0 PRE_first_tail_x15_r0_body.s0 y.t := by
    rw [bodyStartEq]
    exact hnat
  exact ⟨y, rfl, rfl, ⟨K0, hrel', book, hip, inputs, hmap', hk⟩, hfresh, hids, hnat'⟩

end Host.Ts.Sim.Compose.VWFirst
