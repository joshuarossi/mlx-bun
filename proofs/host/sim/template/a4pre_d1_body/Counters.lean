import host.sim.template.a4pre_d1_body.Entry
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyCounters
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Template Host.Route
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.SetupD1 Host.Ts.Sim.Prefill
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl startHandles : (mlxOf D1Call.s1.ffi).next = 18156
kernel_rfl startNodes : (mlxOf D1Call.s1.ffi).nnext = 15236
kernel_rfl startHeap : D1Call.s1.next = 2673518

theorem nativeDelta {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx}
    {x x' : SegInst FF}
    (h0 : RelB FF (Disp.FRJ (FullRXD {setupP with rest := machReads T tk} NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K D1Call.s1
      ⟨D1Call.S1.tab, []⟩ x.t x.C)
    (h1 : (D1BodyAdvance.cut NB T tk π K0 x.M (mlxOf x.t.ffi) D1Body.s155 D1Body.S155).R
      x' D1Body.s155 ⟨D1Body.S155.tab, []⟩)
    (he : Ext x.M x'.M 17) :
    (mlxOf x'.t.ffi).next = (mlxOf x.t.ffi).next + 3830 ∧
    (mlxOf x'.t.ffi).nnext = (mlxOf x.t.ffi).nnext + 2528 := by
  obtain ⟨P0, hP0, r0⟩ := h0.ffi.1
  obtain ⟨P1, hP1, r1⟩ := h1.1.ffi.1.1
  have hE0 : P0.E = 131072 := by
    rcases hP0 with rfl | ⟨k, _, _, rfl⟩ <;> rfl
  have hE1 : P1.E = 131072 := by
    rcases hP1 with rfl | ⟨k, _, _, rfl⟩ <;> rfl
  have a0 := r0.load.mlx.hfreshB 3830 (by
    change (mlxOf D1Call.s1.ffi).next + 3830 < P0.E
    rw [startHandles, hE0]; decide)
  have a1 := r1.load.mlx.hfreshB 0 (by
    change (mlxOf D1Body.s155.ffi).next + 0 < P1.E
    rw [D1Body.handleCounter, hE1]; decide)
  have n0 := r0.load.mlx.nfresh 2528
  have n1 := r1.load.mlx.nfresh 0
  change x.M.big 21986 = Int.ofNat ((mlxOf x.t.ffi).next + 3830) at a0
  change x'.M.big 21986 = Int.ofNat (mlxOf x'.t.ffi).next at a1
  change x.M.node 17764 = (mlxOf x.t.ffi).nnext + 2528 at n0
  change x'.M.node 17764 = (mlxOf x'.t.ffi).nnext at n1
  rw [he.big] at a1
  rw [he.node] at n1
  exact ⟨Int.ofNat_inj.mp (a1.symm.trans a0), n1.symm.trans n0⟩

theorem heapDelta {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {K0 : Host.Ts.Sim.Ctx}
    {x x' : SegInst FF}
    (h0 : RelB FF (Disp.FRJ (FullRXD {setupP with rest := machReads T tk} NB))
      (D1Frames.typedW (D1Typed.bytes π)) [] x.M x.ν x.K D1Call.s1
      ⟨D1Call.S1.tab, []⟩ x.t x.C)
    (hb : ForwardBook π K0 x)
    (h1 : (D1BodyAdvance.cut NB T tk π K0 x.M (mlxOf x.t.ffi) D1Body.s155 D1Body.S155).R
      x' D1Body.s155 ⟨D1Body.S155.tab, []⟩) :
    x'.t.next = x.t.next + 153261 ∧ x'.K.D = 13 ∧
    x'.K.lo = setupP.lo ∧ x'.K.hi = setupP.E := by
  obtain ⟨origin, hf, hp⟩ := h1.2
  refine ⟨?_, hf.offset, hf.lo.trans hf.incoming.1.1, hf.hi.trans hf.incoming.1.2.1⟩
  rw [h1.1.offset, h0.offset, hf.offset, hb.offset, startHeap, D1Body.heapCounter]

end Host.Load.Run.Tpl.D1BodyCounters

-- rechecked: literal chunk length
