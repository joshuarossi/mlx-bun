import host.load.run.full.FirstChoice
import host.load.CachedShapes
import host.load.run.full.CachedLayout
import host.load.run.full.cached.Choice2
import host.load.run.full.cached.Choice3
import host.load.run.full.cached.Choice4
import host.load.run.full.cached.Choice5
import host.mlx.KernelSources
namespace Host.Load.Run.Full.Cached
open Host.Load.Extract Host.Load.CachedShapes Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

theorem cache_classes1 (contents : Nat → Nat → Nat) :
    List.Forall₂ CacheClassMatches (stageWeights (weights (headerValues contents))) firstChoice.cache := by
  repeat' first | apply List.Forall₂.cons | exact List.Forall₂.nil | rfl

theorem cache_shapes_checked1 (table : List F64) :
    checkCaches (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s3573.ffi.mlx)
      .bfloat16 [1,4,256,256] 6 firstChoice.cache = true := by rfl

theorem cache_classes2 (contents : Nat → Nat → Nat) :
    List.Forall₂ CacheClassMatches (stageWeights (weights (headerValues contents))) after2.cache := by
  repeat' first | apply List.Forall₂.cons | exact List.Forall₂.nil | rfl

theorem cache_shapes_checked2 (table : List F64) :
    checkCaches (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s3573.ffi.mlx)
      .bfloat16 [1,4,256,256] 6 after2.cache = true := by rfl

theorem cache_classes3 (contents : Nat → Nat → Nat) :
    List.Forall₂ CacheClassMatches (stageWeights (weights (headerValues contents))) after3.cache := by
  repeat' first | apply List.Forall₂.cons | exact List.Forall₂.nil | rfl

theorem cache_shapes_checked3 (table : List F64) :
    checkCaches (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s3573.ffi.mlx)
      .bfloat16 [1,4,256,256] 6 after3.cache = true := by rfl

theorem cache_classes4 (contents : Nat → Nat → Nat) :
    List.Forall₂ CacheClassMatches (stageWeights (weights (headerValues contents))) after4.cache := by
  repeat' first | apply List.Forall₂.cons | exact List.Forall₂.nil | rfl

theorem cache_shapes_checked4 (table : List F64) :
    checkCaches (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s3573.ffi.mlx)
      .bfloat16 [1,4,256,256] 6 after4.cache = true := by rfl

theorem cache_classes5 (contents : Nat → Nat → Nat) :
    List.Forall₂ CacheClassMatches (stageWeights (weights (headerValues contents))) after5.cache := by
  repeat' first | apply List.Forall₂.cons | exact List.Forall₂.nil | rfl

theorem cache_shapes_checked5 (table : List F64) :
    checkCaches (ffiGraph (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources P.s3573.ffi.mlx)
      .bfloat16 [1,4,256,256] 6 after5.cache = true := by rfl

end Host.Load.Run.Full.Cached
