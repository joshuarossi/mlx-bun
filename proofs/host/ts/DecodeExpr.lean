import Lean

namespace Host.Ts.ConstructorDecode
open Lean Meta

/-- Native data reconstructed from constructor expressions is a choice only.
Kernel checks compare every resulting machine segment with the original states. -/
structure Ctor where
  params : Nat
  fields : Nat
  proofs : Array Bool
  make : Array NonScalar → NonScalar

structure Cache where
  constructors : Std.HashMap Name Ctor := {}
  values : Std.HashMap Lean.Expr NonScalar := {}
  aliases : Array (Name × Lean.Expr × NonScalar) := #[]

abbrev M := StateT Cache MetaM

private def anyTy : Lean.Expr := mkConst ``NonScalar
private def arrayTy : Lean.Expr := mkApp (mkConst ``Array [.zero]) anyTy

private def castExpr (srcTy dstTy value : Lean.Expr) : MetaM Lean.Expr :=
  mkAppOptM ``unsafeCast #[srcTy, dstTy, value]

/-- Compile one small constructor wrapper, never a machine-state expression.
The datatype's type parameters are erased; opaque boxed children retain their
runtime representations, including boxed machine integers. -/
unsafe def constructor (name : Name) : M Ctor := do
  if let some c := (← get).constructors[name]? then return c
  let .ctorInfo info ← getConstInfo name | throwError "not a constructor: {name}"
  let levels := info.levelParams.map fun _ => Level.zero
  let mut ty := info.type.instantiateLevelParams info.levelParams levels
  let mut app := mkConst name levels
  for _ in [0:info.numParams] do
    let .forallE _ dom body _ ← whnf ty | throwError "constructor parameter: {name}"
    let p ← match ← whnf dom with
      | .sort _ => pure anyTy
      | e =>
        if e.isConstOf ``Nat then pure (mkRawNatLit 0)
        else throwError "unsupported constructor parameter of {name}: {dom}"
    app := mkApp app p
    ty := body.instantiate1 p
  let (fnExpr, proofFields) ← withLocalDeclD `children arrayTy fun children => do
    let mut ty := ty
    let mut app := app
    let mut proofFields := #[]
    let zero ← castExpr (mkConst ``Nat) anyTy (mkRawNatLit 0)
    for i in [0:info.numFields] do
      let .forallE _ dom body _ ← whnf ty | throwError "constructor field: {name}"
      let proof ← isProp dom
      let child := mkAppN (mkConst ``Array.getD [.zero]) #[anyTy, children, mkRawNatLit i, zero]
      let arg ← if proof then castExpr (mkConst ``Nat) dom (mkRawNatLit 0) else castExpr anyTy dom child
      app := mkApp app arg
      ty := body.instantiate1 arg
      proofFields := proofFields.push proof
    let result ← castExpr ty anyTy app
    let fn ← mkLambdaFVars #[children] result
    pure (fn, proofFields)
  let fnTy ← mkArrow arrayTy anyTy
  let make ← evalExpr (Array NonScalar → NonScalar) fnTy fnExpr (safety := .unsafe)
  let c := { params := info.numParams, fields := info.numFields, proofs := proofFields, make }
  modify fun d => { d with constructors := d.constructors.insert name c }
  return c

private unsafe def boxed {α : Type} (x : α) : NonScalar := unsafeCast x

private inductive Work where
  | enter (e : Lean.Expr)
  | ctor (e : Lean.Expr) (c : Ctor)
  | alias (e : Lean.Expr) (name : Option (Name × Lean.Expr))
  | scalar (e : Lean.Expr) (type : Name)
  | drop (e : Lean.Expr)

/-- Decode constructor data and the scalar wrappers used by `ToExpr`.
Traversal is iterative so long data lists consume no native call stack.
Definitions are resolved as expressions, never compiled as machine-state IR. -/
unsafe def decode (root : Lean.Expr) : M NonScalar := do
  let mut todo := #[Work.enter root]
  let mut out : Array NonScalar := #[]
  let zero := boxed (0 : Nat)
  while h : todo.size > 0 do
    let work := todo[todo.size - 1]
    todo := todo.pop
    match work with
    | .enter e =>
      if let some value := (← get).values[e]? then
        out := out.push value
        continue
      match e with
      | .lit (.natVal n) =>
        let value := boxed n
        modify fun d => { d with values := d.values.insert e value }
        out := out.push value
      | .lit (.strVal s) =>
        let value := boxed s
        modify fun d => { d with values := d.values.insert e value }
        out := out.push value
      | .mdata _ body =>
        todo := todo.push (.alias e none) |>.push (.enter body)
      | _ =>
        let .const name levels := e.getAppFn | throwError "constructor data expected: {e}"
        let args := e.getAppArgs
        if name == ``Char.ofNat && args.size == 1 then
          todo := todo.push (.scalar e ``Char) |>.push (.enter args[0]!)
        else if name == ``OfNat.ofNat && args.size == 3 then
          let .const type _ := args[0]! | throwError "unsupported scalar type: {args[0]!}"
          todo := todo.push (.scalar e type) |>.push (.enter args[1]!)
        else if name == ``List.drop && args.size == 3 then
          todo := todo.push (.drop e) |>.push (.enter args[2]!) |>.push (.enter args[1]!)
        else match ← getConstInfo name with
          | .ctorInfo _ =>
            let c ← constructor name
            unless args.size == c.params + c.fields do throwError "unsaturated constructor: {name}"
            todo := todo.push (.ctor e c)
            for j in [0:c.fields] do
              let i := c.fields - 1 - j
              unless c.proofs[i]! do todo := todo.push (.enter args[c.params + i]!)
          | ci =>
            let some body := ci.value? | throwError "no data definition: {name}"
            let body := body.instantiateLevelParams ci.levelParams levels
            let alias := if args.isEmpty then some (name, ci.type) else none
            todo := todo.push (.alias e alias) |>.push (.enter (mkAppN body args))
    | .ctor e c =>
      let mut children := Array.replicate c.fields zero
      for j in [0:c.fields] do
        let i := c.fields - 1 - j
        unless c.proofs[i]! do
          unless out.size > 0 do throwError "decoder constructor stack: {e}"
          children := children.set! i (out.getD (out.size - 1) zero)
          out := out.pop
      let value := c.make children
      modify fun d => { d with values := d.values.insert e value }
      out := out.push value
    | .alias e alias =>
      unless out.size > 0 do throwError "decoder alias stack: {e}"
      let value := out.getD (out.size - 1) zero
      modify fun d => { d with values := d.values.insert e value, aliases := match alias with | none => d.aliases | some (n, ty) => d.aliases.push (n, ty, value) }
    | .scalar e type =>
      unless out.size > 0 do throwError "decoder scalar stack: {e}"
      let n : Nat := unsafeCast (out.getD (out.size - 1) zero)
      let value ←
        if type == ``Nat then pure (boxed n)
        else if type == ``Int then pure (boxed (Int.ofNat n))
        else if type == ``Char then pure (boxed (Char.ofNat n))
        else if type == ``UInt8 then pure (boxed (UInt8.ofNat n))
        else if type == ``UInt16 then pure (boxed (UInt16.ofNat n))
        else if type == ``UInt32 then pure (boxed (UInt32.ofNat n))
        else if type == ``UInt64 then pure (boxed (UInt64.ofNat n))
        else if type == ``USize then pure (boxed (USize.ofNat n))
        else throwError "unsupported scalar type: {type}"
      out := out.pop.push value
      modify fun d => { d with values := d.values.insert e value }
    | .drop e =>
      unless out.size ≥ 2 do throwError "decoder list stack: {e}"
      let xs : List NonScalar := unsafeCast (out.getD (out.size - 1) zero)
      out := out.pop
      let n : Nat := unsafeCast (out.getD (out.size - 1) zero)
      let value := boxed (xs.drop n)
      out := out.pop.push value
      modify fun d => { d with values := d.values.insert e value }
  unless out.size == 1 do throwError "decoder result stack"
  return out.getD 0 zero

end Host.Ts.ConstructorDecode
