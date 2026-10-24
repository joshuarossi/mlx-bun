import host.sim.full.World

/-! # The template's abstract readback suffix into the target's remaining readbacks

A template state's mlx token queue can end in an abstract suffix `τ` (references standing for the
target's later readbacks, which the template does not read within the run that follows): the decode
template's start holds the look-ahead reference and `τ`. The relation then carries `τ`'s images as
the target's remaining readbacks (`P.rest`) and the template keeps only the queue's head
(`FullR.dropTokens`, `RelF.dropTokens`): the decode loop runs from that start, its end has read all
of its tokens (`MShift.tokens`) and the restart (`full_restart_drop`) is unchanged, the remaining
readbacks shrinking by one per iteration. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-- The source's mlx tokens replaced by `ts`. -/
def fullSetTokens (x : FF.S) (ts : List NumV) : FF.S :=
  ((⟨{ x.1.1.base with mlx := { x.1.1.base.mlx with tokens := ts } }, x.1.1.bridge⟩, x.1.2), x.2)

/-- **The template's token suffix `τ` into the remaining readbacks** (`G.LoadR`). -/
theorem _root_.Host.Ts.Sim.G.LoadR.dropTokens {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : Host.Load.LSt}
    {live τ : List NumV} {r : List NumV} (hr : G.LoadR { P with rest := r } NB M n x y) (hx : x.mlx.tokens = live ++ τ) :
    G.LoadR { P with rest := τ.map M.nv ++ r } NB M n { x with mlx := { x.mlx with tokens := live } } y := by
  have hm := hr.mlx
  have hc := hm.cl
  have ht : y.mlx.tokens = live.map M.nv ++ (τ.map M.nv ++ r) := by
    rw [hm.tokensX, hx, List.map_append, List.append_assoc]
  refine ⟨hr.host, hr.hostReg, hr.hostLt, hr.cbr, { hm with tokens := ⟨_, ht⟩, tokensX := ht, cl := ?_ }⟩
  refine ⟨hc.1, hc.2.1, fun t h => hc.2.2.1 t ?_, hc.2.2.2.1, hc.2.2.2.2⟩
  show t ∈ x.mlx.tokens
  rw [hx]; exact List.mem_append_left _ h

/-- **The template's token suffix `τ` into the remaining readbacks.** -/
theorem FullR.dropTokens {P : LoadP} {NB : Nat} {r : List NumV} {M : Map} {n : Nat} {x y : FF.S}
    {live τ : List NumV} (hr : FLR P NB r M n x y) (hx : (mlxOf x).tokens = live ++ τ) :
    FLR P NB (τ.map M.nv ++ r) M n (fullSetTokens x live) y :=
  ⟨G.LoadR.dropTokens hr.load hx, hr.bridge, hr.live.ofObjs rfl, hr.kern.ofObjs rfl, hr.pend.congr rfl rfl⟩

/-- **The template's token suffix `τ` into the remaining readbacks**, at a state relation. -/
theorem RelF.dropTokens {P : LoadP} {NB : Nat} {r : List NumV} {W : Nat → Option WFrame} {M : Map} {ν : Nat → F64}
    {K : Ctx} {s t : St FF.S} {S : SSrv} {C : CSrv} {live τ : List NumV} (h : RelF FF (FLR P NB r) W M ν K s S t C)
    (hx : (mlxOf s.ffi).tokens = live ++ τ) :
    RelF FF (FLR P NB (τ.map M.nv ++ r)) W M ν K (s.setFfi (fullSetTokens s.ffi live)) S t C :=
  { h with ffi := FullR.dropTokens h.ffi hx }

end Host.Ts.Sim.Full
