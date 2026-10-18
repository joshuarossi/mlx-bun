import host.mlx.Ffi
import host.ts.Stream
namespace Host.Mlx.Ffi
open Lean

/-! Serialization of the MLX FFI model's state for chunked runs (`host_chain`, `host_stream`). -/

deriving instance Lean.ToExpr for Host.Mlx.Ffi.Dim
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Cfg
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Prim
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Node
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Trace
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Clo
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Obj
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Pending
deriving instance Lean.ToExpr for Host.Mlx.Ffi.St

open Host.Ts.Stream in
/-- Streamed: the stores' pages and the checkpoint headers by name. -/
instance : StreamExpr St where
  ser s := do
    let tf := toTypeExpr (List (List Char × Header))
    let tr {α : Type} [ToExpr α] (tag : String) (t : Host.Ts.PTrie α) : GenM Expr :=
      ptrieE (toTypeExpr α) tag (fun x => pure (toExpr x)) t
    pure (mkAppN (mkConst ``St.mk) #[toExpr s.next, ← tr "fn" s.nodes, toExpr s.nnext, ← tr "fa" s.arrs, ← tr "fo" s.objs,
      toExpr s.tokens, ← named tf "ff" s.files (fun x => pure (toExpr x)), toExpr s.pending, toExpr s.errh, toExpr s.arch,
      toExpr s.deviceSizes, toExpr s.wired, ← tr "fi" s.items])

end Host.Mlx.Ffi
