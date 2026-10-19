import host.load.RuntimeNamespacedDecodePlan1362
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
noncomputable def At1438.s0 := Region1362.s76
noncomputable def At1438.S0 := Region1362.S76
noncomputable def At1438.s1 := Host.Ts.finishBig At1438.s0 At1438.s0.ffi chars!"mlx_array_new" [] 0
noncomputable def At1438.S1 := At1438.S0
host_retained_arrayNew P.F, At1438.s0 using At1438.S0 to At1438.s1 using At1438.S1 as Null1438
host_derive_source_cuts P.F, At1438.s1 using At1438.S1 steps 25 as From1439
host_derive_source_cuts P.F, From1439.s25 using From1439.S25 steps 25 as From1464
host_derive_source_cuts P.F, From1464.s25 using From1464.S25 steps 25 as From1489
host_derive_source_cuts P.F, From1489.s25 using From1489.S25 steps 25 as From1514
host_derive_source_cuts P.F, From1514.s25 using From1514.S25 steps 10 as From1539
end Host.Load.Run.Full.Ordinary.NamespacedDecode
