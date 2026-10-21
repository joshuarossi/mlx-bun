import host.simgraph.Domain
import host.load.CacheValues
namespace Host.Mlx.SimGraph
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Load.Extract

/-! # Graph growth

A native state only grows: nodes are added at the counter, kernel objects are
never replaced. `Grows Ks s s'` states it; values of `s`'s nodes, carried
cache values and token readbacks then hold in `s'` (in particular in the
run's terminal graph). -/

section
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
  {κ : Type} [DecidableEq κ] (env : Env κ)

/-- Growth of a native state: the nodes below its counter and its route kernels are kept. -/
def Grows (Ks : KernelSources) (s s' : Ffi.St) : Prop :=
  (∀ j, j < s.nnext → s'.nodes.get j = s.nodes.get j) ∧
    ∀ k name, kernelName? Ks s k = some name → kernelName? Ks s' k = some name

theorem Grows.trans {Ks : KernelSources} {s s' s'' : Ffi.St} (h : Grows Ks s s') (h' : Grows Ks s' s'')
    (hn : s.nnext ≤ s'.nnext) : Grows Ks s s'' :=
  ⟨fun j hj => (h'.1 j (by omega)).trans (h.1 j hj), fun k name hk => h'.2 k name (h.2 k name hk)⟩

theorem evalR_grows (N : Nums Int) (Ks : KernelSources) (s s' : Ffi.St) (h : Grows Ks s s') (i : Nat)
    (hi : i < s.nnext) (v : Value) (hv : evalR M K env (ffiGraph N Ks s) i = some v) :
    evalR M K env (ffiGraph N Ks s') i = some v :=
  evalR_extend M K env N Ks s s' i (fun j hj => h.1 j (by omega)) h.2 v hv

end

section
variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
  (env : Env InKey)

/-- Carried cache values survive growth. -/
theorem cacheValues_grows (N : Nums Int) (Ks : KernelSources) (s s' : Ffi.St) (h : Grows Ks s s')
    (cs : List Cache) (hs : List Host.Mlx.GlueStep.Handles)
    (hlt : ∀ c ∈ cs, ∀ t, (c.first = some t ∨ c.second = some t) → t.node < s.nnext)
    (hv : CacheValues M K env (ffiGraph N Ks s) cs hs) : CacheValues M K env (ffiGraph N Ks s') cs hs := by
  induction hv with
  | nil => exact .nil
  | @cons c hd cs hs hc _ ih =>
    obtain ⟨ta, tb, a, b, h1, h2, hvals, ha, hb⟩ := hc
    exact .cons ⟨ta, tb, a, b, h1, h2, hvals,
      evalR_grows M K env N Ks s s' h _ (hlt c (List.mem_cons_self ..) ta (.inl h1)) a ha,
      evalR_grows M K env N Ks s s' h _ (hlt c (List.mem_cons_self ..) tb (.inr h2)) b hb⟩
      (ih fun c' hm => hlt c' (List.mem_cons_of_mem _ hm))

end

end Host.Mlx.SimGraph
