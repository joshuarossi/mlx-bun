import host.sim.compose.a4b.PF0Nc_0
import host.sim.compose.a4b.PF0Nc_1
import host.sim.compose.a4b.PF0Nc_2
import host.sim.compose.a4b.PF0Nc_3
import host.sim.compose.a4b.PF0Nc_4
import host.sim.compose.a4b.PF0Nc_5
import host.sim.compose.a4b.PF0Nc_6
import host.sim.compose.a4b.PF0Nc_7
import host.sim.compose.a4b.PF0Nc_8
import host.sim.compose.a4b.PF0Nc_9
import host.sim.compose.a4b.PF0Nc_10
import host.sim.compose.a4b.PF0Nc_11
import host.sim.compose.a4b.PF0Nc_12
import host.sim.compose.a4b.PF0Nc_13
import host.sim.compose.a4b.PF0Nc_14
import host.sim.compose.a4b.PF0Nc_15
import host.sim.compose.a4b.PF0Nc_16
import host.sim.compose.a4b.PF0Nc_17
import host.sim.compose.a4b.PF0Nc_18
import host.sim.compose.a4b.PF0Nc_19
import host.sim.compose.a4b.PF0Nc_20
import host.sim.compose.a4b.PF0Nc_21
import host.sim.compose.a4b.PF0Nc_22
import host.sim.compose.a4b.PF0Nc_23
import host.sim.compose.a4b.PF0Nc_24
import host.sim.compose.a4b.PF0Nc_25
import host.sim.compose.a4b.PF0Nc_26
import host.sim.compose.a4b.PF0Nc_27
import host.sim.compose.a4b.PF0Nc_28
import host.sim.compose.a4b.PF0Nc_29
import host.sim.compose.a4b.PF0Nc_30
import host.sim.compose.a4b.PF0Nc_31
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF0.nhandles_end : (((((((((((((handlesOfA PF0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF0.nhandles : (handlesOfA PF0.x0).all (handleOK PFW0.R.data.map PF0.P0.lo PF0.x0 PF0.x1) = true :=
  all_take_drop 2000 PF0.nhandles_0 (all_take_drop 2000 PF0.nhandles_1 (all_take_drop 2000 PF0.nhandles_2 (all_take_drop 2000 PF0.nhandles_3 (all_take_drop 2000 PF0.nhandles_4 (all_take_drop 2000 PF0.nhandles_5 (all_take_drop 2000 PF0.nhandles_6 (all_take_drop 2000 PF0.nhandles_7 (all_take_drop 2000 PF0.nhandles_8 (all_take_drop 2000 PF0.nhandles_9 (all_take_drop 2000 PF0.nhandles_10 (all_take_drop 2000 PF0.nhandles_11 (all_take_drop 2000 PF0.nhandles_12 (all_of_nil PF0.nhandles_end)))))))))))))
kernel_rfl PF0.nnodes_end : (((((((((PTrie.keysA PF0.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF0.nnodes : (PTrie.keysA PF0.x0.nodes).all (nodeOKF PFW0.R.data.map PF0.P0 PF0.x0 PF0.x1) = true :=
  all_take_drop 2000 PF0.nnodes_0 (all_take_drop 2000 PF0.nnodes_1 (all_take_drop 2000 PF0.nnodes_2 (all_take_drop 2000 PF0.nnodes_3 (all_take_drop 2000 PF0.nnodes_4 (all_take_drop 2000 PF0.nnodes_5 (all_take_drop 2000 PF0.nnodes_6 (all_take_drop 2000 PF0.nnodes_7 (all_take_drop 2000 PF0.nnodes_8 (all_of_nil PF0.nnodes_end)))))))))
kernel_rfl PF0.nprims_end : (((((((((fullKeysF PF0.P0 PF0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF0.nprims : (fullKeysF PF0.P0 PF0.x0).map (fun i => (PF0.x1.nodes.get (PFW0.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PF0.P0 PF0.x0).map (fun i => (PF0.x0.nodes.get i).map fun nd => PFW0.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PF0.nprims_0 (map_take_drop 2000 PF0.nprims_1 (map_take_drop 2000 PF0.nprims_2 (map_take_drop 2000 PF0.nprims_3 (map_take_drop 2000 PF0.nprims_4 (map_take_drop 2000 PF0.nprims_5 (map_take_drop 2000 PF0.nprims_6 (map_take_drop 2000 PF0.nprims_7 (map_take_drop 2000 PF0.nprims_8 (map_of_nil PF0.nprims_end)))))))))

theorem PF0.nshift : NShift PF0.P0 PRE_pf_x0.n PFW0.R.data.map PF0.y0 PF0.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PF0.nnh0, PF0.nnh1, PF0.nnn0, PF0.nnn1, PF0.nlo, PF0.ncnt, PF0.nnband, PF0.nhbelow, PF0.nhandles, PF0.nhren, PF0.nband, PF0.nnh1pos, PF0.nobjs, PF0.nobjok, PF0.nnodes, PF0.nprims, PF0.nnren, PF0.nnlow, PF0.nnord, PF0.nitems, PF0.nssT, PF0.nabs0a, PF0.nabs0b, PF0.ntok1, PF0.npend, PF0.nerrh, PF0.nfiles, PF0.narch, PF0.nsizes, PF0.nwired⟩ PF0.nhost fun _ => rfl

end Host.Load.Run.Tpl
