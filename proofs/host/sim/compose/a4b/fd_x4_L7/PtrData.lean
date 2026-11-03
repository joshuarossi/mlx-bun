import host.sim.compose.a4b.fd_x4_L7.TypedData
import host.sim.template.a4pre_fd_x4_L7_r0.K0
import host.sim.template.a4pre_fd_x4_L7_r0.K1
import host.sim.template.a4pre_fd_x4_L7_r0.K2
import host.sim.template.a4pre_fd_x4_L7_r0.K3
import host.sim.template.a4pre_fd_x4_L7_r0.K4
import host.sim.template.a4pre_fd_x4_L7_r0.K5
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl

kernel_rfl ptrCtl : PRE_fd_x4_L7_r0.s13.ctl = .call (.obj 2638) .undef [.obj 2834129]
kernel_rfl ptrFo : PRE_fd_x4_L7_r0.s13.obj? 2638 = some (Host.Ts.Sim.Template.objOf PRE_fd_x4_L7_r0.s13 2638)
kernel_rfl ptrKind : (Host.Ts.Sim.Template.objOf PRE_fd_x4_L7_r0.s13 2638).kind = .fn (.native (.ffi .ptr) [])
kernel_rfl viewObj : PRE_fd_x4_L7_r0.s13.obj? 2834129 = some (Host.Ts.Sim.Template.objOf PRE_fd_x4_L7_r0.s13 2834129)

theorem ptr {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {bs : List Byte} {n : Nat}
    (h : RelB FF FR (FDX4L7Frames.typedW bs n) [] M ν K PRE_fd_x4_L7_r0.s13 ⟨PRE_fd_x4_L7_r0.S13.tab, []⟩ t C)
    (hview : K.fr FDX4L7Frames.view = some ([], [])) (hbuf : K.fr FDX4L7Frames.buffer = some ([], [])) (hn : n ≠ 0) :
    runC FF 1 t C = some (t.ret (.ptr (.js (M.a FDX4L7Frames.buffer)) 0), C) ∧
      RelB FF FR (FDX4L7Frames.typedW bs n) [] M ν K PRE_fd_x4_L7_r0.s14 ⟨PRE_fd_x4_L7_r0.S14.tab, []⟩
        (t.ret (.ptr (.js (M.a FDX4L7Frames.buffer)) 0)) C := by
  have hwv : FDX4L7Frames.typedW bs n FDX4L7Frames.view = some (.typed .i32 FDX4L7Frames.buffer 0 n) := rfl
  have hwb : FDX4L7Frames.typedW bs n FDX4L7Frames.buffer = some (.buf bs) := rfl
  obtain ⟨hs, hr⟩ := Disp.bridge_ptr h ptrCtl ptrFo ptrKind rfl rfl hview hwv hn viewObj hbuf hwb
  have hp := Option.some.inj PRE_fd_x4_L7_r0.patchB5
  have rel : RelB FF FR (FDX4L7Frames.typedW bs n) [] M ν K PRE_fd_x4_L7_r0.s14
      ⟨PRE_fd_x4_L7_r0.S14.tab, []⟩ (t.ret (.ptr (.js (M.a FDX4L7Frames.buffer)) 0)) C :=
    (congrArg (fun p : St FF.S × SSrv => RelB FF FR (FDX4L7Frames.typedW bs n) [] M ν K p.1
      ⟨p.2.tab, []⟩ (t.ret (.ptr (.js (M.a FDX4L7Frames.buffer)) 0)) C) hp).mp hr
  exact ⟨runC_one (by rw [h.isHalt, ptrCtl]; rfl) hs, rel⟩

end Host.Ts.Sim.Compose.FDX4L7
