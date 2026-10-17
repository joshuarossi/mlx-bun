import host.mlx.Ffi
import host.ts.Chunk
namespace Host.Mlx.Ffi
open Lean

/-! Serialization of the MLX FFI model's state for chunked runs (`host_chain`). -/

deriving instance Lean.ToExpr for Host.Mlx.Ffi.Dim
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Cfg
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Prim
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Node
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Trace
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Clo
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Obj
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Pending
deriving instance Lean.ToExpr for Host.Mlx.Ffi.St

end Host.Mlx.Ffi
