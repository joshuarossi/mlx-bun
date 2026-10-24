import host.load.boot.States
set_option Elab.async false
set_option interpreter.prefer_native true
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Prompt

/- Chunk 87 subdivided as in `run/prompt/micro/M87`.
A native run from the boot only chooses the intermediate states. -/
boot_w_micro P 87, 2665 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]

end Host.Load.Run.Prompt
