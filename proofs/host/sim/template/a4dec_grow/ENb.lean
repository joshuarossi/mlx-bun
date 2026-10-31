import host.sim.template.a4dec_grow.ENc_0
import host.sim.template.a4dec_grow.ENc_1
import host.sim.template.a4dec_grow.ENc_2
import host.sim.template.a4dec_grow.ENc_3
import host.sim.template.a4dec_grow.ENc_4
import host.sim.template.a4dec_grow.ENc_5
import host.sim.template.a4dec_grow.ENc_6
import host.sim.template.a4dec_grow.ENc_7
import host.sim.template.a4dec_grow.ENc_8
import host.sim.template.a4dec_grow.ENc_9
import host.sim.template.a4dec_grow.ENc_10
import host.sim.template.a4dec_grow.ENc_11
import host.sim.template.a4dec_grow.ENc_12
import host.sim.template.a4dec_grow.ENc_13
import host.sim.template.a4dec_grow.ENc_14
import host.sim.template.a4dec_grow.ENc_15
import host.sim.template.a4dec_grow.ENc_16
import host.sim.template.a4dec_grow.ENc_17
import host.sim.template.a4dec_grow.ENc_18
import host.sim.template.a4dec_grow.ENc_19
import host.sim.template.a4dec_grow.ENc_20
import host.sim.template.a4dec_grow.ENc_21
import host.sim.template.a4dec_grow.ENc_22
import host.sim.template.a4dec_grow.ENc_23
import host.sim.template.a4dec_grow.ENc_24
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_grow.nhandles_end : ((((((((handlesOfA DEC_grow.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_grow.nhandles : (handlesOfA DEC_grow.X0).all (handleOK DEC_grow.σ DEC_grow.PE.lo DEC_grow.X0 DEC_grow.X1) = true :=
  all_take_drop 2000 DEC_grow.nhandles_0 (all_take_drop 2000 DEC_grow.nhandles_1 (all_take_drop 2000 DEC_grow.nhandles_2 (all_take_drop 2000 DEC_grow.nhandles_3 (all_take_drop 2000 DEC_grow.nhandles_4 (all_take_drop 2000 DEC_grow.nhandles_5 (all_take_drop 2000 DEC_grow.nhandles_6 (all_take_drop 2000 DEC_grow.nhandles_7 (all_of_nil DEC_grow.nhandles_end))))))))
kernel_rfl DEC_grow.nnodes_end : ((((((((PTrie.keysA DEC_grow.X0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_grow.nnodes : (PTrie.keysA DEC_grow.X0.nodes).all (nodeOKF DEC_grow.σ DEC_grow.PE DEC_grow.X0 DEC_grow.X1) = true :=
  all_take_drop 2000 DEC_grow.nnodes_0 (all_take_drop 2000 DEC_grow.nnodes_1 (all_take_drop 2000 DEC_grow.nnodes_2 (all_take_drop 2000 DEC_grow.nnodes_3 (all_take_drop 2000 DEC_grow.nnodes_4 (all_take_drop 2000 DEC_grow.nnodes_5 (all_take_drop 2000 DEC_grow.nnodes_6 (all_take_drop 2000 DEC_grow.nnodes_7 (all_of_nil DEC_grow.nnodes_end))))))))
kernel_rfl DEC_grow.nprims_end : ((((((((fullKeysF DEC_grow.PE DEC_grow.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_grow.nprims : (fullKeysF DEC_grow.PE DEC_grow.X0).map (fun i => (DEC_grow.X1.nodes.get (DEC_grow.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF DEC_grow.PE DEC_grow.X0).map (fun i => (DEC_grow.X0.nodes.get i).map fun nd => DEC_grow.σ.prim nd.prim) :=
  map_take_drop 2000 DEC_grow.nprims_0 (map_take_drop 2000 DEC_grow.nprims_1 (map_take_drop 2000 DEC_grow.nprims_2 (map_take_drop 2000 DEC_grow.nprims_3 (map_take_drop 2000 DEC_grow.nprims_4 (map_take_drop 2000 DEC_grow.nprims_5 (map_take_drop 2000 DEC_grow.nprims_6 (map_take_drop 2000 DEC_grow.nprims_7 (map_of_nil DEC_grow.nprims_end))))))))

/-- **The native shift of chain `DEC_grow`'s end** on the load-world projections. -/
theorem DEC_grow.nshift : NShift DEC_grow.PE DEC_grow.S0.tab.length DEC_grow.σ (Host.Load.Layers.toLoad DEC_grow.s0.ffi)
    (Host.Load.Layers.toLoad DEC_grow.s11.ffi) := by
  rw [DEC_grow.S0_len]
  exact nshift_of ⟨rfl, rfl, rfl, DEC_grow.nnh0, DEC_grow.nnh1, DEC_grow.nnn0, DEC_grow.nnn1, DEC_grow.nlo, DEC_grow.ncnt, DEC_grow.nnband, DEC_grow.nhbelow, DEC_grow.nhandles, DEC_grow.nhren, DEC_grow.nband, DEC_grow.nnh1pos, DEC_grow.nobjs, DEC_grow.nobjok, DEC_grow.nnodes, DEC_grow.nprims, DEC_grow.nnren, DEC_grow.nnlow, DEC_grow.nnord, DEC_grow.nitems, DEC_grow.nssT, DEC_grow.nabs0a, DEC_grow.nabs0b, DEC_grow.ntok1, DEC_grow.npend, DEC_grow.nerrh, DEC_grow.nfiles, DEC_grow.narch, DEC_grow.nsizes, DEC_grow.nwired⟩ DEC_grow.nhost fun _ => rfl

end Host.Load.Run.Tpl
