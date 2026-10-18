import host.mlx.ClosedGeometry
import host.mlx.CachedInference

set_option Elab.async false

namespace Host.Load.Run.Full.Shapeless
open Host.Ts Host.Mlx.Ffi Host.Mlx.Ffi.Annotated

theorem dtype_exp : unaryDtype chars!"exp" 10 = 10 := by
  have hn : nameEq chars!"exp" chars!"negative" = false := by decide +kernel
  have hc : nameEq chars!"exp" chars!"contiguous" = false := by decide +kernel
  simp only [unaryDtype,hn,hc]
  rfl

theorem dtype_negative : unaryDtype chars!"negative" 10 = 10 := by
  have hn : nameEq chars!"negative" chars!"negative" = true := by decide +kernel
  simp only [unaryDtype,hn,Bool.true_or]
  rfl

theorem dtype_add : binaryDtype chars!"add" 12 12 = 12 := by
  have hd : nameEq chars!"add" chars!"divide" = false := by decide +kernel
  have hl : nameEq chars!"add" chars!"logaddexp" = false := by decide +kernel
  simp only [binaryDtype,hd,hl]
  rfl

theorem dtype_logaddexp : binaryDtype chars!"logaddexp" 12 12 = 12 := by
  have hd : nameEq chars!"logaddexp" chars!"divide" = false := by decide +kernel
  have hl : nameEq chars!"logaddexp" chars!"logaddexp" = true := by decide +kernel
  simp only [binaryDtype,hd,hl]
  rfl

theorem dtype_multiply : binaryDtype chars!"multiply" 10 12 = 10 := by
  have hd : nameEq chars!"multiply" chars!"divide" = false := by decide +kernel
  have hl : nameEq chars!"multiply" chars!"logaddexp" = false := by decide +kernel
  simp only [binaryDtype,hd,hl]
  rfl

theorem infer_astype : infer (.astype 10) (literalMetadata [([48],12)]) =
    M.pure (some (Out.node ([48].map Dim.lit) 10)) := by rfl

theorem infer_exp48 : infer (.unary chars!"exp") (literalMetadata [([48],10)]) =
    M.pure (some (Out.node ([48].map Dim.lit) 10)) := by
  change M.pure (some (Out.node ([48].map Dim.lit) (unaryDtype chars!"exp" 10))) = _
  rw [dtype_exp]

theorem infer_negative : infer (.unary chars!"negative") (literalMetadata [([48],10)]) =
    M.pure (some (Out.node ([48].map Dim.lit) 10)) := by
  change M.pure (some (Out.node ([48].map Dim.lit) (unaryDtype chars!"negative" 10))) = _
  rw [dtype_negative]

theorem infer_add : infer (.binary chars!"add") (literalMetadata [([1,1,48],12),([48],12)]) =
    M.pure (some (Out.node ([1,1,48].map Dim.lit) 12)) := by
  change (broadcast ([Dim.lit 1,Dim.lit 1] ++ [Dim.lit 48]) [Dim.lit 48]).bind _ = _
  rw [InferenceRoles.broadcast_leading [.lit 48] [.lit 1,.lit 1]]
  change M.pure (some (Out.node ([1,1,48].map Dim.lit) (binaryDtype chars!"add" 12 12))) = _
  rw [dtype_add]

theorem infer_logaddexp : infer (.binary chars!"logaddexp") (literalMetadata [([1,1,48],12),([],12)]) =
    M.pure (some (Out.node ([1,1,48].map Dim.lit) 12)) := by
  change (broadcast ([1,1,48].map Dim.lit) []).bind _ = _
  rw [InferenceRoles.broadcast_scalar]
  change M.pure (some (Out.node ([1,1,48].map Dim.lit) (binaryDtype chars!"logaddexp" 12 12))) = _
  rw [dtype_logaddexp]

theorem infer_multiply : infer (.binary chars!"multiply") (literalMetadata [([48],10),([1,1,48],12)]) =
    M.pure (some (Out.node ([1,1,48].map Dim.lit) 10)) := by
  change (broadcast [Dim.lit 48] ([Dim.lit 1,Dim.lit 1] ++ [Dim.lit 48])).bind _ = _
  rw [InferenceRoles.broadcast_suffix [.lit 48] [.lit 1,.lit 1]]
  change M.pure (some (Out.node ([1,1,48].map Dim.lit) (binaryDtype chars!"multiply" 10 12))) = _
  rw [dtype_multiply]

theorem infer_exp148 : infer (.unary chars!"exp") (literalMetadata [([1,1,48],10)]) =
    M.pure (some (Out.node ([1,1,48].map Dim.lit) 10)) := by
  change M.pure (some (Out.node ([1,1,48].map Dim.lit) (unaryDtype chars!"exp" 10))) = _
  rw [dtype_exp]

end Host.Load.Run.Full.Shapeless
