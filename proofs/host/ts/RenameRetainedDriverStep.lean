import host.ts.RenameRuntimeDriverRetained
import host.ts.RenameRuntimeDriverClosure
import host.ts.RenameRuntimeDriverHeapReads
import host.ts.RenameRuntimeDriverPatterns
import host.ts.RenameRuntimeDriverMethods
import host.ts.RenameRuntimeDriverGlobal
import host.ts.RenameRuntimeDriverArrays
import host.ts.RenameRuntimeDriverAllocations
import host.ts.RenameRuntimeDriverUndefined
import host.ts.RenameRuntimeDriverBranch
import host.ts.RenameRuntimeDriverObjects
import host.ts.RenameRuntimeDriverArrayLength
import host.ts.RenameRuntimeDriverFor
import host.ts.RenameRuntimeDriverClosedComparison
import host.ts.RenameRuntimeDriverIndex
import host.ts.RenameRuntimeDriverObjectShorthand
import host.ts.RenameRuntimeDriverUpdate
import host.ts.RenameRuntimeDriverArrayPush
import host.ts.RenameRuntimeDriverExpressionBody
import host.ts.RenameRuntimeDriverGetter
import host.ts.RenameRuntimeDriverTry
import host.ts.RenameRuntimeDriverMissingRead
import host.ts.RenameRuntimeDriverConstructors
import host.ts.RenameRuntimeDriverUndefinedBranch
import host.ts.RenameRuntimeDriverPrivateFields
import host.ts.RenameRuntimeDriverConstructorReturn
import host.ts.RenameRuntimeDriverFinally
import host.ts.RenameRuntimeDriverArraySpreadEntry
import host.ts.RenameRuntimeDriverPrivateAssign
import host.ts.RenameRuntimeDriverPrivateObjectRead
import host.ts.RenameRuntimeDriverObjectVariable
import host.ts.RenameRuntimeDriverNullishAssignment
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_retained_step: source syntax cannot be printed"

private def ordinaryGetter (state key address : Lean.Expr) : Nat → MetaM Bool
  | 0 => pure false
  | fuel+1 => do
    let found ← whnf (← mkAppM ``St.obj? #[state,address])
    unless found.isAppOfArity ``Option.some 2 do return false
    let object := found.getAppArgs[1]!
    unless (← whnf (← mkAppM ``Obj.kind #[object])).isConstOf ``Kind.ordinary do return false
    let property ← whnf (← mkAppM ``findProp #[key,← mkAppM ``Obj.props #[object]])
    if property.isAppOfArity ``Option.some 2 then
      let property ← whnf property.getAppArgs[1]!
      unless property.isAppOfArity ``PropV.acc 3 do return false
      return (← whnf property.getAppArgs[0]!).isAppOfArity ``Val.obj 1 &&
        (← whnf property.getAppArgs[2]!).isConstOf ``Bool.false
    let proto ← whnf (← mkAppM ``Obj.proto #[object])
    if proto.isAppOfArity ``Val.obj 1 then ordinaryGetter state key proto.getAppArgs[0]! fuel
    else pure false

private def ordinaryMissing (state key address : Lean.Expr) : Nat → MetaM Bool
  | 0 => pure false
  | fuel+1 => do
    let found ← whnf (← mkAppM ``St.obj? #[state,address])
    unless found.isAppOfArity ``Option.some 2 do return false
    let object := found.getAppArgs[1]!
    unless (← whnf (← mkAppM ``Obj.kind #[object])).isConstOf ``Kind.ordinary do return false
    unless (← whnf (← mkAppM ``findProp #[key,← mkAppM ``Obj.props #[object]])).isAppOfArity ``Option.none 1 do
      return false
    let proto ← whnf (← mkAppM ``Obj.proto #[object])
    if proto.isConstOf ``Val.null then pure true
    else if proto.isAppOfArity ``Val.obj 1 then ordinaryMissing state key proto.getAppArgs[0]! fuel
    else pure false

/-- Source-selected retained host rules. Native dispatch is registered by its
owning frontend. An unsupported source case is rejected before a target result
or a new operand meaning is selected. -/
elab "host_retained_step " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let selected ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.ev 2 then
      let expression ← whnf control.getAppArgs[0]!
      if expression.isAppOfArity ``Expr.id 1 then
        let address ← whnf (← mkAppM ``lookupEnv #[expression.getAppArgs[0]!,control.getAppArgs[1]!])
        if address.isAppOfArity ``Option.none 1 then pure "host_retained_global"
        else
          if address.isAppOfArity ``Option.some 2 then
            let cell ← whnf (← mkAppM ``St.cell? #[s,address.getAppArgs[1]!])
            if cell.isAppOfArity ``Option.some 2 then
              let value ← whnf cell.getAppArgs[1]!
              if value.isAppOfArity ``Option.some 2 then
                if (← whnf value.getAppArgs[1]!).isAppOfArity ``Val.obj 1 then
                  return "host_retained_object_variable"
          pure "host_retained_pure_step"
      else if expression.isConstOf ``Expr.this || expression.isAppOfArity ``Expr.priv 3 then
        pure "host_retained_heap_read"
      else if expression.isAppOfArity ``Expr.array 1 then
        let elements ← whnf expression.getAppArgs[0]!
        if elements.isAppOfArity ``List.cons 3 then
          if (← whnf elements.getAppArgs[1]!).isAppOfArity ``Elem.spread 1 then
            return "host_retained_array_spread_entry"
        pure "host_retained_array"
      else if expression.isAppOfArity ``Expr.arrow 1 then pure "host_retained_allocation"
      else if expression.isAppOfArity ``Expr.object 1 then pure "host_retained_object"
      else if expression.isAppOfArity ``Expr.update 3 then pure "host_retained_update"
      else if expression.isAppOfArity ``Expr.assign 3 then
        let pattern ← whnf expression.getAppArgs[1]!
        if pattern.isAppOfArity ``Pat.expr 1 then
          if (← whnf pattern.getAppArgs[0]!).isAppOfArity ``Expr.priv 3 then
            return "host_retained_private_assign"
        pure "host_retained_pure_step"
      else pure "host_retained_pure_step"
    else if control.isAppOfArity ``Ctl.ex 2 then
      let statement ← whnf control.getAppArgs[0]!
      if statement.isAppOfArity ``Stmt.for_ 4 then pure "host_retained_for"
      else if statement.isAppOfArity ``Stmt.try_ 3 then pure "host_retained_try"
      else pure "host_retained_pure_step"
    else if control.isAppOfArity ``Ctl.bind 5 then pure "host_retained_pattern"
    else if control.isAppOfArity ``Ctl.call 3 then
      let a ← Parametric.Driver.field control.getAppArgs[0]! ``Val.obj 1 0
      let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
      let code ← whnf (← Parametric.Driver.field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
      unless code.isAppOfArity ``Code.closure 4 do
        throwError "host_retained_step: native source call requires native retained frontend"
      pure "host_retained_closure"
    else if control.isAppOfArity ``Ctl.abr 1 then
      let abrupt ← whnf control.getAppArgs[0]!
      if abrupt.isAppOfArity ``Abrupt.ret 1 then
        if (← whnf abrupt.getAppArgs[0]!).isAppOfArity ``Val.obj 1 then
          let frame ← whnf (← Parametric.Driver.field (← mkAppM ``St.stack #[s]) ``List.cons 3 1)
          if frame.isAppOfArity ``Frame.s 1 then
            let statement ← whnf frame.getAppArgs[0]!
            if statement.isAppOfArity ``StmtF.try_ 3 then
              if (← whnf statement.getAppArgs[1]!).isAppOfArity ``Option.some 2 then return "host_retained_finally"
      pure "host_retained_pure_step"
    else if control.isAppOfArity ``Ctl.ret 1 then
      let frame ← whnf (← Parametric.Driver.field (← mkAppM ``St.stack #[s]) ``List.cons 3 1)
      let inner ← if frame.getAppArgs.size == 1 then whnf frame.getAppArgs[0]! else pure frame
      if frame.isAppOfArity ``Frame.c 1 && inner.isAppOfArity ``CallF.member 5 then
        pure "host_retained_method"
      else if frame.isAppOfArity ``Frame.c 1 && inner.isAppOfArity ``CallF.spread 6 then
        pure "host_retained_array"
      else if frame.isAppOfArity ``Frame.l 1 && inner.isAppOfArity ``LitF.array 3 then
        pure "host_retained_array"
      else if frame.isAppOfArity ``Frame.l 1 && inner.isAppOfArity ``LitF.objVal 4 then
        let rest ← whnf inner.getAppArgs[2]!
        if rest.isAppOfArity ``List.cons 3 then
          let property ← whnf rest.getAppArgs[1]!
          if property.isAppOfArity ``Property.short 1 then pure "host_retained_object_short"
          else pure "host_retained_object"
        else pure "host_retained_object"
      else if frame.isAppOfArity ``Frame.b 1 then pure "host_retained_pattern"
      else if frame.isAppOfArity ``Frame.a 1 && inner.isAppOfArity ``AsgF.updOld 3 then
        pure "host_retained_update"
      else if frame.isAppOfArity ``Frame.a 1 && inner.isAppOfArity ``AsgF.old 4 then
        let op ← whnf inner.getAppArgs[0]!
        if op.isAppOfArity ``AsgOp.log 1 && (← whnf op.getAppArgs[0]!).isConstOf ``LogOp.nullish &&
            (← whnf control.getAppArgs[0]!).isAppOfArity ``Val.obj 1 then
          pure "host_retained_nullish_object"
        else pure "host_retained_pure_step"
      else if frame.isAppOfArity ``Frame.a 1 && inner.isAppOfArity ``AsgF.privObj 5 then
        pure "host_retained_private_assign"
      else if frame.isAppOfArity ``Frame.a 1 && inner.isAppOfArity ``AsgF.put 3 then
        if (← whnf inner.getAppArgs[1]!).isAppOfArity ``Target.priv 3 then pure "host_retained_private_assign"
        else pure "host_retained_pure_step"
      else if frame.isAppOfArity ``Frame.s 1 && inner.isAppOfArity ``StmtF.declNext 3 then
        pure "host_retained_pattern"
      else if frame.isAppOfArity ``Frame.s 1 && inner.isAppOfArity ``StmtF.if_ 3 then
        if (← whnf control.getAppArgs[0]!).isConstOf ``Val.undef then pure "host_retained_undefined_branch"
        else pure "host_retained_branch"
      else if frame.isAppOfArity ``Frame.s 1 && inner.isAppOfArity ``StmtF.finally_ 1 then
        pure "host_retained_finally"
      else if frame.isAppOfArity ``Frame.lp 1 then
        if inner.isAppOfArity ``LoopF.forTest 7 || inner.isAppOfArity ``LoopF.forBody 6 || inner.isAppOfArity ``LoopF.forUpd 6 then
          pure "host_retained_for"
        else pure "host_retained_pure_step"
      else if frame.isAppOfArity ``Frame.e 1 && (inner.isAppOfArity ``ExprF.indexL 3 || inner.isAppOfArity ``ExprF.indexR 1) then
        pure "host_retained_index"
      else if frame.isAppOfArity ``Frame.e 1 && inner.isAppOfArity ``ExprF.const 1 then
        pure "host_retained_update"
      else if frame.isAppOfArity ``Frame.e 1 && inner.isAppOfArity ``ExprF.priv 3 then
        let value ← whnf control.getAppArgs[0]!
        if value.isAppOfArity ``Val.obj 1 then
          let object ← whnf (← mkAppM ``St.obj? #[s,value.getAppArgs[0]!])
          if object.isAppOfArity ``Option.some 2 then
            let property ← whnf (← mkAppM ``findPriv #[inner.getAppArgs[0]!,inner.getAppArgs[1]!,← mkAppM ``Obj.priv #[object.getAppArgs[1]!]])
            if property.isAppOfArity ``Option.some 2 then
              let descriptor ← whnf property.getAppArgs[1]!
              if descriptor.isAppOfArity ``PropV.data 3 then
                if (← whnf descriptor.getAppArgs[0]!).isAppOfArity ``Val.obj 1 then
                  return "host_retained_private_object"
        pure "host_retained_heap_read"
      else if frame.isAppOfArity ``Frame.e 1 && inner.isAppOfArity ``ExprF.member 2 then
        let value ← whnf control.getAppArgs[0]!
        if value.isAppOfArity ``Val.obj 1 then
          let object ← whnf (← mkAppM ``St.obj? #[s,value.getAppArgs[0]!])
          if object.isAppOfArity ``Option.some 2 then
            let kind ← whnf (← mkAppM ``Obj.kind #[object.getAppArgs[1]!])
            if kind.isAppOfArity ``Kind.array 1 then
              if ← isDefEq inner.getAppArgs[0]! (mkConst ``kLength) then pure "host_retained_array_length"
              else pure "host_retained_pure_step"
            else if ← ordinaryGetter s inner.getAppArgs[0]! value.getAppArgs[0]! 16 then
              pure "host_retained_getter"
            else if ← ordinaryMissing s inner.getAppArgs[0]! value.getAppArgs[0]! 16 then
              pure "host_retained_missing_read"
            else pure "host_retained_pure_step"
          else pure "host_retained_pure_step"
        else pure "host_retained_pure_step"
      else if frame.isAppOfArity ``Frame.e 1 && inner.isAppOfArity ``ExprF.binR 2 then
        let returned ← whnf control.getAppArgs[0]!
        let saved ← whnf inner.getAppArgs[1]!
        let operation ← whnf inner.getAppArgs[0]!
        if returned.isConstOf ``Val.undef && saved.isConstOf ``Val.undef && operation.isConstOf ``BinOp.sne then
          pure "host_retained_undefined"
        else if returned.isAppOfArity ``Val.num 1 && saved.isAppOfArity ``Val.num 1 then
          let right ← whnf returned.getAppArgs[0]!
          let left ← whnf saved.getAppArgs[0]!
          if right.isAppOfArity ``NumV.lit 1 && left.isAppOfArity ``NumV.lit 1 &&
              (operation.isConstOf ``BinOp.lt || operation.isConstOf ``BinOp.le || operation.isConstOf ``BinOp.seq ||
               operation.isConstOf ``BinOp.sne || operation.isConstOf ``BinOp.eq || operation.isConstOf ``BinOp.ne) then
            pure "host_retained_closed_comparison"
          else pure "host_retained_pure_step"
        else pure "host_retained_pure_step"
      else if frame.isAppOfArity ``Frame.k 1 then
        let fn ← whnf frame.getAppArgs[0]!
        if fn.isAppOfArity ``FnF.params 4 then
          if (← whnf fn.getAppArgs[1]!).isAppOfArity ``List.nil 1 then
            let body ← Parametric.Driver.field fn.getAppArgs[0]! ``Func.mk 7 3
            if (← whnf body).isAppOfArity ``Body.expr 1 then pure "host_retained_expression_body"
            else pure "host_retained_parameter_body"
          else pure "host_retained_pure_step"
        else if fn.isAppOfArity ``FnF.ctorBody 4 then pure "host_retained_constructor"
        else if fn.isAppOfArity ``FnF.fields 3 || fn.isAppOfArity ``FnF.privVal 5 then pure "host_retained_private_fields"
        else if fn.isAppOfArity ``FnF.fn 1 then
          if (← whnf fn.getAppArgs[0]!).isAppOfArity ``Boundary.ctor 1 then pure "host_retained_constructor_return"
          else pure "host_retained_pure_step"
        else pure "host_retained_pure_step"
      else pure "host_retained_pure_step"
    else pure "host_retained_pure_step"
  Parametric.Driver.emit s!"{selected} {← printed f.raw}, {← printed s.raw} using {← printed initial.raw} to {← printed t.raw} using {← printed next.raw} as {name.getId}"

end Host.Ts.Owned.Annotated.Driver
