import host.sim.template.World
import host.load.NativeFull
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The full stack as a template world

`fullWorld : TWorld Host.Load.Layers.full`: the template commands over the full stack
(kernel recording over liveness over symbolic shapes over the Neural Engine world). Its
native state is `FS`, the Neural Engine world's state (the load world's state and the
bridge's, `Ane.ASt`) with the two observers' states.

* Serialization: the load world's state by name as for the load world (`host.load.Stream`),
  the bridge state `FfiAne.St`, the released handles `Option (PTrie Unit)` and the kernel
  record `Option KRec` inline (`toExpr`; they are small on the route).
* `ofLoad`, a template cut from a load-world state: the bridge rebuilt from the trace
  (`FfiAne.ofTrace`, as `Ane.lift` and `LayerLift.full_lift`), the observers' states the
  chooser `obsFreed`/`obsKRec` of the trace: the handles the trace's object frees release,
  the flags of the kernels and the template arguments of the configurations it creates, in
  order (the folds `LayerLift.liveFold`/`kernFold` of an accepted run, read off its calls;
  relating the two is a kernel obligation of the boot lift, gen-plan G13).
  `fullFreshWorld` starts the observers fresh instead (`Layers.start`).
* Collection keeps the bridge's unscheduled and running nodes, and restricts the released
  handles, the kernel record and the bridge's aliases and touches to kept handles and nodes.
* The lockstep walk compares the bridge (surfaces, programs and create handles equal; aliases,
  touches, unscheduled, running and the effect log under the node map) and the observers
  (each kept released handle released at its image; flags and template arguments at the
  images of kept kernels and configurations, numbers paired as everywhere). -/

namespace Host.Ts.Sim.Template
open Lean Meta Host.Ts Host.Load Host.Mlx
open Host.Load.Layers (full KRec TArg toLoad)

deriving instance Lean.ToExpr for Host.Mlx.AneProgram
deriving instance Lean.ToExpr for Host.Mlx.FfiAne.Program
deriving instance Lean.ToExpr for Host.Mlx.FfiAne.Alias
deriving instance Lean.ToExpr for Host.Mlx.FfiAne.Touch
deriving instance Lean.ToExpr for Host.Mlx.FfiAne.Effect
deriving instance Lean.ToExpr for Host.Mlx.FfiAne.St
deriving instance Lean.ToExpr for Host.Load.Layers.TArg
deriving instance Lean.ToExpr for Host.Load.Layers.KRec

/-- The full stack's native state. -/
abbrev FS : Type := (Ane.ASt × Option (PTrie Unit)) × Option KRec

theorem full_S : full.S = FS := rfl

/-! ## The observers' states of a trace -/

/-- The handles the trace's object frees release (non-null handle arguments). -/
def obsFreed (tr : List Event) : PTrie Unit :=
  tr.foldl (fun t e => match Ffi.symOf e.sym, e.args with
    | some x, [a] => bif Layers.isObjFree x then match Ffi.argNat a with
        | some h => bif Nat.beq h 0 then t else t.set h ()
        | none => t
      else t
    | _, _ => t) PTrie.nil

/-- One call's kernel-record update (`Layers.kernCall` without the launch check). -/
def obsKStep (k : KRec) (e : Event) : KRec :=
  match Ffi.symOf e.sym, e.args, e.ret with
  | some .kernelNew, [_, _, _, _, _, rc, ao], .big h => match Ffi.argBool rc, Ffi.argBool ao with
    | some rc, some ao => { k with flags := k.flags.set h.toNat (rc, ao) }
    | _, _ => k
  | some .cfgNew, [], .big h => { k with targs := k.targs.set h.toNat [] }
  | some .cfgDtype, [c, nm, dt], _ => match Ffi.argNat c, Ffi.cstrArg nm, Ffi.argNat dt with
    | some h, some n, some d => match k.targs.get h with
      | some l => { k with targs := k.targs.set h (l ++ [(n, .dtype d)]) }
      | none => k
    | _, _, _ => k
  | some .cfgInt, [c, nm, .num v], _ => match Ffi.argNat c, Ffi.cstrArg nm with
    | some h, some n => match k.targs.get h with
      | some l => { k with targs := k.targs.set h (l ++ [(n, .int v)]) }
      | none => k
    | _, _ => k
  | _, _, _ => k

/-- The kernel record of the trace's calls, oldest first. -/
def obsKRec (tr : List Event) : KRec := tr.reverse.foldl obsKStep KRec.empty

/-- The full stack's state of a load-world machine state: the bridge from its trace, the
observers' states the chooser's. -/
def fullOfLoad (s : St LSt) : FS :=
  ((⟨s.aux.ffi, FfiAne.ofTrace s.aux.trace⟩, some (obsFreed s.aux.trace)), some (obsKRec s.aux.trace))

/-- The same with fresh observers (`Layers.start`). -/
def fullOfLoadFresh (s : St LSt) : FS := Layers.start ⟨s.aux.ffi, FfiAne.ofTrace s.aux.trace⟩

/-! ## Serialization, collection, walk -/

/-- The full stack's state: the load world's by name (`host.load.Stream`); the bridge state, its
programs, the released handles' and the kernel record's pages by name too, so a boundary
defines only what changed since the previous ones. -/
def serFull (p : FS) : Stream.GenM Lean.Expr := do
  let base ← Stream.StreamExpr.ser (α := LSt) p.1.1.base
  let b := p.1.1.bridge
  let progs ← Stream.named (toTypeExpr (List FfiAne.Program)) "bp" b.programs (fun x => pure (toExpr x))
  let bE ← Stream.named (toTypeExpr FfiAne.St) "br" b (fun b => pure (mkAppN (mkConst ``FfiAne.St.mk)
    #[toExpr b.surfaces, progs, toExpr b.handles, toExpr b.active, toExpr b.aliases, toExpr b.touch,
      toExpr b.unscheduled, toExpr b.running, toExpr b.log]))
  let pt (α : Lean.Expr) := mkApp (mkConst ``PTrie) α
  let unitT := mkConst ``Unit
  let fE ← match p.1.2 with
    | some f => do
      pure (mkApp2 (mkConst ``Option.some [.zero]) (pt unitT) (← Stream.ptrieE unitT "rl" (fun _ => pure (mkConst ``Unit.unit)) f))
    | none => pure (mkApp (mkConst ``Option.none [.zero]) (pt unitT))
  let kT := mkConst ``KRec
  let flT := toTypeExpr (Bool × Bool)
  let taT := toTypeExpr (List (List Char × TArg))
  let kE ← match p.2 with
    | some k => do
      let e := mkApp2 (mkConst ``KRec.mk) (← Stream.ptrieE flT "kf" (fun x => pure (toExpr x)) k.flags)
        (← Stream.ptrieE taT "kt" (fun x => pure (toExpr x)) k.targs)
      pure (mkApp2 (mkConst ``Option.some [.zero]) kT e)
    | none => pure (mkApp (mkConst ``Option.none [.zero]) kT)
  let aT := mkConst ``Ane.ASt
  let fT := mkApp (mkConst ``Option [.zero]) (pt unitT)
  let oT := mkApp (mkConst ``Option [.zero]) kT
  let a := mkApp2 (mkConst ``Ane.ASt.mk) base bE
  let inner := mkApp4 (mkConst ``Prod.mk [.zero, .zero]) aT fT a fE
  pure (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) aT fT) oT inner kE)

def ptrieFilter {α : Type} (t : PTrie α) (keep : Nat → Bool) : PTrie α :=
  ptrieFold (fun (acc : PTrie α) k x => if keep k then acc.set k x else acc) t PTrie.nil

def restrictFull (p : FS) (keepH keepN : Nat → Bool) : FS :=
  let b := p.1.1.bridge
  let b := { b with aliases := ptrieFilter b.aliases keepN, touch := ptrieFilter b.touch keepN }
  let k := p.2.map fun k => ({ flags := ptrieFilter k.flags keepH, targs := ptrieFilter k.targs keepH } : KRec)
  ((⟨p.1.1.base, b⟩, p.1.2.map (ptrieFilter · keepH)), k)

/-- `t` with its keys renamed by `f` (`none`: dropped). -/
def ptrieRekey {α : Type} (t : PTrie α) (f : Nat → Option Nat) : PTrie α :=
  ptrieFold (fun (acc : PTrie α) k x => match f k with
    | some k' => acc.set k' x
    | none => acc) t PTrie.nil

/-- The bridge's and the observers' handle and node keys renamed. -/
def renameFull (p : FS) (h n : Nat → Option Nat) : FS :=
  let b := p.1.1.bridge
  let b := { b with aliases := ptrieRekey b.aliases n, touch := ptrieRekey b.touch n,
                    unscheduled := b.unscheduled.filterMap n, running := b.running.filterMap n,
                    log := b.log.map fun e => match e with
                      | .gpu l => .gpu (l.filterMap n)
                      | e => e }
  let k := p.2.map fun k => ({ flags := ptrieRekey k.flags h, targs := ptrieRekey k.targs h } : KRec)
  ((⟨p.1.1.base, b⟩, p.1.2.map (ptrieRekey · h)), k)

def ptrieSize {α : Type} (t : PTrie α) : Nat := ptrieFold (fun (n : Nat) _ _ => n + 1) t 0

def describeFull (p : FS) : String :=
  let b := p.1.1.bridge
  let obs := match p.1.2, p.2 with
    | some f, some k => s!"released {ptrieSize f}, kernels {ptrieSize k.flags}, configurations {ptrieSize k.targs}"
    | none, _ => "liveness rejected a call"
    | _, none => "kernel recording rejected a call"
  s!"bridge {b.surfaces.length} surfaces, {b.programs.length} programs, active {b.active}, {b.log.length} effects; {obs}"

def tArgCmp (x y : TArg) (loc : Loc) (lab : String) : WM Unit :=
  match x, y with
  | .int a, .int b => numCmp a b loc lab
  | .dtype a, .dtype b => unless a == b do mism loc lab s!"template dtype {a} vs {b}"
  | _, _ => mism loc lab "template argument kind"

def walkFull (p1 p2 : FS) : WM Unit := do
  let b1 := p1.1.1.bridge; let b2 := p2.1.1.bridge
  let loc := Loc.root "bridge"
  unless b1.surfaces == b2.surfaces do mism loc "surfaces" "surface sizes differ"
  unless decide (b1.programs = b2.programs) do mism loc "programs" "programs differ"
  unless (toExpr b1.handles) == (toExpr b2.handles) do mism loc "handles" "create handles differ"
  unless b1.active == b2.active do mism loc "active" s!"active {b1.active} vs {b2.active}"
  let nodeMap := (← get).nod
  let keyed {α : Type} (lab : String) (t1 t2 : PTrie α) (eq : α → α → Bool) : WM Unit := do
    for (n, x) in ptrieFold (fun (acc : Array (Nat × α)) k x => acc.push (k, x)) t1 #[] do
      match nodeMap[n]? with
      | some n' => match t2.get n' with
        | some y => unless eq x y do mism (.node n) lab "differs at the image"
        | none => mism (.node n) lab "missing at the image"
      | none => pure ()
  keyed "alias" b1.aliases b2.aliases (fun x y => decide (x = y))
  keyed "touch" b1.touch b2.touch (fun x y => decide (x = y))
  let nodes (lab : String) (l1 l2 : List Nat) : WM Unit := do
    if l1.length != l2.length then mism loc lab s!"length {l1.length} vs {l2.length}"
    for (a, b) in l1.zip l2 do pairNode a b loc lab
  nodes "unscheduled" b1.unscheduled b2.unscheduled
  nodes "running" b1.running b2.running
  if b1.log.length != b2.log.length then mism loc "log" s!"effects {b1.log.length} vs {b2.log.length}"
  for (e1, e2) in b1.log.zip b2.log do
    match e1, e2 with
    | .gpu l1, .gpu l2 => nodes "log.gpu" l1 l2
    | .start a, .start b => unless a == b do mism loc "log.start" s!"program {a} vs {b}"
    | .join a, .join b => unless a == b do mism loc "log.join" s!"program {a} vs {b}"
    | _, _ => mism loc "log" "effect kind"
  let hnd := (← get).hnd
  let oloc := Loc.root "observers"
  match p1.1.2, p2.1.2 with
  | some f1, some f2 =>
    for (h, _) in ptrieFold (fun (acc : Array (Nat × Unit)) k x => acc.push (k, x)) f1 #[] do
      match hnd[h]? with
      | some h' => if (f2.get h').isNone then mism (.hnd h) "released" "not released at the image"
      | none => pure ()
  | none, none => pure ()
  | _, _ => mism oloc "released" "liveness verdicts differ"
  match p1.2, p2.2 with
  | some k1, some k2 =>
    for (h, fl) in ptrieFold (fun (acc : Array (Nat × (Bool × Bool))) k x => acc.push (k, x)) k1.flags #[] do
      match hnd[h]? with
      | some h' => match k2.flags.get h' with
        | some fl' => unless fl == fl' do mism (.hnd h) "kernel flags" "differ at the image"
        | none => mism (.hnd h) "kernel flags" "missing at the image"
      | none => pure ()
    for (h, l) in ptrieFold (fun (acc : Array (Nat × List (List Char × TArg))) k x => acc.push (k, x)) k1.targs #[] do
      match hnd[h]? with
      | some h' => match k2.targs.get h' with
        | some l' =>
          if l.length != l'.length then mism (.hnd h) "template arguments" "count differs at the image"
          for ((n, x), (n', y)) in l.zip l' do
            if n == n' then tArgCmp x y (.hnd h) ("targ:" ++ strOf n) else mism (.hnd h) "template arguments" "names differ"
        | none => mism (.hnd h) "template arguments" "missing at the image"
      | none => pure ()
  | none, none => pure ()
  | _, _ => mism oloc "kernel record" "kernel-recording verdicts differ"

def fullWorldOf (name : String) (ofLoad : St LSt → FS) : TWorld full where
  name := name
  ffiC := ``Host.Load.Layers.full
  tyS := mkApp (mkConst ``Ffi.S) (mkConst ``Host.Load.Layers.full)
  ser := serFull
  toLoad := fun p => toLoad p
  setLoad := fun p l => ((⟨l, p.1.1.bridge⟩, p.1.2), p.2)
  ofLoad := ofLoad
  extraNodes := fun p => p.1.1.bridge.unscheduled ++ p.1.1.bridge.running
  restrict := restrictFull
  renameExtra := renameFull
  walkExtra := walkFull
  describe := describeFull
  okModule := "host.sim.template.FullOk"
  okName := "okFull"

/-- The full stack, a cut's observers from its trace. -/
def fullWorld : TWorld full := fullWorldOf "full" fullOfLoad

/-- The full stack, a cut's observers fresh. -/
def fullFreshWorld : TWorld full := fullWorldOf "fullFresh" fullOfLoadFresh

end Host.Ts.Sim.Template
