import host.sim.compose.a4b.PF6Nc_0
import host.sim.compose.a4b.PF6Nc_1
import host.sim.compose.a4b.PF6Nc_2
import host.sim.compose.a4b.PF6Nc_3
import host.sim.compose.a4b.PF6Nc_4
import host.sim.compose.a4b.PF6Nc_5
import host.sim.compose.a4b.PF6Nc_6
import host.sim.compose.a4b.PF6Nc_7
import host.sim.compose.a4b.PF6Nc_8
import host.sim.compose.a4b.PF6Nc_9
import host.sim.compose.a4b.PF6Nc_10
import host.sim.compose.a4b.PF6Nc_11
import host.sim.compose.a4b.PF6Nc_12
import host.sim.compose.a4b.PF6Nc_13
import host.sim.compose.a4b.PF6Nc_14
import host.sim.compose.a4b.PF6Nc_15
import host.sim.compose.a4b.PF6Nc_16
import host.sim.compose.a4b.PF6Nc_17
import host.sim.compose.a4b.PF6Nc_18
import host.sim.compose.a4b.PF6Nc_19
import host.sim.compose.a4b.PF6Nc_20
import host.sim.compose.a4b.PF6Nc_21
import host.sim.compose.a4b.PF6Nc_22
import host.sim.compose.a4b.PF6Nc_23
import host.sim.compose.a4b.PF6Nc_24
import host.sim.compose.a4b.PF6Nc_25
import host.sim.compose.a4b.PF6Nc_26
import host.sim.compose.a4b.PF6Nc_27
import host.sim.compose.a4b.PF6Nc_28
import host.sim.compose.a4b.PF6Nc_29
import host.sim.compose.a4b.PF6Nc_30
import host.sim.compose.a4b.PF6Nc_31
import host.sim.compose.a4b.PF6Nc_32
import host.sim.compose.a4b.PF6Nc_33
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF6.nhandles_end : (((((((((((((handlesOfA PF6.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF6.nhandles : (handlesOfA PF6.x0).all (handleOK PFW6.R.data.map PF6.P0.lo PF6.x0 PF6.x1) = true :=
  all_take_drop 2000 PF6.nhandles_0 (all_take_drop 2000 PF6.nhandles_1 (all_take_drop 2000 PF6.nhandles_2 (all_take_drop 2000 PF6.nhandles_3 (all_take_drop 2000 PF6.nhandles_4 (all_take_drop 2000 PF6.nhandles_5 (all_take_drop 2000 PF6.nhandles_6 (all_take_drop 2000 PF6.nhandles_7 (all_take_drop 2000 PF6.nhandles_8 (all_take_drop 2000 PF6.nhandles_9 (all_take_drop 2000 PF6.nhandles_10 (all_take_drop 2000 PF6.nhandles_11 (all_take_drop 2000 PF6.nhandles_12 (all_of_nil PF6.nhandles_end)))))))))))))
kernel_rfl PF6.nnodes_end : ((((((((((PTrie.keysA PF6.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF6.nnodes : (PTrie.keysA PF6.x0.nodes).all (nodeOKF PFW6.R.data.map PF6.P0 PF6.x0 PF6.x1) = true :=
  all_take_drop 2000 PF6.nnodes_0 (all_take_drop 2000 PF6.nnodes_1 (all_take_drop 2000 PF6.nnodes_2 (all_take_drop 2000 PF6.nnodes_3 (all_take_drop 2000 PF6.nnodes_4 (all_take_drop 2000 PF6.nnodes_5 (all_take_drop 2000 PF6.nnodes_6 (all_take_drop 2000 PF6.nnodes_7 (all_take_drop 2000 PF6.nnodes_8 (all_take_drop 2000 PF6.nnodes_9 (all_of_nil PF6.nnodes_end))))))))))
kernel_rfl PF6.nprims_end : ((((((((((fullKeysF PF6.P0 PF6.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF6.nprims : (fullKeysF PF6.P0 PF6.x0).map (fun i => (PF6.x1.nodes.get (PFW6.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PF6.P0 PF6.x0).map (fun i => (PF6.x0.nodes.get i).map fun nd => PFW6.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PF6.nprims_0 (map_take_drop 2000 PF6.nprims_1 (map_take_drop 2000 PF6.nprims_2 (map_take_drop 2000 PF6.nprims_3 (map_take_drop 2000 PF6.nprims_4 (map_take_drop 2000 PF6.nprims_5 (map_take_drop 2000 PF6.nprims_6 (map_take_drop 2000 PF6.nprims_7 (map_take_drop 2000 PF6.nprims_8 (map_take_drop 2000 PF6.nprims_9 (map_of_nil PF6.nprims_end))))))))))

theorem PF6.nshift : NShift PF6.P0 PRE_pf_vw.n PFW6.R.data.map PF6.y0 PF6.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PF6.nnh0, PF6.nnh1, PF6.nnn0, PF6.nnn1, PF6.nlo, PF6.ncnt, PF6.nnband, PF6.nhbelow, PF6.nhandles, PF6.nhren, PF6.nband, PF6.nnh1pos, PF6.nobjs, PF6.nobjok, PF6.nnodes, PF6.nprims, PF6.nnren, PF6.nnlow, PF6.nnord, PF6.nitems, PF6.nssT, PF6.nabs0a, PF6.nabs0b, PF6.ntok1, PF6.npend, PF6.nerrh, PF6.nfiles, PF6.narch, PF6.nsizes, PF6.nwired⟩ PF6.nhost fun _ => rfl

end Host.Load.Run.Tpl
