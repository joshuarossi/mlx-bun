import host.sim.compose.a4b.PF3Nc_0
import host.sim.compose.a4b.PF3Nc_1
import host.sim.compose.a4b.PF3Nc_2
import host.sim.compose.a4b.PF3Nc_3
import host.sim.compose.a4b.PF3Nc_4
import host.sim.compose.a4b.PF3Nc_5
import host.sim.compose.a4b.PF3Nc_6
import host.sim.compose.a4b.PF3Nc_7
import host.sim.compose.a4b.PF3Nc_8
import host.sim.compose.a4b.PF3Nc_9
import host.sim.compose.a4b.PF3Nc_10
import host.sim.compose.a4b.PF3Nc_11
import host.sim.compose.a4b.PF3Nc_12
import host.sim.compose.a4b.PF3Nc_13
import host.sim.compose.a4b.PF3Nc_14
import host.sim.compose.a4b.PF3Nc_15
import host.sim.compose.a4b.PF3Nc_16
import host.sim.compose.a4b.PF3Nc_17
import host.sim.compose.a4b.PF3Nc_18
import host.sim.compose.a4b.PF3Nc_19
import host.sim.compose.a4b.PF3Nc_20
import host.sim.compose.a4b.PF3Nc_21
import host.sim.compose.a4b.PF3Nc_22
import host.sim.compose.a4b.PF3Nc_23
import host.sim.compose.a4b.PF3Nc_24
import host.sim.compose.a4b.PF3Nc_25
import host.sim.compose.a4b.PF3Nc_26
import host.sim.compose.a4b.PF3Nc_27
import host.sim.compose.a4b.PF3Nc_28
import host.sim.compose.a4b.PF3Nc_29
import host.sim.compose.a4b.PF3Nc_30
import host.sim.compose.a4b.PF3Nc_31
import host.sim.compose.a4b.PF3Nc_32
import host.sim.compose.a4b.PF3Nc_33
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF3.nhandles_end : (((((((((((((handlesOfA PF3.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF3.nhandles : (handlesOfA PF3.x0).all (handleOK PFW3.R.data.map PF3.P0.lo PF3.x0 PF3.x1) = true :=
  all_take_drop 2000 PF3.nhandles_0 (all_take_drop 2000 PF3.nhandles_1 (all_take_drop 2000 PF3.nhandles_2 (all_take_drop 2000 PF3.nhandles_3 (all_take_drop 2000 PF3.nhandles_4 (all_take_drop 2000 PF3.nhandles_5 (all_take_drop 2000 PF3.nhandles_6 (all_take_drop 2000 PF3.nhandles_7 (all_take_drop 2000 PF3.nhandles_8 (all_take_drop 2000 PF3.nhandles_9 (all_take_drop 2000 PF3.nhandles_10 (all_take_drop 2000 PF3.nhandles_11 (all_take_drop 2000 PF3.nhandles_12 (all_of_nil PF3.nhandles_end)))))))))))))
kernel_rfl PF3.nnodes_end : ((((((((((PTrie.keysA PF3.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF3.nnodes : (PTrie.keysA PF3.x0.nodes).all (nodeOKF PFW3.R.data.map PF3.P0 PF3.x0 PF3.x1) = true :=
  all_take_drop 2000 PF3.nnodes_0 (all_take_drop 2000 PF3.nnodes_1 (all_take_drop 2000 PF3.nnodes_2 (all_take_drop 2000 PF3.nnodes_3 (all_take_drop 2000 PF3.nnodes_4 (all_take_drop 2000 PF3.nnodes_5 (all_take_drop 2000 PF3.nnodes_6 (all_take_drop 2000 PF3.nnodes_7 (all_take_drop 2000 PF3.nnodes_8 (all_take_drop 2000 PF3.nnodes_9 (all_of_nil PF3.nnodes_end))))))))))
kernel_rfl PF3.nprims_end : ((((((((((fullKeysF PF3.P0 PF3.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF3.nprims : (fullKeysF PF3.P0 PF3.x0).map (fun i => (PF3.x1.nodes.get (PFW3.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PF3.P0 PF3.x0).map (fun i => (PF3.x0.nodes.get i).map fun nd => PFW3.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PF3.nprims_0 (map_take_drop 2000 PF3.nprims_1 (map_take_drop 2000 PF3.nprims_2 (map_take_drop 2000 PF3.nprims_3 (map_take_drop 2000 PF3.nprims_4 (map_take_drop 2000 PF3.nprims_5 (map_take_drop 2000 PF3.nprims_6 (map_take_drop 2000 PF3.nprims_7 (map_take_drop 2000 PF3.nprims_8 (map_take_drop 2000 PF3.nprims_9 (map_of_nil PF3.nprims_end))))))))))

theorem PF3.nshift : NShift PF3.P0 PRE_pf_vw.n PFW3.R.data.map PF3.y0 PF3.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PF3.nnh0, PF3.nnh1, PF3.nnn0, PF3.nnn1, PF3.nlo, PF3.ncnt, PF3.nnband, PF3.nhbelow, PF3.nhandles, PF3.nhren, PF3.nband, PF3.nnh1pos, PF3.nobjs, PF3.nobjok, PF3.nnodes, PF3.nprims, PF3.nnren, PF3.nnlow, PF3.nnord, PF3.nitems, PF3.nssT, PF3.nabs0a, PF3.nabs0b, PF3.ntok1, PF3.npend, PF3.nerrh, PF3.nfiles, PF3.narch, PF3.nsizes, PF3.nwired⟩ PF3.nhost fun _ => rfl

end Host.Load.Run.Tpl
