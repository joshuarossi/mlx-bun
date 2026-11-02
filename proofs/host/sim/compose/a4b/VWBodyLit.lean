import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.VWLit
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-! # The body's stretches over a literal prompt length

`bodyGlue` and `bodyToCall` at `VWFrames.bodyLitOk`. The bridges and stages don't read the acceptance, or take it as a parameter. -/

/-- A checked glue stretch of the body, under the body's acceptance for every token buffer. -/
theorem bodyLitGlue {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Θ : List Nat × List SymE} {Tr : SegInst FF → Prop} {O : BodyOff} {n : Nat}
    {m : List (Nat × Q)} {sa sb : St FF.S} {Sa Sb : SSrv}
    (ha : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows sa Sa) = fun _ _ => true)
    (hrun : ∀ (bs : List Byte) (rows : Nat), runOk FF (VWFrames.bodyLitOk bs rows) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true) (hgood : ∀ ν, MapOk ν i m → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sb = true) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (bodyCore NB T tk π i Θ O m sa Sa)) (withMem Tr (bodyCore NB T tk π i Θ O m sb Sb)) n := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hnat, hip, hins, hmap, hdf⟩, ⟨hfresh, hids⟩, htr⟩
  have hok := congrFun (congrFun ha (tokenBytes (π.take i.n))) (π.take i.n).length
  obtain ⟨M', t', C', hrun', hext, hm'⟩ := D1Advance.run
    (bodyLitSim NB T tk (tokenBytes (π.take i.n)) (π.take i.n).length []) hb.context hb.valuation
    (hgood x.ν hmap) hok (hrun _ _) htop hr
  have hgs := bodyLitGrowSim NB T tk (tokenBytes (π.take i.n)) (π.take i.n).length []
  have ng := glue_ngrow hgs hok (hrun _ _) hb.valuation hb.context (hr.withOracle (hgood x.ν hmap)) hrun'
  have ip : InputAt (π.take i.n) (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun')
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨K0, hm', hb.ext hext, hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hm' hext.big hext.node hcnt, ip, setupInputs_ext hins hext, hmap, hdf⟩,
    ⟨bodyFresh hr hm' hi hbr hfresh, fixedCells_ext hids hext⟩,
    hT x _ ⟨runC_le _ _ _ _ _ hrun', hext.node, ng, tokens_of_grow hr hm' ng (countersOkB_tokens hcnt), congrFun hext.a 12504⟩ htr⟩

/-- A checked glue stretch and the step into the next bridge or call. -/
theorem bodyLitToCall {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Θ : List Nat × List SymE} {Tr : SegInst FF → Prop} {O : BodyOff} {n : Nat}
    {m : List (Nat × Q)} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    (ha : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows sa Sa) = fun _ _ => true)
    (hrun : ∀ (bs : List Byte) (rows : Nat), runOk FF (VWFrames.bodyLitOk bs rows) n sa Sa = some (sb, Sb))
    (hb' : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyLitOk bs rows sb Sb) = fun _ _ => true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true) (hgood : ∀ ν, MapOk ν i m → Good ν Sa.oracle)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi)
    (hcnt : countersOkB sa sc = true) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (bodyCore NB T tk π i Θ O m sa Sa)) (withMem Tr (bodyCore NB T tk π i Θ O m sc Sc)) (n + 1) := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hnat, hip, hins, hmap, hdf⟩, ⟨hfresh, hids⟩, htr⟩
  let bs := tokenBytes (π.take i.n)
  let rows := (π.take i.n).length
  have hok := congrFun (congrFun ha bs) rows
  have hok' := congrFun (congrFun hb' bs) rows
  have hg := hgood x.ν hmap
  obtain ⟨M', t', C', hrun', hext, hm'⟩ := D1Advance.call
    (bodyLitSim NB T tk bs rows []) hb.context hb.valuation hg hok (hrun _ _) hok' hh hs htop hr
  have ng := glueCall_ngrow (bodyLitGrowSim NB T tk bs rows [])
    hok (hrun _ _) hok' hh hs hb.valuation hb.context (hr.withOracle hg) hrun'
  have ip : InputAt (π.take i.n) (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun')
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨K0, hm', hb.ext hext, hnat.step (P := { setupP with rest := machReads T tk }) rfl hr hm' hext.big hext.node hcnt, ip, setupInputs_ext hins hext, hmap, hdf⟩,
    ⟨bodyFresh hr hm' hi hbr hfresh, fixedCells_ext hids hext⟩,
    hT x _ ⟨runC_le _ _ _ _ _ hrun', hext.node, ng, tokens_of_grow hr hm' ng (countersOkB_tokens hcnt), congrFun hext.a 12504⟩ htr⟩


end Host.Ts.Sim.Compose.VWFirst
