import host.ts.RenameParametricArrayLength
import host.ts.RenameRouteComposition

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

def mapStorageResult {S : Type} (s : St S) (lengthCell arrayCell : Nat) (value : Val)
    (rest : List Stmt) (env : Env) (fs : List Frame) : St S :=
  let s' := ((s.setCell lengthCell value).alloc (.obj ⟨.array [],.obj aArrayProto,[],[],true⟩)).2
  {(s'.setCell arrayCell (.obj s.next)) with ctl := .ret .undef,stack := .s (.block rest env)::fs}

/-- Exact effects of the original map prelude after reading its length:
initialize the length cell, allocate the result array, and bind that array.
The returned length value is retained without forgetting its occurrence role. -/
theorem map_storage_run (F : Ffi) (s : St F.S) (C : CSrv) (n r : Name)
    (a b : Nat) (value : Val) (rest : List Stmt) (env : Env) (fs : List Frame)
    (hc : s.ctl = .ret value)
    (hf : s.stack = .s (.decl .const (.id n) [] env)::
      .s (.block (.decl .const [(.id r,some (.array []))]::rest) env)::fs)
    (hn : lookupEnv n env = some a) (hr : lookupEnv r env = some b) :
    runC F 9 s C = some (mapStorageResult s a b value rest env fs,C) := by
  let outer := .s (.block (.decl .const [(.id r,some (.array []))]::rest) env)::fs
  let tail := .s (.block rest env)::fs
  let s1 := declarationValue {s with stack := outer} .const (.id n) [] env value
  let s2 := (s1.setCell a value).ret .undef
  let s3 := {s2 with stack := outer}.ret .undef
  let s4 := ({s3 with stack := fs}.push (.s (.block rest env))).go
    (.ex (.decl .const [(.id r,some (.array []))]) env)
  let s5 := (.declarationInit .const (.id r) (.array []) [] : StatementAction).advance s4 env
  let s6 := (s5.alloc (.obj ⟨.array [],.obj aArrayProto,[],[],true⟩)).2.ret (.obj s5.next)
  let s7 := declarationValue {s6 with stack := tail} .const (.id r) [] env (.obj s5.next)
  let s8 := (s7.setCell b (.obj s5.next)).ret .undef
  let s9 := {s8 with stack := tail}.ret .undef
  have h0 : step F s = M.pure s1 := step_declaration_value_eq F s value .const (.id n) [] env outer hc hf rfl
  have h1 : step F s1 = M.pure s2 := step_bind_init_eq F s1 n value env .const a rfl hn
  have h2 : step F s2 = M.pure s3 := step_declaration_next_eq F s2 .undef .const [] env outer rfl rfl
  have h3 : step F s3 = M.pure s4 := step_block_next_eq F s3 .undef
    (.decl .const [(.id r,some (.array []))]) rest env fs rfl rfl
  have h4 : step F s4 = M.pure s5 := step_statement_eq F s4 (.declarationInit .const (.id r) (.array []) []) env rfl
  have h5 : step F s5 = M.pure s6 := step_empty_array_eq F s5 env rfl
  have h6 : step F s6 = M.pure s7 := step_declaration_value_eq F s6 (.obj s5.next) .const (.id r) [] env tail rfl rfl rfl
  have h7 : step F s7 = M.pure s8 := step_bind_init_eq F s7 r (.obj s5.next) env .const b rfl hr
  have h8 : step F s8 = M.pure s9 := step_declaration_next_eq F s8 .undef .const [] env tail rfl rfl
  change runC F 9 s C = some (s9,C)
  apply runC_cons F 8 s s1 s9 C C C (by rw [hc]; rfl) (by rw [h0]; rfl)
  apply runC_cons F 7 s1 s2 s9 C C C rfl (by rw [h1]; rfl)
  apply runC_cons F 6 s2 s3 s9 C C C rfl (by rw [h2]; rfl)
  apply runC_cons F 5 s3 s4 s9 C C C rfl (by rw [h3]; rfl)
  apply runC_cons F 4 s4 s5 s9 C C C rfl (by rw [h4]; rfl)
  apply runC_cons F 3 s5 s6 s9 C C C rfl (by rw [h5]; rfl)
  apply runC_cons F 2 s6 s7 s9 C C C rfl (by rw [h6]; rfl)
  apply runC_cons F 1 s7 s8 s9 C C C rfl (by rw [h7]; rfl)
  apply runC_cons F 0 s8 s9 s9 C C C rfl (by rw [h8]; rfl)
  rfl

theorem mapStorageResult_length {S : Type} (s : St S) (a b : Nat) (value : Val)
    (rest : List Stmt) (env : Env) (fs : List Frame)
    (ha : a < s.next) (hb : b < 2^64) (hn : s.next < 2^64) (hab : a ≠ b) :
    (mapStorageResult s a b value rest env fs).heap.get a = some (.cell (some value)) := by
  have ha64 := Nat.lt_trans ha hn
  simp only [mapStorageResult,St.setCell,St.alloc,PTrie.get_set_u64 _ _ _ hb,
    PTrie.get_set_u64 _ _ _ hn,PTrie.get_set_u64 _ _ _ ha64,ite_eq_right hab,
    ite_eq_right (Nat.ne_of_lt ha),ite_true]

theorem mapStorageResult_frame {S : Type} (s : St S) (a b k : Nat) (value : Val)
    (rest : List Stmt) (env : Env) (fs : List Frame)
    (ha : a < 2^64) (hb : b < 2^64) (hn : s.next < 2^64)
    (ka : k ≠ a) (kb : k ≠ b) (kn : k < s.next) :
    (mapStorageResult s a b value rest env fs).heap.get k = s.heap.get k := by
  simp only [mapStorageResult,St.setCell,St.alloc,PTrie.get_set_u64 _ _ _ hb,
    PTrie.get_set_u64 _ _ _ hn,PTrie.get_set_u64 _ _ _ ha,ite_eq_right ka,
    ite_eq_right kb,ite_eq_right (Nat.ne_of_lt kn)]

end Host.Ts.Owned.Parametric
