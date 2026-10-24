import host.sim.full.SymAccept
import host.sim.full.Rel
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf Pending)

/-! # `mlx_vector_array_set_data` into a pending trace's result

A compiled closure's first application records its trace through a `JSCallback`
(`packages/mlx/src/compile.ts`, the trampoline): the model returns the callback with the result
vector `.extPtr (4·id + 2) 0` of the pending trace `id` (`Ffi.closureApply`), and the callback
ends with `mlx_vector_array_set_data(resPtr, ptr(handles), n)`, which sets the pending trace's
outputs (`Ffi.call`'s `vecSetData` arm). Its first argument is a region the map renames: the
target's call names its own pending trace only where the map sends the pending result regions
in step with the handles (`PendReg`), which `G.MR` does not state. `sim_vecSetData` is the
simulation under `PendReg`; `NativeOkX.vset` its decider (a JS buffer of node handles, as
`mlx_vector_array_new_data`'s). -/

/-- `vecSetData`'s decider: a pending result region and a JS buffer of node handles. -/
def NativeOkX.vset (P : LoadP) (x : NSt) : List Arg → Bool
  | [.extPtr _ 0, p, c] => handlesOk P x p c
  | _ => false

/-- Setting the head pending trace's outputs keeps the relation. -/
theorem MR.setRes {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y) {q : Pending}
    {rest : List Pending} (ns : List Nat) :
    MR P NB M n { x with pending := { q with res := some ns } :: rest }
      { y with pending := { M.pend q with res := some (ns.map M.node) } :: rest.map M.pend } :=
  { hr with pending := rfl }

/-- The model's `vecSetData` on the pending traces. -/
def vsetPend (s : NSt) (r : Nat) (ns : List Nat) : Host.Mlx.Ffi.R :=
  match s.pending with
  | q :: rest => bif Nat.beq q.id (r / 4) then
      Host.Mlx.Ffi.ok { s with pending := { q with res := some ns } :: rest } Host.Mlx.Ffi.status0
    else Host.Mlx.Ffi.stuck
  | [] => Host.Mlx.Ffi.stuck

/-- The model's `vecSetData` arm once the outputs are decoded. -/
def vsetProg (s : NSt) (r : Nat) (o : Option (List Nat)) : Host.Mlx.Ffi.R :=
  match o with
  | some ns => bif Nat.beq (r % 4) 2 then vsetPend s r ns else Host.Mlx.Ffi.stuck
  | none => Host.Mlx.Ffi.stuck

theorem call_vecSetData (s : NSt) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .vecSetData) (r : Nat)
    (p c : Arg) :
    Host.Mlx.Ffi.call s name [.extPtr r 0, p, c] = vsetProg s r ((Host.Mlx.Ffi.handlesArg p c).bind (Host.Mlx.Ffi.nodesOf s)) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  unfold vsetProg vsetPend
  rfl

theorem vsetPend_cons {s : NSt} {q : Pending} {rest : List Pending} (h : s.pending = q :: rest) (r : Nat) (ns : List Nat) :
    vsetPend s r ns = bif Nat.beq q.id (r / 4) then
      Host.Mlx.Ffi.ok { s with pending := { q with res := some ns } :: rest } Host.Mlx.Ffi.status0
    else Host.Mlx.Ffi.stuck := by
  unfold vsetPend; rw [h]

theorem vsetPend_nil {s : NSt} (h : s.pending = []) (r : Nat) (ns : List Nat) :
    vsetPend s r ns = Host.Mlx.Ffi.stuck := by
  unfold vsetPend; rw [h]

/-- `vsetProg` makes no request. -/
theorem vsetProg_pure (s : NSt) (r : Nat) (o : Option (List Nat)) : ∃ q, ∀ γ k, vsetProg s r o γ k = k q := by
  rcases o with _ | ns
  · exact ⟨_, fun _ _ => rfl⟩
  · show ∃ q, ∀ γ k, (bif Nat.beq (r % 4) 2 then vsetPend s r ns else Host.Mlx.Ffi.stuck) γ k = k q
    cases Nat.beq (r % 4) 2
    · exact ⟨_, fun _ _ => rfl⟩
    · show ∃ q, ∀ γ k, vsetPend s r ns γ k = k q
      cases hp : s.pending with
      | nil => rw [vsetPend_nil hp]; exact ⟨_, fun _ _ => rfl⟩
      | cons q rest => rw [vsetPend_cons hp]; cases Nat.beq q.id (r / 4) <;> exact ⟨_, fun _ _ => rfl⟩

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

/-- **`mlx_vector_array_set_data` into a pending trace's result**, the map renaming the pending
result regions with the handles. -/
theorem sim_vecSetData (hsym : Host.Mlx.Ffi.symOf name = some .vecSetData) {r : Nat} {p c : Arg}
    (hok : handlesOk P x p c = true) (hpr : PendReg M x y) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [.extPtr r 0, p, c])
      (Host.Mlx.Ffi.call y name [.extPtr (M.region r) 0, M.arg p, M.arg c]) := by
  rw [call_vecSetData x hsym, call_vecSetData y hsym]
  cases hh : Host.Mlx.Ffi.handlesArg p c with
  | none => exact msim_stuck' hs (vsetProg_pure _ _ _)
  | some hds =>
    obtain ⟨e1, hp⟩ := hr.handlesArg_map hok hh
    rw [Option.bind_some, e1, Option.bind_some, hr.nodesOf_map hp]
    cases hn : Host.Mlx.Ffi.nodesOf x hds with
    | none => exact msim_stuck' hs (vsetProg_pure _ _ _)
    | some ns =>
      show MSim _ S C (bif Nat.beq (r % 4) 2 then vsetPend x r ns else Host.Mlx.Ffi.stuck)
        (vsetProg y (M.region r) (some (ns.map M.node)))
      cases h4 : Nat.beq (r % 4) 2
      · exact msim_stuck' hs (vsetProg_pure _ _ _)
      · show MSim _ S C (vsetPend x r ns) _
        cases hpx : x.pending with
        | nil => rw [vsetPend_nil hpx]; exact msim_stuck' hs (vsetProg_pure _ _ _)
        | cons q rest =>
          rw [vsetPend_cons hpx]
          cases hid : Nat.beq q.id (r / 4)
          · exact msim_stuck' hs (vsetProg_pure _ _ _)
          · have e4 : r % 4 = 2 := Nat.eq_of_beq_eq_true h4
            have eid : q.id = r / 4 := Nat.eq_of_beq_eq_true hid
            have hr4 : r = 4 * q.id + 2 := by omega
            have hreg : M.region r = 4 * M.handle q.id + 2 := by
              rw [hr4]; exact (hpr.reg q (by rw [hpx]; exact List.mem_cons_self ..)).2.1
            have hpy : y.pending = M.pend q :: rest.map M.pend := by rw [hr.pending, hpx]; rfl
            have t4 : Nat.beq (M.region r % 4) 2 = true := by rw [hreg]; simp
            have tid : Nat.beq (M.pend q).id (M.region r / 4) = true := by
              rw [hreg]; show Nat.beq (M.handle q.id) ((4 * M.handle q.id + 2) / 4) = true; simp; omega
            show MSim _ S C _ (bif Nat.beq (M.region r % 4) 2 then vsetPend y (M.region r) (ns.map M.node)
              else Host.Mlx.Ffi.stuck)
            rw [t4, Bool.cond_true, vsetPend_cons hpy, tid, Bool.cond_true]
            exact msim_ok' hs hr rfl (hr.setRes ns)

end

end Host.Ts.Sim.G
