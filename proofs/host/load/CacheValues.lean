import host.load.InputValues
import host.mlx.FfiCache

namespace Host.Load.Extract
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.GlueStep

def cacheTensor (c : Cache) : Nat → Option Tensor
  | 0 => c.first
  | 1 => c.second
  | _ => none

/-- Input selection for a populated recurrent or attention cache. -/
def cacheValue (h : Handles) (i : Nat) : Option Value :=
  (handleVals h).bind fun (a,b) => match i with
    | 0 => some a
    | 1 => some b
    | _ => none

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (G : Nat → Option (RNode Int InKey))

/-- Actual cache objects carry the values produced by the mathematical step.
This relation is derived from output carriers and graph evaluation below. -/
def CacheValues (cs : List Cache) (hs : List Handles) : Prop :=
  List.Forall₂ (fun c h => ∃ ta tb a b,
    c.first = some ta ∧ c.second = some tb ∧ handleVals h = some (a,b) ∧
    evalR M K env G ta.node = some a ∧ evalR M K env G tb.node = some b) cs hs

/-- A checked output-carrier match and the original graph's cache results
establish the next call's cache values, without assuming those values anew. -/
theorem cacheValues_of_facts (cs : List Cache) (ps : List (Nat × Nat)) (hs : List Handles)
    (carrier : Nat → Nat)
    (hcar : cs.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
      ps.map (fun (a,b) => (some (carrier a), some (carrier b))))
    (hlen : ps.length = hs.length) (hsome : ∀ h ∈ hs, (handleVals h).isSome)
    (hev : ∀ q ∈ cacheFacts ps hs, evalR M K env G (carrier q.1) = some q.2) :
    CacheValues M K env G cs hs := by
  induction ps generalizing cs hs with
  | nil =>
    cases cs with
    | nil => cases hs <;> simp_all [CacheValues]
    | cons c cs => simp at hcar
  | cons p ps ih =>
    cases cs with
    | nil => simp at hcar
    | cons c cs =>
      cases hs with
      | nil => simp at hlen
      | cons h hs =>
        have hc := List.cons.inj hcar
        have hl : ps.length = hs.length := by simpa using hlen
        have populated := hsome h (List.mem_cons_self ..)
        cases ht : c.first with
        | none => simp [ht] at hc
        | some ta =>
          cases hu : c.second with
          | none => simp [hu] at hc
          | some tb =>
            have ha : ta.node = carrier p.1 := by simpa [ht] using congrArg Prod.fst hc.1
            have hb : tb.node = carrier p.2 := by simpa [hu] using congrArg Prod.snd hc.1
            cases hv : handleVals h with
            | none => simp [hv] at populated
            | some pair =>
              rcases pair with ⟨a,b⟩
              apply List.Forall₂.cons
              · refine ⟨ta, tb, a, b, ht, hu, hv, ?_, ?_⟩
                · rw [ha]
                  exact hev (p.1,a) (by simp [cacheFacts, hv])
                · rw [hb]
                  exact hev (p.2,b) (by simp [cacheFacts, hv])
              · exact ih cs hs hc.2 hl (fun x hx => hsome x (List.mem_cons_of_mem _ hx))
                  (fun q hq => hev q (by simp only [cacheFacts, hv]; exact List.mem_append_right _ hq))

/-- The resulting cache relation gives precisely the next input's value at
every stage and cache coordinate, including out-of-range coordinates. -/
theorem CacheValues.inputs {cs : List Cache} {hs : List Handles}
    (h : CacheValues M K env G cs hs) (p i : Nat) :
    (cs[p]?).bind (fun c => (cacheTensor c i).bind fun t => evalR M K env G t.node) =
      (hs[p]?).bind (fun h => cacheValue h i) := by
  induction h generalizing p with
  | nil => rfl
  | @cons c h cs hs hc hrest ih =>
    cases p with
    | succ p => exact ih p
    | zero =>
      obtain ⟨ta, tb, a, b, ht, hu, hv, ha, hb⟩ := hc
      cases i with
      | zero => simpa [cacheTensor, cacheValue, ht, hv] using ha
      | succ i =>
        cases i with
        | zero => simpa [cacheTensor, cacheValue, hu, hv] using hb
        | succ i => simp [cacheTensor, cacheValue]

/-- Graph extension or a change of expected-input interpretation preserves
cache feedback when it preserves the producing nodes' evaluations. -/
theorem CacheValues.congr {cs : List Cache} {hs : List Handles}
    (h : CacheValues M K env G cs hs) (env' : FfiEval.Env InKey)
    (G' : Nat → Option (RNode Int InKey))
    (he : ∀ i, evalR M K env G i = evalR M K env' G' i) :
    CacheValues M K env' G' cs hs := by
  induction h with
  | nil => exact .nil
  | cons hc _ ih =>
    obtain ⟨ta, tb, a, b, ht, hu, hv, ha, hb⟩ := hc
    exact .cons ⟨ta, tb, a, b, ht, hu, hv, (he _).symm.trans ha, (he _).symm.trans hb⟩ ih

end Host.Load.Extract
