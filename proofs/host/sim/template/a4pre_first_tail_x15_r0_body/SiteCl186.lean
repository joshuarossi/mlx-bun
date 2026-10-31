import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK186
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA186 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo186.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd186 : (PRE_first_tail_x15_r0_body.clo186 ++ PRE_first_tail_x15_r0_body.cln186 ++ PRE_first_tail_x15_r0_body.cli186).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle186 : Conv.Cnt.leB (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck186 : Conv.ncleanListB (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx PRE_first_tail_x15_r0_body.clo186 PRE_first_tail_x15_r0_body.cln186 PRE_first_tail_x15_r0_body.cli186 = true
theorem PRE_first_tail_x15_r0_body.cncl186 (h : Conv.NClean (⟨21870, 18959, 2821247, 8036⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1799.ffi).mlx) : Conv.NClean (⟨21873, 18986, 2821253, 8054⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1801.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle186 PRE_first_tail_x15_r0_body.ckA186 PRE_first_tail_x15_r0_body.cobjsK186 PRE_first_tail_x15_r0_body.cnodesK186 PRE_first_tail_x15_r0_body.citemsK186 PRE_first_tail_x15_r0_body.cbd186 PRE_first_tail_x15_r0_body.cck186

end Host.Load.Run.Tpl
