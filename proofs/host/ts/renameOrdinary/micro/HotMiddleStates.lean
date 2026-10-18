import host.load.Micro
import host.ts.renameOrdinary.micro.hot65.H8
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.P.HotMiddle
noncomputable def F : Host.Ts.Ffi := Host.Load.Run.Full.P.F
def ks : List Nat := [2560]
noncomputable def s0 := Host.Load.Run.Full.P.Hot65.micro0.s768
noncomputable def s1 := Host.Load.Run.Full.P.Hot65.micro0.s1024
noncomputable def S0 := Host.Load.Run.Full.P.Hot65.micro0.S768
noncomputable def S1 := Host.Load.Run.Full.P.Hot65.micro0.S1024
end Host.Load.Run.Full.P.HotMiddle
namespace Host.Load.Run.Full
host_micro_stream P.HotMiddle 0, 1
end Host.Load.Run.Full
