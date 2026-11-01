import host.sim.compose.a4b.PF1Nc_0
import host.sim.compose.a4b.PF1Nc_1
import host.sim.compose.a4b.PF1Nc_2
import host.sim.compose.a4b.PF1Nc_3
import host.sim.compose.a4b.PF1Nc_4
import host.sim.compose.a4b.PF1Nc_5
import host.sim.compose.a4b.PF1Nc_6
import host.sim.compose.a4b.PF1Nc_7
import host.sim.compose.a4b.PF1Nc_8
import host.sim.compose.a4b.PF1Nc_9
import host.sim.compose.a4b.PF1Nc_10
import host.sim.compose.a4b.PF1Nc_11
import host.sim.compose.a4b.PF1Nc_12
import host.sim.compose.a4b.PF1Nc_13
import host.sim.compose.a4b.PF1Nc_14
import host.sim.compose.a4b.PF1Nc_15
import host.sim.compose.a4b.PF1Nc_16
import host.sim.compose.a4b.PF1Nc_17
import host.sim.compose.a4b.PF1Nc_18
import host.sim.compose.a4b.PF1Nc_19
import host.sim.compose.a4b.PF1Nc_20
import host.sim.compose.a4b.PF1Nc_21
import host.sim.compose.a4b.PF1Nc_22
import host.sim.compose.a4b.PF1Nc_23
import host.sim.compose.a4b.PF1Nc_24
import host.sim.compose.a4b.PF1Nc_25
import host.sim.compose.a4b.PF1Nc_26
import host.sim.compose.a4b.PF1Nc_27
import host.sim.compose.a4b.PF1Nc_28
import host.sim.compose.a4b.PF1Nc_29
import host.sim.compose.a4b.PF1Nc_30
import host.sim.compose.a4b.PF1Nc_31
import host.sim.compose.a4b.PF1Nc_32
import host.sim.compose.a4b.PF1Nc_33
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF1.nhandles_end : (((((((((((((handlesOfA PF1.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF1.nhandles : (handlesOfA PF1.x0).all (handleOK PFW1.R.data.map PF1.P0.lo PF1.x0 PF1.x1) = true :=
  all_take_drop 2000 PF1.nhandles_0 (all_take_drop 2000 PF1.nhandles_1 (all_take_drop 2000 PF1.nhandles_2 (all_take_drop 2000 PF1.nhandles_3 (all_take_drop 2000 PF1.nhandles_4 (all_take_drop 2000 PF1.nhandles_5 (all_take_drop 2000 PF1.nhandles_6 (all_take_drop 2000 PF1.nhandles_7 (all_take_drop 2000 PF1.nhandles_8 (all_take_drop 2000 PF1.nhandles_9 (all_take_drop 2000 PF1.nhandles_10 (all_take_drop 2000 PF1.nhandles_11 (all_take_drop 2000 PF1.nhandles_12 (all_of_nil PF1.nhandles_end)))))))))))))
kernel_rfl PF1.nnodes_end : ((((((((((PTrie.keysA PF1.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF1.nnodes : (PTrie.keysA PF1.x0.nodes).all (nodeOKF PFW1.R.data.map PF1.P0 PF1.x0 PF1.x1) = true :=
  all_take_drop 2000 PF1.nnodes_0 (all_take_drop 2000 PF1.nnodes_1 (all_take_drop 2000 PF1.nnodes_2 (all_take_drop 2000 PF1.nnodes_3 (all_take_drop 2000 PF1.nnodes_4 (all_take_drop 2000 PF1.nnodes_5 (all_take_drop 2000 PF1.nnodes_6 (all_take_drop 2000 PF1.nnodes_7 (all_take_drop 2000 PF1.nnodes_8 (all_take_drop 2000 PF1.nnodes_9 (all_of_nil PF1.nnodes_end))))))))))
kernel_rfl PF1.nprims_end : ((((((((((fullKeysF PF1.P0 PF1.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PF1.nprims : (fullKeysF PF1.P0 PF1.x0).map (fun i => (PF1.x1.nodes.get (PFW1.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PF1.P0 PF1.x0).map (fun i => (PF1.x0.nodes.get i).map fun nd => PFW1.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PF1.nprims_0 (map_take_drop 2000 PF1.nprims_1 (map_take_drop 2000 PF1.nprims_2 (map_take_drop 2000 PF1.nprims_3 (map_take_drop 2000 PF1.nprims_4 (map_take_drop 2000 PF1.nprims_5 (map_take_drop 2000 PF1.nprims_6 (map_take_drop 2000 PF1.nprims_7 (map_take_drop 2000 PF1.nprims_8 (map_take_drop 2000 PF1.nprims_9 (map_of_nil PF1.nprims_end))))))))))

theorem PF1.nshift : NShift PF1.P0 PRE_pf_vw.n PFW1.R.data.map PF1.y0 PF1.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PF1.nnh0, PF1.nnh1, PF1.nnn0, PF1.nnn1, PF1.nlo, PF1.ncnt, PF1.nnband, PF1.nhbelow, PF1.nhandles, PF1.nhren, PF1.nband, PF1.nnh1pos, PF1.nobjs, PF1.nobjok, PF1.nnodes, PF1.nprims, PF1.nnren, PF1.nnlow, PF1.nnord, PF1.nitems, PF1.nssT, PF1.nabs0a, PF1.nabs0b, PF1.ntok1, PF1.npend, PF1.nerrh, PF1.nfiles, PF1.narch, PF1.nsizes, PF1.nwired⟩ PF1.nhost fun _ => rfl

end Host.Load.Run.Tpl
