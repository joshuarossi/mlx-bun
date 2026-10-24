import host.load.run.prompt.link.Abs
set_option Elab.async false
namespace Host.Load.Run.Prompt.Link
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
link_chunk_abs_eager Lp from Host.Load.Run.Prompt.Link.L using RoutePrompt.cxV 336
link_chunk_abs_eager Lp from Host.Load.Run.Prompt.Link.L using RoutePrompt.cxV 337
link_chunk_abs_eager Lp from Host.Load.Run.Prompt.Link.L using RoutePrompt.cxV 338
link_chunk_abs_eager Lp from Host.Load.Run.Prompt.Link.L using RoutePrompt.cxV 339
end Host.Load.Run.Prompt.Link
