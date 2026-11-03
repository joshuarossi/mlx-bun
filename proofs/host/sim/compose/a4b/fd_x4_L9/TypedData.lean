import host.sim.compose.a4b.fd_x4_L9.SliceData
import host.sim.template.a4pre_fd_x4_L9_r0.K0
import host.sim.template.a4pre_fd_x4_L9_r0.K1
import host.sim.template.a4pre_fd_x4_L9_r0.K2
import host.sim.template.a4pre_fd_x4_L9_r0.K3
import host.sim.template.a4pre_fd_x4_L9_r0.K4
import host.sim.template.a4pre_fd_x4_L9_r0.K5
import host.sim.template.a4pre_d1_dispatch.GenericTyped
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.FDX4L9
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

def tokenBytes (γ : List Nat) : List Byte := cellBytes .i32 ((γ.map F64.ofNat).map Disp.i32Cell)

kernel_rfl typedCtl : PRE_fd_x4_L9_r0.s10.ctl = .construct (.obj 90) [.obj 2834731] (.obj 90)
kernel_rfl typedFo : PRE_fd_x4_L9_r0.s10.obj? 90 = some (Host.Ts.Sim.Template.objOf PRE_fd_x4_L9_r0.s10 90)
kernel_rfl typedKind : (Host.Ts.Sim.Template.objOf PRE_fd_x4_L9_r0.s10 90).kind = .fn (.native (.buf .typedCtor) [natV 4, natV 21])
kernel_rfl chunkObj : PRE_fd_x4_L9_r0.s10.obj? 2834731 = some (Host.Ts.Sim.Template.objOf PRE_fd_x4_L9_r0.s10 2834731)
kernel_rfl chunkEmpty : (Host.Ts.Sim.Template.objOf PRE_fd_x4_L9_r0.s10 2834731).kind = .array []

theorem typed {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR wideGPf [] M ν K PRE_fd_x4_L9_r0.s10 ⟨PRE_fd_x4_L9_r0.S10.tab, []⟩ t C)
    (hfr : K.fr FDX4L9Frames.chunk = some ([], γ.map natV)) :
    runC FF 1 t C = some (Disp.typedT FF t 21 (γ.map F64.ofNat), C) ∧
      RelB FF FR (FDX4L9Frames.typedW (tokenBytes γ) γ.length) [] M ν (Disp.typedK K FDX4L9Frames.buffer)
        PRE_fd_x4_L9_r0.s11 ⟨PRE_fd_x4_L9_r0.S11.tab, []⟩ (Disp.typedT FF t 21 (γ.map F64.ofNat)) C := by
  have hf : K.fr FDX4L9Frames.chunk = some ([], (γ.map F64.ofNat).map Disp.litV) := by
    simpa only [Disp.natV_map_litV] using hfr
  obtain ⟨hs, hr⟩ := D1TypedGeneric.transport (sa := PRE_fd_x4_L9_r0.s10) (sb := PRE_fd_x4_L9_r0.s11)
    (Sa := PRE_fd_x4_L9_r0.S10) (Sb := PRE_fd_x4_L9_r0.S11) (fa := 90) (ch := FDX4L9Frames.chunk)
    (proto := 21) (a := FDX4L9Frames.buffer) h typedCtl typedFo typedKind
    (by decide) (by decide) (by decide) hf chunkObj chunkEmpty
    (Nat.blt_eq.mp PRE_fd_x4_L9_r0.roomA4_check) PRE_fd_x4_L9_r0.bufA4 PRE_fd_x4_L9_r0.protoA4
    PRE_fd_x4_L9_r0.newA4 (Option.some.inj PRE_fd_x4_L9_r0.patchB4)
  have hw : Disp.typedWF wideGPf FDX4L9Frames.buffer (γ.map F64.ofNat) = FDX4L9Frames.typedW (tokenBytes γ) γ.length := by
    simp only [Disp.typedWF, FDX4L9Frames.typedW, tokenBytes, List.length_map]
    rfl
  rw [hw] at hr
  exact ⟨hs, hr⟩

theorem typedContext (bs : List Byte) (n : Nat) {K : Ctx}
    (hk : Disp.KpJ FDX4L9Frames.chunkJ 131072 K) :
    Disp.KpJ (FDX4L9Frames.typedJ bs n) 131072 (Disp.typedK K FDX4L9Frames.buffer) := by
  let J := fullJSPPXS setupP (2665 :: 4910 :: (ghostPf ++ [FDX4L9Frames.chunk, FDX4L9Frames.buffer])) wideListPf
  have h1 : Disp.KpJ J 131072 (Disp.Ctx.frameAt K FDX4L9Frames.buffer ([], [])) :=
    FDX4L9Frames.kp_frame (J := FDX4L9Frames.chunkJ) (J' := J) rfl rfl rfl hk ([], [])
  exact FDX4L9Frames.kp_frame (J := J) (J' := FDX4L9Frames.typedJ bs n) rfl rfl rfl h1 ([], [])

end Host.Ts.Sim.Compose.FDX4L9
