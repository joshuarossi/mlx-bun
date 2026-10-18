import host.load.Expr
import host.mlx.FfiExpr
namespace Host.Load
open Lean Host.Ts Host.Ts.Stream

/-- The host's persistent inputs are shared across streamed boundaries. -/
instance : StreamExpr HostSt where
  ser s := do
    let fields {α : Type} [ToExpr α] (tag : String) (xs : List α) : GenM Lean.Expr :=
      match xs with
      | [] => pure (toExpr xs)
      | _ => named (toTypeExpr (List α)) tag xs (fun x => pure (toExpr x))
    let objs ← match s.objs with
      | .nil => pure (toExpr s.objs)
      | _ => named (toTypeExpr (Trie HObj)) "ho" s.objs (fun x => pure (toExpr x))
    pure (mkAppN (mkConst ``HostSt.mk) #[← fields "he" s.env, ← fields "hf" s.files,
      toExpr s.fds, toExpr s.nextFd, objs, toExpr s.nextMap, toExpr s.next,
      toExpr s.arch, toExpr s.memsize, toExpr s.cwd, toExpr s.ane, ← fields "hm" s.math])

instance : StreamExpr LSt where
  ser s := do
    pure (mkApp2 (mkConst ``LSt.mk) (← StreamExpr.ser s.mlx) (← StreamExpr.ser s.host))

end Host.Load
