import host.sim.compose.a4b.PF2Nc_0
import host.sim.compose.a4b.PF2Nc_1
import host.sim.compose.a4b.PF2Nc_2
import host.sim.compose.a4b.PF2Nc_3
import host.sim.compose.a4b.PF2Nc_4
import host.sim.compose.a4b.PF2Nc_5
import host.sim.compose.a4b.PF2Nc_6
import host.sim.compose.a4b.PF2Nc_7
import host.sim.compose.a4b.PF2Nc_8
import host.sim.compose.a4b.PF2Nc_9
import host.sim.compose.a4b.PF2Nc_10
import host.sim.compose.a4b.PF2Nc_11
import host.sim.compose.a4b.PF2Nc_12
import host.sim.compose.a4b.PF2Nc_13
import host.sim.compose.a4b.PF2Nc_14
import host.sim.compose.a4b.PF2Nc_15
import host.sim.compose.a4b.PF2Nc_16
import host.sim.compose.a4b.PF2Nc_17
import host.sim.compose.a4b.PF2Nc_18
import host.sim.compose.a4b.PF2Nc_19
import host.sim.compose.a4b.PF2Nc_20
import host.sim.compose.a4b.PF2Nc_21
import host.sim.compose.a4b.PF2Nc_22
import host.sim.compose.a4b.PF2Nc_23
import host.sim.compose.a4b.PF2Nc_24
import host.sim.compose.a4b.PF2Nc_25
import host.sim.compose.a4b.PF2Nc_26
import host.sim.compose.a4b.PF2Nc_27
import host.sim.compose.a4b.PF2Nc_28
import host.sim.compose.a4b.PF2Nc_29
import host.sim.compose.a4b.PF2Nc_30
import host.sim.compose.a4b.PF2Nc_31
import host.sim.compose.a4b.PF2Nc_32
import host.sim.compose.a4b.PF2Nc_33
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF2.nhandles_end : (((((((((((((handlesOfA PF2.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF2.nhandles : (handlesOfA PF2.x0).all (handleOK PFW2.R.data.map PF2.P0.lo PF2.x0 PF2.x1) = true :=
  all_take_drop 2000 PF2.nhandles_0 (all_take_drop 2000 PF2.nhandles_1 (all_take_drop 2000 PF2.nhandles_2 (all_take_drop 2000 PF2.nhandles_3 (all_take_drop 2000 PF2.nhandles_4 (all_take_drop 2000 PF2.nhandles_5 (all_take_drop 2000 PF2.nhandles_6 (all_take_drop 2000 PF2.nhandles_7 (all_take_drop 2000 PF2.nhandles_8 (all_take_drop 2000 PF2.nhandles_9 (all_take_drop 2000 PF2.nhandles_10 (all_take_drop 2000 PF2.nhandles_11 (all_take_drop 2000 PF2.nhandles_12 (all_of_nil PF2.nhandles_end)))))))))))))
kernel_rfl PF2.nnodes_end : ((((((((((PTrie.keysA PF2.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF2.nnodes : (PTrie.keysA PF2.x0.nodes).all (nodeOKF PFW2.R.data.map PF2.P0 PF2.x0 PF2.x1) = true :=
  all_take_drop 2000 PF2.nnodes_0 (all_take_drop 2000 PF2.nnodes_1 (all_take_drop 2000 PF2.nnodes_2 (all_take_drop 2000 PF2.nnodes_3 (all_take_drop 2000 PF2.nnodes_4 (all_take_drop 2000 PF2.nnodes_5 (all_take_drop 2000 PF2.nnodes_6 (all_take_drop 2000 PF2.nnodes_7 (all_take_drop 2000 PF2.nnodes_8 (all_take_drop 2000 PF2.nnodes_9 (all_of_nil PF2.nnodes_end))))))))))
kernel_rfl PF2.nprims_end : ((((((((((fullKeysF PF2.P0 PF2.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF2.nprims : (fullKeysF PF2.P0 PF2.x0).map (fun i => (PF2.x1.nodes.get (PFW2.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PF2.P0 PF2.x0).map (fun i => (PF2.x0.nodes.get i).map fun nd => PFW2.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PF2.nprims_0 (map_take_drop 2000 PF2.nprims_1 (map_take_drop 2000 PF2.nprims_2 (map_take_drop 2000 PF2.nprims_3 (map_take_drop 2000 PF2.nprims_4 (map_take_drop 2000 PF2.nprims_5 (map_take_drop 2000 PF2.nprims_6 (map_take_drop 2000 PF2.nprims_7 (map_take_drop 2000 PF2.nprims_8 (map_take_drop 2000 PF2.nprims_9 (map_of_nil PF2.nprims_end))))))))))

theorem PF2.nshift : NShift PF2.P0 PRE_pf_vw.n PFW2.R.data.map PF2.y0 PF2.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PF2.nnh0, PF2.nnh1, PF2.nnn0, PF2.nnn1, PF2.nlo, PF2.ncnt, PF2.nnband, PF2.nhbelow, PF2.nhandles, PF2.nhren, PF2.nband, PF2.nnh1pos, PF2.nobjs, PF2.nobjok, PF2.nnodes, PF2.nprims, PF2.nnren, PF2.nnlow, PF2.nnord, PF2.nitems, PF2.nssT, PF2.nabs0a, PF2.nabs0b, PF2.ntok1, PF2.npend, PF2.nerrh, PF2.nfiles, PF2.narch, PF2.nsizes, PF2.nwired⟩ PF2.nhost fun _ => rfl

end Host.Load.Run.Tpl
