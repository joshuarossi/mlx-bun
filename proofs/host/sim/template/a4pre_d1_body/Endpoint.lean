import host.sim.template.a4pre_d1_body.D4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template

kernel_rfl D1Body.returned : D1Body.s155.ctl = .ret (.obj 2826766)
kernel_rfl D1Body.caller : D1Body.s155.stack = D1Call.s1.stack
kernel_rfl D1Body.stackCount : D1Body.s155.stack.length = 61
kernel_rfl D1Body.top : Host.Ts.Sim.Compose.noRetBlock D1Body.s155 = true
kernel_rfl D1Body.heapCounter : D1Body.s155.next = 2826779
kernel_rfl D1Body.handleCounter : (mlxOf D1Body.s155.ffi).next = 21986
kernel_rfl D1Body.nodeCounter : (mlxOf D1Body.s155.ffi).nnext = 17764
kernel_rfl D1Body.tableCount : D1Body.S155.tab.length = 3190
kernel_rfl D1Body.outputHandle :
  D1Endpoint.privateVal (objOf D1Body.s155 2826766) (chars!"handle") = some (.big 21985)
kernel_rfl D1Body.outputNode : (mlxOf D1Body.s155.ffi).arrs.get 21985 = some 17763
kernel_rfl D1Body.bridge : bridgeOf D1Body.s155.ffi = bridgeOf D1Call.s1.ffi

end Host.Load.Run.Tpl
