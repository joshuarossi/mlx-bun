import host.sim.template.a4dec_clear.ENc_0
import host.sim.template.a4dec_clear.ENc_1
import host.sim.template.a4dec_clear.ENc_2
import host.sim.template.a4dec_clear.ENc_3
import host.sim.template.a4dec_clear.ENc_4
import host.sim.template.a4dec_clear.ENc_5
import host.sim.template.a4dec_clear.ENc_6
import host.sim.template.a4dec_clear.ENc_7
import host.sim.template.a4dec_clear.ENc_8
import host.sim.template.a4dec_clear.ENc_9
import host.sim.template.a4dec_clear.ENc_10
import host.sim.template.a4dec_clear.ENc_11
import host.sim.template.a4dec_clear.ENc_12
import host.sim.template.a4dec_clear.ENc_13
import host.sim.template.a4dec_clear.ENc_14
import host.sim.template.a4dec_clear.ENc_15
import host.sim.template.a4dec_clear.ENc_16
import host.sim.template.a4dec_clear.ENc_17
import host.sim.template.a4dec_clear.ENc_18
import host.sim.template.a4dec_clear.ENc_19
import host.sim.template.a4dec_clear.ENc_20
import host.sim.template.a4dec_clear.ENc_21
import host.sim.template.a4dec_clear.ENc_22
import host.sim.template.a4dec_clear.ENc_23
import host.sim.template.a4dec_clear.ENc_24
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clear.nhandles_end : ((((((((handlesOfA DEC_clear.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_clear.nhandles : (handlesOfA DEC_clear.X0).all (handleOK DEC_clear.σ DEC_clear.PE.lo DEC_clear.X0 DEC_clear.X1) = true :=
  all_take_drop 2000 DEC_clear.nhandles_0 (all_take_drop 2000 DEC_clear.nhandles_1 (all_take_drop 2000 DEC_clear.nhandles_2 (all_take_drop 2000 DEC_clear.nhandles_3 (all_take_drop 2000 DEC_clear.nhandles_4 (all_take_drop 2000 DEC_clear.nhandles_5 (all_take_drop 2000 DEC_clear.nhandles_6 (all_take_drop 2000 DEC_clear.nhandles_7 (all_of_nil DEC_clear.nhandles_end))))))))
kernel_rfl DEC_clear.nnodes_end : ((((((((PTrie.keysA DEC_clear.X0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_clear.nnodes : (PTrie.keysA DEC_clear.X0.nodes).all (nodeOKF DEC_clear.σ DEC_clear.PE DEC_clear.X0 DEC_clear.X1) = true :=
  all_take_drop 2000 DEC_clear.nnodes_0 (all_take_drop 2000 DEC_clear.nnodes_1 (all_take_drop 2000 DEC_clear.nnodes_2 (all_take_drop 2000 DEC_clear.nnodes_3 (all_take_drop 2000 DEC_clear.nnodes_4 (all_take_drop 2000 DEC_clear.nnodes_5 (all_take_drop 2000 DEC_clear.nnodes_6 (all_take_drop 2000 DEC_clear.nnodes_7 (all_of_nil DEC_clear.nnodes_end))))))))
kernel_rfl DEC_clear.nprims_end : ((((((((fullKeysF DEC_clear.PE DEC_clear.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000 = []
theorem DEC_clear.nprims : (fullKeysF DEC_clear.PE DEC_clear.X0).map (fun i => (DEC_clear.X1.nodes.get (DEC_clear.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (fullKeysF DEC_clear.PE DEC_clear.X0).map (fun i => (DEC_clear.X0.nodes.get i).map fun nd => DEC_clear.σ.prim nd.prim) :=
  map_take_drop 2000 DEC_clear.nprims_0 (map_take_drop 2000 DEC_clear.nprims_1 (map_take_drop 2000 DEC_clear.nprims_2 (map_take_drop 2000 DEC_clear.nprims_3 (map_take_drop 2000 DEC_clear.nprims_4 (map_take_drop 2000 DEC_clear.nprims_5 (map_take_drop 2000 DEC_clear.nprims_6 (map_take_drop 2000 DEC_clear.nprims_7 (map_of_nil DEC_clear.nprims_end))))))))

/-- **The native shift of chain `DEC_clear`'s end** on the load-world projections. -/
theorem DEC_clear.nshift : NShift DEC_clear.PE DEC_clear.S0.tab.length DEC_clear.σ (Host.Load.Layers.toLoad DEC_clear.s0.ffi)
    (Host.Load.Layers.toLoad DEC_clear.s11.ffi) := by
  rw [DEC_clear.S0_len]
  exact nshift_of ⟨rfl, rfl, rfl, DEC_clear.nnh0, DEC_clear.nnh1, DEC_clear.nnn0, DEC_clear.nnn1, DEC_clear.nlo, DEC_clear.ncnt, DEC_clear.nnband, DEC_clear.nhbelow, DEC_clear.nhandles, DEC_clear.nhren, DEC_clear.nband, DEC_clear.nnh1pos, DEC_clear.nobjs, DEC_clear.nobjok, DEC_clear.nnodes, DEC_clear.nprims, DEC_clear.nnren, DEC_clear.nnlow, DEC_clear.nnord, DEC_clear.nitems, DEC_clear.nssT, DEC_clear.nabs0a, DEC_clear.nabs0b, DEC_clear.ntok1, DEC_clear.npend, DEC_clear.nerrh, DEC_clear.nfiles, DEC_clear.narch, DEC_clear.nsizes, DEC_clear.nwired⟩ DEC_clear.nhost fun _ => rfl

end Host.Load.Run.Tpl
