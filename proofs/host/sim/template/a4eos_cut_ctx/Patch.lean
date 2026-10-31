import host.sim.template.a4eos_cut_ctx.LenH0
import host.sim.template.Bridges
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Lean Meta Elab Command

def EOSCutCtx.promptLen : SymE := .bin .sub (.bin .sub (.var 9) (.var 10)) litOne
noncomputable def EOSCutCtx.patched : St EOSCutCtxLen.F.S × SSrv :=
  Bridge.lenPatch EOSCutCtxLen.s1 EOSCutCtxLen.S1 EOSCutCtx.promptLen

private partial def patchData (native : Lean.Expr) (e : Lean.Expr) :
    StateT (Std.HashMap Lean.Expr Lean.Expr) MetaM Lean.Expr := do
  if e == native || e.isConst || e.isLit || e.isAppOfArity ``OfNat.ofNat 3 ||
      e.isAppOfArity ``Char.ofNat 1 then return e
  if let some r := (← get)[e]? then return r
  let original := e
  let e ← whnf e
  let result ← match e.getAppFn with
    | .const name _ =>
      match ← getConstInfo name with
      | .ctorInfo c =>
        let mut args := e.getAppArgs
        for i in [c.numParams:args.size] do
          unless ← isProp (← inferType args[i]!) do
            args := args.set! i (← patchData native args[i]!)
        pure (mkAppN e.getAppFn args)
      | _ => pure e
    | _ => pure e
  modify fun cache => cache.insert original result
  return result

elab "eos_cut_len_patch" : command => liftTermElabM do
  let s := mkConst ``EOSCutCtxLen.s1
  let native ← mkAppM ``St.ffi #[s]
  let state ← whnf (← mkAppM ``Prod.fst #[mkConst ``EOSCutCtx.patched])
  let mut args := state.getAppArgs
  let aux ← whnf args[5]!
  args := args.set! 5 (mkAppN aux.getAppFn (aux.getAppArgs.set! 2 native))
  let (state, cache) ← (patchData native (mkAppN state.getAppFn args)).run {}
  let server ← (patchData native (← whnf (← mkAppM ``Prod.snd #[mkConst ``EOSCutCtx.patched]))).run' cache
  let declare (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
    addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
  declare ((← getCurrNamespace) ++ `EOSCutCtx.start) (← inferType s) state
  declare ((← getCurrNamespace) ++ `EOSCutCtx.inputSrv) (mkConst ``SSrv) server

eos_cut_len_patch
kernel_rfl EOSCutCtx.patch_exact : Bridge.lenPatch EOSCutCtxLen.s1 EOSCutCtxLen.S1 EOSCutCtx.promptLen =
    (EOSCutCtx.start, EOSCutCtx.inputSrv)
end Host.Load.Run.Tpl
