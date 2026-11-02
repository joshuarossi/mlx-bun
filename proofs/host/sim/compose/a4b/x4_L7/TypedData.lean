import host.sim.compose.a4b.x4_L7.SliceData
import host.sim.template.a4pre_first_tail_x4_L7_r0.K6
import host.sim.template.a4pre_d1_dispatch.GenericTyped
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.X4_L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Load.Run.Tpl Host.Route

def tokenBytes (γ : List Nat) : List Byte := cellBytes .i32 ((γ.map F64.ofNat).map Disp.i32Cell)

kernel_rfl typedCtl : PRE_first_tail_x4_L7_r0.s27.ctl = .construct (.obj 90) [.obj 2673467] (.obj 90)
kernel_rfl typedFo : PRE_first_tail_x4_L7_r0.s27.obj? 90 = some (Host.Ts.Sim.Template.objOf PRE_first_tail_x4_L7_r0.s27 90)
kernel_rfl typedKind : (Host.Ts.Sim.Template.objOf PRE_first_tail_x4_L7_r0.s27 90).kind = .fn (.native (.buf .typedCtor) [natV 4, natV 21])
kernel_rfl chunkObj : PRE_first_tail_x4_L7_r0.s27.obj? 2673467 = some (Host.Ts.Sim.Template.objOf PRE_first_tail_x4_L7_r0.s27 2673467)
kernel_rfl chunkEmpty : (Host.Ts.Sim.Template.objOf PRE_first_tail_x4_L7_r0.s27 2673467).kind = .array []

theorem typed {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {ν : Nat → F64}
    {K : Ctx} {t : St FF.S} {C : CSrv} {γ : List Nat}
    (h : RelB FF FR wideP [] M ν K PRE_first_tail_x4_L7_r0.s27 ⟨PRE_first_tail_x4_L7_r0.S27.tab, []⟩ t C)
    (hfr : K.fr VWFrames.chunk = some ([], γ.map natV)) :
    runC FF 1 t C = some (Disp.typedT FF t 21 (γ.map F64.ofNat), C) ∧
      RelB FF FR (VWFrames.typedW (tokenBytes γ) γ.length) [] M ν (Disp.typedK K VWFrames.buffer)
        PRE_first_tail_x4_L7_r0.s28 ⟨PRE_first_tail_x4_L7_r0.S28.tab, []⟩ (Disp.typedT FF t 21 (γ.map F64.ofNat)) C := by
  have hf : K.fr VWFrames.chunk = some ([], (γ.map F64.ofNat).map Disp.litV) := by
    simpa only [Disp.natV_map_litV] using hfr
  obtain ⟨hs, hr⟩ := D1TypedGeneric.transport (sa := PRE_first_tail_x4_L7_r0.s27) (sb := PRE_first_tail_x4_L7_r0.s28)
    (Sa := PRE_first_tail_x4_L7_r0.S27) (Sb := PRE_first_tail_x4_L7_r0.S28) (fa := 90) (ch := VWFrames.chunk)
    (proto := 21) (a := VWFrames.buffer) h typedCtl typedFo typedKind
    (by decide) (by decide) (by decide) hf chunkObj chunkEmpty
    (Nat.blt_eq.mp PRE_first_tail_x4_L7_r0.roomA9_check) PRE_first_tail_x4_L7_r0.bufA9 PRE_first_tail_x4_L7_r0.protoA9
    PRE_first_tail_x4_L7_r0.newA9 (Option.some.inj PRE_first_tail_x4_L7_r0.patchB9)
  have hw : Disp.typedWF wideP VWFrames.buffer (γ.map F64.ofNat) = VWFrames.typedW (tokenBytes γ) γ.length := by
    simp only [Disp.typedWF, VWFrames.typedW, tokenBytes, List.length_map]
    rfl
  rw [hw] at hr
  exact ⟨hs, hr⟩

theorem typedContext (bs : List Byte) (n : Nat) {K : Ctx}
    (hk : Disp.KpJ VWFrames.chunkJ 4096 K) :
    Disp.KpJ (VWFrames.typedJ bs n) 4096 (Disp.typedK K VWFrames.buffer) := by
  let J := fullJSPPXS setupP [2665, VWFrames.chunk, VWFrames.buffer] [(4910, .memo [])]
  have h1 : Disp.KpJ J 4096 (Disp.Ctx.frameAt K VWFrames.buffer ([], [])) :=
    VWFrames.kp_frame (J := VWFrames.chunkJ) (J' := J) rfl rfl rfl hk ([], [])
  exact VWFrames.kp_frame (J := J) (J' := VWFrames.typedJ bs n) rfl rfl rfl h1 ([], [])

end Host.Ts.Sim.Compose.VWFirst.X4_L7
