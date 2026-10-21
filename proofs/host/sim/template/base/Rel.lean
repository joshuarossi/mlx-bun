import host.sim.template.base.Closed
import host.load.run.full.H102
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Load.Run.Full (P.s3272 P.S3272)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! The base relation: the template `Base.s0` is related to the actual ordinary readback
cut `P.s3272` of the five-token run, under the identity names and the template's fresh
number references sent to the cut's numbers (`Base.orig`). The template variables are
terms over the cut's table variables (`Base.θB`), so the relation holds at every valuation
`ρ` of the five-token run's variables, for every template server with the template's
table whose oracle is correct there. JavaScript part; it does not see the target's native
state (`RelJS.setFfi`); the native part is `LoadR` (`host.sim.native.Rel`). -/

/-- The cut's number for each template reference. -/
noncomputable def Base.numOf (i : Nat) : NumV := ((Base.orig.find? fun p => p.1 == i).map Prod.snd).getD (.ref i)

/-- Identity names; template references denote the cut's numbers. -/
noncomputable def Base.M : Map := ⟨fun a => a, Base.numOf, fun i => i, fun r => r, fun k => k⟩

/-- The template variables as terms over the cut's variables: the loop counters at iteration 1,
the current token (`var 2`) and the previous one (`var 1`), the capacity 256. -/
def Base.θB (v : Nat) : SymE :=
  match v with
  | 9 => .lit (F64.ofNat 3) | 10 => .lit (F64.ofNat 1) | 11 => .lit (F64.ofNat 1) | 12 => .lit (F64.ofNat 1)
  | 13 => .lit (F64.ofNat 0) | 14 => .var 2 | 15 => .var 1 | 16 => .lit (F64.ofNat 256) | j => .var j

/-- The valuation of the template variables for a valuation `ρ` of the run's variables. -/
def Base.νOf (ρ : Nat → F64) (j : Nat) : F64 := (Base.θB j).eval ρ

/-- The concrete server of the run at the cut, at `ρ`. -/
noncomputable def Base.COf (ρ : Nat → F64) : CSrv := ⟨P.S3272.tab.map (SymE.eval ρ)⟩

/-- The context: the framed arrays with the cut's own prefixes, the cut's event lists
as bases, no counter offset, the renamed-handle band `[25000, 131072)`. -/
noncomputable def Base.K : Host.Ts.Sim.Ctx :=
  ⟨frOf Base.s0 (arrOf P.s3272 2673447) (arrOf P.s3272 12502), Base.s0.trace, P.s3272.trace, 0, 25000, 131072⟩

tpl_heap_blocks Base.RelR from Base : Base.M, Base.s0, P.s3272

kernel_rfl Base.numB_check : checkNum Base.M Base.θB Base.S0 P.S3272 = true

theorem Base.numOK (ρ : Nat → F64) : NumOK Base.M (Base.νOf ρ) Base.S0 (Base.COf ρ) :=
  numOK_of_subst (checkNum_sound Base.numB_check) ρ
kernel_rfl Base.next_eq : P.s3272.next = Base.s0.next
kernel_rfl Base.ctl_eq : P.s3272.ctl = Base.M.ctl Base.s0.ctl
kernel_rfl Base.stack_eq : P.s3272.stack = Base.s0.stack.map Base.M.frame
kernel_rfl Base.jobs_eq : P.s3272.jobs = Base.s0.jobs.map Base.M.job
kernel_rfl Base.stores_eq : P.s3272.stores = Base.M.stores Base.s0.stores
kernel_rfl Base.f1g0 : Base.s0.heap.get 2673447 = some (.obj (objOf Base.s0 2673447))
kernel_rfl Base.f1k : (objOf Base.s0 2673447).kind = .array (arrOf Base.s0 2673447 ++ [])
kernel_rfl Base.f1t : P.s3272.heap.get 2673447 =
  some (.obj { Base.M.obj (objOf Base.s0 2673447) with kind := .array (arrOf P.s3272 2673447 ++ Base.M.vals []) })
kernel_rfl Base.f2g0 : Base.s0.heap.get 12502 = some (.obj (objOf Base.s0 12502))
kernel_rfl Base.f2k : (objOf Base.s0 12502).kind = .array (arrOf Base.s0 12502 ++ [])
kernel_rfl Base.f2t : P.s3272.heap.get 12502 =
  some (.obj { Base.M.obj (objOf Base.s0 12502) with kind := .array (arrOf P.s3272 12502 ++ Base.M.vals []) })

/-- The JavaScript part of `Rel` for the actual ordinary cut, at every valuation `ρ`, for every
template server `S` with the template's table whose oracle is correct there. -/
theorem Base.relJS (ρ : Nat → F64) (S : SSrv) (hS : S.tab = Base.S0.tab) (hg : Good (Base.νOf ρ) S.oracle) :
    RelJS Host.Load.ffi Base.M (Base.νOf ρ) Base.K Base.s0 S P.s3272 (Base.COf ρ) where
  srv := ⟨fun i e he => Base.numOK ρ i e (by rw [← hS]; exact he), hg⟩
  heap := by
    intro a h ha
    cases hk : Base.K.fr a with
    | none =>
      rw [SlotOK.none_iff hk]
      obtain ⟨q, hq, haq⟩ := Base.cover a h ha (frOf_none hk)
      rw [Base.RelR.heapAt q hq a haq, ha]
      rfl
    | some p =>
      obtain ⟨pre, pre'⟩ := p
      rw [SlotOK.some_iff hk]
      rcases frOf_some hk with ⟨rfl, hp⟩ | ⟨rfl, hp⟩ <;> simp only [Prod.mk.injEq] at hp <;> obtain ⟨rfl, rfl⟩ := hp
      · rw [Base.f1g0] at ha
        exact ⟨_, _, (Option.some.inj ha).symm, Base.f1t, [], Base.f1k, rfl⟩
      · rw [Base.f2g0] at ha
        exact ⟨_, _, (Option.some.inj ha).symm, Base.f2t, [], Base.f2k, rfl⟩
  next := by intro k; show Base.s0.next + k = P.s3272.next + k; rw [Base.next_eq]
  offset := by show P.s3272.next = Base.s0.next + 0; rw [Base.next_eq]; rfl
  room := by decide
  bigFixed := fun _ _ => rfl
  bigExt := fun _ _ _ => rfl
  band := by decide
  intr := fun _ _ => rfl
  bound := by intro a ha; show a < P.s3272.next; rw [Base.next_eq]; exact Base.presentBound a ha
  inj := fun _ _ _ _ h => h
  presentBound := Base.presentBound
  framedPresent := by
    intro a p hk
    rcases frOf_some hk with ⟨rfl, _⟩ | ⟨rfl, _⟩
    · exact Present.of_get Base.f1g0
    · exact Present.of_get Base.f2g0
  ctl := Base.ctl_eq
  stack := Base.stack_eq
  jobs := Base.jobs_eq
  stores := Base.stores_eq
  trace := ⟨[], rfl, rfl⟩
  heapSupp := by rw [hS, Base.tab_len]; exact Base.heapSupp
  ctlSupp := by rw [hS, Base.tab_len]; exact Base.rootsSupp.1
  stackSupp := by rw [hS, Base.tab_len]; exact Base.rootsSupp.2.1
  jobsSupp := by rw [hS, Base.tab_len]; exact Base.rootsSupp.2.2.1
  storesSupp := by rw [hS, Base.tab_len]; exact Base.rootsSupp.2.2.2
  traceSupp := ⟨[], rfl, fun _ h => by cases h⟩

end Host.Load.Run.Tpl
