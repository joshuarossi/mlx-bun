import host.sim.compose.a4b.PF8Nc_0
import host.sim.compose.a4b.PF8Nc_1
import host.sim.compose.a4b.PF8Nc_2
import host.sim.compose.a4b.PF8Nc_3
import host.sim.compose.a4b.PF8Nc_4
import host.sim.compose.a4b.PF8Nc_5
import host.sim.compose.a4b.PF8Nc_6
import host.sim.compose.a4b.PF8Nc_7
import host.sim.compose.a4b.PF8Nc_8
import host.sim.compose.a4b.PF8Nc_9
import host.sim.compose.a4b.PF8Nc_10
import host.sim.compose.a4b.PF8Nc_11
import host.sim.compose.a4b.PF8Nc_12
import host.sim.compose.a4b.PF8Nc_13
import host.sim.compose.a4b.PF8Nc_14
import host.sim.compose.a4b.PF8Nc_15
import host.sim.compose.a4b.PF8Nc_16
import host.sim.compose.a4b.PF8Nc_17
import host.sim.compose.a4b.PF8Nc_18
import host.sim.compose.a4b.PF8Nc_19
import host.sim.compose.a4b.PF8Nc_20
import host.sim.compose.a4b.PF8Nc_21
import host.sim.compose.a4b.PF8Nc_22
import host.sim.compose.a4b.PF8Nc_23
import host.sim.compose.a4b.PF8Nc_24
import host.sim.compose.a4b.PF8Nc_25
import host.sim.compose.a4b.PF8Nc_26
import host.sim.compose.a4b.PF8Nc_27
import host.sim.compose.a4b.PF8Nc_28
import host.sim.compose.a4b.PF8Nc_29
import host.sim.compose.a4b.PF8Nc_30
import host.sim.compose.a4b.PF8Nc_31
import host.sim.compose.a4b.PF8Nc_32
import host.sim.compose.a4b.PF8Nc_33
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF8.nhandles_end : (((((((((((((handlesOfA PF8.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF8.nhandles : (handlesOfA PF8.x0).all (handleOK PFW8.R.data.map PF8.P0.lo PF8.x0 PF8.x1) = true :=
  all_take_drop 2000 PF8.nhandles_0 (all_take_drop 2000 PF8.nhandles_1 (all_take_drop 2000 PF8.nhandles_2 (all_take_drop 2000 PF8.nhandles_3 (all_take_drop 2000 PF8.nhandles_4 (all_take_drop 2000 PF8.nhandles_5 (all_take_drop 2000 PF8.nhandles_6 (all_take_drop 2000 PF8.nhandles_7 (all_take_drop 2000 PF8.nhandles_8 (all_take_drop 2000 PF8.nhandles_9 (all_take_drop 2000 PF8.nhandles_10 (all_take_drop 2000 PF8.nhandles_11 (all_take_drop 2000 PF8.nhandles_12 (all_of_nil PF8.nhandles_end)))))))))))))
kernel_rfl PF8.nnodes_end : ((((((((((PTrie.keysA PF8.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF8.nnodes : (PTrie.keysA PF8.x0.nodes).all (nodeOKF PFW8.R.data.map PF8.P0 PF8.x0 PF8.x1) = true :=
  all_take_drop 2000 PF8.nnodes_0 (all_take_drop 2000 PF8.nnodes_1 (all_take_drop 2000 PF8.nnodes_2 (all_take_drop 2000 PF8.nnodes_3 (all_take_drop 2000 PF8.nnodes_4 (all_take_drop 2000 PF8.nnodes_5 (all_take_drop 2000 PF8.nnodes_6 (all_take_drop 2000 PF8.nnodes_7 (all_take_drop 2000 PF8.nnodes_8 (all_take_drop 2000 PF8.nnodes_9 (all_of_nil PF8.nnodes_end))))))))))
kernel_rfl PF8.nprims_end : ((((((((((fullKeysF PF8.P0 PF8.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF8.nprims : (fullKeysF PF8.P0 PF8.x0).map (fun i => (PF8.x1.nodes.get (PFW8.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PF8.P0 PF8.x0).map (fun i => (PF8.x0.nodes.get i).map fun nd => PFW8.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PF8.nprims_0 (map_take_drop 2000 PF8.nprims_1 (map_take_drop 2000 PF8.nprims_2 (map_take_drop 2000 PF8.nprims_3 (map_take_drop 2000 PF8.nprims_4 (map_take_drop 2000 PF8.nprims_5 (map_take_drop 2000 PF8.nprims_6 (map_take_drop 2000 PF8.nprims_7 (map_take_drop 2000 PF8.nprims_8 (map_take_drop 2000 PF8.nprims_9 (map_of_nil PF8.nprims_end))))))))))

theorem PF8.nshift : NShift PF8.P0 PRE_pf_vw.n PFW8.R.data.map PF8.y0 PF8.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PF8.nnh0, PF8.nnh1, PF8.nnn0, PF8.nnn1, PF8.nlo, PF8.ncnt, PF8.nnband, PF8.nhbelow, PF8.nhandles, PF8.nhren, PF8.nband, PF8.nnh1pos, PF8.nobjs, PF8.nobjok, PF8.nnodes, PF8.nprims, PF8.nnren, PF8.nnlow, PF8.nnord, PF8.nitems, PF8.nssT, PF8.nabs0a, PF8.nabs0b, PF8.ntok1, PF8.npend, PF8.nerrh, PF8.nfiles, PF8.narch, PF8.nsizes, PF8.nwired⟩ PF8.nhost fun _ => rfl

end Host.Load.Run.Tpl
