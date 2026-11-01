import host.sim.compose.a4b.PLD1Nc_0
import host.sim.compose.a4b.PLD1Nc_1
import host.sim.compose.a4b.PLD1Nc_2
import host.sim.compose.a4b.PLD1Nc_3
import host.sim.compose.a4b.PLD1Nc_4
import host.sim.compose.a4b.PLD1Nc_5
import host.sim.compose.a4b.PLD1Nc_6
import host.sim.compose.a4b.PLD1Nc_7
import host.sim.compose.a4b.PLD1Nc_8
import host.sim.compose.a4b.PLD1Nc_9
import host.sim.compose.a4b.PLD1Nc_10
import host.sim.compose.a4b.PLD1Nc_11
import host.sim.compose.a4b.PLD1Nc_12
import host.sim.compose.a4b.PLD1Nc_13
import host.sim.compose.a4b.PLD1Nc_14
import host.sim.compose.a4b.PLD1Nc_15
import host.sim.compose.a4b.PLD1Nc_16
import host.sim.compose.a4b.PLD1Nc_17
import host.sim.compose.a4b.PLD1Nc_18
import host.sim.compose.a4b.PLD1Nc_19
import host.sim.compose.a4b.PLD1Nc_20
import host.sim.compose.a4b.PLD1Nc_21
import host.sim.compose.a4b.PLD1Nc_22
import host.sim.compose.a4b.PLD1Nc_23
import host.sim.compose.a4b.PLD1Nc_24
import host.sim.compose.a4b.PLD1Nc_25
import host.sim.compose.a4b.PLD1Nc_26
import host.sim.compose.a4b.PLD1Nc_27
import host.sim.compose.a4b.PLD1Nc_28
import host.sim.compose.a4b.PLD1Nc_29
import host.sim.compose.a4b.PLD1Nc_30
import host.sim.compose.a4b.PLD1Nc_31
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.nhandles_end : (((((((((((((handlesOfA PLD1.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLD1.nhandles : (handlesOfA PLD1.x0).all (handleOK PLWalkD1.R.data.map PLD1.P0.lo PLD1.x0 PLD1.x1) = true :=
  all_take_drop 2000 PLD1.nhandles_0 (all_take_drop 2000 PLD1.nhandles_1 (all_take_drop 2000 PLD1.nhandles_2 (all_take_drop 2000 PLD1.nhandles_3 (all_take_drop 2000 PLD1.nhandles_4 (all_take_drop 2000 PLD1.nhandles_5 (all_take_drop 2000 PLD1.nhandles_6 (all_take_drop 2000 PLD1.nhandles_7 (all_take_drop 2000 PLD1.nhandles_8 (all_take_drop 2000 PLD1.nhandles_9 (all_take_drop 2000 PLD1.nhandles_10 (all_take_drop 2000 PLD1.nhandles_11 (all_take_drop 2000 PLD1.nhandles_12 (all_of_nil PLD1.nhandles_end)))))))))))))
kernel_rfl PLD1.nnodes_end : (((((((((PTrie.keysA PLD1.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLD1.nnodes : (PTrie.keysA PLD1.x0.nodes).all (nodeOKF PLWalkD1.R.data.map PLD1.P0 PLD1.x0 PLD1.x1) = true :=
  all_take_drop 2000 PLD1.nnodes_0 (all_take_drop 2000 PLD1.nnodes_1 (all_take_drop 2000 PLD1.nnodes_2 (all_take_drop 2000 PLD1.nnodes_3 (all_take_drop 2000 PLD1.nnodes_4 (all_take_drop 2000 PLD1.nnodes_5 (all_take_drop 2000 PLD1.nnodes_6 (all_take_drop 2000 PLD1.nnodes_7 (all_take_drop 2000 PLD1.nnodes_8 (all_of_nil PLD1.nnodes_end)))))))))
kernel_rfl PLD1.nprims_end : (((((((((fullKeysF PLD1.P0 PLD1.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLD1.nprims : (fullKeysF PLD1.P0 PLD1.x0).map (fun i => (PLD1.x1.nodes.get (PLWalkD1.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PLD1.P0 PLD1.x0).map (fun i => (PLD1.x0.nodes.get i).map fun nd => PLWalkD1.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PLD1.nprims_0 (map_take_drop 2000 PLD1.nprims_1 (map_take_drop 2000 PLD1.nprims_2 (map_take_drop 2000 PLD1.nprims_3 (map_take_drop 2000 PLD1.nprims_4 (map_take_drop 2000 PLD1.nprims_5 (map_take_drop 2000 PLD1.nprims_6 (map_take_drop 2000 PLD1.nprims_7 (map_take_drop 2000 PLD1.nprims_8 (map_of_nil PLD1.nprims_end)))))))))

theorem PLD1.nshift : NShift PLD1.P0 PRE_pl_entry.n PLWalkD1.R.data.map PLD1.y0 PLD1.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PLD1.nnh0, PLD1.nnh1, PLD1.nnn0, PLD1.nnn1, PLD1.nlo, PLD1.ncnt, PLD1.nnband, PLD1.nhbelow, PLD1.nhandles, PLD1.nhren, PLD1.nband, PLD1.nnh1pos, PLD1.nobjs, PLD1.nobjok, PLD1.nnodes, PLD1.nprims, PLD1.nnren, PLD1.nnlow, PLD1.nnord, PLD1.nitems, PLD1.nssT, PLD1.nabs0a, PLD1.nabs0b, PLD1.ntok1, PLD1.npend, PLD1.nerrh, PLD1.nfiles, PLD1.narch, PLD1.nsizes, PLD1.nwired⟩ PLD1.nhost fun _ => rfl

end Host.Load.Run.Tpl
