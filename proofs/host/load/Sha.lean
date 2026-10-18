import host.ts.Run
set_option Elab.async false

namespace Host.Load.Sha
open Host.Ts

def pad (msg : List Nat) : List Nat :=
  let l := len msg
  msg ++ [0x80] ++ List.replicate ((119-l%64)%64) 0 ++ beBytes 8 (l*8)

theorem sha256_pad (msg : List Nat) :
    sha256 msg = (shaBlocks (len (pad msg)/64+1) shaH0 (pad msg)).flatMap (beBytes 4) := rfl

/-- Split one original compression block, without changing the SHA rounds. -/
theorem blocks_step (h block rest next : List Nat) (fuel : Nat)
    (length : block.length = 64) (checked : shaBlock h block = next) :
    shaBlocks (fuel+1) h (block++rest) = shaBlocks fuel next rest := by
  have take : (block++rest).take 64 = block := by
    simpa only [length] using (List.take_append_length (l₁ := block) (l₂ := rest))
  have drop : (block++rest).drop 64 = rest := by
    simpa only [length] using (List.drop_append_length (l₁ := block) (l₂ := rest))
  cases block with
  | nil => simp at length
  | cons b bs =>
    change shaBlocks fuel (shaBlock h (((b::bs)++rest).take 64)) (((b::bs)++rest).drop 64) = _
    rw [take, drop, checked]

theorem sha256_of_blocks (msg padded words : List Nat) (fuel : Nat)
    (padding : pad msg = padded) (count : len padded/64+1 = fuel)
    (blocks : shaBlocks fuel shaH0 padded = words) :
    sha256 msg = words.flatMap (beBytes 4) := by
  rw [sha256_pad, padding, count, blocks]

theorem hostN_sha256 (F : Ffi) (s : St F.S) (this : Val) (args data parts : List Val)
    (bss : List (List Nat)) (digest : List Nat)
    (hp : elemsOf F s (arg args 0) = .pure (some parts))
    (hb : parts.mapM (partBytes F s) = some bss)
    (hd : sha256 bss.flatten = digest) :
    hostN F s this args data .sha256 = retS F s (.str (hexBytes digest)) := by
  unfold hostN
  rw [hp]
  change (match parts.mapM (partBytes F s) with
    | some bss => retS F s (.str (hexBytes (sha256 bss.flatten)))
    | none => .fail "sha256 of an unsupported part") = _
  rw [hb]
  change retS F s (.str (hexBytes (sha256 bss.flatten))) = _
  rw [hd]

theorem step_sha256 (F : Ffi) (s : St F.S) (f : Nat) (this : Val)
    (args data parts : List Val) (o : Obj) (bss : List (List Nat)) (digest : List Nat)
    (hc : s.ctl = .call (.obj f) this args) (ho : s.obj? f = some o)
    (hn : o.kind = .fn (.native (.host .sha256) data))
    (hp : elemsOf F s (arg args 0) = .pure (some parts))
    (hb : parts.mapM (partBytes F s) = some bss)
    (hd : sha256 bss.flatten = digest) :
    step F s = .pure (s.ret (.str (hexBytes digest))) := by
  simp only [step, hc]
  change callStep F s (.obj f) this args = _
  simp only [callStep, ho, hn]
  change hostN F s this args data .sha256 = _
  exact hostN_sha256 F s this args data parts bss digest hp hb hd

theorem runS_one_of_step (F : Ffi) (s t : St F.S) (srv : SSrv)
    (hh : isHalt s.ctl = false) (hs : step F s = .pure t) :
    runS F 1 s srv = some (t,srv) := by
  simp only [runS, runWith_succ, hh, Bool.cond_false, hs, M.run, M.pure, interpS,
    St.rebuild_eq, runWith_zero]

end Host.Load.Sha
