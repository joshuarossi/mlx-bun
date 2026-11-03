import host.sim.compose.a4b.PLT4L7Nc_0
import host.sim.compose.a4b.PLT4L7Nc_1
import host.sim.compose.a4b.PLT4L7Nc_2
import host.sim.compose.a4b.PLT4L7Nc_3
import host.sim.compose.a4b.PLT4L7Nc_4
import host.sim.compose.a4b.PLT4L7Nc_5
import host.sim.compose.a4b.PLT4L7Nc_6
import host.sim.compose.a4b.PLT4L7Nc_7
import host.sim.compose.a4b.PLT4L7Nc_8
import host.sim.compose.a4b.PLT4L7Nc_9
import host.sim.compose.a4b.PLT4L7Nc_10
import host.sim.compose.a4b.PLT4L7Nc_11
import host.sim.compose.a4b.PLT4L7Nc_12
import host.sim.compose.a4b.PLT4L7Nc_13
import host.sim.compose.a4b.PLT4L7Nc_14
import host.sim.compose.a4b.PLT4L7Nc_15
import host.sim.compose.a4b.PLT4L7Nc_16
import host.sim.compose.a4b.PLT4L7Nc_17
import host.sim.compose.a4b.PLT4L7Nc_18
import host.sim.compose.a4b.PLT4L7Nc_19
import host.sim.compose.a4b.PLT4L7Nc_20
import host.sim.compose.a4b.PLT4L7Nc_21
import host.sim.compose.a4b.PLT4L7Nc_22
import host.sim.compose.a4b.PLT4L7Nc_23
import host.sim.compose.a4b.PLT4L7Nc_24
import host.sim.compose.a4b.PLT4L7Nc_25
import host.sim.compose.a4b.PLT4L7Nc_26
import host.sim.compose.a4b.PLT4L7Nc_27
import host.sim.compose.a4b.PLT4L7Nc_28
import host.sim.compose.a4b.PLT4L7Nc_29
import host.sim.compose.a4b.PLT4L7Nc_30
import host.sim.compose.a4b.PLT4L7Nc_31
import host.sim.compose.a4b.PLT4L7Nc_32
import host.sim.compose.a4b.PLT4L7Nc_33
import host.sim.compose.a4b.PLT4L7Nc_34
import host.sim.compose.a4b.PLT4L7Nc_35
import host.sim.compose.a4b.PLT4L7Nc_36
import host.sim.compose.a4b.PLT4L7Nc_37
import host.sim.compose.a4b.PLT4L7Nc_38
import host.sim.compose.a4b.PLT4L7Nc_39
import host.sim.compose.a4b.PLT4L7Nc_40
import host.sim.compose.a4b.PLT4L7Nc_41
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L7.nhandles_end : ((((((((((((((handlesOfA PLT4L7.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT4L7.nhandles : (handlesOfA PLT4L7.x0).all (handleOK PLTW4L7.R.data.map PLT4L7.P0.lo PLT4L7.x0 PLT4L7.x1) = true :=
  all_take_drop 2000 PLT4L7.nhandles_0 (all_take_drop 2000 PLT4L7.nhandles_1 (all_take_drop 2000 PLT4L7.nhandles_2 (all_take_drop 2000 PLT4L7.nhandles_3 (all_take_drop 2000 PLT4L7.nhandles_4 (all_take_drop 2000 PLT4L7.nhandles_5 (all_take_drop 2000 PLT4L7.nhandles_6 (all_take_drop 2000 PLT4L7.nhandles_7 (all_take_drop 2000 PLT4L7.nhandles_8 (all_take_drop 2000 PLT4L7.nhandles_9 (all_take_drop 2000 PLT4L7.nhandles_10 (all_take_drop 2000 PLT4L7.nhandles_11 (all_take_drop 2000 PLT4L7.nhandles_12 (all_take_drop 2000 PLT4L7.nhandles_13 (all_of_nil PLT4L7.nhandles_end))))))))))))))
kernel_rfl PLT4L7.nnodes_end : (((((((((PTrie.keysA PLT4L7.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT4L7.nnodes : (PTrie.keysA PLT4L7.x0.nodes).all (nodeOKF PLTW4L7.R.data.map PLT4L7.P0 PLT4L7.x0 PLT4L7.x1) = true :=
  all_take_drop 2000 PLT4L7.nnodes_0 (all_take_drop 2000 PLT4L7.nnodes_1 (all_take_drop 2000 PLT4L7.nnodes_2 (all_take_drop 2000 PLT4L7.nnodes_3 (all_take_drop 2000 PLT4L7.nnodes_4 (all_take_drop 2000 PLT4L7.nnodes_5 (all_take_drop 2000 PLT4L7.nnodes_6 (all_take_drop 2000 PLT4L7.nnodes_7 (all_take_drop 2000 PLT4L7.nnodes_8 (all_of_nil PLT4L7.nnodes_end)))))))))
kernel_rfl PLT4L7.nprims_end : (((((((((fullKeysF PLT4L7.P0 PLT4L7.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT4L7.nprims : (fullKeysF PLT4L7.P0 PLT4L7.x0).map (fun i => (PLT4L7.x1.nodes.get (PLTW4L7.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PLT4L7.P0 PLT4L7.x0).map (fun i => (PLT4L7.x0.nodes.get i).map fun nd => PLTW4L7.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PLT4L7.nprims_0 (map_take_drop 2000 PLT4L7.nprims_1 (map_take_drop 2000 PLT4L7.nprims_2 (map_take_drop 2000 PLT4L7.nprims_3 (map_take_drop 2000 PLT4L7.nprims_4 (map_take_drop 2000 PLT4L7.nprims_5 (map_take_drop 2000 PLT4L7.nprims_6 (map_take_drop 2000 PLT4L7.nprims_7 (map_take_drop 2000 PLT4L7.nprims_8 (map_of_nil PLT4L7.nprims_end)))))))))
kernel_rfl PLT4L7.nedges_end : (((((((((PTrie.keysA PLT4L7.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT4L7.nedges : (PTrie.keysA PLT4L7.x0.nodes).all (edgeOK PLTW4L7.R.data.map PLT4L7.x0) = true :=
  all_take_drop 2000 PLT4L7.nedges_0 (all_take_drop 2000 PLT4L7.nedges_1 (all_take_drop 2000 PLT4L7.nedges_2 (all_take_drop 2000 PLT4L7.nedges_3 (all_take_drop 2000 PLT4L7.nedges_4 (all_take_drop 2000 PLT4L7.nedges_5 (all_take_drop 2000 PLT4L7.nedges_6 (all_take_drop 2000 PLT4L7.nedges_7 (all_take_drop 2000 PLT4L7.nedges_8 (all_of_nil PLT4L7.nedges_end)))))))))

theorem PLT4L7.nshift : Conv.TraceNShift PLT4L7.P0 15235 PRE_pl_tail.n PLTW4L7.R.data.map PLT4L7.y0 PLT4L7.y1 :=
  traceNShift_of ⟨rfl, rfl, rfl, PLT4L7.nnh0, PLT4L7.nnh1, PLT4L7.nnn0, PLT4L7.nnn1, PLT4L7.nlo, PLT4L7.ncnt, PLT4L7.nnband, PLT4L7.nhbelow, PLT4L7.nhandles, PLT4L7.nhren, PLT4L7.nband, PLT4L7.nnh1pos, PLT4L7.nobjs, PLT4L7.nobjok, PLT4L7.nnodes, PLT4L7.nprims, PLT4L7.nnren, PLT4L7.nnlow, PLT4L7.nedges, PLT4L7.nitems, PLT4L7.nssT, PLT4L7.nabs0a, PLT4L7.nabs0b, PLT4L7.ntok1, PLT4L7.npend, PLT4L7.nerrh, PLT4L7.nfiles, PLT4L7.narch, PLT4L7.nsizes, PLT4L7.nwired⟩ PLT4L7.nhost fun _ => rfl

end Host.Load.Run.Tpl
