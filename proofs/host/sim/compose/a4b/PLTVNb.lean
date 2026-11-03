import host.sim.compose.a4b.PLTVNc_0
import host.sim.compose.a4b.PLTVNc_1
import host.sim.compose.a4b.PLTVNc_2
import host.sim.compose.a4b.PLTVNc_3
import host.sim.compose.a4b.PLTVNc_4
import host.sim.compose.a4b.PLTVNc_5
import host.sim.compose.a4b.PLTVNc_6
import host.sim.compose.a4b.PLTVNc_7
import host.sim.compose.a4b.PLTVNc_8
import host.sim.compose.a4b.PLTVNc_9
import host.sim.compose.a4b.PLTVNc_10
import host.sim.compose.a4b.PLTVNc_11
import host.sim.compose.a4b.PLTVNc_12
import host.sim.compose.a4b.PLTVNc_13
import host.sim.compose.a4b.PLTVNc_14
import host.sim.compose.a4b.PLTVNc_15
import host.sim.compose.a4b.PLTVNc_16
import host.sim.compose.a4b.PLTVNc_17
import host.sim.compose.a4b.PLTVNc_18
import host.sim.compose.a4b.PLTVNc_19
import host.sim.compose.a4b.PLTVNc_20
import host.sim.compose.a4b.PLTVNc_21
import host.sim.compose.a4b.PLTVNc_22
import host.sim.compose.a4b.PLTVNc_23
import host.sim.compose.a4b.PLTVNc_24
import host.sim.compose.a4b.PLTVNc_25
import host.sim.compose.a4b.PLTVNc_26
import host.sim.compose.a4b.PLTVNc_27
import host.sim.compose.a4b.PLTVNc_28
import host.sim.compose.a4b.PLTVNc_29
import host.sim.compose.a4b.PLTVNc_30
import host.sim.compose.a4b.PLTVNc_31
import host.sim.compose.a4b.PLTVNc_32
import host.sim.compose.a4b.PLTVNc_33
import host.sim.compose.a4b.PLTVNc_34
import host.sim.compose.a4b.PLTVNc_35
import host.sim.compose.a4b.PLTVNc_36
import host.sim.compose.a4b.PLTVNc_37
import host.sim.compose.a4b.PLTVNc_38
import host.sim.compose.a4b.PLTVNc_39
import host.sim.compose.a4b.PLTVNc_40
import host.sim.compose.a4b.PLTVNc_41
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.nhandles_end : ((((((((((((((handlesOfA PLTV.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLTV.nhandles : (handlesOfA PLTV.x0).all (handleOK PLTVW.R.data.map PLTV.P0.lo PLTV.x0 PLTV.x1) = true :=
  all_take_drop 2000 PLTV.nhandles_0 (all_take_drop 2000 PLTV.nhandles_1 (all_take_drop 2000 PLTV.nhandles_2 (all_take_drop 2000 PLTV.nhandles_3 (all_take_drop 2000 PLTV.nhandles_4 (all_take_drop 2000 PLTV.nhandles_5 (all_take_drop 2000 PLTV.nhandles_6 (all_take_drop 2000 PLTV.nhandles_7 (all_take_drop 2000 PLTV.nhandles_8 (all_take_drop 2000 PLTV.nhandles_9 (all_take_drop 2000 PLTV.nhandles_10 (all_take_drop 2000 PLTV.nhandles_11 (all_take_drop 2000 PLTV.nhandles_12 (all_take_drop 2000 PLTV.nhandles_13 (all_of_nil PLTV.nhandles_end))))))))))))))
kernel_rfl PLTV.nnodes_end : (((((((((PTrie.keysA PLTV.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLTV.nnodes : (PTrie.keysA PLTV.x0.nodes).all (nodeOKF PLTVW.R.data.map PLTV.P0 PLTV.x0 PLTV.x1) = true :=
  all_take_drop 2000 PLTV.nnodes_0 (all_take_drop 2000 PLTV.nnodes_1 (all_take_drop 2000 PLTV.nnodes_2 (all_take_drop 2000 PLTV.nnodes_3 (all_take_drop 2000 PLTV.nnodes_4 (all_take_drop 2000 PLTV.nnodes_5 (all_take_drop 2000 PLTV.nnodes_6 (all_take_drop 2000 PLTV.nnodes_7 (all_take_drop 2000 PLTV.nnodes_8 (all_of_nil PLTV.nnodes_end)))))))))
kernel_rfl PLTV.nprims_end : (((((((((fullKeysF PLTV.P0 PLTV.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLTV.nprims : (fullKeysF PLTV.P0 PLTV.x0).map (fun i => (PLTV.x1.nodes.get (PLTVW.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PLTV.P0 PLTV.x0).map (fun i => (PLTV.x0.nodes.get i).map fun nd => PLTVW.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PLTV.nprims_0 (map_take_drop 2000 PLTV.nprims_1 (map_take_drop 2000 PLTV.nprims_2 (map_take_drop 2000 PLTV.nprims_3 (map_take_drop 2000 PLTV.nprims_4 (map_take_drop 2000 PLTV.nprims_5 (map_take_drop 2000 PLTV.nprims_6 (map_take_drop 2000 PLTV.nprims_7 (map_take_drop 2000 PLTV.nprims_8 (map_of_nil PLTV.nprims_end)))))))))
kernel_rfl PLTV.nedges_end : (((((((((PTrie.keysA PLTV.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLTV.nedges : (PTrie.keysA PLTV.x0.nodes).all (edgeOK PLTVW.R.data.map PLTV.x0) = true :=
  all_take_drop 2000 PLTV.nedges_0 (all_take_drop 2000 PLTV.nedges_1 (all_take_drop 2000 PLTV.nedges_2 (all_take_drop 2000 PLTV.nedges_3 (all_take_drop 2000 PLTV.nedges_4 (all_take_drop 2000 PLTV.nedges_5 (all_take_drop 2000 PLTV.nedges_6 (all_take_drop 2000 PLTV.nedges_7 (all_take_drop 2000 PLTV.nedges_8 (all_of_nil PLTV.nedges_end)))))))))

theorem PLTV.nshift : Conv.TraceNShift PLTV.P0 15235 PRE_pl_tail.n PLTVW.R.data.map PLTV.y0 PLTV.y1 :=
  traceNShift_of ⟨rfl, rfl, rfl, PLTV.nnh0, PLTV.nnh1, PLTV.nnn0, PLTV.nnn1, PLTV.nlo, PLTV.ncnt, PLTV.nnband, PLTV.nhbelow, PLTV.nhandles, PLTV.nhren, PLTV.nband, PLTV.nnh1pos, PLTV.nobjs, PLTV.nobjok, PLTV.nnodes, PLTV.nprims, PLTV.nnren, PLTV.nnlow, PLTV.nedges, PLTV.nitems, PLTV.nssT, PLTV.nabs0a, PLTV.nabs0b, PLTV.ntok1, PLTV.npend, PLTV.nerrh, PLTV.nfiles, PLTV.narch, PLTV.nsizes, PLTV.nwired⟩ PLTV.nhost fun _ => rfl

end Host.Load.Run.Tpl
