import host.sim.compose.a4b.vw15.sfx.VWBodyChain
import host.sim.template.a4pre_first_tail_x15_r0_suffix.m.B0
import host.sim.lin.Table
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

def bodyM : List (Nat × Q) := [(9, Q.L), (10, Q.n)]

kernel_rfl bodyGoodAll : (fwdRows.all fun r => goodLin r.ps (varsOf r.V bodyM) PRE_first_tail_x15_r0_suffix.OR) = true

theorem bodyGoodDrop {r : Row} {i : Cls.Inst} {ν : Nat → F64} (hr : r ∈ fwdRows) (hi : InRow r i)
    (hν : MapOk ν i bodyM) (d : Nat) : Good ν (List.drop d PRE_first_tail_x15_r0_suffix.OR) :=
  fun q hq => good_of_row (List.all_eq_true.mp bodyGoodAll r hr) hi hν q (List.mem_of_mem_drop hq)

end Host.Ts.Sim.Compose.VWFirst.VW15.Sfx
