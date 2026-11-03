import host.sim.compose.a4b.PL4L7Nc_0
import host.sim.compose.a4b.PL4L7Nc_1
import host.sim.compose.a4b.PL4L7Nc_2
import host.sim.compose.a4b.PL4L7Nc_3
import host.sim.compose.a4b.PL4L7Nc_4
import host.sim.compose.a4b.PL4L7Nc_5
import host.sim.compose.a4b.PL4L7Nc_6
import host.sim.compose.a4b.PL4L7Nc_7
import host.sim.compose.a4b.PL4L7Nc_8
import host.sim.compose.a4b.PL4L7Nc_9
import host.sim.compose.a4b.PL4L7Nc_10
import host.sim.compose.a4b.PL4L7Nc_11
import host.sim.compose.a4b.PL4L7Nc_12
import host.sim.compose.a4b.PL4L7Nc_13
import host.sim.compose.a4b.PL4L7Nc_14
import host.sim.compose.a4b.PL4L7Nc_15
import host.sim.compose.a4b.PL4L7Nc_16
import host.sim.compose.a4b.PL4L7Nc_17
import host.sim.compose.a4b.PL4L7Nc_18
import host.sim.compose.a4b.PL4L7Nc_19
import host.sim.compose.a4b.PL4L7Nc_20
import host.sim.compose.a4b.PL4L7Nc_21
import host.sim.compose.a4b.PL4L7Nc_22
import host.sim.compose.a4b.PL4L7Nc_23
import host.sim.compose.a4b.PL4L7Nc_24
import host.sim.compose.a4b.PL4L7Nc_25
import host.sim.compose.a4b.PL4L7Nc_26
import host.sim.compose.a4b.PL4L7Nc_27
import host.sim.compose.a4b.PL4L7Nc_28
import host.sim.compose.a4b.PL4L7Nc_29
import host.sim.compose.a4b.PL4L7Nc_30
import host.sim.compose.a4b.PL4L7Nc_31
import host.sim.compose.a4b.PL4L7Nc_32
import host.sim.compose.a4b.PL4L7Nc_33
import host.sim.compose.a4b.PL4L7Nc_34
import host.sim.compose.a4b.PL4L7Nc_35
import host.sim.compose.a4b.PL4L7Nc_36
import host.sim.compose.a4b.PL4L7Nc_37
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L7.nhandles_end : (((((((((((((((handlesOfA PL4L7.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL4L7.nhandles : (handlesOfA PL4L7.x0).all (handleOK PLW4L7.R.data.map PL4L7.P0.lo PL4L7.x0 PL4L7.x1) = true :=
  all_take_drop 2000 PL4L7.nhandles_0 (all_take_drop 2000 PL4L7.nhandles_1 (all_take_drop 2000 PL4L7.nhandles_2 (all_take_drop 2000 PL4L7.nhandles_3 (all_take_drop 2000 PL4L7.nhandles_4 (all_take_drop 2000 PL4L7.nhandles_5 (all_take_drop 2000 PL4L7.nhandles_6 (all_take_drop 2000 PL4L7.nhandles_7 (all_take_drop 2000 PL4L7.nhandles_8 (all_take_drop 2000 PL4L7.nhandles_9 (all_take_drop 2000 PL4L7.nhandles_10 (all_take_drop 2000 PL4L7.nhandles_11 (all_take_drop 2000 PL4L7.nhandles_12 (all_take_drop 2000 PL4L7.nhandles_13 (all_take_drop 2000 PL4L7.nhandles_14 (all_of_nil PL4L7.nhandles_end)))))))))))))))
kernel_rfl PL4L7.nnodes_end : (((((((((((PTrie.keysA PL4L7.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL4L7.nnodes : (PTrie.keysA PL4L7.x0.nodes).all (nodeOKF PLW4L7.R.data.map PL4L7.P0 PL4L7.x0 PL4L7.x1) = true :=
  all_take_drop 2000 PL4L7.nnodes_0 (all_take_drop 2000 PL4L7.nnodes_1 (all_take_drop 2000 PL4L7.nnodes_2 (all_take_drop 2000 PL4L7.nnodes_3 (all_take_drop 2000 PL4L7.nnodes_4 (all_take_drop 2000 PL4L7.nnodes_5 (all_take_drop 2000 PL4L7.nnodes_6 (all_take_drop 2000 PL4L7.nnodes_7 (all_take_drop 2000 PL4L7.nnodes_8 (all_take_drop 2000 PL4L7.nnodes_9 (all_take_drop 2000 PL4L7.nnodes_10 (all_of_nil PL4L7.nnodes_end)))))))))))
kernel_rfl PL4L7.nprims_end : (((((((((((fullKeysF PL4L7.P0 PL4L7.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL4L7.nprims : (fullKeysF PL4L7.P0 PL4L7.x0).map (fun i => (PL4L7.x1.nodes.get (PLW4L7.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PL4L7.P0 PL4L7.x0).map (fun i => (PL4L7.x0.nodes.get i).map fun nd => PLW4L7.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PL4L7.nprims_0 (map_take_drop 2000 PL4L7.nprims_1 (map_take_drop 2000 PL4L7.nprims_2 (map_take_drop 2000 PL4L7.nprims_3 (map_take_drop 2000 PL4L7.nprims_4 (map_take_drop 2000 PL4L7.nprims_5 (map_take_drop 2000 PL4L7.nprims_6 (map_take_drop 2000 PL4L7.nprims_7 (map_take_drop 2000 PL4L7.nprims_8 (map_take_drop 2000 PL4L7.nprims_9 (map_take_drop 2000 PL4L7.nprims_10 (map_of_nil PL4L7.nprims_end)))))))))))

theorem PL4L7.nshift : NShift PL4L7.P0 PRE_plx4_L7_entry.n PLW4L7.R.data.map PL4L7.y0 PL4L7.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PL4L7.nnh0, PL4L7.nnh1, PL4L7.nnn0, PL4L7.nnn1, PL4L7.nlo, PL4L7.ncnt, PL4L7.nnband, PL4L7.nhbelow, PL4L7.nhandles, PL4L7.nhren, PL4L7.nband, PL4L7.nnh1pos, PL4L7.nobjs, PL4L7.nobjok, PL4L7.nnodes, PL4L7.nprims, PL4L7.nnren, PL4L7.nnlow, PL4L7.nnord, PL4L7.nitems, PL4L7.nssT, PL4L7.nabs0a, PL4L7.nabs0b, PL4L7.ntok1, PL4L7.npend, PL4L7.nerrh, PL4L7.nfiles, PL4L7.narch, PL4L7.nsizes, PL4L7.nwired⟩ PL4L7.nhost fun _ => rfl

end Host.Load.Run.Tpl
