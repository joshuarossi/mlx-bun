import host.sim.template.a4eos_cut.H0
import host.sim.template.a4eos_cut.OkB
import host.sim.compose.a4b.GraphStart
import host.sim.compose.Seg
import host.sim.template.EndGen
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Compose Host.Ts.Sim.Template Host.Ts.Sim.Full
open Host.Load.Run.Prompt

kernel_rfl EOSCut.start_exact : EOSCut.s0 = DEC.s0
kernel_rfl EOSCut.tab_exact : EOSCut.S0.tab = DEC.tab0
kernel_rfl EOSCut.oracle_exact : EOSCut.S0.oracle = EOSCut.O
kernel_rfl EOSCut.oracle2 : EOSCut.S2.oracle = []
kernel_rfl EOSCut.oracle3 : EOSCut.S3.oracle = []
kernel_rfl EOSCut.oracle4 : EOSCut.S4.oracle = []
kernel_rfl EOSCut.okA0 : EOSCut.okB0 EOSCut.s0 EOSCut.S0 = true
kernel_rfl EOSCut.okP : EOSCut.okB0 EOSCut.s1 EOSCut.S1 = true
kernel_rfl EOSCut.haltP : isHalt EOSCut.s1.ctl = false
kernel_rfl EOSCut.ctlA : EOSCut.s2.ctl = .ret (.obj 2673448)
noncomputable def EOSCut.accA : List Val := match EOSCut.s2.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def EOSCut.envA : Env := match EOSCut.s2.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def EOSCut.fsA : List Frame := EOSCut.s2.stack.drop 1
kernel_rfl EOSCut.stackA : EOSCut.s2.stack = .l (.spread EOSCut.accA [] EOSCut.envA) :: EOSCut.fsA
kernel_rfl EOSCut.roomA_check : Nat.blt (EOSCut.s2.next + margin) Sim.bound = true
kernel_rfl EOSCut.arrA : (EOSCut.s2.heap.get aArrayProto).isSome = true
kernel_rfl EOSCut.newA : EOSCut.s2.next = 3123590
kernel_rfl EOSCut.okB0_after : EOSCut.okB EOSCut.s3 EOSCut.S3 = true
noncomputable def EOSCut.vF : Val := match EOSCut.s4.ctl with
  | .halt (.normal v) => v
  | _ => .undef
kernel_rfl EOSCut.haltF : EOSCut.s4.ctl = .halt (.normal EOSCut.vF)
kernel_rfl EOSCut.emit_get : EOSCut.s4.heap.get 12504 = some (.obj (objOf EOSCut.s4 12504))
kernel_rfl EOSCut.emit_kind : (objOf EOSCut.s4 12504).kind = .array (arrOf DEC.s0 12504 ++ [])
kernel_rfl EOSCut.cell : EOSCut.s4.cell? 2590 = some (some (.obj 12504))
noncomputable def EOSCut.gF : Nat := match EOSCut.s4.cell? 2589 with
  | some (some (.obj g)) => g
  | _ => 0
noncomputable def EOSCut.wF : Nat := match ownW EOSCut.s4 (.obj EOSCut.gF) chars!"stats" with
  | some (.obj w) => w
  | _ => 0
kernel_rfl EOSCut.stop_cell : EOSCut.s4.cell? 2589 = some (some (.obj EOSCut.gF))
kernel_rfl EOSCut.stop_gen_frame : wideP EOSCut.gF = none
kernel_rfl EOSCut.stop_stats : ownW EOSCut.s4 (.obj EOSCut.gF) chars!"stats" = some (.obj EOSCut.wF)
kernel_rfl EOSCut.stop_stats_frame : wideP EOSCut.wF = none
kernel_rfl EOSCut.stop_reason : ownW EOSCut.s4 (.obj EOSCut.wF) chars!"finishReason" = some (.str chars!"stop")

theorem EOSCut.stop (b0 : BSt) (NB : Nat) : StopAtW (Wd := fullWorldFb b0 NB) wideP addrPrompt EOSCut.s4 :=
  ⟨by decide, EOSCut.gF, EOSCut.wF, EOSCut.stop_cell, EOSCut.stop_gen_frame,
    EOSCut.stop_stats, EOSCut.stop_stats_frame, EOSCut.stop_reason⟩

theorem EOSCut.exitOk : ExitOk EOSCut.O := by
  unfold ExitOk
  decide +kernel
kernel_rfl EOSCut.read : (mlxOf EOSCut.s4.ffi).items.get 20157 = some (.ref 79)
kernel_rfl EOSCut.read_present : ((mlxOf EOSCut.s4.ffi).nodes.get 20157).isSome = true
kernel_rfl EOSCut.tokens : (mlxOf EOSCut.s4.ffi).tokens = []
kernel_rfl EOSCut.token_var : nth? EOSCut.S4.tab 79 = some (.var 14)
kernel_rfl EOSCut.actualRun : runS EOSCut.F 929 DEC.s0 EOSCut.S0 = some (EOSCut.s4, EOSCut.S4)
kernel_rfl EOSCut.notHalt928 : (runS EOSCut.F 928 DEC.s0 EOSCut.S0).map (fun p => isHalt p.1.ctl) = some false
kernel_rfl EOSCut.accepted393 : (runOk EOSCut.F EOSCut.okB0 393 DEC.s0 EOSCut.S0).isSome = true
kernel_rfl EOSCut.rejected394 : runOk EOSCut.F EOSCut.okB0 394 DEC.s0 EOSCut.S0 = none
end Host.Load.Run.Tpl
