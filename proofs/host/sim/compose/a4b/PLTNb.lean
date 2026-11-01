import host.sim.compose.a4b.PLTNc_0
import host.sim.compose.a4b.PLTNc_1
import host.sim.compose.a4b.PLTNc_2
import host.sim.compose.a4b.PLTNc_3
import host.sim.compose.a4b.PLTNc_4
import host.sim.compose.a4b.PLTNc_5
import host.sim.compose.a4b.PLTNc_6
import host.sim.compose.a4b.PLTNc_7
import host.sim.compose.a4b.PLTNc_8
import host.sim.compose.a4b.PLTNc_9
import host.sim.compose.a4b.PLTNc_10
import host.sim.compose.a4b.PLTNc_11
import host.sim.compose.a4b.PLTNc_12
import host.sim.compose.a4b.PLTNc_13
import host.sim.compose.a4b.PLTNc_14
import host.sim.compose.a4b.PLTNc_15
import host.sim.compose.a4b.PLTNc_16
import host.sim.compose.a4b.PLTNc_17
import host.sim.compose.a4b.PLTNc_18
import host.sim.compose.a4b.PLTNc_19
import host.sim.compose.a4b.PLTNc_20
import host.sim.compose.a4b.PLTNc_21
import host.sim.compose.a4b.PLTNc_22
import host.sim.compose.a4b.PLTNc_23
import host.sim.compose.a4b.PLTNc_24
import host.sim.compose.a4b.PLTNc_25
import host.sim.compose.a4b.PLTNc_26
import host.sim.compose.a4b.PLTNc_27
import host.sim.compose.a4b.PLTNc_28
import host.sim.compose.a4b.PLTNc_29
import host.sim.compose.a4b.PLTNc_30
import host.sim.compose.a4b.PLTNc_31
import host.sim.compose.a4b.PLTNc_32
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.nhandles_end : ((((((((((((((handlesOfA PLT.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT.nhandles : (handlesOfA PLT.x0).all (handleOK PLTail.R.data.map PLT.P0.lo PLT.x0 PLT.x1) = true :=
  all_take_drop 2000 PLT.nhandles_0 (all_take_drop 2000 PLT.nhandles_1 (all_take_drop 2000 PLT.nhandles_2 (all_take_drop 2000 PLT.nhandles_3 (all_take_drop 2000 PLT.nhandles_4 (all_take_drop 2000 PLT.nhandles_5 (all_take_drop 2000 PLT.nhandles_6 (all_take_drop 2000 PLT.nhandles_7 (all_take_drop 2000 PLT.nhandles_8 (all_take_drop 2000 PLT.nhandles_9 (all_take_drop 2000 PLT.nhandles_10 (all_take_drop 2000 PLT.nhandles_11 (all_take_drop 2000 PLT.nhandles_12 (all_take_drop 2000 PLT.nhandles_13 (all_of_nil PLT.nhandles_end))))))))))))))
kernel_rfl PLT.nnodes_end : (((((((((PTrie.keysA PLT.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT.nnodes : (PTrie.keysA PLT.x0.nodes).all (nodeOKF PLTail.R.data.map PLT.P0 PLT.x0 PLT.x1) = true :=
  all_take_drop 2000 PLT.nnodes_0 (all_take_drop 2000 PLT.nnodes_1 (all_take_drop 2000 PLT.nnodes_2 (all_take_drop 2000 PLT.nnodes_3 (all_take_drop 2000 PLT.nnodes_4 (all_take_drop 2000 PLT.nnodes_5 (all_take_drop 2000 PLT.nnodes_6 (all_take_drop 2000 PLT.nnodes_7 (all_take_drop 2000 PLT.nnodes_8 (all_of_nil PLT.nnodes_end)))))))))
kernel_rfl PLT.nprims_end : (((((((((fullKeysF PLT.P0 PLT.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLT.nprims : (fullKeysF PLT.P0 PLT.x0).map (fun i => (PLT.x1.nodes.get (PLTail.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PLT.P0 PLT.x0).map (fun i => (PLT.x0.nodes.get i).map fun nd => PLTail.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PLT.nprims_0 (map_take_drop 2000 PLT.nprims_1 (map_take_drop 2000 PLT.nprims_2 (map_take_drop 2000 PLT.nprims_3 (map_take_drop 2000 PLT.nprims_4 (map_take_drop 2000 PLT.nprims_5 (map_take_drop 2000 PLT.nprims_6 (map_take_drop 2000 PLT.nprims_7 (map_take_drop 2000 PLT.nprims_8 (map_of_nil PLT.nprims_end)))))))))

theorem PLT.nshift : NShift PLT.P0 PRE_pl_tail.n PLTail.R.data.map PLT.y0 PLT.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PLT.nnh0, PLT.nnh1, PLT.nnn0, PLT.nnn1, PLT.nlo, PLT.ncnt, PLT.nnband, PLT.nhbelow, PLT.nhandles, PLT.nhren, PLT.nband, PLT.nnh1pos, PLT.nobjs, PLT.nobjok, PLT.nnodes, PLT.nprims, PLT.nnren, PLT.nnlow, PLT.nnord, PLT.nitems, PLT.nssT, PLT.nabs0a, PLT.nabs0b, PLT.ntok1, PLT.npend, PLT.nerrh, PLT.nfiles, PLT.narch, PLT.nsizes, PLT.nwired⟩ PLT.nhost fun _ => rfl

end Host.Load.Run.Tpl
