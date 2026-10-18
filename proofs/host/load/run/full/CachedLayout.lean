import host.load.run.full.InitialLayout
import host.load.CacheInputValues

namespace Host.Load.Run.Full
open Host.Load.Extract Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval
set_option Elab.async false
set_option maxRecDepth 1000000

/-- Only cache presence and attention capacity enter the graph builder. -/
def populatedHandle (capacity : Nat) : StageWeights → Handles
  | .delta _ => .delta (some (zeros [] .bfloat16)) (some (zeros [] .bfloat16))
  | .attention _ => .attention
      (some (zeros [1,4,capacity,256] .bfloat16))
      (some (zeros [1,4,capacity,256] .bfloat16))

def populatedHandlesFor (ws : List StageWeights) (capacity : Nat) : List Handles :=
  ws.map (populatedHandle capacity)

def CacheClassMatches : StageWeights → Cache → Prop
  | .delta _, c => c.operation = chars!"SSMCache"
  | .attention _, c => c.operation = chars!"KVCache"

theorem stageLayout_populated (w : StageWeights) (h : Handles) (a b : Value)
    (capacity : Nat) (compatible : CacheCompatible w h)
    (populated : handleVals h = some (a,b))
    (shapes : ∀ aw, w = .attention aw →
      a.shape.getD 2 0 = capacity ∧ b.shape.getD 2 0 = capacity) :
    stageLayout w h = stageLayout w (populatedHandle capacity w) := by
  cases w <;> cases h <;> simp_all only [CacheCompatible]
  all_goals rename_i wa first second
  all_goals cases first <;> cases second <;> simp_all [handleVals]
  · rfl
  · obtain ⟨ha,hb⟩ := shapes
    simp_all [FfiEval.stageLayout, populatedHandle, attnLayout, capOf, zeros]

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
    (env : FfiEval.Env InKey) (G : Nat → Option (RNode Int InKey))

/-- The producing graph's cache values and checked source-cache shapes fix
the later decode graph's complete layout. No later graph match is assumed. -/
theorem chainLayout_of_cacheValues (ws : List StageWeights) (cs : List Cache)
    (hs : List Handles) (capacity : Nat)
    (values : CacheValues M K env G cs hs)
    (compatible : List.Forall₂ CacheCompatible ws hs)
    (classes : List.Forall₂ CacheClassMatches ws cs)
    (shapes : ∀ c ∈ cs, c.operation = chars!"KVCache" →
      ∀ t, c.first = some t ∨ c.second = some t →
      ∀ v, evalR M K env G t.node = some v → v.shape = [1,4,capacity,256]) :
    chainLayout ws hs = chainLayout ws (populatedHandlesFor ws capacity) := by
  induction compatible generalizing cs with
  | nil => rfl
  | @cons w h ws hs hc rest ih =>
    cases classes with
    | @cons _ c _ cs hclass classrest =>
      cases values with
      | cons hv valrest =>
        obtain ⟨ta,tb,a,b,hfirst,hsecond,hvals,ha,hb⟩ := hv
        have head := stageLayout_populated w h a b capacity hc hvals (by
          intro aw hw
          subst w
          have hop : c.operation = chars!"KVCache" := hclass
          have ashape := shapes c (List.mem_cons_self ..) hop ta (.inl hfirst) a ha
          have bshape := shapes c (List.mem_cons_self ..) hop tb (.inr hsecond) b hb
          simp [ashape,bshape])
        have tail := ih cs valrest classrest (fun c hm =>
          shapes c (List.mem_cons_of_mem _ hm))
        simpa only [populatedHandlesFor,List.map_cons,chainLayout,head] using congrArg
          (fun xs => stageLayout w (populatedHandle capacity w) :: xs) tail

def populatedLayoutHandles (capacity : Nat) : List Handles :=
  (List.range 64).map fun i => if i % 4 = 3 then
    .attention (some (zeros [1,4,capacity,256] .bfloat16))
      (some (zeros [1,4,capacity,256] .bfloat16))
  else .delta (some (zeros [] .bfloat16)) (some (zeros [] .bfloat16))

theorem populatedHandlesFor_loaded (contents : Nat → Nat → Nat) (capacity : Nat) :
    populatedHandlesFor (stageWeights (weights (headerValues contents))) capacity =
      populatedLayoutHandles capacity := by rfl

theorem cached_stage_layout (contents : Nat → Nat → Nat) (cs : List Cache)
    (hs : List Handles) (capacity : Nat)
    (values : CacheValues M K env G cs hs)
    (compatible : List.Forall₂ CacheCompatible
      (stageWeights (weights (headerValues contents))) hs)
    (classes : List.Forall₂ CacheClassMatches
      (stageWeights (weights (headerValues contents))) cs)
    (shapes : ∀ c ∈ cs, c.operation = chars!"KVCache" →
      ∀ t, c.first = some t ∨ c.second = some t →
      ∀ v, evalR M K env G t.node = some v → v.shape = [1,4,capacity,256]) :
    chainLayout (stageWeights (weights (headerValues contents))) hs =
      chainLayout (stageWeights (weights (headerValues contents)))
        (populatedLayoutHandles capacity) := by
  rw [← populatedHandlesFor_loaded contents capacity]
  exact chainLayout_of_cacheValues M K env G _ cs hs capacity values compatible classes shapes

end Host.Load.Run.Full
