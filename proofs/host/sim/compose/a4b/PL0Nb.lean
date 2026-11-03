import host.sim.compose.a4b.PL0Nc_0
import host.sim.compose.a4b.PL0Nc_1
import host.sim.compose.a4b.PL0Nc_2
import host.sim.compose.a4b.PL0Nc_3
import host.sim.compose.a4b.PL0Nc_4
import host.sim.compose.a4b.PL0Nc_5
import host.sim.compose.a4b.PL0Nc_6
import host.sim.compose.a4b.PL0Nc_7
import host.sim.compose.a4b.PL0Nc_8
import host.sim.compose.a4b.PL0Nc_9
import host.sim.compose.a4b.PL0Nc_10
import host.sim.compose.a4b.PL0Nc_11
import host.sim.compose.a4b.PL0Nc_12
import host.sim.compose.a4b.PL0Nc_13
import host.sim.compose.a4b.PL0Nc_14
import host.sim.compose.a4b.PL0Nc_15
import host.sim.compose.a4b.PL0Nc_16
import host.sim.compose.a4b.PL0Nc_17
import host.sim.compose.a4b.PL0Nc_18
import host.sim.compose.a4b.PL0Nc_19
import host.sim.compose.a4b.PL0Nc_20
import host.sim.compose.a4b.PL0Nc_21
import host.sim.compose.a4b.PL0Nc_22
import host.sim.compose.a4b.PL0Nc_23
import host.sim.compose.a4b.PL0Nc_24
import host.sim.compose.a4b.PL0Nc_25
import host.sim.compose.a4b.PL0Nc_26
import host.sim.compose.a4b.PL0Nc_27
import host.sim.compose.a4b.PL0Nc_28
import host.sim.compose.a4b.PL0Nc_29
import host.sim.compose.a4b.PL0Nc_30
import host.sim.compose.a4b.PL0Nc_31
import host.sim.compose.a4b.PL0Nc_32
import host.sim.compose.a4b.PL0Nc_33
import host.sim.compose.a4b.PL0Nc_34
import host.sim.compose.a4b.PL0Nc_35
import host.sim.compose.a4b.PL0Nc_36
import host.sim.compose.a4b.PL0Nc_37
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL0.nhandles_end : (((((((((((((((handlesOfA PL0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL0.nhandles : (handlesOfA PL0.x0).all (handleOK PLW0.R.data.map PL0.P0.lo PL0.x0 PL0.x1) = true :=
  all_take_drop 2000 PL0.nhandles_0 (all_take_drop 2000 PL0.nhandles_1 (all_take_drop 2000 PL0.nhandles_2 (all_take_drop 2000 PL0.nhandles_3 (all_take_drop 2000 PL0.nhandles_4 (all_take_drop 2000 PL0.nhandles_5 (all_take_drop 2000 PL0.nhandles_6 (all_take_drop 2000 PL0.nhandles_7 (all_take_drop 2000 PL0.nhandles_8 (all_take_drop 2000 PL0.nhandles_9 (all_take_drop 2000 PL0.nhandles_10 (all_take_drop 2000 PL0.nhandles_11 (all_take_drop 2000 PL0.nhandles_12 (all_take_drop 2000 PL0.nhandles_13 (all_take_drop 2000 PL0.nhandles_14 (all_of_nil PL0.nhandles_end)))))))))))))))
kernel_rfl PL0.nnodes_end : (((((((((((PTrie.keysA PL0.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL0.nnodes : (PTrie.keysA PL0.x0.nodes).all (nodeOKF PLW0.R.data.map PL0.P0 PL0.x0 PL0.x1) = true :=
  all_take_drop 2000 PL0.nnodes_0 (all_take_drop 2000 PL0.nnodes_1 (all_take_drop 2000 PL0.nnodes_2 (all_take_drop 2000 PL0.nnodes_3 (all_take_drop 2000 PL0.nnodes_4 (all_take_drop 2000 PL0.nnodes_5 (all_take_drop 2000 PL0.nnodes_6 (all_take_drop 2000 PL0.nnodes_7 (all_take_drop 2000 PL0.nnodes_8 (all_take_drop 2000 PL0.nnodes_9 (all_take_drop 2000 PL0.nnodes_10 (all_of_nil PL0.nnodes_end)))))))))))
kernel_rfl PL0.nprims_end : (((((((((((fullKeysF PL0.P0 PL0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PL0.nprims : (fullKeysF PL0.P0 PL0.x0).map (fun i => (PL0.x1.nodes.get (PLW0.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PL0.P0 PL0.x0).map (fun i => (PL0.x0.nodes.get i).map fun nd => PLW0.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PL0.nprims_0 (map_take_drop 2000 PL0.nprims_1 (map_take_drop 2000 PL0.nprims_2 (map_take_drop 2000 PL0.nprims_3 (map_take_drop 2000 PL0.nprims_4 (map_take_drop 2000 PL0.nprims_5 (map_take_drop 2000 PL0.nprims_6 (map_take_drop 2000 PL0.nprims_7 (map_take_drop 2000 PL0.nprims_8 (map_take_drop 2000 PL0.nprims_9 (map_take_drop 2000 PL0.nprims_10 (map_of_nil PL0.nprims_end)))))))))))

theorem PL0.nshift : NShift PL0.P0 PRE_plx0_entry.n PLW0.R.data.map PL0.y0 PL0.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PL0.nnh0, PL0.nnh1, PL0.nnn0, PL0.nnn1, PL0.nlo, PL0.ncnt, PL0.nnband, PL0.nhbelow, PL0.nhandles, PL0.nhren, PL0.nband, PL0.nnh1pos, PL0.nobjs, PL0.nobjok, PL0.nnodes, PL0.nprims, PL0.nnren, PL0.nnlow, PL0.nnord, PL0.nitems, PL0.nssT, PL0.nabs0a, PL0.nabs0b, PL0.ntok1, PL0.npend, PL0.nerrh, PL0.nfiles, PL0.narch, PL0.nsizes, PL0.nwired⟩ PL0.nhost fun _ => rfl

end Host.Load.Run.Tpl
