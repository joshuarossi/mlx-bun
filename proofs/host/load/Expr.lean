import host.load.World
import host.mlx.FfiExpr
import host.ts.Memo
namespace Host.Load.Memo
open Lean Host.Ts.Memo

/-! Serialization of the world's state for chunked runs, over the memoizing
instances (`Host.Ts.Memo`). -/

deriving instance Lean.ToExpr for Host.Load.FileC
attribute [instance 20000] instToExprFileC
deriving instance Lean.ToExpr for Host.Load.HObj
attribute [instance 20000] instToExprHObj
deriving instance Lean.ToExpr for Host.Load.HostSt
attribute [instance 20000] instToExprHostSt
deriving instance Lean.ToExpr for Host.Load.LSt
attribute [instance 20000] instToExprLSt

end Host.Load.Memo
