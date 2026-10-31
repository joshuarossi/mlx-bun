import host.sim.compose.a4b.VWBodyStart
import host.sim.compose.a4b.VWDispatchCompact
import host.sim.template.a4pre_d1_body.SizeAt
import host.sim.lin.Enum
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- What the VW forward body keeps across its glue, size bridges and compactions.  The offset
grows at compactions, so each cut names its own bound; the frames stay the forward's. -/
structure BodyBook (i : Cls.Inst) (π : List Nat) (K0 : Ctx) (x : SegInst FF) (Dmax : Nat) : Prop where
  length : π.length = i.L
  vocab : ∀ k ∈ π, k < 248320
  valuation : VBOkF loopVB x.ν
  context : Disp.KpJ (VWFrames.typedJ (tokenBytes (π.take i.n)) (π.take i.n).length) VWFrames.bodyD0 x.K
  incoming : Disp.KpJ setupJ 4096 K0
  incomingPrompt : K0.fr 2665 = some ([], π.map natV)
  incomingMemo : K0.fr 4910 = none
  frames : x.K.fr = (g1Framed K0 π i.n).fr
  offset : x.K.D ≤ Dmax
  lo : x.K.lo = K0.lo
  hi : x.K.hi = K0.hi
  inputEvent : ∃ asR ret pre tr, x.K.base' = pre ++
    ⟨chars!"mlx_array_new_data", .jsPtr (x.M.a VWFrames.buffer) 0 (tokenBytes (π.take i.n)) :: asR, ret⟩ :: tr

theorem BodyBook.prompt {i : Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : BodyBook i π K0 x Dmax) : x.K.fr 2665 = some ([], π.map natV) := by
  rw [hb.frames]
  exact hb.incomingPrompt

theorem BodyBook.chunk {i : Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : BodyBook i π K0 x Dmax) : x.K.fr VWFrames.chunk = some ([], (π.take i.n).map natV) := by
  rw [hb.frames]
  rfl

theorem BodyBook.memo {i : Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : BodyBook i π K0 x Dmax) : x.K.fr 4910 = none := by
  rw [hb.frames]
  exact hb.incomingMemo

/-- A body boundary of the prompt `π`, at the variables `m`, with offset at most `Dmax`. -/
noncomputable def bodyCut (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (i : Cls.Inst) (Dmax : Nat)
    (m : List (Nat × Q)) (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (VWFrames.typedW (tokenBytes (π.take i.n)) (π.take i.n).length) [] x.M x.ν x.K s S x.t x.C ∧
    BodyBook i π K0 x Dmax ∧ InputAt (π.take i.n) (x.M.node 15235) x.t x.C ∧
    setupInputs T tk x ∧ MapOk x.ν i m
  B := fun x => AneFresh x.t ∧ fixedCells x

/-- The bridge of the target follows the template's while both sides are inactive. -/
theorem bodyFresh {W : Nat → Option WFrame}
    {NB : Nat} {P : LoadP} {M M' : Map} {ν ν' : Nat → F64} {K K' : Ctx}
    {sa sb t t' : St FF.S} {Sa Sb : SSrv} {C C' : CSrv}
    (hr : RelB FF (Disp.FRJ (FullRXD P NB)) W [] M ν K sa Sa t C)
    (hr' : RelB FF (Disp.FRJ (FullRXD P NB)) W [] M' ν' K' sb Sb t' C')
    (hi : (bridgeOf sa.ffi).active = false) (he : bridgeOf sb.ffi = bridgeOf sa.ffi)
    (hf : AneFresh t) : AneFresh t' := by
  obtain ⟨_, _, r0⟩ := hr.ffi.1
  obtain ⟨_, _, r1⟩ := hr'.ffi.1
  have hi' : (bridgeOf sb.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) he).trans hi
  have hb : bridgeOf t'.ffi = bridgeOf t.ffi :=
    (r1.toR hi').bridge.1.trans (he.trans (r0.toR hi).bridge.1.symm)
  intro Cx Pc Kc weights kind NE IP G init
  rw [hb]
  exact hf Cx Pc Kc weights kind NE IP G init

/-- Extending the map leaves the book's cells alone. -/
theorem BodyBook.ext {i : Cls.Inst} {π : List Nat} {K0 K : Ctx} {M M' : Map} {ν : Nat → F64}
    {t t' : St FF.S} {C C' : CSrv} {Dmax n : Nat}
    (hb : BodyBook i π K0 ⟨M, ν, K, t, C⟩ Dmax) (he : Ext M M' n) :
    BodyBook i π K0 ⟨M', ν, K, t', C'⟩ Dmax := by
  refine ⟨hb.length, hb.vocab, hb.valuation, hb.context, hb.incoming, hb.incomingPrompt,
    hb.incomingMemo, hb.frames, hb.offset, hb.lo, hb.hi, ?_⟩
  change ∃ asR ret pre tr, K.base' = _
  rw [he.a]
  exact hb.inputEvent

theorem setupInputs_ext {T : Nat} {tk : Nat → Nat} {M M' : Map} {ν : Nat → F64} {K K' : Ctx}
    {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : setupInputs T tk ⟨M, ν, K, t, C⟩) (he : Ext M M' n) :
    setupInputs T tk ⟨M', ν, K', t', C'⟩ :=
  ⟨h.1, by change M'.a 2590 = 2590; rw [he.a]; exact h.2⟩

theorem fixedCells_ext {M M' : Map} {ν : Nat → F64} {K K' : Ctx}
    {t t' : St FF.S} {C C' : CSrv} {n : Nat}
    (h : fixedCells (⟨M, ν, K, t, C⟩ : SegInst FF)) (he : Ext M M' n) :
    fixedCells (⟨M', ν, K', t', C'⟩ : SegInst FF) := by
  change M'.a 2586 = 2586 ∧ M'.a 2589 = 2589
  rw [he.a]
  exact h

/-- A checked glue stretch of the body, under the body's acceptance for every token buffer. -/
theorem bodyGlue {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Dmax n : Nat}
    {m m' : List (Nat × Q)} {sa sb : St FF.S} {Sa Sb : SSrv}
    (ha : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows sa Sa) = fun _ _ => true)
    (hrun : ∀ (bs : List Byte) (rows : Nat), runOk FF (VWFrames.bodyOk bs rows) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true) (hgood : ∀ ν, MapOk ν i m → Good ν Sa.oracle)
    (hsub : ∀ p ∈ m', p ∈ m) (hi : (bridgeOf sa.ffi).active = false)
    (hbr : bridgeOf sb.ffi = bridgeOf sa.ffi) :
    CutStep (bodyCut NB T tk π i Dmax m sa Sa) (bodyCut NB T tk π i Dmax m' sb Sb) n := by
  rintro t C ⟨x, rfl, rfl, ⟨K0, hr, hb, hip, hins, hmap⟩, hfresh, hids⟩
  have hok := congrFun (congrFun ha (tokenBytes (π.take i.n))) (π.take i.n).length
  obtain ⟨M', t', C', hrun', hext, hm'⟩ := D1Advance.run
    (bodySim NB T tk (tokenBytes (π.take i.n)) (π.take i.n).length []) hb.context hb.valuation
    (hgood x.ν hmap) hok (hrun _ _) htop hr
  have hgs := typedGrowSimAt NB T tk (tokenBytes (π.take i.n)) (π.take i.n).length VWFrames.bodyD0 []
  have ng := glue_ngrow hgs hok (hrun _ _) hb.valuation hb.context (hr.withOracle (hgood x.ν hmap)) hrun'
  have ip : InputAt (π.take i.n) (M'.node 15235) t' C' := by
    rw [hext.node]
    exact hip.grow ng (runC_le _ _ _ _ _ hrun')
  exact ⟨t', C', hrun', ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨K0, hm', hb.ext hext, ip, setupInputs_ext hins hext, MapOk.sub hmap hsub⟩,
    bodyFresh hr hm' hi hbr hfresh, fixedCells_ext hids hext⟩

end Host.Ts.Sim.Compose.VWFirst
