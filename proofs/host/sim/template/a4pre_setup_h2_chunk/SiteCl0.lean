import host.sim.template.a4pre_setup_h2_chunk.SiteK0
import host.sim.conv.NClean
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_setup_h2_chunk.ckA0 : (Host.Load.Layers.toLoad PRE_setup_h2_chunk.s2.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_setup_h2_chunk.s0.ffi).mlx.arrs (PRE_setup_h2_chunk.clo0.filterMap fun i => ((Host.Load.Layers.toLoad PRE_setup_h2_chunk.s2.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_setup_h2_chunk.cbd0 : (PRE_setup_h2_chunk.clo0 ++ PRE_setup_h2_chunk.cln0 ++ PRE_setup_h2_chunk.cli0).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_setup_h2_chunk.cle0 : Conv.Cnt.leB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) = true
kernel_rfl PRE_setup_h2_chunk.cck0 : Conv.ncleanListB (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h2_chunk.s2.ffi).mlx PRE_setup_h2_chunk.clo0 PRE_setup_h2_chunk.cln0 PRE_setup_h2_chunk.cli0 = true
theorem PRE_setup_h2_chunk.cncl0 (h : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h2_chunk.s0.ffi).mlx) : Conv.NClean (⟨18155, 15235, 2673336, 10⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_setup_h2_chunk.s2.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_setup_h2_chunk.cle0 PRE_setup_h2_chunk.ckA0 PRE_setup_h2_chunk.cobjsK0 PRE_setup_h2_chunk.cnodesK0 PRE_setup_h2_chunk.citemsK0 PRE_setup_h2_chunk.cbd0 PRE_setup_h2_chunk.cck0

end Host.Load.Run.Tpl
