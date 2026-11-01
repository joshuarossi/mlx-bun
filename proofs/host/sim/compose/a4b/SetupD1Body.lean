import host.sim.template.a4pre_d1_body.History
import host.sim.template.a4pre_d1_body.Endpoint
import host.sim.template.a4pre_d1_body.Entry
import host.sim.template.a4pre_d1_body.Counters
import host.sim.template.a4pre_d1_body.Output
import host.sim.template.a4pre_d1_body.OutputProjection
import host.sim.template.a4pre_d1_body.OutputValue
import host.sim.template.a4pre_d1_body.Reserved
import host.sim.template.a4pre_d1_body.SizedRun
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupD1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Ts.Sim.Prefill
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-- The exact original caller return, retaining initialization data historically
when size bridges have restarted the trace bases. -/
noncomputable def returnedCut (NB T : Nat) (tk : Nat → Nat) : ICut FF where
  s0 := D1Body.s155
  tab0 := D1Body.S155.tab
  R := fun x s S => ∃ π K0,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K s S x.t x.C ∧ BodyBook π K0 x
  B := fun x => AneFresh x.t ∧ fixedCells x

structure BodyResult (NB T : Nat) (tk : Nat → Nat) (π : List Nat)
    (K0 : Host.Ts.Sim.Ctx) (x x' : SegInst FF) : Prop where
  run : runC FF 1541184 x.t x.C = some (x'.t, x'.C)
  relation : RelB FF (Disp.FRJ (FullRXD {setupP with rest := machReads T tk} NB))
    (D1Frames.typedW (D1Typed.bytes π)) [] x'.M x'.ν x'.K D1Body.s155
    ⟨D1Body.S155.tab, []⟩ x'.t x'.C
  book : BodyBook π K0 x'
  fresh : AneFresh x'.t
  anchors : fixedCells x'
  ext : Ext x.M x'.M 17
  nativeGrow : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf x'.t.ffi)
  server : CSrv.Le x.C x'.C
  caller : x'.t.stack = x.t.stack
  nativeCounters : (mlxOf x'.t.ffi).next = (mlxOf x.t.ffi).next + 3830 ∧
    (mlxOf x'.t.ffi).nnext = (mlxOf x.t.ffi).nnext + 2528
  heapBand : x'.t.next = x.t.next + 153261 ∧ x'.K.D = 13 ∧
    x'.K.lo = setupP.lo ∧ x'.K.hi = setupP.E

/-- The original full64 cold function, through its return on the original caller
stack. Native growth and server extension refer to this same actual run. -/
theorem run_full {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx}
    {x : SegInst FF}
    (hr : RelB FF (Disp.FRJ (FullRXD {setupP with rest := machReads T tk} NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K D1Call.s1
      ⟨D1Call.S1.tab, []⟩ x.t x.C)
    (hb : ForwardBook π K0 x) (hf : AneFresh x.t) (hc : fixedCells x) :
    ∃ x', BodyResult NB T tk π K0 x x' := by
  obtain ⟨t', C', hrun, x', ht, hC, ⟨hrel, hbook⟩, hf', hc', he⟩ :=
    D1BodySized.fullRun x.t x.C (D1BodyAdvance.enter hr hb hf hc)
  change RelB FF (D1BodyAdvance.Native NB T tk (mlxOf x.t.ffi))
    (D1Frames.typedW (D1Typed.bytes π)) [] x'.M x'.ν x'.K
    D1BodySized.s155 ⟨D1BodySized.S155.tab, []⟩ x'.t x'.C at hrel
  rw [D1BodySized.end_exact, D1BodySized.end_tab] at hrel
  have hend : (D1BodyAdvance.cut NB T tk π K0 x.M (mlxOf x.t.ffi) D1Body.s155 D1Body.S155).R
      x' D1Body.s155 ⟨D1Body.S155.tab, []⟩ := ⟨hrel, hbook⟩
  have hrun' : runC FF 1541184 x.t x.C = some (x'.t, x'.C) := by
    rw [ht, hC]
    exact hrun
  exact ⟨x', ⟨hrun', D1BodyAdvance.forgetNative hrel, hbook, hf', hc', he,
    hrel.ffi.1.2, runC_le _ _ _ _ _ hrun', D1BodyAdvance.originalCaller hr hend he,
    D1BodyCounters.nativeDelta hr hend he, D1BodyCounters.heapDelta hr hb hend⟩⟩

theorem forward_returned {NB T : Nat} {tk : Nat → Nat} :
    CutStep (forwardCut NB T tk) (returnedCut NB T tk) 1541184 := by
  rintro t C ⟨x, rfl, rfl, ⟨π, K0, hr, hb⟩, hf, hc⟩
  obtain ⟨x', h⟩ := run_full hr hb hf hc
  exact ⟨x'.t, x'.C, h.run, x', rfl, rfl, ⟨π, K0, h.relation, h.book⟩, h.fresh, h.anchors⟩

theorem BodyResult.inputNode {NB T : Nat} {tk : Nat → Nat} {π : List Nat}
    {K0 : Host.Ts.Sim.Ctx} {x x' : SegInst FF} (h : BodyResult NB T tk π K0 x x') :
    x'.M.node 15235 = x.M.node 15235 := congrFun h.ext.node _

theorem BodyResult.returned {NB T : Nat} {tk : Nat → Nat} {π : List Nat}
    {K0 : Host.Ts.Sim.Ctx} {x x' : SegInst FF} (h : BodyResult NB T tk π K0 x x') :
    x'.t.ctl = .ret (.obj (x'.M.a 2826766)) := by
  rw [h.relation.ctl, D1Body.returned]
  rfl

theorem BodyResult.output {NB T : Nat} {tk : Nat → Nat} {π : List Nat}
    {K0 : Host.Ts.Sim.Ctx} {x x' : SegInst FF} (h : BodyResult NB T tk π K0 x x') :
    (∃ o, x'.t.obj? (x'.M.a 2826766) = some o ∧
      D1Endpoint.privateVal o (chars!"handle") = some (.big (x'.M.big 21985))) ∧
    (mlxOf x'.t.ffi).arrs.get (x'.M.handle 21985) = some (x'.M.node 17763) ∧
    ((mlxOf x'.t.ffi).nodes.get (x'.M.node 17763)).map (fun n => (n.shape, n.dtype)) =
      some (x'.M.dims [.lit 1, .lit 1, .lit 5120], 12) := by
  obtain ⟨origin, hb, hp⟩ := h.book
  exact D1BodyOutput.targetOutput h.relation hb.context.1

theorem BodyResult.caches {NB T : Nat} {tk : Nat → Nat} {π : List Nat}
    {K0 : Host.Ts.Sim.Ctx} {x x' : SegInst FF} (h : BodyResult NB T tk π K0 x x') :
    D1Endpoint.caches.length = 64 ∧
    (∀ a ∈ D1Endpoint.caches, ∃ o, x'.t.obj? (x'.M.a a) = some o ∧
      D1BodyOutput.updatedB o = true) ∧
    (∃ o, x'.t.obj? (x'.M.a 2672295) = some o ∧
      o.kind = .array (D1Endpoint.caches.map (fun a => Val.obj (x'.M.a a)))) := by
  obtain ⟨origin, hb, hp⟩ := h.book
  exact ⟨D1Endpoint.cacheCount, D1BodyOutput.targetCaches h.relation hb.context.1,
    D1BodyOutput.targetCacheArray h.relation hb.context.1⟩

theorem BodyResult.outputDimensions {NB T : Nat} {tk : Nat → Nat} {π : List Nat}
    {K0 : Host.Ts.Sim.Ctx} {x x' : SegInst FF} (h : BodyResult NB T tk π K0 x x') :
    DVSs x'.M x'.C ⟨D1Body.S155.tab, []⟩
      [.lit 1, .lit 1, .lit 5120] [1, 1, 5120] := by
  obtain ⟨origin, hb, hp⟩ := h.book
  exact D1BodyOutputValue.dimensions

end Host.Ts.Sim.Compose.SetupD1
