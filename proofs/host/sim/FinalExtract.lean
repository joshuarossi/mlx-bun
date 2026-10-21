import host.sim.Iter
import host.load.Extract
namespace Host.Ts.Sim
open Host.Ts

/-! # Reading the emitted tokens off a related target

The driver's `emitted` binding (an environment cell holding the framed output
array) reads, in a related target, as the array's target prefix followed by the
images of the source's appended elements. -/

theorem Rel.emitted {FR : Map → Nat → Host.Load.LSt → Host.Load.LSt → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St Host.Load.LSt} {S : SSrv} {C : CSrv} (h : Rel Host.Load.ffi FR M ν K s S t C)
    {env : Env} {n : Name} {cE b : Nat} {pre pre' xs : List Val} {o : Obj}
    (hl : lookupEnv n env = some cE) (hc : s.cell? cE = some (some (.obj b)))
    (hfa : M.a cE = cE) (hfb : M.a b = b) (hk : K.fr b = some (pre, pre'))
    (hg : s.heap.get b = some (.obj o)) (hkind : o.kind = .array (pre ++ xs)) :
    (bindingOf t env n).bind (Host.Load.Extract.elements t) = some (pre' ++ M.vals xs) := by
  have hc' : t.cell? cE = some (some (.obj b)) := by
    have := h.cell? hc
    rw [hfa] at this
    exact this.trans (by show some (some (Val.obj (M.a b))) = _; rw [hfb])
  obtain ⟨o', hg', hk'⟩ := h.framed_target hk hg hkind
  rw [hfb] at hg'
  unfold bindingOf
  rw [hl, Option.bind_some, hc']
  show Host.Load.Extract.elements t (.obj b) = _
  have ho : t.obj? b = some o' := by simp only [St.obj?, hg']
  simp [Host.Load.Extract.elements, Host.Load.Extract.object, ho, hk']

end Host.Ts.Sim
