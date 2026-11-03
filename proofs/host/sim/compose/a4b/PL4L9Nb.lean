import host.sim.compose.a4b.PL4L9Nc_0
import host.sim.compose.a4b.PL4L9Nc_1
import host.sim.compose.a4b.PL4L9Nc_2
import host.sim.compose.a4b.PL4L9Nc_3
import host.sim.compose.a4b.PL4L9Nc_4
import host.sim.compose.a4b.PL4L9Nc_5
import host.sim.compose.a4b.PL4L9Nc_6
import host.sim.compose.a4b.PL4L9Nc_7
import host.sim.compose.a4b.PL4L9Nc_8
import host.sim.compose.a4b.PL4L9Nc_9
import host.sim.compose.a4b.PL4L9Nc_10
import host.sim.compose.a4b.PL4L9Nc_11
import host.sim.compose.a4b.PL4L9Nc_12
import host.sim.compose.a4b.PL4L9Nc_13
import host.sim.compose.a4b.PL4L9Nc_14
import host.sim.compose.a4b.PL4L9Nc_15
import host.sim.compose.a4b.PL4L9Nc_16
import host.sim.compose.a4b.PL4L9Nc_17
import host.sim.compose.a4b.PL4L9Nc_18
import host.sim.compose.a4b.PL4L9Nc_19
import host.sim.compose.a4b.PL4L9Nc_20
import host.sim.compose.a4b.PL4L9Nc_21
import host.sim.compose.a4b.PL4L9Nc_22
import host.sim.compose.a4b.PL4L9Nc_23
import host.sim.compose.a4b.PL4L9Nc_24
import host.sim.compose.a4b.PL4L9Nc_25
import host.sim.compose.a4b.PL4L9Nc_26
import host.sim.compose.a4b.PL4L9Nc_27
import host.sim.compose.a4b.PL4L9Nc_28
import host.sim.compose.a4b.PL4L9Nc_29
import host.sim.compose.a4b.PL4L9Nc_30
import host.sim.compose.a4b.PL4L9Nc_31
import host.sim.compose.a4b.PL4L9Nc_32
import host.sim.compose.a4b.PL4L9Nc_33
import host.sim.compose.a4b.PL4L9Nc_34
import host.sim.compose.a4b.PL4L9Nc_35
import host.sim.compose.a4b.PL4L9Nc_36
import host.sim.compose.a4b.PL4L9Nc_37
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L9.nhandles_end : (((((((((((((((handlesOfA PL4L9.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL4L9.nhandles : (handlesOfA PL4L9.x0).all (handleOK PLW4L9.R.data.map PL4L9.P0.lo PL4L9.x0 PL4L9.x1) = true :=
  all_take_drop 2000 PL4L9.nhandles_0 (all_take_drop 2000 PL4L9.nhandles_1 (all_take_drop 2000 PL4L9.nhandles_2 (all_take_drop 2000 PL4L9.nhandles_3 (all_take_drop 2000 PL4L9.nhandles_4 (all_take_drop 2000 PL4L9.nhandles_5 (all_take_drop 2000 PL4L9.nhandles_6 (all_take_drop 2000 PL4L9.nhandles_7 (all_take_drop 2000 PL4L9.nhandles_8 (all_take_drop 2000 PL4L9.nhandles_9 (all_take_drop 2000 PL4L9.nhandles_10 (all_take_drop 2000 PL4L9.nhandles_11 (all_take_drop 2000 PL4L9.nhandles_12 (all_take_drop 2000 PL4L9.nhandles_13 (all_take_drop 2000 PL4L9.nhandles_14 (all_of_nil PL4L9.nhandles_end)))))))))))))))
kernel_rfl PL4L9.nnodes_end : (((((((((((PTrie.keysA PL4L9.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL4L9.nnodes : (PTrie.keysA PL4L9.x0.nodes).all (nodeOKF PLW4L9.R.data.map PL4L9.P0 PL4L9.x0 PL4L9.x1) = true :=
  all_take_drop 2000 PL4L9.nnodes_0 (all_take_drop 2000 PL4L9.nnodes_1 (all_take_drop 2000 PL4L9.nnodes_2 (all_take_drop 2000 PL4L9.nnodes_3 (all_take_drop 2000 PL4L9.nnodes_4 (all_take_drop 2000 PL4L9.nnodes_5 (all_take_drop 2000 PL4L9.nnodes_6 (all_take_drop 2000 PL4L9.nnodes_7 (all_take_drop 2000 PL4L9.nnodes_8 (all_take_drop 2000 PL4L9.nnodes_9 (all_take_drop 2000 PL4L9.nnodes_10 (all_of_nil PL4L9.nnodes_end)))))))))))
kernel_rfl PL4L9.nprims_end : (((((((((((fullKeysF PL4L9.P0 PL4L9.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL4L9.nprims : (fullKeysF PL4L9.P0 PL4L9.x0).map (fun i => (PL4L9.x1.nodes.get (PLW4L9.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PL4L9.P0 PL4L9.x0).map (fun i => (PL4L9.x0.nodes.get i).map fun nd => PLW4L9.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PL4L9.nprims_0 (map_take_drop 2000 PL4L9.nprims_1 (map_take_drop 2000 PL4L9.nprims_2 (map_take_drop 2000 PL4L9.nprims_3 (map_take_drop 2000 PL4L9.nprims_4 (map_take_drop 2000 PL4L9.nprims_5 (map_take_drop 2000 PL4L9.nprims_6 (map_take_drop 2000 PL4L9.nprims_7 (map_take_drop 2000 PL4L9.nprims_8 (map_take_drop 2000 PL4L9.nprims_9 (map_take_drop 2000 PL4L9.nprims_10 (map_of_nil PL4L9.nprims_end)))))))))))

theorem PL4L9.nshift : NShift PL4L9.P0 PRE_plx4_L9_entry.n PLW4L9.R.data.map PL4L9.y0 PL4L9.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PL4L9.nnh0, PL4L9.nnh1, PL4L9.nnn0, PL4L9.nnn1, PL4L9.nlo, PL4L9.ncnt, PL4L9.nnband, PL4L9.nhbelow, PL4L9.nhandles, PL4L9.nhren, PL4L9.nband, PL4L9.nnh1pos, PL4L9.nobjs, PL4L9.nobjok, PL4L9.nnodes, PL4L9.nprims, PL4L9.nnren, PL4L9.nnlow, PL4L9.nnord, PL4L9.nitems, PL4L9.nssT, PL4L9.nabs0a, PL4L9.nabs0b, PL4L9.ntok1, PL4L9.npend, PL4L9.nerrh, PL4L9.nfiles, PL4L9.narch, PL4L9.nsizes, PL4L9.nwired⟩ PL4L9.nhost fun _ => rfl

end Host.Load.Run.Tpl
