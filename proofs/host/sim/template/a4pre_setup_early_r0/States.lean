import host.sim.template.Chain
import host.sim.template.FullWorld
import host.load.boot.Ld
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl

/-! Prefill row `setup_early.r0` from the fixed loadDone template. The prompt array is framed;
its length is variable 9, with representative value 4 used only by the native state chooser. -/

open Lean Host.Ts Host.Ts.Sim.Template Host.Load Host.Mlx in
/-- This setup prefix keeps the boot bridge. Only the chooser's serialization uses its
canonical expression; the generated start equality and full-world runs still check it. -/
def PRE_setup_early_r0.ser (p : FS) : Stream.GenM Lean.Expr := do
  let e ← serFull ((⟨p.1.1.base, FfiAne.St.empty⟩, p.1.2), p.2)
  let bridge := mkApp (mkConst ``Host.Load.Boot.replay) (mkConst ``Host.Load.Run.Prompt.P.oblog2818)
  return e.replace fun e =>
    if e.isAppOfArity ``Ane.ASt.mk 2 then
      some (mkApp2 (mkConst ``Ane.ASt.mk) e.getAppArgs[0]! bridge)
    else none

def PRE_setup_early_r0.nativeWorld : Host.Ts.Sim.Template.TWorld Host.Load.Layers.full :=
  { Host.Ts.Sim.Template.fullWorld with ser := PRE_setup_early_r0.ser }

noncomputable def PRE_setup_early_r0.input := Host.Load.Run.Prompt.ldStT [] []
noncomputable def PRE_setup_early_r0.inputLoad := Host.Load.Run.Prompt.P.at2818 [] []
def PRE_setup_early_r0.inputSrv : Host.Ts.SSrv :=
  ⟨[.var 0, .var 1, .var 2, .var 3, .var 4, .var 5, .var 6, .var 7, .var 8], []⟩
kernel_rfl PRE_setup_early_r0.inputSrv_eq : PRE_setup_early_r0.inputSrv = ⟨Host.Load.Decode.tab, []⟩

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native false in
tpl_chain PRE_setup_early_r0 from PRE_setup_early_r0.inputLoad, PRE_setup_early_r0.inputSrv : "/Users/joshrossi/Code/mlx-bun-proof-m1max/proofs/host/sim/template/a4pre_setup_early_r0/plan.json" («world» := Host.Load.Run.Tpl.PRE_setup_early_r0.nativeWorld)

end Host.Load.Run.Tpl
