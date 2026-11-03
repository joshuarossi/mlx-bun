import host.sim.compose.a4b.PLT4L9Nc_0
import host.sim.compose.a4b.PLT4L9Nc_1
import host.sim.compose.a4b.PLT4L9Nc_2
import host.sim.compose.a4b.PLT4L9Nc_3
import host.sim.compose.a4b.PLT4L9Nc_4
import host.sim.compose.a4b.PLT4L9Nc_5
import host.sim.compose.a4b.PLT4L9Nc_6
import host.sim.compose.a4b.PLT4L9Nc_7
import host.sim.compose.a4b.PLT4L9Nc_8
import host.sim.compose.a4b.PLT4L9Nc_9
import host.sim.compose.a4b.PLT4L9Nc_10
import host.sim.compose.a4b.PLT4L9Nc_11
import host.sim.compose.a4b.PLT4L9Nc_12
import host.sim.compose.a4b.PLT4L9Nc_13
import host.sim.compose.a4b.PLT4L9Nc_14
import host.sim.compose.a4b.PLT4L9Nc_15
import host.sim.compose.a4b.PLT4L9Nc_16
import host.sim.compose.a4b.PLT4L9Nc_17
import host.sim.compose.a4b.PLT4L9Nc_18
import host.sim.compose.a4b.PLT4L9Nc_19
import host.sim.compose.a4b.PLT4L9Nc_20
import host.sim.compose.a4b.PLT4L9Nc_21
import host.sim.compose.a4b.PLT4L9Nc_22
import host.sim.compose.a4b.PLT4L9Nc_23
import host.sim.compose.a4b.PLT4L9Nc_24
import host.sim.compose.a4b.PLT4L9Nc_25
import host.sim.compose.a4b.PLT4L9Nc_26
import host.sim.compose.a4b.PLT4L9Nc_27
import host.sim.compose.a4b.PLT4L9Nc_28
import host.sim.compose.a4b.PLT4L9Nc_29
import host.sim.compose.a4b.PLT4L9Nc_30
import host.sim.compose.a4b.PLT4L9Nc_31
import host.sim.compose.a4b.PLT4L9Nc_32
import host.sim.compose.a4b.PLT4L9Nc_33
import host.sim.compose.a4b.PLT4L9Nc_34
import host.sim.compose.a4b.PLT4L9Nc_35
import host.sim.compose.a4b.PLT4L9Nc_36
import host.sim.compose.a4b.PLT4L9Nc_37
import host.sim.compose.a4b.PLT4L9Nc_38
import host.sim.compose.a4b.PLT4L9Nc_39
import host.sim.compose.a4b.PLT4L9Nc_40
import host.sim.compose.a4b.PLT4L9Nc_41
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L9.nhandles_end : ((((((((((((((handlesOfA PLT4L9.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT4L9.nhandles : (handlesOfA PLT4L9.x0).all (handleOK PLTW4L9.R.data.map PLT4L9.P0.lo PLT4L9.x0 PLT4L9.x1) = true :=
  all_take_drop 2000 PLT4L9.nhandles_0 (all_take_drop 2000 PLT4L9.nhandles_1 (all_take_drop 2000 PLT4L9.nhandles_2 (all_take_drop 2000 PLT4L9.nhandles_3 (all_take_drop 2000 PLT4L9.nhandles_4 (all_take_drop 2000 PLT4L9.nhandles_5 (all_take_drop 2000 PLT4L9.nhandles_6 (all_take_drop 2000 PLT4L9.nhandles_7 (all_take_drop 2000 PLT4L9.nhandles_8 (all_take_drop 2000 PLT4L9.nhandles_9 (all_take_drop 2000 PLT4L9.nhandles_10 (all_take_drop 2000 PLT4L9.nhandles_11 (all_take_drop 2000 PLT4L9.nhandles_12 (all_take_drop 2000 PLT4L9.nhandles_13 (all_of_nil PLT4L9.nhandles_end))))))))))))))
kernel_rfl PLT4L9.nnodes_end : (((((((((PTrie.keysA PLT4L9.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT4L9.nnodes : (PTrie.keysA PLT4L9.x0.nodes).all (nodeOKF PLTW4L9.R.data.map PLT4L9.P0 PLT4L9.x0 PLT4L9.x1) = true :=
  all_take_drop 2000 PLT4L9.nnodes_0 (all_take_drop 2000 PLT4L9.nnodes_1 (all_take_drop 2000 PLT4L9.nnodes_2 (all_take_drop 2000 PLT4L9.nnodes_3 (all_take_drop 2000 PLT4L9.nnodes_4 (all_take_drop 2000 PLT4L9.nnodes_5 (all_take_drop 2000 PLT4L9.nnodes_6 (all_take_drop 2000 PLT4L9.nnodes_7 (all_take_drop 2000 PLT4L9.nnodes_8 (all_of_nil PLT4L9.nnodes_end)))))))))
kernel_rfl PLT4L9.nprims_end : (((((((((fullKeysF PLT4L9.P0 PLT4L9.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT4L9.nprims : (fullKeysF PLT4L9.P0 PLT4L9.x0).map (fun i => (PLT4L9.x1.nodes.get (PLTW4L9.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PLT4L9.P0 PLT4L9.x0).map (fun i => (PLT4L9.x0.nodes.get i).map fun nd => PLTW4L9.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PLT4L9.nprims_0 (map_take_drop 2000 PLT4L9.nprims_1 (map_take_drop 2000 PLT4L9.nprims_2 (map_take_drop 2000 PLT4L9.nprims_3 (map_take_drop 2000 PLT4L9.nprims_4 (map_take_drop 2000 PLT4L9.nprims_5 (map_take_drop 2000 PLT4L9.nprims_6 (map_take_drop 2000 PLT4L9.nprims_7 (map_take_drop 2000 PLT4L9.nprims_8 (map_of_nil PLT4L9.nprims_end)))))))))
kernel_rfl PLT4L9.nedges_end : (((((((((PTrie.keysA PLT4L9.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT4L9.nedges : (PTrie.keysA PLT4L9.x0.nodes).all (edgeOK PLTW4L9.R.data.map PLT4L9.x0) = true :=
  all_take_drop 2000 PLT4L9.nedges_0 (all_take_drop 2000 PLT4L9.nedges_1 (all_take_drop 2000 PLT4L9.nedges_2 (all_take_drop 2000 PLT4L9.nedges_3 (all_take_drop 2000 PLT4L9.nedges_4 (all_take_drop 2000 PLT4L9.nedges_5 (all_take_drop 2000 PLT4L9.nedges_6 (all_take_drop 2000 PLT4L9.nedges_7 (all_take_drop 2000 PLT4L9.nedges_8 (all_of_nil PLT4L9.nedges_end)))))))))

theorem PLT4L9.nshift : Conv.TraceNShift PLT4L9.P0 15235 PRE_pl_tail.n PLTW4L9.R.data.map PLT4L9.y0 PLT4L9.y1 :=
  traceNShift_of ⟨rfl, rfl, rfl, PLT4L9.nnh0, PLT4L9.nnh1, PLT4L9.nnn0, PLT4L9.nnn1, PLT4L9.nlo, PLT4L9.ncnt, PLT4L9.nnband, PLT4L9.nhbelow, PLT4L9.nhandles, PLT4L9.nhren, PLT4L9.nband, PLT4L9.nnh1pos, PLT4L9.nobjs, PLT4L9.nobjok, PLT4L9.nnodes, PLT4L9.nprims, PLT4L9.nnren, PLT4L9.nnlow, PLT4L9.nedges, PLT4L9.nitems, PLT4L9.nssT, PLT4L9.nabs0a, PLT4L9.nabs0b, PLT4L9.ntok1, PLT4L9.npend, PLT4L9.nerrh, PLT4L9.nfiles, PLT4L9.narch, PLT4L9.nsizes, PLT4L9.nwired⟩ PLT4L9.nhost fun _ => rfl

end Host.Load.Run.Tpl
