import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab1
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab2
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab3
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab4
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab5
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab6
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab7
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab8
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab9
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab10
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab11
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab12
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab13
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab14
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab15
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab16
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab17
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab18
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab19
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab20
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab21
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab22
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab23
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab24
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab25
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab26
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab27
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab28
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab29
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab30
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab31
import host.sim.template.a4pre_first_tail_x15_r0_suffix.BoundaryTab32
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
kernel_rfl PRE_first_tail_x15_r0_suffix.endTabNilS : PRE_first_tail_x15_r0_suffix.S8.tab.drop 8448 = []
kernel_rfl PRE_first_tail_x15_r0_suffix.endTabNilT : PRE_first_tail_x15_r0_suffix.endSrv.tab.drop 8448 = []
theorem PRE_first_tail_x15_r0_suffix.endTab : PRE_first_tail_x15_r0_suffix.S8.tab.map (·.subst PRE_first_tail_x15_r0_suffix.dtheta) = PRE_first_tail_x15_r0_suffix.endSrv.tab := boundary_map_drop 256 0 PRE_first_tail_x15_r0_suffix.endTab0 (boundary_map_drop 256 256 PRE_first_tail_x15_r0_suffix.endTab1 (boundary_map_drop 256 512 PRE_first_tail_x15_r0_suffix.endTab2 (boundary_map_drop 256 768 PRE_first_tail_x15_r0_suffix.endTab3 (boundary_map_drop 256 1024 PRE_first_tail_x15_r0_suffix.endTab4 (boundary_map_drop 256 1280 PRE_first_tail_x15_r0_suffix.endTab5 (boundary_map_drop 256 1536 PRE_first_tail_x15_r0_suffix.endTab6 (boundary_map_drop 256 1792 PRE_first_tail_x15_r0_suffix.endTab7 (boundary_map_drop 256 2048 PRE_first_tail_x15_r0_suffix.endTab8 (boundary_map_drop 256 2304 PRE_first_tail_x15_r0_suffix.endTab9 (boundary_map_drop 256 2560 PRE_first_tail_x15_r0_suffix.endTab10 (boundary_map_drop 256 2816 PRE_first_tail_x15_r0_suffix.endTab11 (boundary_map_drop 256 3072 PRE_first_tail_x15_r0_suffix.endTab12 (boundary_map_drop 256 3328 PRE_first_tail_x15_r0_suffix.endTab13 (boundary_map_drop 256 3584 PRE_first_tail_x15_r0_suffix.endTab14 (boundary_map_drop 256 3840 PRE_first_tail_x15_r0_suffix.endTab15 (boundary_map_drop 256 4096 PRE_first_tail_x15_r0_suffix.endTab16 (boundary_map_drop 256 4352 PRE_first_tail_x15_r0_suffix.endTab17 (boundary_map_drop 256 4608 PRE_first_tail_x15_r0_suffix.endTab18 (boundary_map_drop 256 4864 PRE_first_tail_x15_r0_suffix.endTab19 (boundary_map_drop 256 5120 PRE_first_tail_x15_r0_suffix.endTab20 (boundary_map_drop 256 5376 PRE_first_tail_x15_r0_suffix.endTab21 (boundary_map_drop 256 5632 PRE_first_tail_x15_r0_suffix.endTab22 (boundary_map_drop 256 5888 PRE_first_tail_x15_r0_suffix.endTab23 (boundary_map_drop 256 6144 PRE_first_tail_x15_r0_suffix.endTab24 (boundary_map_drop 256 6400 PRE_first_tail_x15_r0_suffix.endTab25 (boundary_map_drop 256 6656 PRE_first_tail_x15_r0_suffix.endTab26 (boundary_map_drop 256 6912 PRE_first_tail_x15_r0_suffix.endTab27 (boundary_map_drop 256 7168 PRE_first_tail_x15_r0_suffix.endTab28 (boundary_map_drop 256 7424 PRE_first_tail_x15_r0_suffix.endTab29 (boundary_map_drop 256 7680 PRE_first_tail_x15_r0_suffix.endTab30 (boundary_map_drop 256 7936 PRE_first_tail_x15_r0_suffix.endTab31 (boundary_map_drop 256 8192 PRE_first_tail_x15_r0_suffix.endTab32 (boundary_map_nil PRE_first_tail_x15_r0_suffix.endTabNilS PRE_first_tail_x15_r0_suffix.endTabNilT)))))))))))))))))))))))))))))))))

theorem PRE_first_tail_x15_r0_suffix.endSrv_length : PRE_first_tail_x15_r0_suffix.endSrv.tab.length = PRE_first_tail_x15_r0_suffix.S8.tab.length := by
  rw [← PRE_first_tail_x15_r0_suffix.endTab, List.length_map]

end Host.Load.Run.Tpl
