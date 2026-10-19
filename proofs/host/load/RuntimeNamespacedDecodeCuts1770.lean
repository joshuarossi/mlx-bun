import host.load.RuntimeNamespacedDecodeCuts1678
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
noncomputable def At1769.s0 := From1753.s16
noncomputable def At1769.S0 := From1753.S16
noncomputable def At1769.s1 := Host.Ts.finishBig At1769.s0 At1769.s0.ffi chars!"mlx_array_new" [] 0
noncomputable def At1769.S1 := At1769.S0
host_retained_arrayNew P.F, At1769.s0 using (At1769.S0.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to At1769.s1 using (At1769.S1.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Null1769
host_derive_source_cuts P.F, At1769.s1 using At1769.S1 steps 25 as From1770
host_derive_source_cuts P.F, From1770.s25 using From1770.S25 steps 25 as From1795
host_derive_source_cuts P.F, From1795.s25 using From1795.S25 steps 25 as From1820
host_derive_source_cuts P.F, From1820.s25 using From1820.S25 steps 11 as From1845
end Host.Load.Run.Full.Ordinary.NamespacedDecode
