import kernels.attention.MlxSdpaTwoPassMemory

namespace Inference.Kernels.Attention.MlxSdpaTwoPassFirstSource
open Contracts.Mlx State MlxSdpaTwoPassSyntax MlxSdpaTwoPassMemory
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

-- Alpha-renaming is performed on identifier TOKENS, never substrings. The
-- ordinary first-pass i-indexed update is the previously checked j-indexed
-- eight-register grammar, with exactly the same expression/barrier order.
def parseUpdate (source : String) : Option MlxSdpaUpdateSource.Update := do
  let tokens ←MlxSdpaScoreSource.lex (source.length+1) source.toList
  let canonical ←MlxSdpaScoreSource.lex (MlxSdpaUpdateSource.sourceBody.length+1) MlxSdpaUpdateSource.sourceBody.toList
  if tokens.map (fun t => if t="i" then "j" else t)=canonical then
    MlxSdpaUpdateSource.parse MlxSdpaUpdateSource.sourceBody
  else none

def sourceUpdate : String := r#"U new_max = max(max_score, score);
      U factor = fast::exp(max_score - new_max);
      U exp_score = fast::exp(score - new_max);

      max_score = new_max;
      sum_exp_score = sum_exp_score * factor + exp_score;

      for (int i = 0; i < v_per_thread; i++) {
        o[i] = o[i] * factor + exp_score * values[i];
      }"#
theorem parsed_update : parseUpdate sourceUpdate=some ⟨0⟩ := by decide +kernel

variable {steps : Nat} {query : Fin 24 → Fin 256 → ArrayStorage.BF} {cache : Kv.Cache Kv.BF steps}
  {p : SdpaVector.Platform} {blocks : Nat}

def updateSource (p : SdpaVector.Platform) (input : SdpaMemory.Input query cache) (head : Fin 24)
    (block : Fin blocks) (lane : Fin 32) (iteration : Nat) (item : Fin 8) (state : SdpaUpdate.State) : Option SdpaUpdate.State := do
  let score ←scoreSource p input head block iteration
  let ast ←parseUpdate sourceUpdate
  pure (MlxSdpaUpdateSource.evaluate ast p.merge.scalar p.maximum state score
    (value input.cache.memory input.cache.layout.valueBase (KvAllocation.capacity steps) blocks head block lane iteration item) item)

theorem current_update (input : SdpaMemory.Input query cache) (head : Fin 24) (block : Fin blocks)
    (lane : Fin 32) (iteration : Fin (SdpaTwoPassLayout.count steps blocks block)) (item : Fin 8) (state : SdpaUpdate.State) :
    updateSource p input head block lane iteration.val item state=
      some (SdpaLoop.next p.merge.scalar p.maximum
        (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)))
        (SdpaVector.valuesAt (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item))
        (SdpaTwoPassLayout.key steps blocks block iteration) state) := by
  unfold updateSource
  rw [current_score,parsed_update]
  change some (MlxSdpaUpdateSource.evaluate ⟨0⟩ p.merge.scalar p.maximum state _ _ item)=_
  rw [MlxSdpaUpdateSource.evaluate_eq,value_current input head block lane iteration item]
  rfl

inductive Executes (p : SdpaVector.Platform) (input : SdpaMemory.Input query cache)
    (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    List (Fin (SdpaTwoPassLayout.count steps blocks block)) → SdpaUpdate.State → SdpaUpdate.State → Prop where
  | done (state) : Executes p input head block lane item [] state state
  | next (iteration) (start middle finish) (rest)
      (parsed : updateSource p input head block lane iteration.val item start=some middle)
      (tail : Executes p input head block lane item rest middle finish) :
      Executes p input head block lane item (iteration::rest) start finish

variable {input : SdpaMemory.Input query cache} {head : Fin 24} {block : Fin blocks} {lane : Fin 32} {item : Fin 8}
  {ordinals : List (Fin (SdpaTwoPassLayout.count steps blocks block))} {start finish : SdpaUpdate.State}

theorem refinement (run : Executes p input head block lane item ordinals start finish) :
    finish=SdpaLoop.run p.merge.scalar p.maximum
      (SdpaVector.scores p (query head) (cache.keys (SdpaScore.kvHead head)))
      (SdpaVector.valuesAt (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item))
      (ordinals.map (SdpaTwoPassLayout.key steps blocks block)) start := by
  induction run with
  | done state => rfl
  | next iteration start middle finish rest parsed tail ih =>
    have step := current_update input head block lane iteration item start (p:=p)
    rw [parsed] at step
    rw [ih,Option.some.inj step]
    rfl

theorem exists_execution (input : SdpaMemory.Input query cache) (head : Fin 24) (block : Fin blocks) (lane : Fin 32)
    (item : Fin 8) (ordinals : List (Fin (SdpaTwoPassLayout.count steps blocks block))) (start : SdpaUpdate.State) :
    ∃ finish, Executes p input head block lane item ordinals start finish := by
  induction ordinals generalizing start with
  | nil => exact ⟨start,.done start⟩
  | cons iteration rest ih =>
    have step := current_update input head block lane iteration item start (p:=p)
    obtain ⟨finish,tail⟩ := ih _
    exact ⟨finish,.next iteration start _ finish rest step tail⟩

theorem complete_exists (input : SdpaMemory.Input query cache) (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    ∃ finish, Executes p input head block lane item (List.finRange (SdpaTwoPassLayout.count steps blocks block))
      (SdpaLoop.initial SdpaVector.initialShift) finish ∧
      finish=SdpaTwoPassFirstPass.raw p (query head) (cache.keys (SdpaScore.kvHead head))
        (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item) block := by
  obtain ⟨finish,run⟩ := exists_execution input head block lane item
    (List.finRange (SdpaTwoPassLayout.count steps blocks block)) (SdpaLoop.initial SdpaVector.initialShift) (p:=p)
  refine ⟨finish,run,?_⟩
  rw [refinement run]
  have schedule : (List.finRange (SdpaTwoPassLayout.count steps blocks block)).map (SdpaTwoPassLayout.key steps blocks block)=SdpaTwoPassLayout.keys steps blocks block := by
    change (List.ofFn id).map (SdpaTwoPassLayout.key steps blocks block)=_
    rw [List.map_ofFn]
    rfl
  rw [schedule]
  rfl

-- The protected input is in the same heap containing the completed first
-- pass writes. Neither logical cache/query values nor a phase result is added.
theorem protected_complete (execution : SdpaTwoPassShared.Execution input p blocks)
    (head : Fin 24) (block : Fin blocks) (lane : Fin 32) (item : Fin 8) :
    ∃ finish, Executes p execution.inputAfter head block lane item (List.finRange (SdpaTwoPassLayout.count steps blocks block))
      (SdpaLoop.initial SdpaVector.initialShift) finish ∧
      finish=SdpaTwoPassFirstPass.raw p (query head) (cache.keys (SdpaScore.kvHead head))
        (cache.values (SdpaScore.kvHead head)) (SdpaScore.index lane item) block :=
  complete_exists execution.inputAfter head block lane item

end Inference.Kernels.Attention.MlxSdpaTwoPassFirstSource
