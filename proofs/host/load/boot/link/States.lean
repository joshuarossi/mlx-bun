import host.load.run.prompt.link.Abs
import host.load.boot.LinkCommand
set_option Elab.async false
namespace Host.Load.Run.Prompt.Link
set_option maxRecDepth 1000000

/-! The prompt route's link states for every prompt and unread readback suffix (`boot_link_states`). -/

boot_link_states Lq from Host.Load.Run.Prompt.Link.Lp 0 to 840

end Host.Load.Run.Prompt.Link
