import host.sim.compose.a4b.SetupCommonFrame
import host.sim.compose.NumHeap

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.SetupDrop
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Load.Run.Tpl

def σ : Map := eraseNum 10 (F64.ofNat 2048)
def writes : List Nat := List.range' 2673294 163

kernel_rfl oldWrites : PRE_setup_early_r0.s16.heap = Stage.setAll PRE_setup_early_r0.s6.heap
  (writes.filterMap fun a => (PRE_setup_early_r0.s16.heap.get a).map (a, ·))
kernel_rfl newWrites : PRE_g0b.s10.heap = Stage.setAll PRE_setup_early_r0.s6.heap
  (writes.filterMap fun a => (PRE_g0b.s10.heap.get a).map (a, ·))
kernel_rfl writesBound : writes.all (fun a => Nat.blt (a / 4096) (4 ^ 31)) = true
kernel_rfl heapImage : writes.map (fun a => PRE_setup_early_r0.s16.heap.get a) =
  writes.map (fun a => (PRE_g0b.s10.heap.get a).map σ.hobj)
kernel_rfl nextEq : PRE_setup_early_r0.s16.next = PRE_g0b.s10.next
kernel_rfl ctlEq : PRE_setup_early_r0.s16.ctl = σ.ctl PRE_g0b.s10.ctl
kernel_rfl stackEq : PRE_setup_early_r0.s16.stack = PRE_g0b.s10.stack.map σ.frame
kernel_rfl jobsEq : PRE_setup_early_r0.s16.jobs = PRE_g0b.s10.jobs.map σ.job
kernel_rfl storesEq : PRE_setup_early_r0.s16.stores = σ.stores PRE_g0b.s10.stores
kernel_rfl traceEq : PRE_setup_early_r0.s16.trace = PRE_g0b.s10.trace.map σ.event
kernel_rfl traceSame : PRE_setup_early_r0.s16.trace = PRE_g0b.s10.trace
kernel_rfl nativeEq : PRE_setup_early_r0.s16.ffi = PRE_g0b.s10.ffi
kernel_rfl nativeClosed : numClosedB 9 PRE_g0b.s10.ffi = true
kernel_rfl oldLen : PRE_setup_early_r0.S16.tab.length = 14
kernel_rfl newLen : PRE_g0b.S10.tab.length = 15
kernel_rfl tableImage : (List.range 14).all (fun j => decide
  (nth? PRE_setup_early_r0.S16.tab j = nth? PRE_g0b.S10.tab (Sim.skipNum 10 j))) = true

end Host.Ts.Sim.Compose.SetupDrop
