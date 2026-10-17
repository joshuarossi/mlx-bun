import models.qwen.ResidualDelta
import models.qwen.ResidualAttention

namespace Inference.Models.Qwen.DecodeStage
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Kernels.Attention
abbrev BF := BFloat16Arithmetic.Value
abbrev Row (α : Type) := Fin 5120 → α

-- These constructors contain concrete proved layer implementations. The
-- interface introduces no assumed stage-level numerical correctness field.
inductive Stage where
  | delta (layer : ResidualDelta.Layer)
  | attention (layer : ResidualAttention.Layer)

def Cache : Stage → Nat → Type
  | .delta _, _ => DeltaNet.Cache
  | .attention _, n => State.Kv.Cache BF n
def ReferenceCache : Stage → Nat → Type
  | .delta _, _ => DeltaNet.ReferenceCache
  | .attention _, n => State.Kv.Cache ℝ n
def CacheError : (s : Stage) → Cache s n → ReferenceCache s n → ReferenceCache s n → Prop
  | .delta _, c, t, e => DeltaNet.CacheError c t e
  | .attention _, c, t, e => State.Kv.Error c t e
def CacheFinite : (s : Stage) → Cache s n → Prop
  | .delta _, c => DeltaCache.Finite c
  | .attention _, c => State.Kv.Finite c

def forward : (s : Stage) → Cache s n → Row BF → RopeAngles.Inputs → Row BF
  | .delta l, c, x, _ => l.forward c (fun _ => x) 0
  | .attention l, c, x, a => l.forward x a c
noncomputable def target : (s : Stage) → ReferenceCache s n → Row ℝ → RopeAngles.Target → Row ℝ
  | .delta l, c, x, _ => l.target c (fun _ => x) 0
  | .attention l, c, x, a => l.target x a c
def Finite : (s : Stage) → Cache s n → Row BF → RopeAngles.Inputs → Type
  | .delta l, c, x, _ => l.Finite c (fun _ => x) 0
  | .attention l, c, x, a => l.Finite x a c

noncomputable def budget : (s : Stage) → (c : Cache s n) → ReferenceCache s n → ReferenceCache s n →
    (x : Row BF) → Row ℝ → Row ℝ → (a : RopeAngles.Inputs) → RopeAngles.Target → RopeAngles.Target → Finite s c x a → Row ℝ
  | .delta l, c, ct, ce, x, t, e, _, _, _, hf => l.budget c ct ce (fun _ => x) (fun _ => t) (fun _ => e) 0 hf
  | .attention l, c, ct, ce, x, t, e, a, aim, ae, hf => l.budget x t e a aim ae c ct ce hf
def Capacity : (s : Stage) → (c : Cache s n) → ReferenceCache s n → ReferenceCache s n →
    (x : Row BF) → Row ℝ → Row ℝ → (a : RopeAngles.Inputs) → RopeAngles.Target → RopeAngles.Target → Finite s c x a → Prop
  | .delta l, c, ct, ce, x, t, e, _, _, _, hf => l.Capacity c ct ce (fun _ => x) (fun _ => t) (fun _ => e) 0 hf
  | .attention l, c, ct, ce, x, t, e, a, aim, ae, hf => l.Capacity x t e a aim ae c ct ce hf

def cacheAfter : (s : Stage) → Cache s n → Row BF → RopeAngles.Inputs → Cache s (n+1)
  | .delta l, c, x, _ => l.cacheAfter c (fun _ => x) 1
  | .attention l, c, x, a => l.cacheAfter x a c
noncomputable def targetCacheAfter : (s : Stage) → ReferenceCache s n → Row ℝ → RopeAngles.Target → ReferenceCache s (n+1)
  | .delta l, c, x, _ => l.targetCacheAfter c (fun _ => x) 1
  | .attention l, c, x, a => l.targetCacheAfter x a c
noncomputable def cacheBudget : (s : Stage) → Cache s n → ReferenceCache s n → ReferenceCache s n →
    Row BF → Row ℝ → Row ℝ → RopeAngles.Inputs → RopeAngles.Target → RopeAngles.Target → ReferenceCache s (n+1)
  | .delta l, c, ct, ce, x, t, e, _, _, _ => l.cacheBudget c ct ce (fun _ => x) (fun _ => t) (fun _ => e) 1
  | .attention l, _, _, ce, x, t, e, a, aim, ae => l.cacheBudget x t e a aim ae ce

theorem forward_error (s : Stage) (c : Cache s n) (ct ce : ReferenceCache s n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (hi : ∀ i, |Model.toReal (x i) - t i| ≤ e i) (hc : CacheError s c ct ce) (hcf : CacheFinite s c)
    (hf : Finite s c x a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : Capacity s c ct ce x t e a aim ae hf) (i : Fin 5120) :
    |Model.toReal (forward s c x a i) - target s ct t aim i| ≤ budget s c ct ce x t e a aim ae hf i := by
  cases s with
  | delta l => exact l.forward_error c ct ce hc (fun _ => x) (fun _ => t) (fun _ => e) (fun _ => hi) 0 hf capacity i
  | attention l => exact l.forward_error x t e a aim ae c ct ce hi hc hcf hf ha hb capacity i

theorem forward_finite (s : Stage) (c : Cache s n) (ct ce : ReferenceCache s n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (hi : ∀ i, |Model.toReal (x i) - t i| ≤ e i) (hc : CacheError s c ct ce) (hcf : CacheFinite s c)
    (hf : Finite s c x a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base)
    (capacity : Capacity s c ct ce x t e a aim ae hf) (i : Fin 5120) :
    Model.isFinite (forward s c x a i) = true := by
  cases s with
  | delta l => exact l.forward_finite c ct ce hc (fun _ => x) (fun _ => t) (fun _ => e) (fun _ => hi) 0 hf capacity i
  | attention l => exact l.forward_finite x t e a aim ae c ct ce hi hc hcf hf ha hb capacity i

theorem cache_error (s : Stage) (c : Cache s n) (ct ce : ReferenceCache s n)
    (x : Row BF) (t e : Row ℝ) (a : RopeAngles.Inputs) (aim ae : RopeAngles.Target)
    (hi : ∀ i, |Model.toReal (x i) - t i| ≤ e i) (hc : CacheError s c ct ce)
    (hf : Finite s c x a) (ha : RopeAngles.InputError a aim ae) (hb : 0 ≤ aim.base) :
    CacheError s (cacheAfter s c x a) (targetCacheAfter s ct t aim) (cacheBudget s c ct ce x t e a aim ae) := by
  cases s with
  | delta l => exact l.cache_error c ct ce hc (fun _ => x) (fun _ => t) (fun _ => e) (fun _ => hi) 0 hf
  | attention l => exact l.cache_error x t e a aim ae c ct ce hi hc hf ha hb

theorem cache_finite (s : Stage) (c : Cache s n) (x : Row BF) (a : RopeAngles.Inputs)
    (hc : CacheFinite s c) (hf : Finite s c x a) : CacheFinite s (cacheAfter s c x a) := by
  cases s with
  | delta l => exact l.cache_finite c (fun _ => x) 0 hf
  | attention l => exact l.cache_finite x a c hc hf

end Inference.Models.Qwen.DecodeStage
