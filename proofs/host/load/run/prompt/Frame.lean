import host.load.run.prompt.H88
import host.load.run.prompt.FrameRel
import host.load.run.tail.Command
import host.ts.Harness
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Load

/-! The prompt at `loadDone`: the states for two prompts differ only in the array at 2665
(`PROMPT`'s cell 2666 holds it), so the empty prompt's state frames every prompt's
(`FrameRel.relF_frame`: identity map, frame at 2665 `([], fw)`). -/

def promptObj (fw : List Val) : Obj := ⟨.array fw, .obj aArrayProto, [], [], true⟩

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager frame : ∀ fw : List Val, P.a2818 fw = (P.a2818 []).setObj 2665 (promptObj fw)

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager prompt_obj : ∀ fw : List Val, (P.a2818 fw).heap.get 2665 = some (.obj (promptObj fw))

set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
kernel_rfl_eager prompt_cell : ∀ fw : List Val, (P.a2818 fw).heap.get 2666 = some (.cell (some (.obj 2665)))

set_option maxRecDepth 1000000 in
kernel_rfl prompt_binding : lookupEnv chars!"PROMPT" (entryEnv P.s0) = some 2666

/-- **The relation at `loadDone`**: under the identity map, with the prompt array framed
(template prefix `[]`, target prefix `fw`), the empty prompt's state is related to the state
for `fw`, given the empty prompt's closedness, native relation and server facts. -/
theorem rel_loadDone {FR : Map → Nat → LSt → LSt → Prop} {ν : Nat → F64} {S : SSrv} {C : CSrv}
    (lo hi : Nat) (fw : List Val) (h : FrameRel.Hyps Host.Load.ffi FR ν S C lo hi (P.a2818 [])) :
    Rel Host.Load.ffi FR Map.id ν (FrameRel.ctx (P.a2818 []) 2665 fw lo hi)
      (P.a2818 []) S (P.a2818 fw) C := by
  rw [frame fw]
  exact FrameRel.relF_frame h (prompt_obj []) rfl (by decide)

end Host.Load.Run.Prompt
