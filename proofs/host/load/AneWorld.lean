import host.load.World
import host.mlx.FfiAne
namespace Host.Load.Ane
open Host.Ts
open Host.Mlx

/-! # The load world with the Neural Engine bridge's buffers

The world of the Neural Engine prompt pieces: the load world (`Host.Load.ffi`)
with the bridge model of `Host.Mlx.FfiAne` around it. Its state is the load
world's and the bridge's (`ASt`):

* `mbane_program_create` is the load world's call (the same handle, a fresh
  host object `HObj.ane n` for the `n`-th create) and records the program,
  its surfaces and its share;
* `mbane_input`, `mbane_output`, `mbane_eval_async`, `mbane_wait`,
  `mbane_free` act on the bridge state (the handle decoded through the load
  world's host objects); the load world has no model of them;
* every `mlx_*` call is `FfiAne.mlxCall`: `Host.Mlx.Ffi.call` on the load
  world's mlx state, a surface wrap for `mlx_array_new_data_managed_payload`,
  and the bridge's bookkeeping once a surface is wrapped;
* every other call, memory reads and trace continuations are the load
  world's (continuations classify replayed nodes).

The load world's dispatch is unchanged: its proofs (native lawfulness,
growth) and checked runs stand, and load and decode behave exactly as there
(`call_load`, `call_mlx_inactive`). A machine state of a checked load run
enters this world through `lift`, which rebuilds the bridge state from the
run's FFI trace (`FfiAne.ofTrace`: the creates, in order). -/

structure ASt where
  base : LSt
  bridge : FfiAne.St

abbrev R := M (Option (ASt × Ret × List (Nat × Nat × List Byte)))

/-- The create call a program handle argument names (`HObj.ane n`). -/
def handleN (h : HostSt) (a : Arg) : Option Nat :=
  match objArgH h a with
  | some (.ane n) => some n
  | _ => none

def onHandle (s : ASt) (a : Arg) (f : Nat → Option (FfiAne.St × Ret)) : R :=
  match handleN s.base.host a with
  | some n => match f n with
    | some (b, r) => .pure (some ({ s with bridge := b }, r, []))
    | none => .pure none
  | none => .pure none

/-- The load world's call, the bridge state unchanged. -/
def baseCall (s : ASt) (name : Name) (args : List Arg) : R :=
  .bind (Host.Load.call s.base name args) fun
    | some (l, r, ws) => .pure (some (⟨l, s.bridge⟩, r, ws))
    | none => .pure none

def bridgeSym (name : Name) : Bool :=
  nameEq name chars!"mbane_program_create" || nameEq name chars!"mbane_input" || nameEq name chars!"mbane_output" ||
    nameEq name chars!"mbane_eval_async" || nameEq name chars!"mbane_wait" || nameEq name chars!"mbane_free"

def call (s : ASt) (name : Name) (args : List Arg) : R :=
  bif isMlx name then .bind (FfiAne.mlxCall s.bridge s.base.mlx name args) fun
    | some (m, b, r, ws) => .pure (some (⟨{ s.base with mlx := m }, b⟩, r, ws))
    | none => .pure none
  else bif nameEq name chars!"mbane_program_create" then
    let share := match args with
      | [_, _, _, _, _, _, _, _, sh, _, _, _] => handleN s.base.host sh
      | _ => none
    .bind (Host.Load.call s.base name args) fun
      | some (l, r, ws) => .pure (some (⟨l, FfiAne.create s.bridge s.base.host.ane args share⟩, r, ws))
      | none => .pure none
  else bif nameEq name chars!"mbane_input" then match args with
    | [h, i] => onHandle s h fun n => FfiAne.input s.bridge n i
    | _ => .pure none
  else bif nameEq name chars!"mbane_output" then match args with
    | [h] => onHandle s h (FfiAne.output s.bridge)
    | _ => .pure none
  else bif nameEq name chars!"mbane_eval_async" then match args with
    | [h] => onHandle s h (FfiAne.evalAsync s.bridge)
    | _ => .pure none
  else bif nameEq name chars!"mbane_wait" then match args with
    | [h, _, _] => onHandle s h (FfiAne.wait s.bridge)
    | _ => .pure none
  else bif nameEq name chars!"mbane_free" then match args with
    | [h] => onHandle s h (FfiAne.free s.bridge)
    | _ => .pure none
  else baseCall s name args

def read (s : ASt) (r off n : Nat) : Option (List Byte) := Host.Load.read s.base r off n

def back (s : ASt) (a : Arg) : R :=
  .bind (FfiAne.back s.bridge s.base.mlx a) fun
    | some (m, b, r, ws) => .pure (some (⟨{ s.base with mlx := m }, b⟩, r, ws))
    | none => .pure none

def ffi : Ffi := ⟨ASt, call, read, fun _ => 4096, back⟩

/-- A machine state of the load world in this world, the bridge rebuilt from its trace. -/
def lift (s : Host.Ts.St LSt) : Host.Ts.St ASt :=
  { heap := s.heap, next := s.next, ctl := s.ctl, stack := s.stack,
    aux := { jobs := s.aux.jobs, ffi := ⟨s.aux.ffi, FfiAne.ofTrace s.aux.trace⟩, trace := s.aux.trace,
             stores := s.aux.stores } }

/-! ## Load and decode are the load world's -/

/-- Outside MLX and the bridge, a call is the load world's. -/
theorem call_load (s : ASt) (name : Name) (args : List Arg) (hm : isMlx name = false) (hb : bridgeSym name = false) :
    call s name args = baseCall s name args := by
  simp only [bridgeSym, Bool.or_eq_false_iff] at hb
  obtain ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩, h6⟩ := hb
  simp only [call, hm, h1, h2, h3, h4, h5, h6, Bool.cond_false]

/-- Before any surface is wrapped, an MLX call other than a wrap is
`Host.Mlx.Ffi.call` on the load world's mlx state, as the load world makes it. -/
theorem call_mlx_inactive (s : ASt) (name : Name) (args : List Arg) (hm : isMlx name = true)
    (ha : s.bridge.active = false) (hp : nameEq name FfiAne.payloadName = false) :
    call s name args = baseCall s name args := by
  funext γ k
  simp only [call, baseCall, hm, Bool.cond_true, FfiAne.mlxCall, hp, Bool.cond_false, Host.Load.call, M.bind]
  congr 1
  funext o
  rcases o with _ | ⟨m, r, ws⟩
  · rfl
  · simp only [ha, Bool.cond_false]; rfl

end Host.Load.Ane
