import host.sim.compose.a4b.PL4L8Nc_0
import host.sim.compose.a4b.PL4L8Nc_1
import host.sim.compose.a4b.PL4L8Nc_2
import host.sim.compose.a4b.PL4L8Nc_3
import host.sim.compose.a4b.PL4L8Nc_4
import host.sim.compose.a4b.PL4L8Nc_5
import host.sim.compose.a4b.PL4L8Nc_6
import host.sim.compose.a4b.PL4L8Nc_7
import host.sim.compose.a4b.PL4L8Nc_8
import host.sim.compose.a4b.PL4L8Nc_9
import host.sim.compose.a4b.PL4L8Nc_10
import host.sim.compose.a4b.PL4L8Nc_11
import host.sim.compose.a4b.PL4L8Nc_12
import host.sim.compose.a4b.PL4L8Nc_13
import host.sim.compose.a4b.PL4L8Nc_14
import host.sim.compose.a4b.PL4L8Nc_15
import host.sim.compose.a4b.PL4L8Nc_16
import host.sim.compose.a4b.PL4L8Nc_17
import host.sim.compose.a4b.PL4L8Nc_18
import host.sim.compose.a4b.PL4L8Nc_19
import host.sim.compose.a4b.PL4L8Nc_20
import host.sim.compose.a4b.PL4L8Nc_21
import host.sim.compose.a4b.PL4L8Nc_22
import host.sim.compose.a4b.PL4L8Nc_23
import host.sim.compose.a4b.PL4L8Nc_24
import host.sim.compose.a4b.PL4L8Nc_25
import host.sim.compose.a4b.PL4L8Nc_26
import host.sim.compose.a4b.PL4L8Nc_27
import host.sim.compose.a4b.PL4L8Nc_28
import host.sim.compose.a4b.PL4L8Nc_29
import host.sim.compose.a4b.PL4L8Nc_30
import host.sim.compose.a4b.PL4L8Nc_31
import host.sim.compose.a4b.PL4L8Nc_32
import host.sim.compose.a4b.PL4L8Nc_33
import host.sim.compose.a4b.PL4L8Nc_34
import host.sim.compose.a4b.PL4L8Nc_35
import host.sim.compose.a4b.PL4L8Nc_36
import host.sim.compose.a4b.PL4L8Nc_37
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L8.nhandles_end : (((((((((((((((handlesOfA PL4L8.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL4L8.nhandles : (handlesOfA PL4L8.x0).all (handleOK PLW4L8.R.data.map PL4L8.P0.lo PL4L8.x0 PL4L8.x1) = true :=
  all_take_drop 2000 PL4L8.nhandles_0 (all_take_drop 2000 PL4L8.nhandles_1 (all_take_drop 2000 PL4L8.nhandles_2 (all_take_drop 2000 PL4L8.nhandles_3 (all_take_drop 2000 PL4L8.nhandles_4 (all_take_drop 2000 PL4L8.nhandles_5 (all_take_drop 2000 PL4L8.nhandles_6 (all_take_drop 2000 PL4L8.nhandles_7 (all_take_drop 2000 PL4L8.nhandles_8 (all_take_drop 2000 PL4L8.nhandles_9 (all_take_drop 2000 PL4L8.nhandles_10 (all_take_drop 2000 PL4L8.nhandles_11 (all_take_drop 2000 PL4L8.nhandles_12 (all_take_drop 2000 PL4L8.nhandles_13 (all_take_drop 2000 PL4L8.nhandles_14 (all_of_nil PL4L8.nhandles_end)))))))))))))))
kernel_rfl PL4L8.nnodes_end : (((((((((((PTrie.keysA PL4L8.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL4L8.nnodes : (PTrie.keysA PL4L8.x0.nodes).all (nodeOKF PLW4L8.R.data.map PL4L8.P0 PL4L8.x0 PL4L8.x1) = true :=
  all_take_drop 2000 PL4L8.nnodes_0 (all_take_drop 2000 PL4L8.nnodes_1 (all_take_drop 2000 PL4L8.nnodes_2 (all_take_drop 2000 PL4L8.nnodes_3 (all_take_drop 2000 PL4L8.nnodes_4 (all_take_drop 2000 PL4L8.nnodes_5 (all_take_drop 2000 PL4L8.nnodes_6 (all_take_drop 2000 PL4L8.nnodes_7 (all_take_drop 2000 PL4L8.nnodes_8 (all_take_drop 2000 PL4L8.nnodes_9 (all_take_drop 2000 PL4L8.nnodes_10 (all_of_nil PL4L8.nnodes_end)))))))))))
kernel_rfl PL4L8.nprims_end : (((((((((((fullKeysF PL4L8.P0 PL4L8.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL4L8.nprims : (fullKeysF PL4L8.P0 PL4L8.x0).map (fun i => (PL4L8.x1.nodes.get (PLW4L8.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PL4L8.P0 PL4L8.x0).map (fun i => (PL4L8.x0.nodes.get i).map fun nd => PLW4L8.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PL4L8.nprims_0 (map_take_drop 2000 PL4L8.nprims_1 (map_take_drop 2000 PL4L8.nprims_2 (map_take_drop 2000 PL4L8.nprims_3 (map_take_drop 2000 PL4L8.nprims_4 (map_take_drop 2000 PL4L8.nprims_5 (map_take_drop 2000 PL4L8.nprims_6 (map_take_drop 2000 PL4L8.nprims_7 (map_take_drop 2000 PL4L8.nprims_8 (map_take_drop 2000 PL4L8.nprims_9 (map_take_drop 2000 PL4L8.nprims_10 (map_of_nil PL4L8.nprims_end)))))))))))

theorem PL4L8.nshift : NShift PL4L8.P0 PRE_plx4_L8_entry.n PLW4L8.R.data.map PL4L8.y0 PL4L8.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PL4L8.nnh0, PL4L8.nnh1, PL4L8.nnn0, PL4L8.nnn1, PL4L8.nlo, PL4L8.ncnt, PL4L8.nnband, PL4L8.nhbelow, PL4L8.nhandles, PL4L8.nhren, PL4L8.nband, PL4L8.nnh1pos, PL4L8.nobjs, PL4L8.nobjok, PL4L8.nnodes, PL4L8.nprims, PL4L8.nnren, PL4L8.nnlow, PL4L8.nnord, PL4L8.nitems, PL4L8.nssT, PL4L8.nabs0a, PL4L8.nabs0b, PL4L8.ntok1, PL4L8.npend, PL4L8.nerrh, PL4L8.nfiles, PL4L8.narch, PL4L8.nsizes, PL4L8.nwired⟩ PL4L8.nhost fun _ => rfl

end Host.Load.Run.Tpl
