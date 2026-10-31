import host.sim.template.a4dec_clearGrow.ENc_0
import host.sim.template.a4dec_clearGrow.ENc_1
import host.sim.template.a4dec_clearGrow.ENc_2
import host.sim.template.a4dec_clearGrow.ENc_3
import host.sim.template.a4dec_clearGrow.ENc_4
import host.sim.template.a4dec_clearGrow.ENc_5
import host.sim.template.a4dec_clearGrow.ENc_6
import host.sim.template.a4dec_clearGrow.ENc_7
import host.sim.template.a4dec_clearGrow.ENc_8
import host.sim.template.a4dec_clearGrow.ENc_9
import host.sim.template.a4dec_clearGrow.ENc_10
import host.sim.template.a4dec_clearGrow.ENc_11
import host.sim.template.a4dec_clearGrow.ENc_12
import host.sim.template.a4dec_clearGrow.ENc_13
import host.sim.template.a4dec_clearGrow.ENc_14
import host.sim.template.a4dec_clearGrow.ENc_15
import host.sim.template.a4dec_clearGrow.ENc_16
import host.sim.template.a4dec_clearGrow.ENc_17
import host.sim.template.a4dec_clearGrow.ENc_18
import host.sim.template.a4dec_clearGrow.ENc_19
import host.sim.template.a4dec_clearGrow.ENc_20
import host.sim.template.a4dec_clearGrow.ENc_21
import host.sim.template.a4dec_clearGrow.ENc_22
import host.sim.template.a4dec_clearGrow.ENc_23
import host.sim.template.a4dec_clearGrow.ENc_24
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clearGrow.nhandles_end : ((((((((handlesOfA DEC_clearGrow.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_clearGrow.nhandles : (handlesOfA DEC_clearGrow.X0).all (handleOK DEC_clearGrow.σ DEC_clearGrow.PE.lo DEC_clearGrow.X0 DEC_clearGrow.X1) = true :=
  all_take_drop 2000 DEC_clearGrow.nhandles_0 (all_take_drop 2000 DEC_clearGrow.nhandles_1 (all_take_drop 2000 DEC_clearGrow.nhandles_2 (all_take_drop 2000 DEC_clearGrow.nhandles_3 (all_take_drop 2000 DEC_clearGrow.nhandles_4 (all_take_drop 2000 DEC_clearGrow.nhandles_5 (all_take_drop 2000 DEC_clearGrow.nhandles_6 (all_take_drop 2000 DEC_clearGrow.nhandles_7 (all_of_nil DEC_clearGrow.nhandles_end))))))))
kernel_rfl DEC_clearGrow.nnodes_end : ((((((((PTrie.keysA DEC_clearGrow.X0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_clearGrow.nnodes : (PTrie.keysA DEC_clearGrow.X0.nodes).all (nodeOKF DEC_clearGrow.σ DEC_clearGrow.PE DEC_clearGrow.X0 DEC_clearGrow.X1) = true :=
  all_take_drop 2000 DEC_clearGrow.nnodes_0 (all_take_drop 2000 DEC_clearGrow.nnodes_1 (all_take_drop 2000 DEC_clearGrow.nnodes_2 (all_take_drop 2000 DEC_clearGrow.nnodes_3 (all_take_drop 2000 DEC_clearGrow.nnodes_4 (all_take_drop 2000 DEC_clearGrow.nnodes_5 (all_take_drop 2000 DEC_clearGrow.nnodes_6 (all_take_drop 2000 DEC_clearGrow.nnodes_7 (all_of_nil DEC_clearGrow.nnodes_end))))))))
kernel_rfl DEC_clearGrow.nprims_end : ((((((((fullKeysF DEC_clearGrow.PE DEC_clearGrow.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_clearGrow.nprims : (fullKeysF DEC_clearGrow.PE DEC_clearGrow.X0).map (fun i => (DEC_clearGrow.X1.nodes.get (DEC_clearGrow.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF DEC_clearGrow.PE DEC_clearGrow.X0).map (fun i => (DEC_clearGrow.X0.nodes.get i).map fun nd => DEC_clearGrow.σ.prim nd.prim) :=
  map_take_drop 2000 DEC_clearGrow.nprims_0 (map_take_drop 2000 DEC_clearGrow.nprims_1 (map_take_drop 2000 DEC_clearGrow.nprims_2 (map_take_drop 2000 DEC_clearGrow.nprims_3 (map_take_drop 2000 DEC_clearGrow.nprims_4 (map_take_drop 2000 DEC_clearGrow.nprims_5 (map_take_drop 2000 DEC_clearGrow.nprims_6 (map_take_drop 2000 DEC_clearGrow.nprims_7 (map_of_nil DEC_clearGrow.nprims_end))))))))

/-- **The native shift of chain `DEC_clearGrow`'s end** on the load-world projections. -/
theorem DEC_clearGrow.nshift : NShift DEC_clearGrow.PE DEC_clearGrow.S0.tab.length DEC_clearGrow.σ (Host.Load.Layers.toLoad DEC_clearGrow.s0.ffi)
    (Host.Load.Layers.toLoad DEC_clearGrow.s11.ffi) := by
  rw [DEC_clearGrow.S0_len]
  exact nshift_of ⟨rfl, rfl, rfl, DEC_clearGrow.nnh0, DEC_clearGrow.nnh1, DEC_clearGrow.nnn0, DEC_clearGrow.nnn1, DEC_clearGrow.nlo, DEC_clearGrow.ncnt, DEC_clearGrow.nnband, DEC_clearGrow.nhbelow, DEC_clearGrow.nhandles, DEC_clearGrow.nhren, DEC_clearGrow.nband, DEC_clearGrow.nnh1pos, DEC_clearGrow.nobjs, DEC_clearGrow.nobjok, DEC_clearGrow.nnodes, DEC_clearGrow.nprims, DEC_clearGrow.nnren, DEC_clearGrow.nnlow, DEC_clearGrow.nnord, DEC_clearGrow.nitems, DEC_clearGrow.nssT, DEC_clearGrow.nabs0a, DEC_clearGrow.nabs0b, DEC_clearGrow.ntok1, DEC_clearGrow.npend, DEC_clearGrow.nerrh, DEC_clearGrow.nfiles, DEC_clearGrow.narch, DEC_clearGrow.nsizes, DEC_clearGrow.nwired⟩ DEC_clearGrow.nhost fun _ => rfl

end Host.Load.Run.Tpl
