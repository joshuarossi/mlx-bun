import host.sim.template.a4pre_first_tail_x15_r0_body.SiteK189
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA189 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1667.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo189.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd189 : (PRE_first_tail_x15_r0_body.clo189 ++ PRE_first_tail_x15_r0_body.cln189 ++ PRE_first_tail_x15_r0_body.cli189).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle189 : Conv.Cnt.leB (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck189 : Conv.ncleanListB (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx PRE_first_tail_x15_r0_body.clo189 PRE_first_tail_x15_r0_body.cln189 PRE_first_tail_x15_r0_body.cli189 = true
theorem PRE_first_tail_x15_r0_body.cncl189 (h : Conv.NClean (⟨21933, 19031, 2823768, 8169⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1667.ffi).mlx) : Conv.NClean (⟨21937, 19037, 2823783, 8178⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1669.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle189 PRE_first_tail_x15_r0_body.ckA189 PRE_first_tail_x15_r0_body.cobjsK189 PRE_first_tail_x15_r0_body.cnodesK189 PRE_first_tail_x15_r0_body.citemsK189 PRE_first_tail_x15_r0_body.cbd189 PRE_first_tail_x15_r0_body.cck189

end Host.Load.Run.Tpl
