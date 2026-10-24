import host.load.run.prompt.link.Abs
set_option Elab.async false
namespace Host.Load.Run.Prompt.Link
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
link_chunk_abs_eager Lp from Host.Load.Run.Prompt.Link.L using RoutePrompt.cxV 608
link_chunk_abs_eager Lp from Host.Load.Run.Prompt.Link.L using RoutePrompt.cxV 609
link_chunk_abs_eager Lp from Host.Load.Run.Prompt.Link.L using RoutePrompt.cxV 610
link_chunk_abs_eager Lp from Host.Load.Run.Prompt.Link.L using RoutePrompt.cxV 611
end Host.Load.Run.Prompt.Link
