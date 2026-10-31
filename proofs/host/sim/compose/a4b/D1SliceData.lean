import host.sim.compose.a4b.D1SplitData
import host.sim.template.a4pre_d1_stage_split.Bridge
import host.sim.template.a4pre_d1_stage_split.K0
import host.sim.template.a4pre_d1_dispatch.GenericSlice

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Route Host.Ts.Sim.Template Host.Load.Run.Tpl

kernel_rfl sliceCtl : D1StageSplit.s3.ctl = .call (.obj 59) (.obj 2665) [natV 0, .num (.ref 13)]
kernel_rfl sliceFn : D1StageSplit.s3.obj? 59 = some (Host.Ts.Sim.Template.objOf D1StageSplit.s3 59)
kernel_rfl sliceKind : (Host.Ts.Sim.Template.objOf D1StageSplit.s3 59).kind = .fn (.native (.arr .slice) [])
kernel_rfl sliceObj : D1StageSplit.s3.obj? 2665 = some (Host.Ts.Sim.Template.objOf D1StageSplit.s3 2665)
kernel_rfl sliceEmpty : (Host.Ts.Sim.Template.objOf D1StageSplit.s3 2665).kind = .array []
kernel_rfl sliceEnd : nth? D1StageSplit.S3.tab 13 = some (.var 9)

theorem slice {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {π : List Nat}
    (h : RelB FF FR wideP [] M ν K D1StageSplit.s3 ⟨D1StageSplit.S3.tab, []⟩ t C)
    (hfr : K.fr 2665 = some ([], π.map natV)) (hlen : π.length = 1) (hv : ν 9 = F64.ofNat 1) :
    let t' := (newArray t (π.map natV)).2.ret (.obj (newArray t (π.map natV)).1)
    runC FF 1 t C = some (t', C) ∧
      RelB FF FR wideP [] M ν (Disp.Ctx.frameAt K 2673479 ([], π.map natV))
        D1StageSplit.s4 ⟨D1StageSplit.S4.tab, []⟩ t' C := by
  exact D1SliceGeneric.transport (sa := D1StageSplit.s3) (sb := D1StageSplit.s4)
    (Sa := D1StageSplit.S3) (Sb := D1StageSplit.S4) (fa := 59) (a := 2665) (ch := 2673479)
    (fo := Host.Ts.Sim.Template.objOf D1StageSplit.s3 59) (o := Host.Ts.Sim.Template.objOf D1StageSplit.s3 2665)
    h sliceCtl sliceFn sliceKind hfr sliceObj sliceEmpty sliceEnd
    (Nat.blt_eq.mp D1StageSplit.roomA2_check) D1StageSplit.arrA2
    (by rw [D1StageSplit.newA2]; rfl) D1StageSplit.newA2
    (Option.some.inj D1StageSplit.patchB2) hlen hv

end Host.Ts.Sim.Compose.D1Split
