import host.sim.State
namespace Host.Ts.Sim

/-! # A framed spread accumulator

The heap frames beyond framed arrays (buffers, typed arrays, ghost cells and objects, ghost
fields, `Map`s by key) are the frames `W` of `RelF` (`Rel.lean`). One more frame is on the
stack: the top frame `LitF.spread acc` of an array literal whose accumulator holds a framed
array's elements (`[...promptTokens, ...forwarded]`). `RelSp … sp` is `RelB` against the target
with its stack replaced by the source's image (and the stack base), and the target's stack
`StackW`: with `sp = some (P, E)` the source accumulator is `A ++ P`, the target's `M.vals A ++ E`.
With `sp = none` it is `RelB` (`RelSp.ofRelF`, `RelSp.toRelF`).

History-dependent counters (`nextTraceId`, `traceCalls`, `#traceId`) need no frame kind when
the template reads them: they are template variables (number references with free target
values); a counter the template never reads is a ghost cell or a ghost field.

The native side (`FR`) must tolerate target values that only frames reach (a ghost cell, a ghost
field or private member, a target-only `Map` entry or a ghost entry's value): such values may be
native handles (`.big`), native pointers (`.ptr (.ext _)`) or objects holding them, live on the
target with no source counterpart, and `M.big`/`M.region` need not be defined consistently on
them. The template side of a ghost holds no live native handle. -/

def StackW (M : Map) (stk : List Frame) : Option (List Val × List Val) → List Frame → List Frame → Prop
  | none, ss, ts => ts = ss.map M.frame ++ stk
  | some (P, E), ss, ts => ∃ A rest env fs, ss = .l (.spread (A ++ P) rest env) :: fs ∧
      ts = .l (.spread (M.vals A ++ E) rest (M.env env)) :: (fs.map M.frame ++ stk)

/-- `RelF` with the framed spread accumulator `sp` in the top frame. -/
def RelSp (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame) (M : Map) (ν : Nat → F64)
    (K : Ctx) (sp : Option (List Val × List Val)) (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop :=
  RelB F FR W stk M ν K s S { t with stack := s.stack.map M.frame ++ stk } C ∧ StackW M stk sp s.stack t.stack

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64}
  {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- The stack frames survive an extension of the map. -/
theorem StackW.agree {A : Nat → Prop} {n : Nat} {M M' : Map} (hA : Agree A n M M')
    {sp : Option (List Val × List Val)} {ss ts : List Frame} (hs : ∀ f ∈ ss, Supp.frame A n f)
    (h : StackW M stk sp ss ts) : StackW M' stk sp ss ts := by
  cases sp with
  | none =>
    show ts = ss.map M'.frame ++ stk
    rw [show ts = ss.map M.frame ++ stk from h]
    exact congrArg (· ++ stk) (List.map_congr_left fun f hf => Map.frame_agree hA (hs f hf))
  | some p =>
    obtain ⟨P, E⟩ := p
    obtain ⟨A', rest, env, fs, rfl, rfl⟩ := h
    have hf := hs _ (List.mem_cons_self ..)
    have hfs : ∀ f ∈ fs, Supp.frame A n f := fun f hf => hs f (List.mem_cons_of_mem _ hf)
    have hA' : Supp.vals A n A' := fun v hv => hf.1 v (List.mem_append_left _ hv)
    refine ⟨A', rest, env, fs, rfl, ?_⟩
    rw [Map.vals_agree hA hA', Map.env_agree hA hf.2,
      List.map_congr_left fun f hf => Map.frame_agree hA (hfs f hf)]

/-- `RelF` reads the target's heap only through `get`. -/
theorem RelB.heapCongr {t' : St F.S} (h : RelB F FR W stk M ν K s S t C) (hh : ∀ y, t'.heap.get y = t.heap.get y)
    (hn : t'.next = t.next) (hc : t'.ctl = t.ctl) (hs : t'.stack = t.stack) (ha : t'.aux = t.aux) :
    RelB F FR W stk M ν K s S t' C := by
  have hj : t'.jobs = t.jobs := by unfold St.jobs; rw [ha]
  have hst : t'.stores = t.stores := by unfold St.stores; rw [ha]
  have hf : t'.ffi = t.ffi := by unfold St.ffi; rw [ha]
  have htr : t'.trace = t.trace := by unfold St.trace; rw [ha]
  exact {
    srv := h.srv
    heap := fun a o hg => by rw [hh]; exact h.heap a o hg
    next := fun k => by rw [hn]; exact h.next k
    offset := by rw [hn]; exact h.offset
    room := h.room
    bigFixed := h.bigFixed
    bigExt := h.bigExt
    band := h.band
    intr := h.intr
    bound := fun a hp => by rw [hn]; exact h.bound a hp
    inj := h.inj
    presentBound := h.presentBound
    framedPresent := h.framedPresent
    ctl := by rw [hc]; exact h.ctl
    stack := by rw [hs]; exact h.stack
    jobs := by rw [hj]; exact h.jobs
    stores := by rw [hst]; exact h.stores
    ffi := by rw [hf]; exact h.ffi
    trace := by rw [htr]; exact h.trace
    heapSupp := h.heapSupp
    ctlSupp := h.ctlSupp
    stackSupp := h.stackSupp
    jobsSupp := h.jobsSupp
    storesSupp := h.storesSupp
    traceSupp := h.traceSupp }

/-- `RelF` is `RelSp` without an accumulator. -/
theorem RelSp.ofRelF (h : RelB F FR W stk M ν K s S t C) : RelSp F FR W stk M ν K none s S t C := by
  refine ⟨?_, h.stack⟩
  have e : ({ t with stack := s.stack.map M.frame ++ stk } : St F.S) = t := by rw [← h.stack]
  rw [e]; exact h

theorem RelSp.toRelF (h : RelSp F FR W stk M ν K none s S t C) : RelB F FR W stk M ν K s S t C :=
  h.1.heapCongr (fun _ => rfl) rfl rfl h.2 rfl

end

end Host.Ts.Sim
