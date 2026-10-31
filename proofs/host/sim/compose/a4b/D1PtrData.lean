import host.sim.compose.a4b.D1TypedData
import host.sim.template.a4pre_d1_stage_split.K3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.D1Split
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl
variable {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {ν : Nat → F64}
  {K : Host.Ts.Sim.Ctx} {t : St FF.S} {C : CSrv} {bs : List Byte}

kernel_rfl ptrCtl : D1StageSplit.s12.ctl = .call (.obj 2638) .undef [.obj 2673485]
kernel_rfl ptrFo : D1StageSplit.s12.obj? 2638 = some (Host.Ts.Sim.Template.objOf D1StageSplit.s12 2638)
kernel_rfl ptrKind : (Host.Ts.Sim.Template.objOf D1StageSplit.s12 2638).kind = .fn (.native (.ffi .ptr) [])
kernel_rfl viewObj : D1StageSplit.s12.obj? 2673485 = some (Host.Ts.Sim.Template.objOf D1StageSplit.s12 2673485)

theorem ptr (h : RelB FF FR (D1Frames.typedW bs) [] M ν K D1StageSplit.s12 ⟨D1StageSplit.S12.tab, []⟩ t C)
    (hview : K.fr D1Frames.view = some ([], [])) (hbuf : K.fr D1Frames.buffer = some ([], [])) :
    runC FF 1 t C = some (t.ret (.ptr (.js (M.a D1Frames.buffer)) 0), C) ∧
      RelB FF FR (D1Frames.typedW bs) [] M ν K D1StageSplit.s13 ⟨D1StageSplit.S13.tab, []⟩
        (t.ret (.ptr (.js (M.a D1Frames.buffer)) 0)) C := by
  have hwv : D1Frames.typedW bs D1Frames.view = some (.typed .i32 D1Frames.buffer 0 1) := rfl
  have hwb : D1Frames.typedW bs D1Frames.buffer = some (.buf bs) := rfl
  exact D1TypedGeneric.ptr (sa := D1StageSplit.s12) (sb := D1StageSplit.s13)
    (Sa := D1StageSplit.S12) (Sb := D1StageSplit.S13) (fp := 2638) (ta := D1Frames.view)
    (b := D1Frames.buffer) (fo := Host.Ts.Sim.Template.objOf D1StageSplit.s12 2638) (o := Host.Ts.Sim.Template.objOf D1StageSplit.s12 D1Frames.view)
    h ptrCtl ptrFo ptrKind hview hwv viewObj hbuf hwb
    (Option.some.inj D1StageSplit.patchB5)
end Host.Ts.Sim.Compose.D1Split
