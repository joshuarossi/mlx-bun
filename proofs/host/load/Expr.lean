import host.load.World
import host.ts.Memo
namespace Host.Load.Memo
open Lean Host.Ts.Memo

/-! Serialization of the world's state for chunked runs, over the memoizing
instances (`Host.Ts.Memo`). -/

deriving instance Lean.ToExpr for Host.Mlx.Ffi.Dim
attribute [instance 20000] instToExprDim
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Cfg
attribute [instance 20000] instToExprCfg
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Prim
attribute [instance 20000] instToExprPrim
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Node
attribute [instance 20000] instToExprNode
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Trace
attribute [instance 20000] instToExprTrace
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Clo
attribute [instance 20000] instToExprClo
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Obj
attribute [instance 20000] instToExprObj
deriving instance Lean.ToExpr for Host.Mlx.Ffi.Pending
attribute [instance 20000] instToExprPending
deriving instance Lean.ToExpr for Host.Mlx.Ffi.St
attribute [instance 20000] instToExprSt
deriving instance Lean.ToExpr for Host.Load.FileC
attribute [instance 20000] instToExprFileC
deriving instance Lean.ToExpr for Host.Load.HObj
attribute [instance 20000] instToExprHObj
deriving instance Lean.ToExpr for Host.Load.HostSt
attribute [instance 20000] instToExprHostSt
deriving instance Lean.ToExpr for Host.Load.LSt
attribute [instance 20000] instToExprLSt

end Host.Load.Memo
