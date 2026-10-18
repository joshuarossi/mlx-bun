import host.load.Micro
import host.load.Compose

namespace Host.Load.Tests.Micro
open Host.Ts Host.Load
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

def source : String := "export let out = 0; let i = 0; while (i < 4) { out += i; i++; }"
source_parse source
source_ast

def world : LSt := ⟨Host.Mlx.Ffi.init [] [] [] [], HostSt.init [] [] [] 0 [] []⟩
def initial : Option (St LSt) := boot world [⟨chars!"main.ts", ast⟩] [] chars!"main.ts"

host_chain P : Host.Load.ffi, initial, (⟨[], []⟩ : SSrv), [80]
host_micro_chunk P 0, 13 refine 26, 29, 1

host_chain Q : Host.Load.ffi, initial, (⟨[], []⟩ : SSrv), [80]
host_micro_states Q 0, 17 chunks [5, 12, 18, 20, 25]
host_chunk Q.micro0 0
host_chunk Q.micro0 1
host_chunk Q.micro0 2
host_chunk Q.micro0 3
host_chunk Q.micro0 4
host_micro_run Q 0

theorem fused : runS P.F 80 P.s0 P.S0 = some (P.s1, P.S1) := P.c0
theorem separate : runS Q.F 80 Q.s0 Q.S0 = some (Q.s1, Q.S1) := Q.c0

host_chain T : Host.Load.ffi, initial, (⟨[], []⟩ : SSrv), [80]
host_micro_stream T 0, 17 chunks [5, 12, 18, 20, 25]
host_stream_state T.micro0 0
host_stream_state T.micro0 1
host_stream_state T.micro0 2
host_stream_state T.micro0 3
host_stream_state T.micro0 4
host_stream_state T.micro0 5
host_chunk T.micro0 0
host_chunk T.micro0 1
host_chunk T.micro0 2
host_chunk T.micro0 3
host_chunk T.micro0 4
host_micro_run T 0

theorem streamed : runS T.F 80 T.s0 T.S0 = some (T.s1, T.S1) := T.c0

host_chain R : Host.Load.ffi, initial, (⟨[], []⟩ : SSrv), [20, 20, 40]
host_chunk R 0
host_chunk R 1
host_chunk R 2
host_chain_run_staged R

theorem staged : runS R.F 80 R.s0 R.S0 = some (R.s3, R.S3) := R.run

def linkCx : LinkCx LSt := ⟨[⟨chars!"main.ts", ast⟩], [], chars!"main.ts", []⟩
link_chain L : linkCx, world, [1, 1, 1, 1, 1]
link_chunk L 0
link_chunk L 1
link_chunk L 2
link_chunk L 3
link_chunk L 4
link_chain_run_staged L

theorem linked : bootL L.cx L.w 20 = some L.x5.st := L.booted 20 (by decide)

link_chain FixedL : linkCx, world, [1, 1, 1, 1, 1] fixed_ffi
link_chunk FixedL 0
link_chunk FixedL 1
link_chunk FixedL 2
link_chunk FixedL 3
link_chunk FixedL 4
link_chain_run_staged FixedL

theorem linked_fixed : bootL FixedL.cx FixedL.w 20 = some FixedL.x5.st :=
  FixedL.booted 20 (by decide)

open Lean Elab Command in
run_elab do
  let some (.defnInfo d) := (← getEnv).find? ``FixedL.x1
    | throwError "missing fixed-world state"
  unless (d.value.find? (· == Lean.mkConst ``world)).isSome do
    throwError "fixed_ffi did not serialize the named world"

def mutatingHost : HMod Nat := ⟨chars!"main.ts", do
  modify fun s => s.setFfi (s.ffi+1)
  pure []⟩

def mutatingCx : LinkCx Nat := ⟨[], [mutatingHost], chars!"main.ts", []⟩
def zeroWorld : Nat := 0

link_chain MutatingDefault : mutatingCx, zeroWorld, [1]
link_chunk MutatingDefault 0

theorem default_changes_ffi : MutatingDefault.x1.st.ffi = 1 := rfl

host_stream Imported : Host.Load.ffi, initial, ([] : List SymE), (fun _ => F64.ofNat 0), 80, 1
host_stream_state Imported 0
host_stream_state Imported 1
host_micro_chunk Imported 0, 11

theorem imported_roundtrip : runS Imported.F 80 Imported.s0 Imported.S0 =
    some (Imported.s1, Imported.S1) := Imported.c0

end Host.Load.Tests.Micro
