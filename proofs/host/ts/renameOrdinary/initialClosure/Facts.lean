import host.ts.RuntimeClosureCheck
import host.ts.renameOrdinary.RankOriginNative
import host.ts.RenameRuntimeSourceCut
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.Ordinary.RankOrigin.InitialClosure
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem source_address_limit : input.next = 3126659 := by host_kernel_rfl
theorem source_table_limit : P.micro3275.S1.tab.length = 10 := by host_kernel_rfl
theorem control_closed : ClosureCheck.tree 3126659 10 (Encode.ctl input.ctl) = true := by host_kernel_rfl
theorem stack_closed : input.stack.all (fun f => ClosureCheck.tree 3126659 10 (Encode.frame f)) = true := by host_kernel_rfl
theorem jobs_closed : input.jobs.all (fun j => ClosureCheck.tree 3126659 10 (Encode.job j)) = true := by host_kernel_rfl
theorem stores_closed : ClosureCheck.tree 3126659 10 (Encode.stores input.stores) = true := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.RankOrigin.InitialClosure
