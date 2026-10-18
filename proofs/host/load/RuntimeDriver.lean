import host.ts.RenameRetainedDriverStep
import host.mlx.NativeInventoryFrontends
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_source_step: source syntax cannot be printed"

/-- The load boundary registers original native source rules alongside the
retained TypeScript dispatcher. Selection uses only the actual source control,
heap kind and continuation; every selected equation and transport is checked. -/
elab "host_source_step " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let selected ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let s ← Term.elabTermEnsuringType s (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f))
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.call 3 then
      let address ← Parametric.Driver.field control.getAppArgs[0]! ``Val.obj 1 0
      let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
      let code ← whnf (← Parametric.Driver.field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
      if code.isAppOfArity ``Code.closure 4 then pure "host_retained_step"
      else
        let native ← whnf (← Parametric.Driver.field code ``Code.native 2 0)
        if native.isAppOfArity ``Native.ffi 1 then
          if (← whnf native.getAppArgs[0]!).isConstOf ``FfiN.toArrayBuffer then
            pure "host_retained_arrayBuffer"
          else throwError "host_source_step: unsupported original native source call"
        else throwError "host_source_step: unsupported original native source call"
    else if control.isAppOfArity ``Ctl.construct 3 then pure "host_retained_typedBuffer"
    else if control.isAppOfArity ``Ctl.ret 1 then
      let frame ← whnf (← Parametric.Driver.field (← mkAppM ``St.stack #[s]) ``List.cons 3 1)
      if frame.isAppOfArity ``Frame.l 1 then
        if (← whnf frame.getAppArgs[0]!).isAppOfArity ``LitF.spread 3 then pure "host_retained_shapeSpread"
        else pure "host_retained_step"
      else pure "host_retained_step"
    else pure "host_retained_step"
  Parametric.Driver.emit s!"{selected} {← printed f.raw}, {← printed s.raw} using {← printed initial.raw} to {← printed t.raw} using {← printed next.raw} as {name.getId}"

end Host.Ts.Owned.Annotated.Driver
