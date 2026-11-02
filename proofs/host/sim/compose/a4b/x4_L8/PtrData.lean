import host.sim.compose.a4b.x4_L8.TypedData
import host.sim.template.a4pre_first_tail_x4_L8_r0.K7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L8
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl

kernel_rfl ptrCtl : PRE_first_tail_x4_L8_r0.s30.ctl = .call (.obj 2638) .undef [.obj 2673473]
kernel_rfl ptrFo : PRE_first_tail_x4_L8_r0.s30.obj? 2638 = some (Host.Ts.Sim.Template.objOf PRE_first_tail_x4_L8_r0.s30 2638)
kernel_rfl ptrKind : (Host.Ts.Sim.Template.objOf PRE_first_tail_x4_L8_r0.s30 2638).kind = .fn (.native (.ffi .ptr) [])
kernel_rfl viewObj : PRE_first_tail_x4_L8_r0.s30.obj? 2673473 = some (Host.Ts.Sim.Template.objOf PRE_first_tail_x4_L8_r0.s30 2673473)

theorem ptr {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {bs : List Byte} {n : Nat}
    (h : RelB FF FR (VWFrames.typedW bs n) [] M ν K PRE_first_tail_x4_L8_r0.s30 ⟨PRE_first_tail_x4_L8_r0.S30.tab, []⟩ t C)
    (hview : K.fr VWFrames.view = some ([], [])) (hbuf : K.fr VWFrames.buffer = some ([], [])) (hn : n ≠ 0) :
    runC FF 1 t C = some (t.ret (.ptr (.js (M.a VWFrames.buffer)) 0), C) ∧
      RelB FF FR (VWFrames.typedW bs n) [] M ν K PRE_first_tail_x4_L8_r0.s31 ⟨PRE_first_tail_x4_L8_r0.S31.tab, []⟩
        (t.ret (.ptr (.js (M.a VWFrames.buffer)) 0)) C := by
  have hwv : VWFrames.typedW bs n VWFrames.view = some (.typed .i32 VWFrames.buffer 0 n) := rfl
  have hwb : VWFrames.typedW bs n VWFrames.buffer = some (.buf bs) := rfl
  obtain ⟨hs, hr⟩ := Disp.bridge_ptr h ptrCtl ptrFo ptrKind rfl rfl hview hwv hn viewObj hbuf hwb
  have hp := Option.some.inj PRE_first_tail_x4_L8_r0.patchB10
  have rel : RelB FF FR (VWFrames.typedW bs n) [] M ν K PRE_first_tail_x4_L8_r0.s31
      ⟨PRE_first_tail_x4_L8_r0.S31.tab, []⟩ (t.ret (.ptr (.js (M.a VWFrames.buffer)) 0)) C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF FR (VWFrames.typedW bs n) [] M ν K p.1
      ⟨p.2.tab, []⟩ (t.ret (.ptr (.js (M.a VWFrames.buffer)) 0)) C) hp).mp hr
  exact ⟨runC_one (by rw [h.isHalt, ptrCtl]; rfl) hs, rel⟩

end Host.Ts.Sim.Compose.VWFirst.X4_L8
