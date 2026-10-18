import host.load.ShaCommand
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Tests.Sha
open Host.Ts Host.Load.Sha

sha256_checked Empty : ([] : List Nat)
sha256_checked Abc : [97,98,99]
sha256_checked Multi : List.replicate 129 97

theorem empty_checked : sha256 [] = Empty.digest := Empty.checked
theorem abc_checked : sha256 [97,98,99] = Abc.digest := Abc.checked
theorem multiblock_checked : sha256 (List.replicate 129 97) = Multi.digest := Multi.checked

theorem abc_digest : Abc.digest =
    [186,120,22,191,143,1,207,234,65,65,64,222,93,174,34,35,
     176,3,97,163,150,23,122,156,180,16,255,97,242,0,21,173] := rfl

namespace Call
def F := Host.Load.ffi
open Lean Elab Command in
run_elab do
  let state : St LSt := { heap := (PTrie.nil.set 1 (.obj ⟨.fn (.native (.host .sha256) []),.null,[],[],true⟩)).set 2 (.obj ⟨.array [.str chars!"abc"],.null,[],[],true⟩), next := 3, ctl := .call (.obj 1) .undef [.obj 2], stack := [], aux := ⟨[],⟨Host.Mlx.Ffi.init [] [] [] [],HostSt.init [] [] [] 0 [] []⟩,[],[]⟩ }
  addDecl (.defnDecl { name := `Host.Load.Tests.Sha.Call.s0, levelParams := [], type := mkApp (mkConst ``St) (mkConst ``LSt), value := toExpr state, hints := .regular 0, safety := .safe })
open Lean Elab Command in
run_elab do
  let value ← Term.elabTermAndSynthesize (← `(s0.ret (.str (hexBytes Abc.digest)))) none
  let type ← Lean.Meta.inferType value
  addDecl (.defnDecl { name := `Host.Load.Tests.Sha.Call.s1, levelParams := [], type, value, hints := .regular 0, safety := .safe })
def S0 : SSrv := ⟨[],[]⟩
def S1 := S0
end Call

host_sha256_step Call 0
theorem actual_host_call : runS Call.F 1 Call.s0 Call.S0 = some (Call.s1,Call.S1) := Call.c0

end Host.Load.Tests.Sha
