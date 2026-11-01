import host.sim.template.a4pre_first_tail_x6_r0_suffix.m.B0
import host.sim.template.BootEq
import host.sim.Chunk
import host.sim.template.Bridges

section -- TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_suffix.bodyK0F from PRE_first_tail_x6_r0_suffix.s0 to PRE_first_tail_x6_r0_suffix.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_suffix.F (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.ks 0).getD 0) PRE_first_tail_x6_r0_suffix.s0 PRE_first_tail_x6_r0_suffix.S0) =
    fun _ _ => some (PRE_first_tail_x6_r0_suffix.s1, PRE_first_tail_x6_r0_suffix.S1)
theorem PRE_first_tail_x6_r0_suffix.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_suffix.F (PRE_first_tail_x6_r0_suffix.bodyOkB bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.ks 0).getD 0) PRE_first_tail_x6_r0_suffix.s0 PRE_first_tail_x6_r0_suffix.S0) =
    fun _ _ => some (PRE_first_tail_x6_r0_suffix.s1, PRE_first_tail_x6_r0_suffix.S1) :=
  runOk_fun_of_runOkS Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok PRE_first_tail_x6_r0_suffix.bodyK0F
end Host.Load.Run.Tpl
end

section -- TypedK4
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_suffix.bodyK4F from PRE_first_tail_x6_r0_suffix.s4 to PRE_first_tail_x6_r0_suffix.s5 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_suffix.F (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.ks 4).getD 0) PRE_first_tail_x6_r0_suffix.s4 PRE_first_tail_x6_r0_suffix.S4) =
    fun _ _ => some (PRE_first_tail_x6_r0_suffix.s5, PRE_first_tail_x6_r0_suffix.S5)
theorem PRE_first_tail_x6_r0_suffix.bodyK4 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_suffix.F (PRE_first_tail_x6_r0_suffix.bodyOkB bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.ks 4).getD 0) PRE_first_tail_x6_r0_suffix.s4 PRE_first_tail_x6_r0_suffix.S4) =
    fun _ _ => some (PRE_first_tail_x6_r0_suffix.s5, PRE_first_tail_x6_r0_suffix.S5) :=
  runOk_fun_of_runOkS Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok PRE_first_tail_x6_r0_suffix.bodyK4F
end Host.Load.Run.Tpl
end

section -- TypedK7
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x6_r0_suffix.bodyK7F from PRE_first_tail_x6_r0_suffix.s7 to PRE_first_tail_x6_r0_suffix.s8 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x6_r0_suffix.F (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.ks 7).getD 0) PRE_first_tail_x6_r0_suffix.s7 PRE_first_tail_x6_r0_suffix.S7) =
    fun _ _ => some (PRE_first_tail_x6_r0_suffix.s8, PRE_first_tail_x6_r0_suffix.S8)
theorem PRE_first_tail_x6_r0_suffix.bodyK7 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x6_r0_suffix.F (PRE_first_tail_x6_r0_suffix.bodyOkB bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.ks 7).getD 0) PRE_first_tail_x6_r0_suffix.s7 PRE_first_tail_x6_r0_suffix.S7) =
    fun _ _ => some (PRE_first_tail_x6_r0_suffix.s8, PRE_first_tail_x6_r0_suffix.S8) :=
  runOk_fun_of_runOkS Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok PRE_first_tail_x6_r0_suffix.bodyK7F
end Host.Load.Run.Tpl
end

section -- TypedSeg0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_suffix.bodyRunSeg0 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_suffix.F (PRE_first_tail_x6_r0_suffix.bodyOkB bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.ks 0).getD 0) PRE_first_tail_x6_r0_suffix.s0 PRE_first_tail_x6_r0_suffix.S0 = some (PRE_first_tail_x6_r0_suffix.s1, PRE_first_tail_x6_r0_suffix.S1) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_suffix.bodyK0 bytes) rows)
end Host.Load.Run.Tpl
end

section -- TypedSeg1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_suffix.bodyRunSeg1 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_suffix.F (PRE_first_tail_x6_r0_suffix.bodyOkB bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.ks 4).getD 0) PRE_first_tail_x6_r0_suffix.s4 PRE_first_tail_x6_r0_suffix.S4 = some (PRE_first_tail_x6_r0_suffix.s5, PRE_first_tail_x6_r0_suffix.S5) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_suffix.bodyK4 bytes) rows)
end Host.Load.Run.Tpl
end

section -- TypedSeg2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x6_r0_suffix.bodyRunSeg2 (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x6_r0_suffix.F (PRE_first_tail_x6_r0_suffix.bodyOkB bytes rows) ((nth? PRE_first_tail_x6_r0_suffix.ks 7).getD 0) PRE_first_tail_x6_r0_suffix.s7 PRE_first_tail_x6_r0_suffix.S7 = some (PRE_first_tail_x6_r0_suffix.s8, PRE_first_tail_x6_r0_suffix.S8) :=
  (congrFun (congrFun PRE_first_tail_x6_r0_suffix.bodyK7 bytes) rows)
end Host.Load.Run.Tpl
end

section -- TypedSteps0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x6_r0_suffix.bodyStepA1 from PRE_first_tail_x6_r0_suffix.s1 to PRE_first_tail_x6_r0_suffix.s2 : interpS (step PRE_first_tail_x6_r0_suffix.F PRE_first_tail_x6_r0_suffix.s1).run PRE_first_tail_x6_r0_suffix.S1 = some (PRE_first_tail_x6_r0_suffix.s2, PRE_first_tail_x6_r0_suffix.S2)
boot_rfl PRE_first_tail_x6_r0_suffix.bodyStepA2 from PRE_first_tail_x6_r0_suffix.s5 to PRE_first_tail_x6_r0_suffix.s6 : interpS (step PRE_first_tail_x6_r0_suffix.F PRE_first_tail_x6_r0_suffix.s5).run PRE_first_tail_x6_r0_suffix.S5 = some (PRE_first_tail_x6_r0_suffix.s6, PRE_first_tail_x6_r0_suffix.S6)
boot_rfl PRE_first_tail_x6_r0_suffix.bodyPatchB2 from PRE_first_tail_x6_r0_suffix.s6 to PRE_first_tail_x6_r0_suffix.s7 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_first_tail_x6_r0_suffix.s6 PRE_first_tail_x6_r0_suffix.S6 (.var 9)) = some (PRE_first_tail_x6_r0_suffix.s7, PRE_first_tail_x6_r0_suffix.S7)
end Host.Load.Run.Tpl
end
