import host.ts.RenameRetainedDriverStep
import host.mlx.NativeInventoryFrontends
import host.mlx.NativeVectorInventoryFrontend
import host.mlx.NativeNullInventoryFrontend
import host.mlx.NativeConcatInventoryFrontend
import host.mlx.NativeVectorFreeFrontend
import host.mlx.NativeMetadataFrontend
import host.mlx.NativeIntegerConversionFrontend
import host.mlx.NativeNumberConversionFrontend
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
          let builtin ← whnf native.getAppArgs[0]!
          if builtin.isConstOf ``FfiN.toArrayBuffer then
            pure "host_retained_arrayBuffer"
          else if builtin.isConstOf ``FfiN.ptr then pure "host_retained_pointer"
          else if builtin.isConstOf ``FfiN.readU64 then pure "host_retained_readU64"
          else if builtin.isConstOf ``FfiN.symbol then
            let captures ← whnf code.getAppArgs[1]!
            let symbol ← Parametric.Driver.field (← Parametric.Driver.field captures ``List.cons 3 1) ``Val.str 1 0
            if ← isDefEq symbol (toExpr chars!"mlx_vector_array_new_data") then pure "host_retained_vectorData"
            else if ← isDefEq symbol (toExpr chars!"mlx_array_new") then pure "host_retained_arrayNew"
            else if ← isDefEq symbol (toExpr chars!"mlx_concatenate_axis") then pure "host_retained_concat"
            else if ← isDefEq symbol (toExpr chars!"mlx_vector_array_free") then pure "host_retained_vectorFree"
            else if ← isDefEq symbol (toExpr chars!"mlx_array_ndim") then pure "host_retained_metadata"
            else if ← isDefEq symbol (toExpr chars!"mlx_array_shape") then pure "host_retained_metadata"
            else throwError "host_source_step: unsupported original native symbol"
          else throwError "host_source_step: unsupported original native source call"
        else if native.isAppOfArity ``Native.arr 1 then
          if (← whnf native.getAppArgs[0]!).isConstOf ``ArrN.push then
            pure "host_retained_arrayPush"
          else throwError "host_source_step: unsupported original native source call"
        else if native.isAppOfArity ``Native.num 1 then
          if (← whnf native.getAppArgs[0]!).isConstOf ``NumN.bigint then pure "host_retained_bigint"
          else if (← whnf native.getAppArgs[0]!).isConstOf ``NumN.number then pure "host_retained_number"
          else throwError "host_source_step: unsupported original numeric native call"
        else throwError "host_source_step: unsupported original native source call"
    else if control.isAppOfArity ``Ctl.construct 3 then
      let address ← Parametric.Driver.field control.getAppArgs[0]! ``Val.obj 1 0
      let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,address]) ``Option.some 2 1
      let code ← whnf (← Parametric.Driver.field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
      if code.isAppOfArity ``Code.klass 4 then return "host_retained_constructor"
      let values ← whnf control.getAppArgs[1]!
      let value ← whnf (← Parametric.Driver.field values ``List.cons 3 1)
      if value.isAppOfArity ``Val.obj 1 then
        let object ← whnf (← mkAppM ``St.obj? #[s,value.getAppArgs[0]!])
        if object.isAppOfArity ``Option.some 2 then
          let kind ← whnf (← mkAppM ``Obj.kind #[object.getAppArgs[1]!])
          if kind.isAppOfArity ``Kind.array 1 then
            let elements ← whnf kind.getAppArgs[0]!
            if elements.isAppOfArity ``List.cons 3 then
              let head ← whnf elements.getAppArgs[1]!
              if head.isAppOfArity ``Val.big 1 then
                if (← whnf elements.getAppArgs[2]!).isAppOfArity ``List.nil 1 then
                  if ← isDefEq head.getAppArgs[0]! (toExpr (0 : Int)) then return "host_retained_nullTyped"
            return "host_retained_handleTyped"
      pure "host_retained_typedBuffer"
    else if control.isAppOfArity ``Ctl.ret 1 then
      let frame ← whnf (← Parametric.Driver.field (← mkAppM ``St.stack #[s]) ``List.cons 3 1)
      if frame.isAppOfArity ``Frame.l 1 then
        if (← whnf frame.getAppArgs[0]!).isAppOfArity ``LitF.spread 3 then pure "host_retained_shapeSpread"
        else pure "host_retained_step"
      else pure "host_retained_step"
    else pure "host_retained_step"
  Parametric.Driver.emit s!"{selected} {← printed f.raw}, {← printed s.raw} using {← printed initial.raw} to {← printed t.raw} using {← printed next.raw} as {name.getId}"

end Host.Ts.Owned.Annotated.Driver
