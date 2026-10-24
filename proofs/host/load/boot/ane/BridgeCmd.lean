import host.load.boot.Command
namespace Host.Load.Boot
open Lean Elab Command Meta Host.Ts Host.Mlx

/-! # The bridge at `loadDone`, in pieces

`replay` of the boot's whole create log in one kernel evaluation is too large, so it is checked in
pieces: `replayOnto b log` replays `log` (newest first) onto `b`, and `boot_ane_bridge [k₁, …]` names
the bridge after the oldest `kᵢ` creates (`aneB<i>`). The states are chosen by a native run of the boot
from `PromptStream.promptBoot` to `loadDone` (its trace's creates in order, as `FfiAne.ofTrace` decodes
them); each piece `replayOnto aneB<i> segᵢ = aneB<i+1>` is a kernel check, so a wrong choice fails it. -/

/-- `log` (newest first) replayed onto `b`. -/
def replayOnto (b : FfiAne.St) : BLog → FfiAne.St
  | [] => b
  | (n, args, share) :: r => FfiAne.create (replayOnto b r) n args share

theorem replay_onto : ∀ log : BLog, replay log = replayOnto FfiAne.St.empty log
  | [] => rfl
  | (n, args, share) :: r => congrArg (fun b => FfiAne.create b n args share) (replay_onto r)

theorem replayOnto_append (b : FfiAne.St) : ∀ l1 l2 : BLog, replayOnto b (l1 ++ l2) = replayOnto (replayOnto b l2) l1
  | [], _ => rfl
  | (n, args, share) :: l1, l2 => congrArg (fun x => FfiAne.create x n args share) (replayOnto_append b l1 l2)

/-- `replayOnto` over a log split at `a`: the older `drop a` first. -/
theorem replayOnto_split (b : FfiAne.St) (l : BLog) (a : Nat) :
    replayOnto b l = replayOnto (replayOnto b (l.drop a)) (l.take a) := by
  conv => lhs; rw [← List.take_append_drop a l]
  exact replayOnto_append b _ _

private def listE (ty : Lean.Expr) : List Lean.Expr → Lean.Expr
  | [] => mkApp (mkConst ``List.nil [.zero]) ty
  | x :: xs => mkApp3 (mkConst ``List.cons [.zero]) ty x (listE ty xs)

private def progE (p : FfiAne.Program) : Lean.Expr :=
  mkAppN (mkConst ``FfiAne.Program.mk)
    #[mkAppN (mkConst ``AneProgram.mk) #[toExpr p.prog.mil, toExpr p.prog.weights, toExpr p.prog.inputBytes,
        toExpr p.prog.outputBytes],
      toExpr p.ins, toExpr p.out, toExpr p.holders, toExpr p.pending, toExpr p.inLocked, toExpr p.outLocked]

/-- A bridge whose aliases, touches and log are the empty bridge's (creates change none of them). -/
private def bridgeE (b : FfiAne.St) : Lean.Expr :=
  let e := mkConst ``FfiAne.St.empty
  mkAppN (mkConst ``FfiAne.St.mk) #[toExpr b.surfaces, listE (mkConst ``FfiAne.Program) (b.programs.map progE),
    toExpr b.handles, toExpr b.active, mkApp (mkConst ``FfiAne.St.aliases) e, mkApp (mkConst ``FfiAne.St.touch) e,
    toExpr b.unscheduled, toExpr b.running, mkApp (mkConst ``FfiAne.St.log) e]

elab "boot_ane_bridge " "[" ks:num,* "]" : command => liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let ns ← getCurrNamespace
  let ks := (ks.getElems.map (·.getNat)).toList
  let some b0 := PromptStream.promptBoot | throwError "boot_ane_bridge: the boot failed"
  let some (s, _) := runFast Host.Load.ffi 28172201 b0 ⟨Decode.tab, []⟩
    | throwError "boot_ane_bridge: the run to loadDone is stuck"
  let mut b := FfiAne.St.empty
  let mut regions : List (Nat × Nat) := []
  let mut n := 0
  let mut out : Array FfiAne.St := #[]
  for e in s.trace.reverse do
    if nameEq e.sym chars!"mbane_program_create" then
      let share := match e.args with
        | [_, _, _, _, _, _, _, _, .extPtr r 0, _, _, _] => (regions.find? fun (x, _) => Nat.beq x r).map Prod.snd
        | _ => none
      regions := match e.ret with
        | .ptr r 0 => (r, n) :: regions
        | _ => regions
      b := FfiAne.create b n e.args share
      n := n + 1
      if ks.contains n then out := out.push b
  unless out.size == ks.length do throwError "boot_ane_bridge: {n} creates, not every count reached"
  for x in out do
    unless x.log.isEmpty && x.unscheduled.isEmpty && x.running.isEmpty && !x.active do
      throwError "boot_ane_bridge: a bridge state has effects"
  for (x, i) in out.toList.zipIdx do
    let name := ns ++ Lean.Name.mkSimple s!"aneB{i + 1}"
    addDecl (.defnDecl (mkDefinitionValEx name [] (mkConst ``FfiAne.St) (bridgeE x) (.regular 0) .safe [name]))
  logInfo m!"boot_ane_bridge: {n} creates; {out.size} states, {out.toList.map (·.programs.length)} programs"

end Host.Load.Boot
