import host.ts.renameOrdinary.CG0
import host.ts.renameOrdinary.micro.streamed128.Result
import host.ts.RenameKernelRfl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full
open Host.Ts

host_chain_prefix_frames P 3272, 3276

theorem ordinary_rest_initial (fw : List Val) (tail : List NumV) :
    P.RestStream.micro0.pfa0 (fw ++ [.num (.ref 2)]) tail = P.pfa3276 fw tail := by host_kernel_rfl

theorem ordinary_rest_final (fw : List Val) (tail : List NumV) :
    P.RestStream.micro0.pfa14623 (fw ++ [.num (.ref 2)]) tail = P.pfa3422 fw tail := by host_kernel_rfl

/-- The complete actual ordinary source interval includes all64 decoder layers
and grows both caller arrays by the read token. The caller prefix and unused
native read suffix are arbitrary. Numeric/resource cut generalization is a
separate obligation. -/
theorem ordinary_body (fw : List Val) (tail : List NumV) :
    runS P.F 1492544 (P.pfa3272 fw tail) P.S3272 = some (P.pfa3422 fw tail,P.S3422) := by
  have hr : runS P.F 1462293 (P.pfa3276 fw tail) P.S3276 =
      some (P.pfa3422 fw tail,P.S3422) := by
    have h := P.RestStream.micro0.full_prefix_run (fw ++ [.num (.ref 2)]) tail
    simpa only [ordinary_rest_initial,ordinary_rest_final,
      P.RestStream.micro0.F,P.RestStream.F,
      P.RestStream.micro0.S0,P.RestStream.S0,
      P.RestStream.micro0.S14623,P.RestStream.S1] using h
  exact runS_trans P.F (m := 30251) (n := 1462293)
    (s₀ := P.pfa3272 fw tail) (s₁ := P.pfa3276 fw tail) (s₂ := P.pfa3422 fw tail)
    (S₀ := P.S3272) (S₁ := P.S3276) (S₂ := P.S3422)
    (P.prefixRun3272_3276 fw tail) hr

theorem ordinary_prefixes_grow (fw : List Val) (tail : List NumV) :
    (arrayOf P.F (P.pfa3422 fw tail) 2673447).map Prod.snd =
        some (fw ++ [.num (.ref 2)]) ∧
      (arrayOf P.F (P.pfa3422 fw tail) 12502).map Prod.snd =
        some (fw ++ [.num (.ref 2)]) ∧
      (P.pfa3422 fw tail).ffi.mlx.tokens = tail := by
  exact ⟨rfl,rfl,rfl⟩
end Host.Load.Run.Full
