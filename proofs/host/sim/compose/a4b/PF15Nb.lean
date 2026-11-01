import host.sim.compose.a4b.PF15Nc_0
import host.sim.compose.a4b.PF15Nc_1
import host.sim.compose.a4b.PF15Nc_2
import host.sim.compose.a4b.PF15Nc_3
import host.sim.compose.a4b.PF15Nc_4
import host.sim.compose.a4b.PF15Nc_5
import host.sim.compose.a4b.PF15Nc_6
import host.sim.compose.a4b.PF15Nc_7
import host.sim.compose.a4b.PF15Nc_8
import host.sim.compose.a4b.PF15Nc_9
import host.sim.compose.a4b.PF15Nc_10
import host.sim.compose.a4b.PF15Nc_11
import host.sim.compose.a4b.PF15Nc_12
import host.sim.compose.a4b.PF15Nc_13
import host.sim.compose.a4b.PF15Nc_14
import host.sim.compose.a4b.PF15Nc_15
import host.sim.compose.a4b.PF15Nc_16
import host.sim.compose.a4b.PF15Nc_17
import host.sim.compose.a4b.PF15Nc_18
import host.sim.compose.a4b.PF15Nc_19
import host.sim.compose.a4b.PF15Nc_20
import host.sim.compose.a4b.PF15Nc_21
import host.sim.compose.a4b.PF15Nc_22
import host.sim.compose.a4b.PF15Nc_23
import host.sim.compose.a4b.PF15Nc_24
import host.sim.compose.a4b.PF15Nc_25
import host.sim.compose.a4b.PF15Nc_26
import host.sim.compose.a4b.PF15Nc_27
import host.sim.compose.a4b.PF15Nc_28
import host.sim.compose.a4b.PF15Nc_29
import host.sim.compose.a4b.PF15Nc_30
import host.sim.compose.a4b.PF15Nc_31
import host.sim.compose.a4b.PF15Nc_32
import host.sim.compose.a4b.PF15Nc_33
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF15.nhandles_end : (((((((((((((handlesOfA PF15.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF15.nhandles : (handlesOfA PF15.x0).all (handleOK PFW15.R.data.map PF15.P0.lo PF15.x0 PF15.x1) = true :=
  all_take_drop 2000 PF15.nhandles_0 (all_take_drop 2000 PF15.nhandles_1 (all_take_drop 2000 PF15.nhandles_2 (all_take_drop 2000 PF15.nhandles_3 (all_take_drop 2000 PF15.nhandles_4 (all_take_drop 2000 PF15.nhandles_5 (all_take_drop 2000 PF15.nhandles_6 (all_take_drop 2000 PF15.nhandles_7 (all_take_drop 2000 PF15.nhandles_8 (all_take_drop 2000 PF15.nhandles_9 (all_take_drop 2000 PF15.nhandles_10 (all_take_drop 2000 PF15.nhandles_11 (all_take_drop 2000 PF15.nhandles_12 (all_of_nil PF15.nhandles_end)))))))))))))
kernel_rfl PF15.nnodes_end : ((((((((((PTrie.keysA PF15.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF15.nnodes : (PTrie.keysA PF15.x0.nodes).all (nodeOKF PFW15.R.data.map PF15.P0 PF15.x0 PF15.x1) = true :=
  all_take_drop 2000 PF15.nnodes_0 (all_take_drop 2000 PF15.nnodes_1 (all_take_drop 2000 PF15.nnodes_2 (all_take_drop 2000 PF15.nnodes_3 (all_take_drop 2000 PF15.nnodes_4 (all_take_drop 2000 PF15.nnodes_5 (all_take_drop 2000 PF15.nnodes_6 (all_take_drop 2000 PF15.nnodes_7 (all_take_drop 2000 PF15.nnodes_8 (all_take_drop 2000 PF15.nnodes_9 (all_of_nil PF15.nnodes_end))))))))))
kernel_rfl PF15.nprims_end : ((((((((((fullKeysF PF15.P0 PF15.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF15.nprims : (fullKeysF PF15.P0 PF15.x0).map (fun i => (PF15.x1.nodes.get (PFW15.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PF15.P0 PF15.x0).map (fun i => (PF15.x0.nodes.get i).map fun nd => PFW15.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PF15.nprims_0 (map_take_drop 2000 PF15.nprims_1 (map_take_drop 2000 PF15.nprims_2 (map_take_drop 2000 PF15.nprims_3 (map_take_drop 2000 PF15.nprims_4 (map_take_drop 2000 PF15.nprims_5 (map_take_drop 2000 PF15.nprims_6 (map_take_drop 2000 PF15.nprims_7 (map_take_drop 2000 PF15.nprims_8 (map_take_drop 2000 PF15.nprims_9 (map_of_nil PF15.nprims_end))))))))))

theorem PF15.nshift : NShift PF15.P0 PRE_pf_vw.n PFW15.R.data.map PF15.y0 PF15.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PF15.nnh0, PF15.nnh1, PF15.nnn0, PF15.nnn1, PF15.nlo, PF15.ncnt, PF15.nnband, PF15.nhbelow, PF15.nhandles, PF15.nhren, PF15.nband, PF15.nnh1pos, PF15.nobjs, PF15.nobjok, PF15.nnodes, PF15.nprims, PF15.nnren, PF15.nnlow, PF15.nnord, PF15.nitems, PF15.nssT, PF15.nabs0a, PF15.nabs0b, PF15.ntok1, PF15.npend, PF15.nerrh, PF15.nfiles, PF15.narch, PF15.nsizes, PF15.nwired⟩ PF15.nhost fun _ => rfl

end Host.Load.Run.Tpl
