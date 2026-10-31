import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK158
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA158 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1525.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1523.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo158.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1525.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd158 : (PRE_first_tail_x15_r0_body.clo158 ++ PRE_first_tail_x15_r0_body.cln158 ++ PRE_first_tail_x15_r0_body.cli158).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle158 : Conv.Cnt.leB (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck158 : Conv.ncleanListB (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1525.ffi).mlx PRE_first_tail_x15_r0_body.clo158 PRE_first_tail_x15_r0_body.cln158 PRE_first_tail_x15_r0_body.cli158 = true
theorem PRE_first_tail_x15_r0_body.cncl158 (h : Conv.NClean (⟨21307, 18403, 2798663, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1523.ffi).mlx) : Conv.NClean (⟨21307, 18403, 2798664, 6808⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1525.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle158 PRE_first_tail_x15_r0_body.ckA158 PRE_first_tail_x15_r0_body.cobjsK158 PRE_first_tail_x15_r0_body.cnodesK158 PRE_first_tail_x15_r0_body.citemsK158 PRE_first_tail_x15_r0_body.cbd158 PRE_first_tail_x15_r0_body.cck158

end Host.Load.Run.Tpl
