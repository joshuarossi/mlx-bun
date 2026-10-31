import host.load.boot.Ld
import host.sim.template.ShiftJS
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl ldMemo_get :
  (Host.Load.Run.Prompt.ldStT [] []).heap.get 4910 =
    some (.obj (objOf (Host.Load.Run.Prompt.ldStT [] []) 4910))
kernel_rfl ldMemo_empty :
  (objOf (Host.Load.Run.Prompt.ldStT [] []) 4910).kind = .map []

kernel_rfl ldPrompt_get :
  (Host.Load.Run.Prompt.ldStT [] []).heap.get 2665 =
    some (.obj (objOf (Host.Load.Run.Prompt.ldStT [] []) 2665))
kernel_rfl ldPrompt_empty :
  (objOf (Host.Load.Run.Prompt.ldStT [] []) 2665).kind = .array []

end Host.Load.Run.Tpl
