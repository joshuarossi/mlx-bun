import host.sim.compose.a4b.PLT0Nc_0
import host.sim.compose.a4b.PLT0Nc_1
import host.sim.compose.a4b.PLT0Nc_2
import host.sim.compose.a4b.PLT0Nc_3
import host.sim.compose.a4b.PLT0Nc_4
import host.sim.compose.a4b.PLT0Nc_5
import host.sim.compose.a4b.PLT0Nc_6
import host.sim.compose.a4b.PLT0Nc_7
import host.sim.compose.a4b.PLT0Nc_8
import host.sim.compose.a4b.PLT0Nc_9
import host.sim.compose.a4b.PLT0Nc_10
import host.sim.compose.a4b.PLT0Nc_11
import host.sim.compose.a4b.PLT0Nc_12
import host.sim.compose.a4b.PLT0Nc_13
import host.sim.compose.a4b.PLT0Nc_14
import host.sim.compose.a4b.PLT0Nc_15
import host.sim.compose.a4b.PLT0Nc_16
import host.sim.compose.a4b.PLT0Nc_17
import host.sim.compose.a4b.PLT0Nc_18
import host.sim.compose.a4b.PLT0Nc_19
import host.sim.compose.a4b.PLT0Nc_20
import host.sim.compose.a4b.PLT0Nc_21
import host.sim.compose.a4b.PLT0Nc_22
import host.sim.compose.a4b.PLT0Nc_23
import host.sim.compose.a4b.PLT0Nc_24
import host.sim.compose.a4b.PLT0Nc_25
import host.sim.compose.a4b.PLT0Nc_26
import host.sim.compose.a4b.PLT0Nc_27
import host.sim.compose.a4b.PLT0Nc_28
import host.sim.compose.a4b.PLT0Nc_29
import host.sim.compose.a4b.PLT0Nc_30
import host.sim.compose.a4b.PLT0Nc_31
import host.sim.compose.a4b.PLT0Nc_32
import host.sim.compose.a4b.PLT0Nc_33
import host.sim.compose.a4b.PLT0Nc_34
import host.sim.compose.a4b.PLT0Nc_35
import host.sim.compose.a4b.PLT0Nc_36
import host.sim.compose.a4b.PLT0Nc_37
import host.sim.compose.a4b.PLT0Nc_38
import host.sim.compose.a4b.PLT0Nc_39
import host.sim.compose.a4b.PLT0Nc_40
import host.sim.compose.a4b.PLT0Nc_41
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT0.nhandles_end : ((((((((((((((handlesOfA PLT0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT0.nhandles : (handlesOfA PLT0.x0).all (handleOK PLTW0.R.data.map PLT0.P0.lo PLT0.x0 PLT0.x1) = true :=
  all_take_drop 2000 PLT0.nhandles_0 (all_take_drop 2000 PLT0.nhandles_1 (all_take_drop 2000 PLT0.nhandles_2 (all_take_drop 2000 PLT0.nhandles_3 (all_take_drop 2000 PLT0.nhandles_4 (all_take_drop 2000 PLT0.nhandles_5 (all_take_drop 2000 PLT0.nhandles_6 (all_take_drop 2000 PLT0.nhandles_7 (all_take_drop 2000 PLT0.nhandles_8 (all_take_drop 2000 PLT0.nhandles_9 (all_take_drop 2000 PLT0.nhandles_10 (all_take_drop 2000 PLT0.nhandles_11 (all_take_drop 2000 PLT0.nhandles_12 (all_take_drop 2000 PLT0.nhandles_13 (all_of_nil PLT0.nhandles_end))))))))))))))
kernel_rfl PLT0.nnodes_end : (((((((((PTrie.keysA PLT0.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT0.nnodes : (PTrie.keysA PLT0.x0.nodes).all (nodeOKF PLTW0.R.data.map PLT0.P0 PLT0.x0 PLT0.x1) = true :=
  all_take_drop 2000 PLT0.nnodes_0 (all_take_drop 2000 PLT0.nnodes_1 (all_take_drop 2000 PLT0.nnodes_2 (all_take_drop 2000 PLT0.nnodes_3 (all_take_drop 2000 PLT0.nnodes_4 (all_take_drop 2000 PLT0.nnodes_5 (all_take_drop 2000 PLT0.nnodes_6 (all_take_drop 2000 PLT0.nnodes_7 (all_take_drop 2000 PLT0.nnodes_8 (all_of_nil PLT0.nnodes_end)))))))))
kernel_rfl PLT0.nprims_end : (((((((((fullKeysF PLT0.P0 PLT0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT0.nprims : (fullKeysF PLT0.P0 PLT0.x0).map (fun i => (PLT0.x1.nodes.get (PLTW0.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PLT0.P0 PLT0.x0).map (fun i => (PLT0.x0.nodes.get i).map fun nd => PLTW0.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PLT0.nprims_0 (map_take_drop 2000 PLT0.nprims_1 (map_take_drop 2000 PLT0.nprims_2 (map_take_drop 2000 PLT0.nprims_3 (map_take_drop 2000 PLT0.nprims_4 (map_take_drop 2000 PLT0.nprims_5 (map_take_drop 2000 PLT0.nprims_6 (map_take_drop 2000 PLT0.nprims_7 (map_take_drop 2000 PLT0.nprims_8 (map_of_nil PLT0.nprims_end)))))))))
kernel_rfl PLT0.nedges_end : (((((((((PTrie.keysA PLT0.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT0.nedges : (PTrie.keysA PLT0.x0.nodes).all (edgeOK PLTW0.R.data.map PLT0.x0) = true :=
  all_take_drop 2000 PLT0.nedges_0 (all_take_drop 2000 PLT0.nedges_1 (all_take_drop 2000 PLT0.nedges_2 (all_take_drop 2000 PLT0.nedges_3 (all_take_drop 2000 PLT0.nedges_4 (all_take_drop 2000 PLT0.nedges_5 (all_take_drop 2000 PLT0.nedges_6 (all_take_drop 2000 PLT0.nedges_7 (all_take_drop 2000 PLT0.nedges_8 (all_of_nil PLT0.nedges_end)))))))))

theorem PLT0.nshift : Conv.TraceNShift PLT0.P0 15235 PRE_pl_tail.n PLTW0.R.data.map PLT0.y0 PLT0.y1 :=
  traceNShift_of ⟨rfl, rfl, rfl, PLT0.nnh0, PLT0.nnh1, PLT0.nnn0, PLT0.nnn1, PLT0.nlo, PLT0.ncnt, PLT0.nnband, PLT0.nhbelow, PLT0.nhandles, PLT0.nhren, PLT0.nband, PLT0.nnh1pos, PLT0.nobjs, PLT0.nobjok, PLT0.nnodes, PLT0.nprims, PLT0.nnren, PLT0.nnlow, PLT0.nedges, PLT0.nitems, PLT0.nssT, PLT0.nabs0a, PLT0.nabs0b, PLT0.ntok1, PLT0.npend, PLT0.nerrh, PLT0.nfiles, PLT0.narch, PLT0.nsizes, PLT0.nwired⟩ PLT0.nhost fun _ => rfl

end Host.Load.Run.Tpl
