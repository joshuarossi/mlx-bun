import host.sim.compose.a4b.VWBodyCut
import host.sim.compose.OracleTrim
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem bodyOk_oracle (bs : List Byte) (rows : Nat) (s : St FF.S) (S : SSrv) (O : List Ans) :
    VWFrames.bodyOk bs rows s { S with oracle := O } = VWFrames.bodyOk bs rows s S := rfl

/-- A checked glue stretch of the body: it needs only the answers it consumes. -/
theorem bodyGlue {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Dmax n : Nat}
    {m m' : List (Nat × Q)} {sa sb : St FF.S} {Sa Sb : SSrv}
    (ha : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows sa Sa) = fun _ _ => true)
    (hrun : ∀ (bs : List Byte) (rows : Nat), runOk FF (VWFrames.bodyOk bs rows) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (hgood : ∀ ν, MapOk ν i m → Good ν (Sa.oracle.take (Sa.oracle.length - Sb.oracle.length)))
    (hsub : ∀ p ∈ m', p ∈ m) (hi : (bridgeOf sa.ffi).active = false)
    (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi) :
    CutStep (bodyCut NB T tk π i Dmax m sa Sa) (bodyCut NB T tk π i Dmax m' sb Sb) n := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hip, hins, hmap⟩, hfresh, hids⟩
  let bs := tokenBytes (π.take i.n)
  let rows := (π.take i.n).length
  obtain ⟨U, hU⟩ := runOk_oracle_suffix (hrun bs rows)
  have hUt := oracle_take hU
  have hS : Sa.oracle = Sa.oracle.take (Sa.oracle.length - Sb.oracle.length) ++ Sb.oracle := by
    rw [← hUt]; exact hU
  have hrun' := runOk_drop_suffix (bodyOk_oracle bs rows) (hrun bs rows) _ Sb.oracle [] hS rfl
  have hok : VWFrames.bodyOk bs rows sa { Sa with oracle := Sa.oracle.take (Sa.oracle.length - Sb.oracle.length) } = true :=
    (bodyOk_oracle bs rows _ _ _).trans (congrFun (congrFun ha bs) rows)
  have hg := hgood x.ν hmap
  obtain ⟨M', t', C', hrun2, hext, hm'⟩ := D1Advance.run
    (bodySim NB T tk bs rows []) hb.context hb.valuation hg hok hrun' htop hr
  have hgs := typedGrowSimAt NB T tk bs rows VWFrames.bodyD0 []
  have ng := glue_ngrow hgs hok hrun' hb.valuation hb.context (hr.withOracle hg) hrun2
  have ip : InputAt (π.take i.n) (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun2)
  exact ⟨t', C', hrun2, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨K0, hm', hb.ext hext, ip, setupInputs_ext hins hext, MapOk.sub hmap hsub⟩,
    bodyFresh hr hm' hi hbr hfresh, fixedCells_ext hids hext⟩

/-- A checked glue stretch and the step into the next bridge or call. -/
theorem bodyToCall {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Dmax n : Nat}
    {m : List (Nat × Q)} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    (ha : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows sa Sa) = fun _ _ => true)
    (hrun : ∀ (bs : List Byte) (rows : Nat), runOk FF (VWFrames.bodyOk bs rows) n sa Sa = some (sb, Sb))
    (hb' : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows sb Sb) = fun _ _ => true)
    (hh : isHalt sb.ctl = false) (hs : interpS (step FF sb).run Sb = some (sc, Sc))
    (htop : noRetBlock sc = true)
    (hgood : ∀ ν, MapOk ν i m → Good ν (Sa.oracle.take (Sa.oracle.length - Sc.oracle.length)))
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sc.ffi = bridgeOf sa.ffi) :
    CutStep (bodyCut NB T tk π i Dmax m sa Sa) (bodyCut NB T tk π i Dmax m sc Sc) (n + 1) := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hip, hins, hmap⟩, hfresh, hids⟩
  let bs := tokenBytes (π.take i.n)
  let rows := (π.take i.n).length
  obtain ⟨U1, hU1⟩ := runOk_oracle_suffix (hrun bs rows)
  obtain ⟨U2, hU2⟩ := interpS_oracle_suffix _ _ _ _ hs
  have hU : Sa.oracle = (U1 ++ U2) ++ Sc.oracle := by rw [hU1, hU2, List.append_assoc]
  have hUt := oracle_take hU
  have hS : Sa.oracle = Sa.oracle.take (Sa.oracle.length - Sc.oracle.length) ++ Sc.oracle := by
    rw [← hUt]; exact hU
  have hrun' := runOk_drop_suffix (bodyOk_oracle bs rows) (hrun bs rows) _ Sc.oracle U2 hS hU2
  have hs' := interpS_drop_suffix _ _ _ _ hs U2 Sc.oracle [] hU2 rfl
  have hok : VWFrames.bodyOk bs rows sa { Sa with oracle := Sa.oracle.take (Sa.oracle.length - Sc.oracle.length) } = true :=
    (bodyOk_oracle bs rows _ _ _).trans (congrFun (congrFun ha bs) rows)
  have hok' : VWFrames.bodyOk bs rows sb { Sb with oracle := U2 } = true :=
    (bodyOk_oracle bs rows _ _ _).trans (congrFun (congrFun hb' bs) rows)
  have hg := hgood x.ν hmap
  obtain ⟨M', t', C', hrun2, hext, hm'⟩ := D1Advance.call
    (bodySim NB T tk bs rows []) hb.context hb.valuation hg hok hrun' hok' hh hs' htop hr
  have ng := glueCall_ngrow (typedGrowSimAt NB T tk bs rows VWFrames.bodyD0 [])
    hok hrun' hok' hh hs' hb.valuation hb.context (hr.withOracle hg) hrun2
  have ip : InputAt (π.take i.n) (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun2)
  exact ⟨t', C', hrun2, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨K0, hm', hb.ext hext, ip, setupInputs_ext hins hext, hmap⟩,
    bodyFresh hr hm' hi hbr hfresh, fixedCells_ext hids hext⟩

/-- An `mlx_array_size` bridge of the body: three target steps, a new trace base, no answers consumed. -/
theorem bodySize {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Dmax : Nat}
    {m : List (Nat × Q)} {sa sb : St FF.S} {Sa Sb Sdec : SSrv}
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val} {asR : List Arg}
    (hparts : Disp.sizeParts sa = some (fsym, ta, nf, name, rt, tys, args))
    (hargs : Disp.sizeArgsOk sa = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hmlx : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hta : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].contains ta = false)
    (hdec : interpS (decodeArgs FF sa tys args).run Sa = some (some asR, Sdec))
    (hpre : sizePreB loopVB Sdec sa.ffi asR = true)
    (hsize : interpS (Disp.sizeS FF sa).run Sa = some (sb, Sb))
    (hlenD : Sdec.oracle.length = Sa.oracle.length) (hlenS : Sb.oracle.length = Sa.oracle.length)
    (hi : (bridgeOf sa.ffi).active = false) (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi) :
    CutStep (bodyCut NB T tk π i Dmax m sa Sa) (bodyCut NB T tk π i Dmax m sb Sb) 3 := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hip, hins, hmap⟩, hfresh, hids⟩
  have keep : ∀ {α : Type} {u : Free α} {a : α} {S' : SSrv}, interpS u Sa = some (a, S') →
      S'.oracle.length = Sa.oracle.length → interpS u { Sa with oracle := [] } = some (a, { S' with oracle := [] }) := by
    intro α u a S' h hl
    obtain ⟨U, hU⟩ := interpS_oracle_suffix _ _ _ _ h
    have hnil : U = [] := by
      have := congrArg List.length hU
      rw [List.length_append, hl] at this
      exact List.length_eq_zero_iff.mp (by omega)
    subst hnil
    exact interpS_drop_suffix _ _ _ _ h [] S'.oracle [] hU rfl
  have hdec' := keep hdec hlenD
  have hsize' := keep hsize hlenS
  have hpre' : sizePreB loopVB { Sdec with oracle := [] } sa.ffi asR = true := hpre
  have hq := (relB_withQ hr.ofJ (Q := fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))
    (Host.Mlx.Ffi.NGrow.refl (mlxOf x.t.ffi))).toJ hr.ffi.2
  have hfr : x.K.fr ta = none := by
    by_contra h
    have hm := (hb.context.1.2.2 ta).mp h
    have hc : [2665, VWFrames.chunk, VWFrames.buffer, VWFrames.view].contains ta = true :=
      List.contains_iff_mem.mpr hm
    rw [hta] at hc
    cases hc
  have hpre0 : ∀ ars S1, interpS (decodeArgs FF sa tys args).run { Sa with oracle := [] } = some (some ars, S1) →
      D1BodySize.Pre x.ν S1 sa.ffi ars := by
    intro ars S1 hd
    exact ⟨sizePre_of hdec' hpre' hb.valuation ars S1 hd, hi⟩
  obtain ⟨M', t', C', _, ⟨⟨gg, hrel, ars, ret, ars', ret', v, hs, ht, hv, hv'⟩, hrun⟩⟩ :=
    (D1BodySize.growAt (mlxOf x.t.ffi) hq hparts hargs hsym hmlx hpay hfr hpre0).run sb _ hsize'
  let K' : Ctx := ⟨x.K.fr, sb.trace, t'.trace, x.K.D, x.K.lo, x.K.hi⟩
  have hout : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] M' x.ν K' sb ⟨Sb.tab, []⟩ t' C' :=
    { hrel with ffi := ⟨hrel.ffi.1.1, hrel.ffi.2⟩ }
  have hext := gg.ext
  have ng : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf t'.ffi) := hrel.ffi.1.2
  have ip : InputAt (π.take i.n) (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun)
  have book : BodyBook i π K0 ⟨M', x.ν, K', t', C'⟩ Dmax := by
    refine ⟨hb.length, hb.vocab, hb.valuation, ⟨hb.context.1, hb.context.2⟩,
      hb.incoming, hb.incomingPrompt, hb.incomingMemo, hb.frames, hb.offset, hb.lo, hb.hi, ?_⟩
    obtain ⟨asR', ret2, pre, tr, hev⟩ := hb.inputEvent
    obtain ⟨fresh, _, hf⟩ := hr.trace
    refine ⟨asR', ret2, ⟨name, ars', ret'⟩ :: (fresh.map x.M.event ++ pre), tr, ?_⟩
    change t'.trace = _
    rw [ht, hf, hev, hext.a]
    simp only [List.cons_append, List.append_assoc]
  refine ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl,
    ⟨K0, hout, book, ip, setupInputs_ext hins hext, hmap⟩,
    bodyFresh hr hout hi hbr hfresh, fixedCells_ext hids hext⟩

end Host.Ts.Sim.Compose.VWFirst
