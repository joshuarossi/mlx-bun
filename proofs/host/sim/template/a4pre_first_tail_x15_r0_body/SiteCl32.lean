import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK32
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA32 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s316.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo32.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd32 : (PRE_first_tail_x15_r0_body.clo32 ++ PRE_first_tail_x15_r0_body.cln32 ++ PRE_first_tail_x15_r0_body.cli32).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle32 : Conv.Cnt.leB (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck32 : Conv.ncleanListB (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx PRE_first_tail_x15_r0_body.clo32 PRE_first_tail_x15_r0_body.cln32 PRE_first_tail_x15_r0_body.cli32 = true
theorem PRE_first_tail_x15_r0_body.cncl32 (h : Conv.NClean (⟨18825, 15922, 2699583, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s316.ffi).mlx) : Conv.NClean (⟨18825, 15922, 2699584, 1423⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s318.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle32 PRE_first_tail_x15_r0_body.ckA32 PRE_first_tail_x15_r0_body.cobjsK32 PRE_first_tail_x15_r0_body.cnodesK32 PRE_first_tail_x15_r0_body.citemsK32 PRE_first_tail_x15_r0_body.cbd32 PRE_first_tail_x15_r0_body.cck32

end Host.Load.Run.Tpl
