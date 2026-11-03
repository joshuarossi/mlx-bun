import host.sim.compose.a4b.PF4L7Nc_0
import host.sim.compose.a4b.PF4L7Nc_1
import host.sim.compose.a4b.PF4L7Nc_2
import host.sim.compose.a4b.PF4L7Nc_3
import host.sim.compose.a4b.PF4L7Nc_4
import host.sim.compose.a4b.PF4L7Nc_5
import host.sim.compose.a4b.PF4L7Nc_6
import host.sim.compose.a4b.PF4L7Nc_7
import host.sim.compose.a4b.PF4L7Nc_8
import host.sim.compose.a4b.PF4L7Nc_9
import host.sim.compose.a4b.PF4L7Nc_10
import host.sim.compose.a4b.PF4L7Nc_11
import host.sim.compose.a4b.PF4L7Nc_12
import host.sim.compose.a4b.PF4L7Nc_13
import host.sim.compose.a4b.PF4L7Nc_14
import host.sim.compose.a4b.PF4L7Nc_15
import host.sim.compose.a4b.PF4L7Nc_16
import host.sim.compose.a4b.PF4L7Nc_17
import host.sim.compose.a4b.PF4L7Nc_18
import host.sim.compose.a4b.PF4L7Nc_19
import host.sim.compose.a4b.PF4L7Nc_20
import host.sim.compose.a4b.PF4L7Nc_21
import host.sim.compose.a4b.PF4L7Nc_22
import host.sim.compose.a4b.PF4L7Nc_23
import host.sim.compose.a4b.PF4L7Nc_24
import host.sim.compose.a4b.PF4L7Nc_25
import host.sim.compose.a4b.PF4L7Nc_26
import host.sim.compose.a4b.PF4L7Nc_27
import host.sim.compose.a4b.PF4L7Nc_28
import host.sim.compose.a4b.PF4L7Nc_29
import host.sim.compose.a4b.PF4L7Nc_30
import host.sim.compose.a4b.PF4L7Nc_31
import host.sim.compose.a4b.PF4L7Nc_32
import host.sim.compose.a4b.PF4L7Nc_33
import host.sim.compose.a4b.PF4L7Nc_34
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L7.nhandles_end : ((((((((((((((handlesOfA PF4L7.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF4L7.nhandles : (handlesOfA PF4L7.x0).all (handleOK PFW4L7.R.data.map PF4L7.P0.lo PF4L7.x0 PF4L7.x1) = true :=
  all_take_drop 2000 PF4L7.nhandles_0 (all_take_drop 2000 PF4L7.nhandles_1 (all_take_drop 2000 PF4L7.nhandles_2 (all_take_drop 2000 PF4L7.nhandles_3 (all_take_drop 2000 PF4L7.nhandles_4 (all_take_drop 2000 PF4L7.nhandles_5 (all_take_drop 2000 PF4L7.nhandles_6 (all_take_drop 2000 PF4L7.nhandles_7 (all_take_drop 2000 PF4L7.nhandles_8 (all_take_drop 2000 PF4L7.nhandles_9 (all_take_drop 2000 PF4L7.nhandles_10 (all_take_drop 2000 PF4L7.nhandles_11 (all_take_drop 2000 PF4L7.nhandles_12 (all_take_drop 2000 PF4L7.nhandles_13 (all_of_nil PF4L7.nhandles_end))))))))))))))
kernel_rfl PF4L7.nnodes_end : ((((((((((PTrie.keysA PF4L7.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF4L7.nnodes : (PTrie.keysA PF4L7.x0.nodes).all (nodeOKF PFW4L7.R.data.map PF4L7.P0 PF4L7.x0 PF4L7.x1) = true :=
  all_take_drop 2000 PF4L7.nnodes_0 (all_take_drop 2000 PF4L7.nnodes_1 (all_take_drop 2000 PF4L7.nnodes_2 (all_take_drop 2000 PF4L7.nnodes_3 (all_take_drop 2000 PF4L7.nnodes_4 (all_take_drop 2000 PF4L7.nnodes_5 (all_take_drop 2000 PF4L7.nnodes_6 (all_take_drop 2000 PF4L7.nnodes_7 (all_take_drop 2000 PF4L7.nnodes_8 (all_take_drop 2000 PF4L7.nnodes_9 (all_of_nil PF4L7.nnodes_end))))))))))
kernel_rfl PF4L7.nprims_end : ((((((((((fullKeysF PF4L7.P0 PF4L7.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF4L7.nprims : (fullKeysF PF4L7.P0 PF4L7.x0).map (fun i => (PF4L7.x1.nodes.get (PFW4L7.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PF4L7.P0 PF4L7.x0).map (fun i => (PF4L7.x0.nodes.get i).map fun nd => PFW4L7.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PF4L7.nprims_0 (map_take_drop 2000 PF4L7.nprims_1 (map_take_drop 2000 PF4L7.nprims_2 (map_take_drop 2000 PF4L7.nprims_3 (map_take_drop 2000 PF4L7.nprims_4 (map_take_drop 2000 PF4L7.nprims_5 (map_take_drop 2000 PF4L7.nprims_6 (map_take_drop 2000 PF4L7.nprims_7 (map_take_drop 2000 PF4L7.nprims_8 (map_take_drop 2000 PF4L7.nprims_9 (map_of_nil PF4L7.nprims_end))))))))))

theorem PF4L7.nshift : NShift PF4L7.P0 PRE_pf_x4_L7.n PFW4L7.R.data.map PF4L7.y0 PF4L7.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PF4L7.nnh0, PF4L7.nnh1, PF4L7.nnn0, PF4L7.nnn1, PF4L7.nlo, PF4L7.ncnt, PF4L7.nnband, PF4L7.nhbelow, PF4L7.nhandles, PF4L7.nhren, PF4L7.nband, PF4L7.nnh1pos, PF4L7.nobjs, PF4L7.nobjok, PF4L7.nnodes, PF4L7.nprims, PF4L7.nnren, PF4L7.nnlow, PF4L7.nnord, PF4L7.nitems, PF4L7.nssT, PF4L7.nabs0a, PF4L7.nabs0b, PF4L7.ntok1, PF4L7.npend, PF4L7.nerrh, PF4L7.nfiles, PF4L7.narch, PF4L7.nsizes, PF4L7.nwired⟩ PF4L7.nhost fun _ => rfl

end Host.Load.Run.Tpl
