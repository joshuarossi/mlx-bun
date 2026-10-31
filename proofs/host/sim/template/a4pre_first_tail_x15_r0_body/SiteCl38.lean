import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK38
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA38 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo38.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd38 : (PRE_first_tail_x15_r0_body.clo38 ++ PRE_first_tail_x15_r0_body.cln38 ++ PRE_first_tail_x15_r0_body.cli38).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle38 : Conv.Cnt.leB (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck38 : Conv.ncleanListB (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx PRE_first_tail_x15_r0_body.clo38 PRE_first_tail_x15_r0_body.cln38 PRE_first_tail_x15_r0_body.cli38 = true
theorem PRE_first_tail_x15_r0_body.cncl38 (h : Conv.NClean (⟨18947, 16033, 2704487, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s340.ffi).mlx) : Conv.NClean (⟨18947, 16033, 2704488, 1678⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s342.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle38 PRE_first_tail_x15_r0_body.ckA38 PRE_first_tail_x15_r0_body.cobjsK38 PRE_first_tail_x15_r0_body.cnodesK38 PRE_first_tail_x15_r0_body.citemsK38 PRE_first_tail_x15_r0_body.cbd38 PRE_first_tail_x15_r0_body.cck38

end Host.Load.Run.Tpl
