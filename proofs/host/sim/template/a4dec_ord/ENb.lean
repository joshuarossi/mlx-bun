import host.sim.template.a4dec_ord.ENc_0
import host.sim.template.a4dec_ord.ENc_1
import host.sim.template.a4dec_ord.ENc_2
import host.sim.template.a4dec_ord.ENc_3
import host.sim.template.a4dec_ord.ENc_4
import host.sim.template.a4dec_ord.ENc_5
import host.sim.template.a4dec_ord.ENc_6
import host.sim.template.a4dec_ord.ENc_7
import host.sim.template.a4dec_ord.ENc_8
import host.sim.template.a4dec_ord.ENc_9
import host.sim.template.a4dec_ord.ENc_10
import host.sim.template.a4dec_ord.ENc_11
import host.sim.template.a4dec_ord.ENc_12
import host.sim.template.a4dec_ord.ENc_13
import host.sim.template.a4dec_ord.ENc_14
import host.sim.template.a4dec_ord.ENc_15
import host.sim.template.a4dec_ord.ENc_16
import host.sim.template.a4dec_ord.ENc_17
import host.sim.template.a4dec_ord.ENc_18
import host.sim.template.a4dec_ord.ENc_19
import host.sim.template.a4dec_ord.ENc_20
import host.sim.template.a4dec_ord.ENc_21
import host.sim.template.a4dec_ord.ENc_22
import host.sim.template.a4dec_ord.ENc_23
import host.sim.template.a4dec_ord.ENc_24
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_ord.nhandles_end : ((((((((handlesOfA DEC_ord.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_ord.nhandles : (handlesOfA DEC_ord.X0).all (handleOK DEC_ord.σ DEC_ord.PE.lo DEC_ord.X0 DEC_ord.X1) = true :=
  all_take_drop 2000 DEC_ord.nhandles_0 (all_take_drop 2000 DEC_ord.nhandles_1 (all_take_drop 2000 DEC_ord.nhandles_2 (all_take_drop 2000 DEC_ord.nhandles_3 (all_take_drop 2000 DEC_ord.nhandles_4 (all_take_drop 2000 DEC_ord.nhandles_5 (all_take_drop 2000 DEC_ord.nhandles_6 (all_take_drop 2000 DEC_ord.nhandles_7 (all_of_nil DEC_ord.nhandles_end))))))))
kernel_rfl DEC_ord.nnodes_end : ((((((((PTrie.keysA DEC_ord.X0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_ord.nnodes : (PTrie.keysA DEC_ord.X0.nodes).all (nodeOKF DEC_ord.σ DEC_ord.PE DEC_ord.X0 DEC_ord.X1) = true :=
  all_take_drop 2000 DEC_ord.nnodes_0 (all_take_drop 2000 DEC_ord.nnodes_1 (all_take_drop 2000 DEC_ord.nnodes_2 (all_take_drop 2000 DEC_ord.nnodes_3 (all_take_drop 2000 DEC_ord.nnodes_4 (all_take_drop 2000 DEC_ord.nnodes_5 (all_take_drop 2000 DEC_ord.nnodes_6 (all_take_drop 2000 DEC_ord.nnodes_7 (all_of_nil DEC_ord.nnodes_end))))))))
kernel_rfl DEC_ord.nprims_end : ((((((((fullKeysF DEC_ord.PE DEC_ord.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_ord.nprims : (fullKeysF DEC_ord.PE DEC_ord.X0).map (fun i => (DEC_ord.X1.nodes.get (DEC_ord.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF DEC_ord.PE DEC_ord.X0).map (fun i => (DEC_ord.X0.nodes.get i).map fun nd => DEC_ord.σ.prim nd.prim) :=
  map_take_drop 2000 DEC_ord.nprims_0 (map_take_drop 2000 DEC_ord.nprims_1 (map_take_drop 2000 DEC_ord.nprims_2 (map_take_drop 2000 DEC_ord.nprims_3 (map_take_drop 2000 DEC_ord.nprims_4 (map_take_drop 2000 DEC_ord.nprims_5 (map_take_drop 2000 DEC_ord.nprims_6 (map_take_drop 2000 DEC_ord.nprims_7 (map_of_nil DEC_ord.nprims_end))))))))

/-- **The native shift of chain `DEC_ord`'s end** on the load-world projections. -/
theorem DEC_ord.nshift : NShift DEC_ord.PE DEC_ord.S0.tab.length DEC_ord.σ (Host.Load.Layers.toLoad DEC_ord.s0.ffi)
    (Host.Load.Layers.toLoad DEC_ord.s11.ffi) := by
  rw [DEC_ord.S0_len]
  exact nshift_of ⟨rfl, rfl, rfl, DEC_ord.nnh0, DEC_ord.nnh1, DEC_ord.nnn0, DEC_ord.nnn1, DEC_ord.nlo, DEC_ord.ncnt, DEC_ord.nnband, DEC_ord.nhbelow, DEC_ord.nhandles, DEC_ord.nhren, DEC_ord.nband, DEC_ord.nnh1pos, DEC_ord.nobjs, DEC_ord.nobjok, DEC_ord.nnodes, DEC_ord.nprims, DEC_ord.nnren, DEC_ord.nnlow, DEC_ord.nnord, DEC_ord.nitems, DEC_ord.nssT, DEC_ord.nabs0a, DEC_ord.nabs0b, DEC_ord.ntok1, DEC_ord.npend, DEC_ord.nerrh, DEC_ord.nfiles, DEC_ord.narch, DEC_ord.nsizes, DEC_ord.nwired⟩ DEC_ord.nhost fun _ => rfl

end Host.Load.Run.Tpl
