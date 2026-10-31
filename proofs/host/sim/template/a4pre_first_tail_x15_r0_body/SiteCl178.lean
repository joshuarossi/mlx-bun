import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK178
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA178 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1569.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo178.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd178 : (PRE_first_tail_x15_r0_body.clo178 ++ PRE_first_tail_x15_r0_body.cln178 ++ PRE_first_tail_x15_r0_body.cli178).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle178 : Conv.Cnt.leB (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck178 : Conv.ncleanListB (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx PRE_first_tail_x15_r0_body.clo178 PRE_first_tail_x15_r0_body.cln178 PRE_first_tail_x15_r0_body.cli178 = true
theorem PRE_first_tail_x15_r0_body.cncl178 (h : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1569.ffi).mlx) : Conv.NClean (⟨21714, 18810, 2814941, 7688⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1571.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle178 PRE_first_tail_x15_r0_body.ckA178 PRE_first_tail_x15_r0_body.cobjsK178 PRE_first_tail_x15_r0_body.cnodesK178 PRE_first_tail_x15_r0_body.citemsK178 PRE_first_tail_x15_r0_body.cbd178 PRE_first_tail_x15_r0_body.cck178

end Host.Load.Run.Tpl
