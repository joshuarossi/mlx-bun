import host.sim.compose.a4b.SetupD1DispatchData
import host.sim.template.a4pre_d1_dispatch.Origin
import host.sim.template.a4pre_d1_dispatch.Continuation
import host.sim.template.a4pre_d1_dispatch.EndpointFields
import host.sim.template.a4pre_d1_dispatch.EndpointProjection

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl
open Host.Route Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The canonical setup cut specialized to the actual singleton branch. -/
noncomputable def dispatchCut (NB T : Nat) (tk : Nat → Nat) (s : St FF.S) (S : SSrv) : ICut FF :=
  { pbCut (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      setupJ wideP [(9, .L)] s S (setupI 1) with
    B := fun x => chunkBook 1 x ∧ fixedCells x }

theorem dispatchCut_congr {NB T : Nat} {tk : Nat → Nat} {sa sb : St FF.S} {Sa Sb : SSrv}
    (hs : sa = sb) (ht : Sa.tab = Sb.tab) : dispatchCut NB T tk sa Sa = dispatchCut NB T tk sb Sb := by
  cases hs
  unfold dispatchCut pbCut
  rw [ht]

noncomputable def startCut (NB T : Nat) (tk : Nat → Nat) : ICut FF :=
  dispatchCut NB T tk PRE_setup_early_r0.s16 PRE_setup_early_r0.S16

theorem startCut_eq_setupNext (NB T : Nat) (tk : Nat → Nat) :
    startCut NB T tk = SetupRest.setupNextCut NB T tk 1 := rfl

/-- The exact singleton row quantities. -/
def coldI : Cls.Inst := ⟨1, 2048, 0, 1, 0, 256, 0, 0, 0, 0⟩

kernel_rfl coldI_first : firstI 1 = coldI

/-- The new branch uses the cold final row, with no cache history. -/
theorem coldRow : InRow final_cold.r0 coldI := by
  exact ⟨by row_close [final_cold.r0, coldI], vx [],
    by row_close [final_cold.r0], by row_close [final_cold.r0, coldI]⟩

theorem coldMap {ν : Nat → F64} (h : MapOk ν (setupI 1) [(9, .L)]) :
    MapOk ν coldI [(9, .L)] := h

private theorem simulation (NB T : Nat) (tk : Nat → Nat) :
    Disp.StepSimXLB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      D1Dispatch.okB0 (Disp.KpJ setupJ 4096) wideP [] (VBOkF loopVB) := by
  let P : LoadP := { setupP with rest := machReads T tk }
  have hjc : setupJ.okCall = okCallFXD P := (callRaiseRest setupP (machReads T tk)).symm
  have hs := fullStepSimXLBXDJS P NB loopVB setupJ 4096 hjc rfl rfl rfl rfl rfl [] setupW_ok
  have ha : D1Dispatch.okB0 = Disp.okJSJ setupJ (okBackFXS setupP) 4096 := by
    funext s S
    exact setup_acceptance s S
  simpa only [P, backRest, ha] using hs

private theorem glue {NB T n : Nat} {tk : Nat → Nat} {sa sb : St FF.S} {Sa Sb : SSrv}
    (hok : D1Dispatch.okB0 sa Sa = true)
    (hrun : runOk FF D1Dispatch.okB0 n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true)
    (horacle : goodLin final_cold.r0.ps (varsOf final_cold.r0.V [(9, .L)]) Sa.oracle = true)
    (hinactive : (bridgeOf sa.ffi).active = false)
    (hbridge : bridgeOf sb.ffi = bridgeOf sa.ffi) :
    CutStep (dispatchCut NB T tk sa Sa) (dispatchCut NB T tk sb Sb) n := by
  apply cut_glue (simulation NB T tk) hok hrun htop
    (fun c hq hb => ⟨hb.1.1, hq.1⟩)
    (fun c hq _ => good_of_row horacle coldRow (coldMap hq.2.2))
  intro c M' t' C' hq hb hrel hext _ hrel'
  refine ⟨⟨hrel'.withOracle (fun _ h => nomatch h), hq⟩, ?_⟩
  exact SetupRest.glueFwd hrel hrel' hext hinactive hbridge hb

/-- The first checked prefix starts at canonical s16, with its new singleton oracle. -/
theorem prefix32 {NB T : Nat} {tk : Nat → Nat} :
    CutStep (startCut NB T tk) (dispatchCut NB T tk D1Dispatch32.s1 D1Dispatch32.S1) 32 := by
  have h := glue (NB := NB) (T := T) (tk := tk) D1Dispatch32.accepted D1Dispatch32.checked
    D1Dispatch32.top D1Dispatch32.oracle start32Inactive D1Dispatch32.bridge
  apply h.cast ?_ rfl rfl
  exact (dispatchCut_congr D1Dispatch32.start_exact D1Dispatch32.tab_exact).symm

/-- The final transition enters the real framed slice call; its body is bridged separately. -/
theorem toSliceCore {NB T : Nat} {tk : Nat → Nat} :
    CutStep (dispatchCut NB T tk D1Input.s0 D1Input.S0)
      (dispatchCut NB T tk D1Input.s2 D1Input.S2) 221 := by
  have hi : (bridgeOf D1Input.s0.ffi).active = false := by
    have h := congrArg (fun s : St FF.S => bridgeOf s.ffi)
      (D1Input.origin.trans D1BeforeSlice.start_exact.symm)
    exact (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) h).trans startSliceInactive
  have hok : D1Dispatch.okB0 D1Input.s0 D1Input.S0 = true := by
    simpa only [D1Input.acceptance0] using D1Input.accepted0
  have hrun : runOk FF D1Dispatch.okB0 220 D1Input.s0 D1Input.S0 = some (D1Input.s1, D1Input.S1) := by
    simpa only [D1Input.F, D1Input.acceptance0] using D1Input.runSeg0
  have hok1 : D1Dispatch.okB0 D1Input.s1 D1Input.S1 = true := by
    simpa only [D1Input.acceptance0] using D1Input.accepted1
  have hstep : interpS (step FF D1Input.s1).run D1Input.S1 = some (D1Input.s2, D1Input.S2) := by
    simpa only [D1Input.F] using D1Input.stepA1
  apply cut_glueCall (simulation NB T tk) hok hrun hok1 D1Input.live1 hstep D1Input.top2
    (fun c hq hb => ⟨hb.1.1, hq.1⟩)
    (fun c hq _ => good_of_row_enum D1Input.oracle0 coldRow (coldMap hq.2.2))
  intro c M' t' C' hq hb hrel hext _ hrel'
  refine ⟨⟨hrel'.withOracle (fun _ h => nomatch h), hq⟩, ?_⟩
  exact SetupRest.glueFwd hrel hrel' hext hi D1Input.bridge2 hb

/-- Canonical s16 to the actual singleton-prompt slice, retaining the same context and anchors. -/
theorem toSlice {NB T : Nat} {tk : Nat → Nat} :
    CutStep (startCut NB T tk) (dispatchCut NB T tk D1BeforeSlice.s1 D1BeforeSlice.S1) 253 := by
  have hmid : dispatchCut NB T tk D1Dispatch32.s1 D1Dispatch32.S1 =
      dispatchCut NB T tk D1Input.s0 D1Input.S0 :=
    (dispatchCut_congr D1Input.origin D1Input.origin_tab).symm
  have hout : dispatchCut NB T tk D1BeforeSlice.s1 D1BeforeSlice.S1 =
      dispatchCut NB T tk D1Input.s2 D1Input.S2 :=
    (dispatchCut_congr D1Input.slice_origin D1Input.slice_tab).symm
  exact (prefix32.trans (toSliceCore.cast hmid rfl rfl)).cast rfl hout rfl

/-- Local acceptance data obtained by the actual slice/typed/newdata bridges. -/
structure ForwardBook (π : List Nat) (K0 : Host.Ts.Sim.Ctx) (x : SegInst FF) : Prop where
  length : π.length = 1
  vocab : ∀ t ∈ π, t < 248320
  valuation : VBOkF loopVB x.ν
  singleton : x.ν 9 = F64.ofNat 1
  context : Disp.KpJ (D1Frames.typedJ (D1Typed.bytes π)) 4096 x.K
  incoming : Disp.KpJ setupJ 4096 K0
  incomingPrompt : K0.fr 2665 = some ([], π.map natV)
  incomingMemo : K0.fr 4910 = none
  frames : x.K.fr = (D1Continue.framed K0 π).fr
  offset : x.K.D = 13
  lo : x.K.lo = K0.lo
  hi : x.K.hi = K0.hi
  inputEvent : ∃ asR ret tr, x.K.base' =
    ⟨chars!"mlx_array_new_data", .jsPtr (x.M.a D1Frames.buffer) 0 (D1Typed.bytes π) :: asR, ret⟩ :: tr

/-- The actual cold forward call, with its widened local context proved from initialization. -/
noncomputable def forwardCut (NB T : Nat) (tk : Nat → Nat) : ICut FF where
  s0 := D1Call.s1
  tab0 := D1Call.S1.tab
  R := fun x s S => ∃ π K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K s S x.t x.C ∧ ForwardBook π K0 x
  B := fun x => AneFresh x.t ∧ fixedCells x

/-- This is a source property of the reached call, before executing any forward body step. -/
theorem forward_source (NB T : Nat) (tk : Nat → Nat) :
    isCallAtB (forwardCut NB T tk).s0 2671709 none = true := D1Call.call

/-- The 350-step continuation executes every concrete bridge; it assumes only the incoming cut. -/
theorem toForwardCore {NB T : Nat} {tk : Nat → Nat} :
    CutStep (dispatchCut NB T tk D1Input.s2 D1Input.S2) (forwardCut NB T tk) 350 := by
  rintro t C ⟨x, rfl, rfl, ⟨hr, hq⟩, hb⟩
  obtain ⟨hk, hmemo, π, hlen, hvocab, hframe, hd, hfresh⟩ := hb.1
  have hi2 : (bridgeOf D1Input.s2.ffi).active = false :=
    (congrArg (fun s : St FF.S => (bridgeOf s.ffi).active) D1Input.slice_origin).trans beforeSliceInactive
  have hbr : bridgeOf D1Call.s1.ffi = bridgeOf D1Input.s2.ffi := D1Call.bridge.trans D1Input.bridge2.symm
  have hiF : (bridgeOf D1Call.s1.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) hbr).trans hi2
  have hi14 : (bridgeOf D1Input.s14.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) (D1Input.bridge14.trans D1Input.bridge2.symm)).trans hi2
  have hv : x.ν 9 = F64.ofNat 1 := hq.2.2.1
  obtain ⟨M', t', C', K', hrun, hext, hrel, hkp, hfr, hD, hlo, hhi, hev⟩ :=
    D1Continue.run hr hk hq.1 hframe hlen hv hi14
  have hbook : ForwardBook π x.K ⟨M', x.ν, K', t', C'⟩ :=
    ⟨hlen, hvocab, hq.1, hv, hkp, hk, hframe, hmemo, hfr, hD.trans hd, hlo, hhi, hev⟩
  have fresh : AneFresh t' := by
    obtain ⟨_, _, r0⟩ := hr.ffi.1
    obtain ⟨_, _, r1⟩ := hrel.ffi.1
    have he : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
      (r1.toR hiF).bridge.1.trans (hbr.trans (r0.toR hi2).bridge.1.symm)
    intro Cx Pc Kc weights kind NE IP G init
    rw [he]
    exact hfresh Cx Pc Kc weights kind NE IP G init
  have hids : fixedCells (⟨M', x.ν, K', t', C'⟩ : SegInst FF) := by
    constructor
    · change M'.a 2586 = 2586
      rw [hext.a]
      exact hb.2.1
    · change M'.a 2589 = 2589
      rw [hext.a]
      exact hb.2.2
  exact ⟨t', C', hrun, ⟨M', x.ν, K', t', C'⟩, rfl, rfl, ⟨π, x.K, hrel, hbook⟩, fresh, hids⟩

/-- Canonical full-FFI s16 to the actual cold D1 call, for an arbitrary singleton token. -/
theorem toForward {NB T : Nat} {tk : Nat → Nat} :
    CutStep (SetupRest.setupNextCut NB T tk 1) (forwardCut NB T tk) 603 := by
  have hout : dispatchCut NB T tk D1Input.s2 D1Input.S2 =
      dispatchCut NB T tk D1BeforeSlice.s1 D1BeforeSlice.S1 :=
    dispatchCut_congr D1Input.slice_origin D1Input.slice_tab
  exact ((toSlice.trans (toForwardCore.cast hout rfl rfl)).cast (startCut_eq_setupNext NB T tk).symm rfl rfl)

/-- The accepted setup is consumed once; this theorem stops before the cold forward body. -/
theorem ldCut_forward {NB T : Nat} {tk : Nat → Nat} (hctx : 1 + T ≤ 262144) :
    CutStep (ldCut NB setupP wideP (Host.Load.Run.Prompt.ldStT [] []) T tk 1)
      (forwardCut NB T tk) 3011 :=
  ((SetupRest.ldCut_next hctx (by decide) (by decide)).trans toForward).cast rfl rfl rfl

/-- The concrete caller and argument fields are read through the same reached relation. -/
theorem forward_fields {NB T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (h : (forwardCut NB T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩) :
    x.t.ctl = .call (.obj (x.M.a 2671709)) .undef
      [.obj (x.M.a 2673495), .obj (x.M.a 2672295), .null] ∧
    x.t.stack.length = 61 ∧ x.K.D = 13 ∧
    x.K.fr 2665 ≠ none ∧ x.K.fr 4910 = none ∧ BigJs x.M := by
  obtain ⟨π, K0, hr, hb⟩ := h
  refine ⟨?_, ?_, hb.offset, ?_, ?_, hr.ffi.2⟩
  · rw [hr.ctl, D1Endpoint.call]
    rfl
  · rw [hr.stack, List.length_append, List.length_map, List.length_nil, Nat.add_zero, D1Endpoint.stack]
  · rw [hb.frames]
    have hp : (D1Continue.framed K0 π).fr 2665 = K0.fr 2665 := by
      exact (Disp.Ctx.frameAt_ne _ _ (by decide)).trans ((Disp.Ctx.frameAt_ne _ _ (by decide)).trans
        (Disp.Ctx.frameAt_ne _ _ (by decide)))
    rw [hp, hb.incomingPrompt]
    exact Option.some_ne_none _
  · rw [hb.frames]
    have hp : (D1Continue.framed K0 π).fr 4910 = K0.fr 4910 := by
      exact (Disp.Ctx.frameAt_ne _ _ (by decide)).trans ((Disp.Ctx.frameAt_ne _ _ (by decide)).trans
        (Disp.Ctx.frameAt_ne _ _ (by decide)))
    exact hp.trans hb.incomingMemo

/-- The input event encodes the incoming tokens themselves under the existing vocabulary bound. -/
theorem ForwardBook.tokenBytes {π : List Nat} {K0 : Host.Ts.Sim.Ctx} {x : SegInst FF}
    (h : ForwardBook π K0 x) :
    D1Typed.bytes π = cellBytes .i32 (π.map (fun k => Cell.num (.lit (F64.ofNat k)))) := by
  unfold D1Typed.bytes
  congr 1
  rw [List.map_map]
  exact List.map_congr_left (fun k hk => Disp.i32Cell_ofNat (by have ht := h.vocab k hk; omega))

/-- The actual 64 cache objects and the actual input object share the cut's map witness. -/
theorem forward_data {NB T : Nat} {tk : Nat → Nat} {x : SegInst FF}
    (h : (forwardCut NB T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩) :
    D1Endpoint.caches.length = 64 ∧
    (∀ a ∈ D1Endpoint.caches, ∃ o, x.t.obj? (x.M.a a) = some o ∧ D1Endpoint.coldB o = true) ∧
    (∃ o, x.t.obj? (x.M.a 2672295) = some o ∧
      o.kind = .array (D1Endpoint.caches.map (fun a => Val.obj (x.M.a a)))) ∧
    (∃ o, x.t.obj? (x.M.a 2673495) = some o ∧
      D1Endpoint.privateVal o (chars!"handle") = some (.big (x.M.big 18155))) := by
  obtain ⟨π, K0, hr, hb⟩ := h
  exact ⟨D1Endpoint.cacheCount, D1Endpoint.targetCaches hr hb.context.1,
    D1Endpoint.targetCacheArray hr hb.context.1, D1Endpoint.targetInput hr hb.context.1⟩

end Host.Ts.Sim.Compose.SetupD1
