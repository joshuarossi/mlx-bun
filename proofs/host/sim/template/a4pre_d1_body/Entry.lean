import host.sim.template.a4pre_d1_body.Advance
import host.sim.template.a4pre_d1_body.SizedEndpoint
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyAdvance
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.SetupD1 Host.Ts.Sim.Prefill
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

theorem enter {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx}
    {x : SegInst FF}
    (hr : RelB FF (Disp.FRJ (FullRXD {setupP with rest := machReads T tk} NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K D1Call.s1
      ⟨D1Call.S1.tab, []⟩ x.t x.C)
    (hb : ForwardBook π K0 x) (hf : AneFresh x.t) (hc : fixedCells x) :
    (cut NB T tk π K0 x.M (mlxOf x.t.ffi) D1BodySized.s0 D1BodySized.S0).Inv x.t x.C := by
  have hq := (relB_withQ hr.ofJ
    (Q := fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y))
    (Host.Mlx.Ffi.NGrow.refl (mlxOf x.t.ffi))).toJ hr.ffi.2
  refine ⟨x, rfl, rfl, ⟨?_, BodyBook.initial hb⟩, hf, hc, Ext.refl _ _⟩
  change RelB FF (Native NB T tk (mlxOf x.t.ffi))
    (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K D1BodySized.s0
    ⟨D1BodySized.S0.tab, []⟩ x.t x.C
  rw [D1BodySized.start_exact, D1BodySized.tab_exact]
  exact hq

theorem forgetNative {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {y0 : Host.Mlx.Ffi.St}
    {x : SegInst FF} {s : St FF.S} {S : SSrv}
    (h : RelB FF (Native NB T tk y0) (D1Frames.typedW (D1Typed.bytes π)) []
      x.M x.ν x.K s S x.t x.C) :
    RelB FF (Disp.FRJ (FullRXD {setupP with rest := machReads T tk} NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K s S x.t x.C :=
  { h with ffi := ⟨h.ffi.1.1, h.ffi.2⟩ }

theorem originalCaller {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx}
    {x x' : SegInst FF}
    (h0 : RelB FF (Disp.FRJ (FullRXD {setupP with rest := machReads T tk} NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K D1Call.s1
      ⟨D1Call.S1.tab, []⟩ x.t x.C)
    (h1 : (cut NB T tk π K0 x.M (mlxOf x.t.ffi) D1Body.s155 D1Body.S155).R
      x' D1Body.s155 ⟨D1Body.S155.tab, []⟩)
    (he : Ext x.M x'.M 17) : x'.t.stack = x.t.stack := by
  rw [h1.1.stack, h0.stack, D1Body.caller]
  congr 1
  apply List.map_congr_left
  intro f hf
  exact Map.frame_agree he.agree' (h0.stackSupp f hf)

end Host.Load.Run.Tpl.D1BodyAdvance

-- rechecked: literal chunk length
