import host.sim.template.a4dec_fill.ENc_0
import host.sim.template.a4dec_fill.ENc_1
import host.sim.template.a4dec_fill.ENc_2
import host.sim.template.a4dec_fill.ENc_3
import host.sim.template.a4dec_fill.ENc_4
import host.sim.template.a4dec_fill.ENc_5
import host.sim.template.a4dec_fill.ENc_6
import host.sim.template.a4dec_fill.ENc_7
import host.sim.template.a4dec_fill.ENc_8
import host.sim.template.a4dec_fill.ENc_9
import host.sim.template.a4dec_fill.ENc_10
import host.sim.template.a4dec_fill.ENc_11
import host.sim.template.a4dec_fill.ENc_12
import host.sim.template.a4dec_fill.ENc_13
import host.sim.template.a4dec_fill.ENc_14
import host.sim.template.a4dec_fill.ENc_15
import host.sim.template.a4dec_fill.ENc_16
import host.sim.template.a4dec_fill.ENc_17
import host.sim.template.a4dec_fill.ENc_18
import host.sim.template.a4dec_fill.ENc_19
import host.sim.template.a4dec_fill.ENc_20
import host.sim.template.a4dec_fill.ENc_21
import host.sim.template.a4dec_fill.ENc_22
import host.sim.template.a4dec_fill.ENc_23
import host.sim.template.a4dec_fill.ENc_24
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_fill.nhandles_end : ((((((((handlesOfA DEC_fill.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_fill.nhandles : (handlesOfA DEC_fill.X0).all (handleOK DEC_fill.σ DEC_fill.PE.lo DEC_fill.X0 DEC_fill.X1) = true :=
  all_take_drop 2000 DEC_fill.nhandles_0 (all_take_drop 2000 DEC_fill.nhandles_1 (all_take_drop 2000 DEC_fill.nhandles_2 (all_take_drop 2000 DEC_fill.nhandles_3 (all_take_drop 2000 DEC_fill.nhandles_4 (all_take_drop 2000 DEC_fill.nhandles_5 (all_take_drop 2000 DEC_fill.nhandles_6 (all_take_drop 2000 DEC_fill.nhandles_7 (all_of_nil DEC_fill.nhandles_end))))))))
kernel_rfl DEC_fill.nnodes_end : ((((((((PTrie.keysA DEC_fill.X0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_fill.nnodes : (PTrie.keysA DEC_fill.X0.nodes).all (nodeOKF DEC_fill.σ DEC_fill.PE DEC_fill.X0 DEC_fill.X1) = true :=
  all_take_drop 2000 DEC_fill.nnodes_0 (all_take_drop 2000 DEC_fill.nnodes_1 (all_take_drop 2000 DEC_fill.nnodes_2 (all_take_drop 2000 DEC_fill.nnodes_3 (all_take_drop 2000 DEC_fill.nnodes_4 (all_take_drop 2000 DEC_fill.nnodes_5 (all_take_drop 2000 DEC_fill.nnodes_6 (all_take_drop 2000 DEC_fill.nnodes_7 (all_of_nil DEC_fill.nnodes_end))))))))
kernel_rfl DEC_fill.nprims_end : ((((((((fullKeysF DEC_fill.PE DEC_fill.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_fill.nprims : (fullKeysF DEC_fill.PE DEC_fill.X0).map (fun i => (DEC_fill.X1.nodes.get (DEC_fill.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF DEC_fill.PE DEC_fill.X0).map (fun i => (DEC_fill.X0.nodes.get i).map fun nd => DEC_fill.σ.prim nd.prim) :=
  map_take_drop 2000 DEC_fill.nprims_0 (map_take_drop 2000 DEC_fill.nprims_1 (map_take_drop 2000 DEC_fill.nprims_2 (map_take_drop 2000 DEC_fill.nprims_3 (map_take_drop 2000 DEC_fill.nprims_4 (map_take_drop 2000 DEC_fill.nprims_5 (map_take_drop 2000 DEC_fill.nprims_6 (map_take_drop 2000 DEC_fill.nprims_7 (map_of_nil DEC_fill.nprims_end))))))))

/-- **The native shift of chain `DEC_fill`'s end** on the load-world projections. -/
theorem DEC_fill.nshift : NShift DEC_fill.PE DEC_fill.S0.tab.length DEC_fill.σ (Host.Load.Layers.toLoad DEC_fill.s0.ffi)
    (Host.Load.Layers.toLoad DEC_fill.s11.ffi) := by
  rw [DEC_fill.S0_len]
  exact nshift_of ⟨rfl, rfl, rfl, DEC_fill.nnh0, DEC_fill.nnh1, DEC_fill.nnn0, DEC_fill.nnn1, DEC_fill.nlo, DEC_fill.ncnt, DEC_fill.nnband, DEC_fill.nhbelow, DEC_fill.nhandles, DEC_fill.nhren, DEC_fill.nband, DEC_fill.nnh1pos, DEC_fill.nobjs, DEC_fill.nobjok, DEC_fill.nnodes, DEC_fill.nprims, DEC_fill.nnren, DEC_fill.nnlow, DEC_fill.nnord, DEC_fill.nitems, DEC_fill.nssT, DEC_fill.nabs0a, DEC_fill.nabs0b, DEC_fill.ntok1, DEC_fill.npend, DEC_fill.nerrh, DEC_fill.nfiles, DEC_fill.narch, DEC_fill.nsizes, DEC_fill.nwired⟩ DEC_fill.nhost fun _ => rfl

end Host.Load.Run.Tpl
