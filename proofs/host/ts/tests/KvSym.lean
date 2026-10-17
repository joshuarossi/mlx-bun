import host.ts.tests.KvSrc
namespace Host.Ts.Tests.KvSym
open Host.Ts Host.Ts.Tests

/-! `KVCache.updateAndFetch` (`state/kv.ts`) at a symbolic offset `n`
(table entry `var 0`), kernel-checked symbolically for both branches, and
transferred to every concrete `n` whose branch answers match by
`run_sim`. -/

def one : SymE := .lit (F64.fin false 1 0)
def nPlus1 : SymE := .bin .add (.var 0) one

/-- Oracle for the no-growth branch: `prev + L > keys.shape[2]` is false. -/
def oNo : List Ans := [⟨.lt, .lit (F64.ofNat 512), nPlus1, false⟩]

/-- Oracle for growth at a 256-aligned offset: the test is true, `prev % 256 !== 0` false. -/
def oGrow : List Ans := [⟨.lt, .lit (F64.ofNat 512), nPlus1, true⟩,
  ⟨.eq, .bin .rem (.var 0) (.lit (F64.ofNat 256)), .lit (F64.zero false), true⟩]

def symRun (o : List Ans) : Option (St Mock.St × SSrv) :=
  kvBoot.bind fun s => runS Mock.ffi 20000 s ⟨[.var 0], o⟩

def concRun (ρ : Nat → F64) : Option (St Mock.St × CSrv) :=
  kvBoot.bind fun s => runC Mock.ffi 20000 s ⟨[ρ 0]⟩

/-- What a run computes: FFI symbols in order, `K.shape` through the table,
the new offset, unused oracle answers. -/
def summary (r : Option (St Mock.St × SSrv)) : Option (List Name × List SymE × SymE × List Ans) :=
  r.bind fun (s, S) => (kvBoot.map entryEnv).bind fun env => (bindingOf s env chars!"out").bind fun out =>
    (elemOf s out 0).bind fun k => (symsOf s S k).bind fun ks => (elemOf s out 2).bind fun off =>
      (symOf S off).map fun o => (traceSyms s, ks, o, S.oracle)

def loadSyms : List Name :=
  [chars!"mlx_set_error_handler", chars!"mlx_string_new", chars!"mlx_version", chars!"mlx_string_data",
   chars!"mlx_string_free", chars!"mlx_default_gpu_stream_new", chars!"mlx_default_cpu_stream_new"]

def setupSyms : List Name :=
  [chars!"mlx_array_new", chars!"mlx_zeros", chars!"mlx_array_new", chars!"mlx_zeros",
   chars!"mlx_array_new", chars!"mlx_zeros", chars!"mlx_array_new", chars!"mlx_zeros"]

/-- The fetched row count: `int32(n + 1) - 0` (slice stop minus start). -/
def fetched : SymE := .bin .sub (.un .int32 nPlus1) (.lit (F64.zero false))

theorem noGrowth : summary (symRun oNo) = some (loadSyms ++ setupSyms ++
    [chars!"mlx_array_ndim", chars!"mlx_array_shape", chars!"mlx_array_ndim", chars!"mlx_array_shape",
     chars!"mlx_array_ndim", chars!"mlx_array_shape", chars!"mlx_array_ndim", chars!"mlx_array_shape",
     chars!"mlx_array_new", chars!"mlx_slice_update", chars!"mlx_array_new", chars!"mlx_slice_update",
     chars!"mlx_array_free", chars!"mlx_array_free",
     chars!"mlx_array_new", chars!"mlx_slice", chars!"mlx_array_new", chars!"mlx_slice",
     chars!"mlx_array_ndim", chars!"mlx_array_shape", chars!"mlx_array_ndim", chars!"mlx_array_shape"],
    [.lit (F64.ofNat 1), .lit (F64.ofNat 2), fetched, .lit (F64.ofNat 4)], nPlus1, []) := by
  decide +kernel

/-- Every concrete offset taking the no-growth branch runs exactly as the
symbolic run: same final machine state (FFI trace included), numbers
instantiated. -/
theorem noGrowth_at (ρ : Nat → F64) (h : F64.test .lt (F64.ofNat 512) (nPlus1.eval ρ) = false) :
    ∀ s' S', symRun oNo = some (s', S') → ∃ C', concRun ρ = some (s', C') ∧ Inst ρ S' C' :=
  fun s' S' => boot_sim Mock.ffi ρ kvBoot 20000 ⟨[.var 0], oNo⟩ ⟨[ρ 0]⟩
    ⟨rfl, by intro q hq; simp only [oNo, List.mem_singleton] at hq; subst hq; simpa [SymE.eval] using h⟩ s' S'

theorem growth : summary (symRun oGrow) = some (loadSyms ++ setupSyms ++
    [chars!"mlx_array_ndim", chars!"mlx_array_shape", chars!"mlx_array_ndim", chars!"mlx_array_shape",
     chars!"mlx_array_ndim", chars!"mlx_array_shape", chars!"mlx_array_ndim", chars!"mlx_array_shape",
     chars!"mlx_array_dtype", chars!"mlx_array_new", chars!"mlx_zeros",
     chars!"mlx_array_dtype", chars!"mlx_array_new", chars!"mlx_zeros",
     chars!"mlx_vector_array_new_data", chars!"mlx_array_new", chars!"mlx_concatenate_axis", chars!"mlx_vector_array_free",
     chars!"mlx_vector_array_new_data", chars!"mlx_array_new", chars!"mlx_concatenate_axis", chars!"mlx_vector_array_free",
     chars!"mlx_array_free", chars!"mlx_array_free", chars!"mlx_array_free", chars!"mlx_array_free",
     chars!"mlx_array_ndim", chars!"mlx_array_shape", chars!"mlx_array_ndim", chars!"mlx_array_shape",
     chars!"mlx_array_new", chars!"mlx_slice_update", chars!"mlx_array_new", chars!"mlx_slice_update",
     chars!"mlx_array_free", chars!"mlx_array_free",
     chars!"mlx_array_new", chars!"mlx_slice", chars!"mlx_array_new", chars!"mlx_slice",
     chars!"mlx_array_ndim", chars!"mlx_array_shape", chars!"mlx_array_ndim", chars!"mlx_array_shape"],
    [.lit (F64.ofNat 1), .lit (F64.ofNat 2), fetched, .lit (F64.ofNat 4)], nPlus1, []) := by
  decide +kernel

theorem growth_at (ρ : Nat → F64) (h1 : F64.test .lt (F64.ofNat 512) (nPlus1.eval ρ) = true)
    (h2 : F64.test .eq (F64.rem (ρ 0) (F64.ofNat 256)) (F64.zero false) = true) :
    ∀ s' S', symRun oGrow = some (s', S') → ∃ C', concRun ρ = some (s', C') ∧ Inst ρ S' C' :=
  fun s' S' => boot_sim Mock.ffi ρ kvBoot 20000 ⟨[.var 0], oGrow⟩ ⟨[ρ 0]⟩
    ⟨rfl, by
      intro q hq
      simp only [oGrow, List.mem_cons, List.mem_singleton, List.not_mem_nil, or_false] at hq
      rcases hq with rfl | rfl
      · simpa [SymE.eval] using h1
      · simpa [SymE.eval, F64.bin] using h2⟩ s' S'

end Host.Ts.Tests.KvSym
