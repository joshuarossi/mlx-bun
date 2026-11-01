import host.sim.compose.a4b.VWBodyBase
import host.sim.template.a4pre_first_tail_x2_r0.States
import host.sim.template.a4pre_first_tail_x2_r0.H1
import host.sim.template.a4pre_first_tail_x2_r0.SiteL2
import host.sim.template.a4pre_first_tail_x2_r0.st2.Tpl
import host.sim.lin.Table
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-! # The class's cuts

To the dispatch this class runs the wide rows' prefix. Its own chain numbers the prefill's result 1008, the wide rows' 1087; the same
state, and the table up to that name. The book still reads 1087, so both are kept. -/

def npsMap : List (Nat × Q) := [(9, .L), (1087, .n), (1008, .n)]

noncomputable def typedCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (s : St FF.S) (S : SSrv) (i : Cls.Inst)
    (Dmax : Nat := 3540) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K s S x.t x.C ∧
    ForwardBook i π K0 x Dmax ∧ InputAt (π.take i.n) (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν i npsMap
  B := fun x => AneFresh x.t ∧ fixedCells x ∧ NativeAt 0 0 s x.t

noncomputable abbrev dispatchCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) :=
  typedCut NB T tk π PRE_first_tail_x2_r0.s38 PRE_first_tail_x2_r0.S38

kernel_rfl s19Eq : PRE_first_tail_x2_r0.s19 = PRE_first_tail_x15_r0.s19
kernel_rfl s38Eq : PRE_first_tail_x2_r0.s38 = PRE_first_tail_x15_r0.s38
kernel_rfl s38Fresh : PRE_first_tail_x15_r0.S38.tab.all (·.noVar 1008) = true
kernel_rfl s38Tab : PRE_first_tail_x15_r0.S38.tab.map (·.subst (fun v => if v = 1087 then .var 1008 else .var v)) = PRE_first_tail_x2_r0.S38.tab
kernel_rfl npsPromptEmpty : arrOf PRE_first_tail_x2_r0.s0 2665 = []

/-- The wide rows' dispatch cut, at this class's numbering. -/
theorem toDispatch {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Mem : SegInst FF → Prop}
    (hMem : ∀ x y, NTrack x y → Mem x → Mem y) (hn : i.n ≤ loopVB 1008) :
    CutConv (withMem Mem (VWFirst.dispatchCut NB T tk π i)) (withMem Mem (dispatchCut NB T tk π i)) := by
  rintro x ⟨K0, hr, hb, hip, hins, hmap⟩ ⟨⟨hfresh, hids, hnat⟩, hm⟩
  have hv : x.ν 1087 = F64.ofNat i.n := hb.rows
  have hval := bindQuantity (v := 1008) (c := i.n) (q := Q.n) hb.valuation hmap
    (by
      intro p hp
      simp only [VWFirst.npsMap, List.mem_cons, List.not_mem_nil, or_false] at hp
      rcases hp with rfl | rfl <;> decide) rfl hn
  let y : SegInst FF := { x with ν := upd x.ν 1008 (F64.ofNat i.n) }
  have hrel := hr.rebindVar (old := 1087) (fresh := 1008) (by decide)
    (fun e he => List.all_eq_true.mp s38Fresh e he) (newOracle := []) (fun _ h => nomatch h)
  rw [hv] at hrel
  have ep : ((PRE_first_tail_x2_r0.s38 : St FF.S), (⟨PRE_first_tail_x2_r0.S38.tab, []⟩ : SSrv)) =
      (PRE_first_tail_x15_r0.s38, ⟨PRE_first_tail_x15_r0.S38.tab.map (·.subst (fun v => if v = 1087 then .var 1008 else .var v)), []⟩) :=
    Prod.ext s38Eq (congrArg (fun tab => (⟨tab, []⟩ : SSrv)) s38Tab.symm)
  have hrel' : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] y.M y.ν y.K
      PRE_first_tail_x2_r0.s38 ⟨PRE_first_tail_x2_r0.S38.tab, []⟩ y.t y.C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF
      (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] y.M y.ν y.K p.1 p.2 y.t y.C) ep).mpr hrel
  have book : ForwardBook i π K0 y := by
    refine ⟨hb.length, hb.vocab, hval.1, ?_, hb.context, hb.incoming, hb.incomingPrompt, hb.incomingMemo,
      hb.frames, hb.offset, hb.lo, hb.hi, hb.inputEvent⟩
    change upd x.ν 1008 (F64.ofNat i.n) 1087 = _
    rw [upd_other _ _ (by decide)]
    exact hb.rows
  have inputs : setupInputs T tk y := by
    refine ⟨?_, hins.2⟩
    intro j hj
    change upd x.ν 1008 (F64.ofNat i.n) j = _
    rw [upd_other _ _ (by omega)]
    exact hins.1 j hj
  have hmap' : MapOk y.ν i npsMap := MapOk.sub hval.2 (by
    intro p hp
    simp only [npsMap, List.mem_cons, List.not_mem_nil, or_false] at hp
    rcases hp with rfl | rfl | rfl <;> simp [VWFirst.npsMap])
  have hnat' : NativeAt 0 0 PRE_first_tail_x2_r0.s38 y.t := by
    rw [s38Eq]
    exact hnat
  exact ⟨y, rfl, rfl, ⟨K0, hrel', book, hip, inputs, hmap'⟩, ⟨hfresh, hids, hnat'⟩, hMem x y (NTrack.conv rfl rfl rfl rfl) hm⟩

end Host.Ts.Sim.Compose.VWFirst.X2
