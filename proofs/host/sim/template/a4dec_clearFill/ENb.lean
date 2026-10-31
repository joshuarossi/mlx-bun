import host.sim.template.a4dec_clearFill.ENc_0
import host.sim.template.a4dec_clearFill.ENc_1
import host.sim.template.a4dec_clearFill.ENc_2
import host.sim.template.a4dec_clearFill.ENc_3
import host.sim.template.a4dec_clearFill.ENc_4
import host.sim.template.a4dec_clearFill.ENc_5
import host.sim.template.a4dec_clearFill.ENc_6
import host.sim.template.a4dec_clearFill.ENc_7
import host.sim.template.a4dec_clearFill.ENc_8
import host.sim.template.a4dec_clearFill.ENc_9
import host.sim.template.a4dec_clearFill.ENc_10
import host.sim.template.a4dec_clearFill.ENc_11
import host.sim.template.a4dec_clearFill.ENc_12
import host.sim.template.a4dec_clearFill.ENc_13
import host.sim.template.a4dec_clearFill.ENc_14
import host.sim.template.a4dec_clearFill.ENc_15
import host.sim.template.a4dec_clearFill.ENc_16
import host.sim.template.a4dec_clearFill.ENc_17
import host.sim.template.a4dec_clearFill.ENc_18
import host.sim.template.a4dec_clearFill.ENc_19
import host.sim.template.a4dec_clearFill.ENc_20
import host.sim.template.a4dec_clearFill.ENc_21
import host.sim.template.a4dec_clearFill.ENc_22
import host.sim.template.a4dec_clearFill.ENc_23
import host.sim.template.a4dec_clearFill.ENc_24
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clearFill.nhandles_end : ((((((((handlesOfA DEC_clearFill.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_clearFill.nhandles : (handlesOfA DEC_clearFill.X0).all (handleOK DEC_clearFill.σ DEC_clearFill.PE.lo DEC_clearFill.X0 DEC_clearFill.X1) = true :=
  all_take_drop 2000 DEC_clearFill.nhandles_0 (all_take_drop 2000 DEC_clearFill.nhandles_1 (all_take_drop 2000 DEC_clearFill.nhandles_2 (all_take_drop 2000 DEC_clearFill.nhandles_3 (all_take_drop 2000 DEC_clearFill.nhandles_4 (all_take_drop 2000 DEC_clearFill.nhandles_5 (all_take_drop 2000 DEC_clearFill.nhandles_6 (all_take_drop 2000 DEC_clearFill.nhandles_7 (all_of_nil DEC_clearFill.nhandles_end))))))))
kernel_rfl DEC_clearFill.nnodes_end : ((((((((PTrie.keysA DEC_clearFill.X0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_clearFill.nnodes : (PTrie.keysA DEC_clearFill.X0.nodes).all (nodeOKF DEC_clearFill.σ DEC_clearFill.PE DEC_clearFill.X0 DEC_clearFill.X1) = true :=
  all_take_drop 2000 DEC_clearFill.nnodes_0 (all_take_drop 2000 DEC_clearFill.nnodes_1 (all_take_drop 2000 DEC_clearFill.nnodes_2 (all_take_drop 2000 DEC_clearFill.nnodes_3 (all_take_drop 2000 DEC_clearFill.nnodes_4 (all_take_drop 2000 DEC_clearFill.nnodes_5 (all_take_drop 2000 DEC_clearFill.nnodes_6 (all_take_drop 2000 DEC_clearFill.nnodes_7 (all_of_nil DEC_clearFill.nnodes_end))))))))
kernel_rfl DEC_clearFill.nprims_end : ((((((((fullKeysF DEC_clearFill.PE DEC_clearFill.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_clearFill.nprims : (fullKeysF DEC_clearFill.PE DEC_clearFill.X0).map (fun i => (DEC_clearFill.X1.nodes.get (DEC_clearFill.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF DEC_clearFill.PE DEC_clearFill.X0).map (fun i => (DEC_clearFill.X0.nodes.get i).map fun nd => DEC_clearFill.σ.prim nd.prim) :=
  map_take_drop 2000 DEC_clearFill.nprims_0 (map_take_drop 2000 DEC_clearFill.nprims_1 (map_take_drop 2000 DEC_clearFill.nprims_2 (map_take_drop 2000 DEC_clearFill.nprims_3 (map_take_drop 2000 DEC_clearFill.nprims_4 (map_take_drop 2000 DEC_clearFill.nprims_5 (map_take_drop 2000 DEC_clearFill.nprims_6 (map_take_drop 2000 DEC_clearFill.nprims_7 (map_of_nil DEC_clearFill.nprims_end))))))))

/-- **The native shift of chain `DEC_clearFill`'s end** on the load-world projections. -/
theorem DEC_clearFill.nshift : NShift DEC_clearFill.PE DEC_clearFill.S0.tab.length DEC_clearFill.σ (Host.Load.Layers.toLoad DEC_clearFill.s0.ffi)
    (Host.Load.Layers.toLoad DEC_clearFill.s11.ffi) := by
  rw [DEC_clearFill.S0_len]
  exact nshift_of ⟨rfl, rfl, rfl, DEC_clearFill.nnh0, DEC_clearFill.nnh1, DEC_clearFill.nnn0, DEC_clearFill.nnn1, DEC_clearFill.nlo, DEC_clearFill.ncnt, DEC_clearFill.nnband, DEC_clearFill.nhbelow, DEC_clearFill.nhandles, DEC_clearFill.nhren, DEC_clearFill.nband, DEC_clearFill.nnh1pos, DEC_clearFill.nobjs, DEC_clearFill.nobjok, DEC_clearFill.nnodes, DEC_clearFill.nprims, DEC_clearFill.nnren, DEC_clearFill.nnlow, DEC_clearFill.nnord, DEC_clearFill.nitems, DEC_clearFill.nssT, DEC_clearFill.nabs0a, DEC_clearFill.nabs0b, DEC_clearFill.ntok1, DEC_clearFill.npend, DEC_clearFill.nerrh, DEC_clearFill.nfiles, DEC_clearFill.narch, DEC_clearFill.nsizes, DEC_clearFill.nwired⟩ DEC_clearFill.nhost fun _ => rfl

end Host.Load.Run.Tpl
