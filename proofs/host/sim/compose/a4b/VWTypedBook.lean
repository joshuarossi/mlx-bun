import host.sim.compose.a4b.VWG1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route

theorem ForwardBook.prompt {i : Lin.Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : ForwardBook i π K0 x Dmax) : x.K.fr 2665 = some ([], π.map natV) := by
  rw [hb.frames]
  change (g1Framed K0 π i.n).fr 2665 = _
  exact hb.incomingPrompt

theorem ForwardBook.chunk {i : Lin.Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : ForwardBook i π K0 x Dmax) : x.K.fr VWFrames.chunk = some ([], (π.take i.n).map natV) := by
  rw [hb.frames]
  rfl

theorem ForwardBook.buffer {i : Lin.Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : ForwardBook i π K0 x Dmax) : x.K.fr VWFrames.buffer = some ([], []) := by
  rw [hb.frames]
  rfl

theorem ForwardBook.view {i : Lin.Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : ForwardBook i π K0 x Dmax) : x.K.fr VWFrames.view = some ([], []) := by
  rw [hb.frames]
  rfl

theorem ForwardBook.memo {i : Lin.Cls.Inst} {π : List Nat} {K0 : Ctx} {x : SegInst FF} {Dmax : Nat}
    (hb : ForwardBook i π K0 x Dmax) : x.K.fr 4910 = none := by
  rw [hb.frames]
  exact hb.incomingMemo

def compactW (bs : List Byte) (n : Nat) : Nat → Option WFrame :=
  Disp.wAt (Disp.wAt noFrames VWFrames.buffer (.buf bs)) VWFrames.view (.typed .i32 VWFrames.buffer 0 n)

theorem compactW_agree (bs : List Byte) (n : Nat) {K : Ctx} (hmemo : K.fr 4910 = none) :
    ∀ a, K.fr a ≠ none → compactW bs n a = VWFrames.typedW bs n a := by
  intro a ha
  by_cases hv : a = VWFrames.view
  · subst hv; rfl
  · by_cases hb : a = VWFrames.buffer
    · subst hb; rfl
    · simpa only [compactW, VWFrames.typedW, Disp.wAt, beq_false hv, beq_false hb, Bool.cond_false] using
        (Host.Ts.Sim.Compose.SetupChunk.wideInactive hmemo a ha).symm

theorem compactW_domain {bs : List Byte} {n a : Nat} {w : WFrame} (hw : compactW bs n a = some w) :
    a = VWFrames.buffer ∨ a = VWFrames.view := by
  by_cases hv : a = VWFrames.view
  · exact .inr hv
  · by_cases hb : a = VWFrames.buffer
    · exact .inl hb
    · simp only [compactW, Disp.wAt, beq_false hv, beq_false hb, Bool.cond_false, noFrames] at hw
      cases hw

theorem compactW_none {bs : List Byte} {n a : Nat} (hb : a ≠ VWFrames.buffer) (hv : a ≠ VWFrames.view) :
    compactW bs n a = none := by
  simp only [compactW, Disp.wAt, beq_false hb, beq_false hv, Bool.cond_false, noFrames]

end Host.Ts.Sim.Compose.VWFirst
