import host.load.Micro
import host.ts.renameOrdinary.micro.streamed128.H66
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.P.Hot65
noncomputable def F : Host.Ts.Ffi := Host.Load.Run.Full.P.F
def ks : List Nat := [12800]
noncomputable def s0 := Host.Load.Run.Full.P.RestStream.micro0.s8320
noncomputable def s1 := Host.Load.Run.Full.P.RestStream.micro0.s8448
noncomputable def S0 := Host.Load.Run.Full.P.RestStream.micro0.S8320
noncomputable def S1 := Host.Load.Run.Full.P.RestStream.micro0.S8448
end Host.Load.Run.Full.P.Hot65
namespace Host.Load.Run.Full
host_micro_stream P.Hot65 0, 10
end Host.Load.Run.Full
