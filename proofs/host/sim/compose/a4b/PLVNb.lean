import host.sim.compose.a4b.PLVNc_0
import host.sim.compose.a4b.PLVNc_1
import host.sim.compose.a4b.PLVNc_2
import host.sim.compose.a4b.PLVNc_3
import host.sim.compose.a4b.PLVNc_4
import host.sim.compose.a4b.PLVNc_5
import host.sim.compose.a4b.PLVNc_6
import host.sim.compose.a4b.PLVNc_7
import host.sim.compose.a4b.PLVNc_8
import host.sim.compose.a4b.PLVNc_9
import host.sim.compose.a4b.PLVNc_10
import host.sim.compose.a4b.PLVNc_11
import host.sim.compose.a4b.PLVNc_12
import host.sim.compose.a4b.PLVNc_13
import host.sim.compose.a4b.PLVNc_14
import host.sim.compose.a4b.PLVNc_15
import host.sim.compose.a4b.PLVNc_16
import host.sim.compose.a4b.PLVNc_17
import host.sim.compose.a4b.PLVNc_18
import host.sim.compose.a4b.PLVNc_19
import host.sim.compose.a4b.PLVNc_20
import host.sim.compose.a4b.PLVNc_21
import host.sim.compose.a4b.PLVNc_22
import host.sim.compose.a4b.PLVNc_23
import host.sim.compose.a4b.PLVNc_24
import host.sim.compose.a4b.PLVNc_25
import host.sim.compose.a4b.PLVNc_26
import host.sim.compose.a4b.PLVNc_27
import host.sim.compose.a4b.PLVNc_28
import host.sim.compose.a4b.PLVNc_29
import host.sim.compose.a4b.PLVNc_30
import host.sim.compose.a4b.PLVNc_31
import host.sim.compose.a4b.PLVNc_32
import host.sim.compose.a4b.PLVNc_33
import host.sim.compose.a4b.PLVNc_34
import host.sim.compose.a4b.PLVNc_35
import host.sim.compose.a4b.PLVNc_36
import host.sim.compose.a4b.PLVNc_37
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLV.nhandles_end : (((((((((((((((handlesOfA PLV.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLV.nhandles : (handlesOfA PLV.x0).all (handleOK PLVW.R.data.map PLV.P0.lo PLV.x0 PLV.x1) = true :=
  all_take_drop 2000 PLV.nhandles_0 (all_take_drop 2000 PLV.nhandles_1 (all_take_drop 2000 PLV.nhandles_2 (all_take_drop 2000 PLV.nhandles_3 (all_take_drop 2000 PLV.nhandles_4 (all_take_drop 2000 PLV.nhandles_5 (all_take_drop 2000 PLV.nhandles_6 (all_take_drop 2000 PLV.nhandles_7 (all_take_drop 2000 PLV.nhandles_8 (all_take_drop 2000 PLV.nhandles_9 (all_take_drop 2000 PLV.nhandles_10 (all_take_drop 2000 PLV.nhandles_11 (all_take_drop 2000 PLV.nhandles_12 (all_take_drop 2000 PLV.nhandles_13 (all_take_drop 2000 PLV.nhandles_14 (all_of_nil PLV.nhandles_end)))))))))))))))
kernel_rfl PLV.nnodes_end : (((((((((((PTrie.keysA PLV.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLV.nnodes : (PTrie.keysA PLV.x0.nodes).all (nodeOKF PLVW.R.data.map PLV.P0 PLV.x0 PLV.x1) = true :=
  all_take_drop 2000 PLV.nnodes_0 (all_take_drop 2000 PLV.nnodes_1 (all_take_drop 2000 PLV.nnodes_2 (all_take_drop 2000 PLV.nnodes_3 (all_take_drop 2000 PLV.nnodes_4 (all_take_drop 2000 PLV.nnodes_5 (all_take_drop 2000 PLV.nnodes_6 (all_take_drop 2000 PLV.nnodes_7 (all_take_drop 2000 PLV.nnodes_8 (all_take_drop 2000 PLV.nnodes_9 (all_take_drop 2000 PLV.nnodes_10 (all_of_nil PLV.nnodes_end)))))))))))
kernel_rfl PLV.nprims_end : (((((((((((fullKeysF PLV.P0 PLV.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem PLV.nprims : (fullKeysF PLV.P0 PLV.x0).map (fun i => (PLV.x1.nodes.get (PLVW.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF PLV.P0 PLV.x0).map (fun i => (PLV.x0.nodes.get i).map fun nd => PLVW.R.data.map.prim nd.prim) :=
  map_take_drop 2000 PLV.nprims_0 (map_take_drop 2000 PLV.nprims_1 (map_take_drop 2000 PLV.nprims_2 (map_take_drop 2000 PLV.nprims_3 (map_take_drop 2000 PLV.nprims_4 (map_take_drop 2000 PLV.nprims_5 (map_take_drop 2000 PLV.nprims_6 (map_take_drop 2000 PLV.nprims_7 (map_take_drop 2000 PLV.nprims_8 (map_take_drop 2000 PLV.nprims_9 (map_take_drop 2000 PLV.nprims_10 (map_of_nil PLV.nprims_end)))))))))))

theorem PLV.nshift : NShift PLV.P0 PRE_plvw_entry.n PLVW.R.data.map PLV.y0 PLV.y1 :=
  nshift_of ⟨rfl, rfl, rfl, PLV.nnh0, PLV.nnh1, PLV.nnn0, PLV.nnn1, PLV.nlo, PLV.ncnt, PLV.nnband, PLV.nhbelow, PLV.nhandles, PLV.nhren, PLV.nband, PLV.nnh1pos, PLV.nobjs, PLV.nobjok, PLV.nnodes, PLV.nprims, PLV.nnren, PLV.nnlow, PLV.nnord, PLV.nitems, PLV.nssT, PLV.nabs0a, PLV.nabs0b, PLV.ntok1, PLV.npend, PLV.nerrh, PLV.nfiles, PLV.narch, PLV.nsizes, PLV.nwired⟩ PLV.nhost fun _ => rfl

end Host.Load.Run.Tpl
