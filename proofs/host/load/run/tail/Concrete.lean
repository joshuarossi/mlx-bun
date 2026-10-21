import host.load.run.tail.Run
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Tail
open Host.Ts Host.Load Host.Load.Run.Full

/- The first ordinary readback cut with unread suffix `τ` is `P.s3272` with only
the native token queue replaced; its next read is `.ref 2`. -/
kernel_rfl_eager ta3272_eq : ∀ τ : List NumV,
  P.ta3272 τ = P.s3272.setFfi
    { (P.s3272.ffi : LSt) with mlx := { (P.s3272.ffi : LSt).mlx with tokens := .ref 2 :: τ } }

kernel_rfl_eager ta3272_tokens : ∀ τ : List NumV, ((P.ta3272 τ).ffi : LSt).mlx.tokens = .ref 2 :: τ

/- The original suffix recovers the original cut (and `worldTail_reads` the
original world). -/
kernel_rfl_eager ta3272_reads : P.ta3272 [.ref 3, .ref 4, .ref 5, .ref 6, .ref 7, .ref 8] = P.s3272

end Host.Load.Run.Tail
