import host.sim.compose.a4b.D1SliceData
import host.sim.template.a4pre_d1_stage_split.K2
import host.sim.template.a4pre_d1_dispatch.TypedStep
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route
variable {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {ν : Nat → F64}
  {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat}
kernel_rfl typedCtl : D1StageSplit.s9.ctl = .construct (.obj 90) [.obj 2673479] (.obj 90)
kernel_rfl typedFo : D1StageSplit.s9.obj? 90 = some (Host.Ts.Sim.Template.objOf D1StageSplit.s9 90)
kernel_rfl typedKind : (Host.Ts.Sim.Template.objOf D1StageSplit.s9 90).kind = .fn (.native (.buf .typedCtor) [natV 4, natV 21])
kernel_rfl chunkObj : D1StageSplit.s9.obj? 2673479 = some (Host.Ts.Sim.Template.objOf D1StageSplit.s9 2673479)
kernel_rfl chunkEmpty : (Host.Ts.Sim.Template.objOf D1StageSplit.s9 2673479).kind = .array []

theorem typed (h : RelB FF FR wideP [] M ν K D1StageSplit.s9 ⟨D1StageSplit.S9.tab, []⟩ t C)
    (hfr : K.fr D1Frames.chunk = some ([], π.map natV)) (hlen : π.length = 1) :
    runC FF 1 t C = some (Disp.typedT FF t 21 (π.map F64.ofNat), C) ∧
      RelB FF FR (D1Frames.typedW (D1Typed.bytes π)) [] M ν (Disp.typedK K D1Frames.buffer)
        D1StageSplit.s10 ⟨D1StageSplit.S10.tab, []⟩ (Disp.typedT FF t 21 (π.map F64.ofNat)) C := by
  have hf : K.fr D1Frames.chunk = some ([], (π.map F64.ofNat).map Disp.litV) := by
    simpa only [Disp.natV_map_litV] using hfr
  have hp : Bridge.typedPatch FF D1StageSplit.s9 D1StageSplit.S9 21 = (D1StageSplit.s10, D1StageSplit.S10) := by
    exact Option.some.inj D1StageSplit.patchB4
  obtain ⟨hs, hr⟩ := D1TypedGeneric.transport (sa := D1StageSplit.s9) (sb := D1StageSplit.s10)
    (Sa := D1StageSplit.S9) (Sb := D1StageSplit.S10) (fa := 90) (ch := D1Frames.chunk)
    (proto := 21) (a := D1Frames.buffer) (fo := Host.Ts.Sim.Template.objOf D1StageSplit.s9 90)
    (oc := Host.Ts.Sim.Template.objOf D1StageSplit.s9 D1Frames.chunk) h D1Split.typedCtl D1Split.typedFo D1Split.typedKind
    (by decide) (by decide) (by decide) hf D1Split.chunkObj D1Split.chunkEmpty
    (Nat.blt_eq.mp D1StageSplit.roomA4_check) D1StageSplit.bufA4 D1StageSplit.protoA4 D1StageSplit.newA4 hp
  have hw : Disp.typedWF wideP D1Frames.buffer (π.map F64.ofNat) = D1Frames.typedW (D1Typed.bytes π) := by
    simp only [Disp.typedWF, D1Frames.typedW, D1Typed.bytes, List.length_map, hlen]
    rfl
  rw [hw] at hr
  exact ⟨hs, hr⟩
end Host.Ts.Sim.Compose.D1Split
