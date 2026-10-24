import metal.Arith

namespace Metal
open Core Inference.Contracts.Mlx

/-! # Memory accesses as states

Shared memory after a thread's loads and stores: the logged reads (`rdn`, `rd`, `rd4`, `logged`), the logged
writes (`wrn`, `wr`, `wr4`, `store4`) and the unlogged writes of thread memory (`tput`, `wrT`), with `loadAt`
and `storeAt` at each access width the kernels make, a thread's footprint, and counted fill loops. -/


/-! ## Scalars at naturally aligned offsets -/

/-- A scalar load from a region other than thread memory, at an offset `place` keeps. -/
theorem loadAt_scalar (ctx : Ctx) (s : Scalar) (reg o : Nat) (r : Region) (sh : Shared)
    (hr : sh.regions reg = some r) (hs : r.space ≠ .thread) (ha : r.align % s.bytes = 0) (hoa : o % s.bytes = 0)
    (hb : o + s.bytes ≤ r.size) (hlo : loadOffset (.scalar s) r o = o) :
    (loadAt ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩).run sh =
      some (Val.ofWord s (bytesWord (cells (sh.bytes reg) o s.bytes)), { sh with log :=
        ((List.range s.bytes).map fun i => entry ctx sh reg (o + i) false).reverse ++ sh.log }) := by
  have hd : decode (.scalar s) ((List.range (Ty.scalar s).bytes).map fun i =>
      sh.bytes reg (loadOffset (.scalar s) r (o : Int).toNat + i)) =
      some (Val.ofWord s (bytesWord (cells (sh.bytes reg) o s.bytes))) := by
    rw [Int.toNat_natCast, hlo]; exact decode_cells s (sh.bytes reg) o
  have h := loadAt_run ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩ r sh
    (Val.ofWord s (bytesWord (cells (sh.bytes reg) o s.bytes))) hr hs (Int.natCast_nonneg _)
    (by simpa [alignment] using ha) (by simpa [hlo, alignment] using hoa) (by simpa [hlo, Ty.bytes] using hb) hd
  simpa [hlo, Ty.bytes] using h

/-- A scalar store to device or threadgroup memory. -/
theorem storeAt_scalar (ctx : Ctx) (s : Scalar) (reg o : Nat) (r : Region) (sh : Shared) (v : Val)
    (bytes : List (BitVec 8)) (hr : sh.regions reg = some r) (hs : r.space ≠ .thread) (hc : r.space ≠ .constant)
    (ha : r.align % s.bytes = 0) (hoa : o % s.bytes = 0) (hb : o + s.bytes ≤ r.size) (he : encode (.scalar s) v = some bytes) :
    (storeAt ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩ v).run sh = some ((), { sh with
      log := ((List.range s.bytes).map fun i => entry ctx sh reg (o + i) true).reverse ++ sh.log,
      bytes := fun region => if region = reg then writeBytes (sh.bytes region) o bytes else sh.bytes region }) := by
  have h := storeAt_run ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩ r sh v bytes hr hs hc (Int.natCast_nonneg _)
    (by simpa [alignment] using ha) (by simpa [alignment] using hoa) (by simpa [Ty.bytes] using hb) he
  simpa [Ty.bytes] using h

/-! ## Logged reads and writes, unlogged thread memory -/

/-- Memory after a logged read of `n` bytes of `reg` from byte `o`. -/
def rdn (ctx : Ctx) (sh : Shared) (reg o n : Nat) : Shared :=
  { sh with log := ((List.range n).map fun i => entry ctx sh reg (o + i) false).reverse ++ sh.log }

/-- Memory after a logged write of the `n` bytes `bs` to `reg` at byte `o`. -/
def wrn (ctx : Ctx) (sh : Shared) (reg o n : Nat) (bs : List (BitVec 8)) : Shared :=
  { sh with log := ((List.range n).map fun i => entry ctx sh reg (o + i) true).reverse ++ sh.log,
            bytes := fun region => if region = reg then writeBytes (sh.bytes region) o bs else sh.bytes region }

/-- Memory after a write of `bs` to thread memory `reg` at byte `o` (not logged). -/
def tput (sh : Shared) (reg o : Nat) (bs : List (BitVec 8)) : Shared :=
  { sh with bytes := fun region => if region = reg then writeBytes (sh.bytes region) o bs else sh.bytes region }

@[simp] theorem rdn_regions (ctx : Ctx) (sh : Shared) (reg o n : Nat) : (rdn ctx sh reg o n).regions = sh.regions := rfl
@[simp] theorem rdn_bytes (ctx : Ctx) (sh : Shared) (reg o n : Nat) : (rdn ctx sh reg o n).bytes = sh.bytes := rfl
@[simp] theorem rdn_dev (ctx : Ctx) (sh : Shared) (reg o n : Nat) : (rdn ctx sh reg o n).deviceEpoch = sh.deviceEpoch := rfl
@[simp] theorem rdn_group (ctx : Ctx) (sh : Shared) (reg o n : Nat) : (rdn ctx sh reg o n).groupEpoch = sh.groupEpoch := rfl
@[simp] theorem tput_regions (sh : Shared) (reg o : Nat) (bs : List (BitVec 8)) : (tput sh reg o bs).regions = sh.regions := rfl
@[simp] theorem tput_log (sh : Shared) (reg o : Nat) (bs : List (BitVec 8)) : (tput sh reg o bs).log = sh.log := rfl
@[simp] theorem tput_dev (sh : Shared) (reg o : Nat) (bs : List (BitVec 8)) : (tput sh reg o bs).deviceEpoch = sh.deviceEpoch := rfl
@[simp] theorem tput_group (sh : Shared) (reg o : Nat) (bs : List (BitVec 8)) : (tput sh reg o bs).groupEpoch = sh.groupEpoch := rfl
theorem tput_other (sh : Shared) {reg r : Nat} (o : Nat) (bs : List (BitVec 8)) (h : r ≠ reg) :
    (tput sh reg o bs).bytes r = sh.bytes r := by simp [tput, h]
theorem tput_same (sh : Shared) (reg o : Nat) (bs : List (BitVec 8)) :
    (tput sh reg o bs).bytes reg = writeBytes (sh.bytes reg) o bs := by simp [tput]
theorem wrn_other (ctx : Ctx) (sh : Shared) {reg r : Nat} (o n : Nat) (bs : List (BitVec 8)) (h : r ≠ reg) :
    (wrn ctx sh reg o n bs).bytes r = sh.bytes r := by simp [wrn, h]
theorem wrn_same (ctx : Ctx) (sh : Shared) (reg o n : Nat) (bs : List (BitVec 8)) :
    (wrn ctx sh reg o n bs).bytes reg = writeBytes (sh.bytes reg) o bs := by simp [wrn]

theorem tput_bytes (sh : Shared) (region o : Nat) (bytes : List (BitVec 8)) (r : Nat) :
    (tput sh region o bytes).bytes r = if r = region then writeBytes (sh.bytes r) o bytes else sh.bytes r := rfl

/-- The state after one 4-byte store. -/
def store4 (ctx : Ctx) (sh : Shared) (reg o : Nat) (bs : List (BitVec 8)) : Shared :=
  { sh with log := ((List.range 4).map fun b => entry ctx sh reg (o + b) true).reverse ++ sh.log,
            bytes := fun region => if region = reg then writeBytes (sh.bytes region) o bs else sh.bytes region }

/-- Memory after an access by `ctx` to element `n` (`s` bytes wide) of `region`: its bytes logged. -/
def logged (ctx : Ctx) (sh : Shared) (region s n : Nat) (w : Bool) : Shared :=
  { sh with log := ((List.range s).map fun i => entry ctx sh region (s * n + i) w).reverse ++ sh.log }

theorem logged_log {ctx : Ctx} {sh : Shared} {reg s m : Nat} {w : Bool} : ∀ e ∈ (logged ctx sh reg s m w).log, e ∈ sh.log ∨
    (e.region = reg ∧ e.write = w ∧ e.thread = ctx.thread ∧ e.group = ctx.group ∧ e.deviceEpoch = sh.deviceEpoch ∧
      s * m ≤ e.byte ∧ e.byte < s * m + s) := by
  intro e he
  simp only [logged, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at he
  rcases he with ⟨i, hi, rfl⟩ | he
  · exact .inr ⟨rfl, rfl, rfl, rfl, rfl, by simp [entry], by simp [entry]; omega⟩
  · exact .inl he

/-- Memory after a bf16 access by `ctx` to element `n` of `region`: its two bytes logged2. -/
def logged2 (ctx : Ctx) (sh : Shared) (region n : Nat) (w : Bool) : Shared :=
  { sh with log := ((List.range 2).map fun i => entry ctx sh region (2 * n + i) w).reverse ++ sh.log }

/-- Memory with element `n` of `region` set to the bf16 `v`. -/
def written2 (sh : Shared) (region n : Nat) (v : BF) : Shared :=
  { sh with bytes := fun r =>
    if r = region then writeBytes (sh.bytes r) (2 * n) (wordBytes 2 (Val.bf16Bits v)) else sh.bytes r }

theorem written2_bytes (sh : Shared) (region n : Nat) (v : BF) (r : Nat) : (written2 sh region n v).bytes r =
    if r = region then writeBytes (sh.bytes r) (2 * n) (wordBytes 2 (Val.bf16Bits v)) else sh.bytes r := rfl

/-- A logged 2-byte read of `region` at byte `off`. -/
def rd (ctx : Ctx) (sh : Shared) (region off : Nat) : Shared :=
  { sh with log := ((List.range 2).map fun j => entry ctx sh region (off + j) false).reverse ++ sh.log }

/-- A logged bf16 store of `y` to `region` at byte `off`. -/
def wr (ctx : Ctx) (sh : Shared) (region off : Nat) (y : BF) : Shared :=
  { sh with
    log := ((List.range 2).map fun j => entry ctx sh region (off + j) true).reverse ++ sh.log,
    bytes := fun r => if r = region then writeBytes (sh.bytes r) off (wordBytes 2 (Val.bf16Bits y)) else sh.bytes r }

/-- A logged 4-byte read of `region` at byte `off`. -/
def rd4 (ctx : Ctx) (sh : Shared) (region off : Nat) : Shared :=
  { sh with log := ((List.range 4).map fun j => entry ctx sh region (off + j) false).reverse ++ sh.log }

/-- A logged f32 store of `y` to `region` at byte `off`. -/
def wr4 (ctx : Ctx) (sh : Shared) (region off : Nat) (y : Float32) : Shared :=
  { sh with
    log := ((List.range 4).map fun j => entry ctx sh region (off + j) true).reverse ++ sh.log,
    bytes := fun r => if r = region then writeBytes (sh.bytes r) off (wordBytes 4 (Val.f32Bits y)) else sh.bytes r }

theorem rd_eq (ctx : Ctx) (sh : Shared) (region off : Nat) : rd ctx sh region off = rdn ctx sh region off 2 := rfl

theorem rd4_eq (ctx : Ctx) (sh : Shared) (region off : Nat) : rd4 ctx sh region off = rdn ctx sh region off 4 := rfl

/-- An f32 store of `y` to thread memory `region` at byte `off` (unlogged). -/
def wrT (sh : Shared) (region off : Nat) (y : Float32) : Shared :=
  { sh with bytes := fun r => if r = region then writeBytes (sh.bytes r) off (wordBytes 4 (Val.f32Bits y)) else sh.bytes r }

theorem wr4_bytes_other (ctx : Ctx) (sh : Shared) (off : Nat) (y : Float32) {region r : Nat} (h : r ≠ region) :
    (wr4 ctx sh region off y).bytes r = sh.bytes r := by simp [wr4, h]

theorem wr_bytes_other (ctx : Ctx) (sh : Shared) (off : Nat) (y : BF) {region r : Nat} (h : r ≠ region) :
    (wr ctx sh region off y).bytes r = sh.bytes r := by simp [wr, h]

theorem wrT_bytes_other (sh : Shared) (off : Nat) (y : Float32) {region r : Nat} (h : r ≠ region) :
    (wrT sh region off y).bytes r = sh.bytes r := by simp [wrT, h]

theorem wrT_bytes_same (sh : Shared) (region off : Nat) (y : Float32) :
    (wrT sh region off y).bytes region = writeBytes (sh.bytes region) off (wordBytes 4 (Val.f32Bits y)) := by simp [wrT]

/-! ## A thread's footprint

What a thread's run between two points changes: its logged reads of regions `R` and its writes of thread
memory `T`. -/

/-- A thread `ctx`'s change of shared memory from `sh` to `sh'` that only reads regions `R` (logged in `sh`'s
epochs) and writes regions `T` (unlogged thread memory). -/
structure Footprint (ctx : Ctx) (R T : Nat → Prop) (sh sh' : Shared) : Prop where
  regions : sh'.regions = sh.regions
  dEpoch : sh'.deviceEpoch = sh.deviceEpoch
  gEpoch : sh'.groupEpoch = sh.groupEpoch
  bytes : ∀ r, ¬ T r → sh'.bytes r = sh.bytes r
  log : ∀ a ∈ sh'.log, a ∈ sh.log ∨ ∃ r b, R r ∧ a = entry ctx sh r b false

namespace Footprint
variable {ctx : Ctx} {R T R' T' : Nat → Prop} {sh sh₁ sh₂ : Shared}

theorem refl (ctx : Ctx) (R T : Nat → Prop) (sh : Shared) : Footprint ctx R T sh sh :=
  ⟨rfl, rfl, rfl, fun _ _ => rfl, fun _ ha => .inl ha⟩

theorem trans (h₁ : Footprint ctx R T sh sh₁) (h₂ : Footprint ctx R T sh₁ sh₂) : Footprint ctx R T sh sh₂ where
  regions := h₂.regions.trans h₁.regions
  dEpoch := h₂.dEpoch.trans h₁.dEpoch
  gEpoch := h₂.gEpoch.trans h₁.gEpoch
  bytes r hr := (h₂.bytes r hr).trans (h₁.bytes r hr)
  log a ha := by
    rcases h₂.log a ha with ha | ⟨r, b, hr, rfl⟩
    · exact h₁.log a ha
    · exact .inr ⟨r, b, hr, by simp only [entry, h₁.dEpoch, h₁.gEpoch]⟩

theorem mono (h : Footprint ctx R T sh sh₁) (hR : ∀ r, R r → R' r) (hT : ∀ r, T r → T' r) : Footprint ctx R' T' sh sh₁ where
  regions := h.regions
  dEpoch := h.dEpoch
  gEpoch := h.gEpoch
  bytes r hr := h.bytes r (fun h' => hr (hT r h'))
  log a ha := by
    rcases h.log a ha with ha | ⟨r, b, hr, rfl⟩
    · exact .inl ha
    · exact .inr ⟨r, b, hR r hr, rfl⟩

theorem bytes_eq (h : Footprint ctx R (fun _ => False) sh sh₁) : sh₁.bytes = sh.bytes := funext fun r => h.bytes r id

end Footprint

theorem Footprint.rdn {ctx : Ctx} {R : Nat → Prop} (T : Nat → Prop) {region : Nat} (sh : Shared) (off n : Nat)
    (hr : R region) : Footprint ctx R T sh (rdn ctx sh region off n) where
  regions := rfl
  dEpoch := rfl
  gEpoch := rfl
  bytes _ _ := rfl
  log a ha := by
    simp only [Metal.rdn, List.mem_append, List.mem_reverse, List.mem_map, List.mem_range] at ha
    rcases ha with ⟨j, _, rfl⟩ | ha
    · exact .inr ⟨region, off + j, hr, rfl⟩
    · exact .inl ha

theorem Footprint.wrT {ctx : Ctx} (R : Nat → Prop) {T : Nat → Prop} {region : Nat} (sh : Shared) (off : Nat) (y : Float32)
    (ht : T region) : Footprint ctx R T sh (wrT sh region off y) where
  regions := rfl
  dEpoch := rfl
  gEpoch := rfl
  bytes r hr := by
    show (if r = region then _ else sh.bytes r) = sh.bytes r
    exact ite_eq_right (fun (h : r = region) => hr (h ▸ ht))
  log a ha := .inl ha

/-- Region `n` (reads or thread writes of one region). -/
def isR (n r : Nat) : Prop := r = n

/-- No region. -/
def noT (_ : Nat) : Prop := False

/-! ## Device, constant and threadgroup memory -/

/-- A scalar load from device, constant or threadgroup memory at a naturally aligned offset. -/
theorem load_shared (ctx : Ctx) (s : Scalar) (sh : Shared) (reg o : Nat) (r : Region)
    (hr : sh.regions reg = some r) (hs : r.space ≠ .thread) (ha : r.align % s.bytes = 0) (hoa : o % s.bytes = 0)
    (hb : o + s.bytes ≤ r.size) (hlo : loadOffset (.scalar s) r o = o) :
    (loadAt ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩).run sh =
      some (Val.ofWord s (bytesWord (cells (sh.bytes reg) o s.bytes)), rdn ctx sh reg o s.bytes) :=
  loadAt_scalar ctx s reg o r sh hr hs ha hoa hb hlo

/-- A scalar store to device or threadgroup memory. -/
theorem store_shared (ctx : Ctx) (s : Scalar) (sh : Shared) (reg o : Nat) (r : Region) (v : Val) (bs : List (BitVec 8))
    (hr : sh.regions reg = some r) (hs : r.space ≠ .thread) (hc : r.space ≠ .constant) (ha : r.align % s.bytes = 0)
    (hoa : o % s.bytes = 0) (hb : o + s.bytes ≤ r.size) (he : encode (.scalar s) v = some bs) :
    (storeAt ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩ v).run sh = some ((), wrn ctx sh reg o s.bytes bs) :=
  storeAt_scalar ctx s reg o r sh v bs hr hs hc ha hoa hb he

/-- A 4-byte threadgroup load at any offset in a 4-aligned array: the low two address bits are ignored. -/
theorem load_group4 (ctx : Ctx) (sh : Shared) (reg o size : Nat) (hr : sh.regions reg = some ⟨.threadgroup, size, 4⟩)
    (hb : 4 * (o / 4) + 4 ≤ size) :
    (loadAt ctx (.scalar .f32) ⟨reg, (o : Int), .scalar .f32⟩).run sh =
      some (Val.ofWord .f32 (bytesWord (cells (sh.bytes reg) (4 * (o / 4)) 4)), rdn ctx sh reg (4 * (o / 4)) 4) := by
  have hlo : loadOffset (.scalar .f32) ⟨.threadgroup, size, 4⟩ (o : Int).toNat = 4 * (o / 4) := by
    simp [loadOffset, Ty.bytes, Scalar.bytes]; omega
  have h := loadAt_run ctx (.scalar .f32) ⟨reg, (o : Int), .scalar .f32⟩ ⟨.threadgroup, size, 4⟩ sh
    (Val.ofWord .f32 (bytesWord (cells (sh.bytes reg) (4 * (o / 4)) 4))) hr (by simp) (Int.natCast_nonneg _) (by simp [alignment, Scalar.bytes])
    (by rw [hlo]; simp [alignment, Scalar.bytes]) (by rw [hlo]; simpa [Ty.bytes, Scalar.bytes] using hb)
    (by rw [hlo]; exact decode_cells .f32 _ _)
  rw [h, hlo]
  rfl

theorem load_u8 (ctx : Ctx) (sh : Shared) (region size align o : Nat)
    (hr : sh.regions region = some ⟨.device, size, align⟩) (hb : o + 1 ≤ size) :
    (loadAt ctx (.scalar .u8) ⟨region, ((o : Nat) : Int), .scalar .u8⟩).run sh =
      some (.int .u8 (sh.bytes region o).toNat, rdn ctx sh region o 1) := by
  have h := loadAt_run ctx (.scalar .u8) ⟨region, ((o : Nat) : Int), .scalar .u8⟩ ⟨.device, size, align⟩ sh
    (.int .u8 (sh.bytes region o).toNat) hr (by simp) (Int.natCast_nonneg _)
    (by simp [alignment, Scalar.bytes, Nat.mod_one]) (by simp [loadOffset, alignment, Scalar.bytes, Nat.mod_one])
    (by simp only [loadOffset, Int.toNat_natCast]; simp [Ty.bytes, Scalar.bytes]; omega)
    (by
      simp only [loadOffset, Int.toNat_natCast]
      have := (sh.bytes region o).isLt
      simp [decode, Ty.bytes, Scalar.bytes, bytesWord, Val.ofWord, Scalar.width]
      omega)
  rw [h]
  simp only [loadOffset, Int.toNat_natCast]
  simp [Ty.bytes, Scalar.bytes, rdn]

theorem load_u16 (ctx : Ctx) (sh : Shared) (region size align o : Nat)
    (hr : sh.regions region = some ⟨.device, size, align⟩) (ha : align % 2 = 0) (ho : o % 2 = 0) (hb : o + 2 ≤ size) :
    (loadAt ctx (.scalar .u16) ⟨region, ((o : Nat) : Int), .scalar .u16⟩).run sh =
      some (.int .u16 ((sh.bytes region o).toNat + 256 * (sh.bytes region (o + 1)).toNat), rdn ctx sh region o 2) := by
  have h := loadAt_run ctx (.scalar .u16) ⟨region, ((o : Nat) : Int), .scalar .u16⟩ ⟨.device, size, align⟩ sh
    (.int .u16 ((sh.bytes region o).toNat + 256 * (sh.bytes region (o + 1)).toNat)) hr (by simp) (Int.natCast_nonneg _)
    (by simpa [alignment, Scalar.bytes] using ha) (by simpa [loadOffset, alignment, Scalar.bytes] using ho)
    (by simp only [loadOffset, Int.toNat_natCast]; simp [Ty.bytes, Scalar.bytes]; omega)
    (by
      simp only [loadOffset, Int.toNat_natCast]
      have := (sh.bytes region o).isLt
      have := (sh.bytes region (o + 1)).isLt
      simp [decode, Ty.bytes, Scalar.bytes, bytesWord, Val.ofWord, Scalar.width, List.range_succ]
      omega)
  rw [h]
  simp only [loadOffset, Int.toNat_natCast]
  simp [Ty.bytes, Scalar.bytes, rdn]

/-- A `uint` load from device memory at a 4-aligned offset. -/
theorem load_u32 (ctx : Ctx) (sh : Shared) (region size align o : Nat)
    (hr : sh.regions region = some ⟨.device, size, align⟩) (ha : align % 4 = 0) (ho : o % 4 = 0) (hb : o + 4 ≤ size) :
    (loadAt ctx (.scalar .u32) ⟨region, ((o : Nat) : Int), .scalar .u32⟩).run sh =
      some (u32 (bytesWord ((List.range 4).map fun j => sh.bytes region (o + j))), rdn ctx sh region o 4) := by
  have h := loadAt_run ctx (.scalar .u32) ⟨region, ((o : Nat) : Int), .scalar .u32⟩ ⟨.device, size, align⟩ sh
    (u32 (bytesWord ((List.range 4).map fun j => sh.bytes region (o + j)))) hr (by simp) (Int.natCast_nonneg _)
    (by simpa [alignment, Scalar.bytes] using ha) (by simpa [loadOffset, alignment, Scalar.bytes] using ho)
    (by simp only [loadOffset, Int.toNat_natCast]; simp [Ty.bytes, Scalar.bytes]; omega)
    (by simp [loadOffset, decode, Ty.bytes, Scalar.bytes, Val.ofWord, u32, Scalar.width]; rw [List.take_of_length_le (by simp)])
  rw [h]
  simp only [loadOffset, Int.toNat_natCast]
  simp [Ty.bytes, Scalar.bytes, rdn]

theorem load_bf16 (ctx : Ctx) (sh : Shared) (region size align e : Nat)
    (hr : sh.regions region = some ⟨.device, size, align⟩) (ha : align % 2 = 0) (hb : 2 * e + 2 ≤ size) :
    (loadAt ctx (.scalar .bf16) ⟨region, ((2 * e : Nat) : Int), .scalar .bf16⟩).run sh =
      some (.bf16 (bfAt (sh.bytes region) e), rd ctx sh region (2 * e)) := by
  have h := loadAt_run ctx (.scalar .bf16) ⟨region, ((2 * e : Nat) : Int), .scalar .bf16⟩ ⟨.device, size, align⟩ sh
    (.bf16 (bfAt (sh.bytes region) e)) hr (by simp) (Int.natCast_nonneg _)
    (by simpa [alignment, Scalar.bytes] using ha) (by simp only [loadOffset, Int.toNat_natCast]; simp [alignment, Scalar.bytes])
    (by simp only [loadOffset, Int.toNat_natCast]; simp [Ty.bytes, Scalar.bytes]; omega) rfl
  rw [h]
  rfl

theorem store_bf16 (ctx : Ctx) (sh : Shared) (region size align e : Nat) (y : BF)
    (hr : sh.regions region = some ⟨.device, size, align⟩) (ha : align % 2 = 0) (hb : 2 * e + 2 ≤ size) :
    (storeAt ctx (.scalar .bf16) ⟨region, ((2 * e : Nat) : Int), .scalar .bf16⟩ (.bf16 y)).run sh =
      some ((), wr ctx sh region (2 * e) y) := by
  rw [storeAt_run ctx (.scalar .bf16) _ ⟨.device, size, align⟩ sh (.bf16 y) (wordBytes 2 (Val.bf16Bits y)) hr
    (by simp) (by simp) (Int.natCast_nonneg _) (by simpa [alignment, Scalar.bytes] using ha)
    (by simp only [Int.toNat_natCast]; simp [alignment, Scalar.bytes]) (by simp [Ty.bytes, Scalar.bytes]; omega)
    (by simp [encode, Val.word, Scalar.bytes])]
  rfl

/-- A bf16 load from a device or constant buffer. -/
theorem load_bf16_elem (ctx : Ctx) (sh : Shared) (region n : Nat) (r : Region) (M : ByteMemory.Bytes)
    (hr : sh.regions region = some r) (hs : r.space = .device ∨ r.space = .constant) (ha : 2 ∣ r.align)
    (hb : 2 * n + 2 ≤ r.size) (hm : sh.bytes region = M) :
    (loadAt ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩).run sh =
      some (.bf16 (bfAt M n), logged2 ctx sh region n false) := by
  have hlo : loadOffset (.scalar .bf16) r (2 * n) = 2 * n := by
    unfold loadOffset; rcases hs with h | h <;> simp [h]
  have := loadAt_run ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩ r sh
    (.bf16 (bfAt M n)) hr (by rcases hs with h | h <;> simp [h]) (by simp)
    (by simp only [alignment, Scalar.bytes]; exact Nat.mod_eq_zero_of_dvd ha)
    (by simp only [Int.toNat_natCast, hlo, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, hlo, Ty.bytes, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, hlo, hm]; rfl)
  simpa only [Int.toNat_natCast, hlo, Ty.bytes, Scalar.bytes, logged2] using this

/-- A bf16 store to a device buffer. -/
theorem store_bf16_elem (ctx : Ctx) (sh : Shared) (region n : Nat) (r : Region) (v : BF)
    (hr : sh.regions region = some r) (hs : r.space = .device) (ha : 2 ∣ r.align) (hb : 2 * n + 2 ≤ r.size) :
    (storeAt ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩ (.bf16 v)).run sh =
      some ((), written2 (logged2 ctx sh region n true) region n v) :=
  storeAt_run ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩ r sh (.bf16 v)
    (wordBytes 2 (Val.bf16Bits v)) hr (by simp [hs]) (by simp [hs]) (by simp)
    (by simp only [alignment, Scalar.bytes]; exact Nat.mod_eq_zero_of_dvd ha)
    (by simp only [Int.toNat_natCast, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, Ty.bytes, Scalar.bytes]; omega) rfl

/-- A bf16 load from a device or constant buffer. -/
theorem load_bf16_logged (ctx : Ctx) (sh : Shared) (region n : Nat) (r : Region) (M : ByteMemory.Bytes)
    (hr : sh.regions region = some r) (hs : r.space = .device ∨ r.space = .constant) (ha : 2 ∣ r.align)
    (hb : 2 * n + 2 ≤ r.size) (hm : sh.bytes region = M) :
    (loadAt ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩).run sh =
      some (.bf16 (bfAt M n), logged ctx sh region 2 n false) := by
  have hlo : loadOffset (.scalar .bf16) r (2 * n) = 2 * n := by
    unfold loadOffset; rcases hs with h | h <;> simp [h]
  have := loadAt_run ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩ r sh
    (.bf16 (bfAt M n)) hr (by rcases hs with h | h <;> simp [h]) (by simp)
    (by simp only [alignment, Scalar.bytes]; exact Nat.mod_eq_zero_of_dvd ha)
    (by simp only [Int.toNat_natCast, hlo, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, hlo, Ty.bytes, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, hlo, hm]; rfl)
  simpa only [Int.toNat_natCast, hlo, Ty.bytes, Scalar.bytes, logged] using this

/-- A bf16 store to a device buffer. -/
theorem store_bf16_logged (ctx : Ctx) (sh : Shared) (region n : Nat) (r : Region) (v : BF)
    (hr : sh.regions region = some r) (hs : r.space = .device) (ha : 2 ∣ r.align) (hb : 2 * n + 2 ≤ r.size) :
    (storeAt ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩ (.bf16 v)).run sh =
      some ((), tput (logged ctx sh region 2 n true) region (2 * n) (wordBytes 2 (Val.bf16Bits v))) :=
  storeAt_run ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩ r sh (.bf16 v)
    (wordBytes 2 (Val.bf16Bits v)) hr (by simp [hs]) (by simp [hs]) (by simp)
    (by simp only [alignment, Scalar.bytes]; exact Nat.mod_eq_zero_of_dvd ha)
    (by simp only [Int.toNat_natCast, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, Ty.bytes, Scalar.bytes]; omega) rfl

/-- A binary32 load from a device or constant buffer. -/
theorem load_f32 (ctx : Ctx) (sh : Shared) (region n : Nat) (r : Region) (M : ByteMemory.Bytes)
    (hr : sh.regions region = some r) (hs : r.space = .device ∨ r.space = .constant) (ha : 4 ∣ r.align)
    (hb : 4 * n + 4 ≤ r.size) (hm : sh.bytes region = M) :
    (loadAt ctx (.scalar .f32) ⟨region, ((4 * n : Nat) : Int), .scalar .f32⟩).run sh =
      some (.f32 (f32At M n), logged ctx sh region 4 n false) := by
  have hlo : loadOffset (.scalar .f32) r (4 * n) = 4 * n := by
    unfold loadOffset; rcases hs with h | h <;> simp [h]
  have := loadAt_run ctx (.scalar .f32) ⟨region, ((4 * n : Nat) : Int), .scalar .f32⟩ r sh
    (.f32 (f32At M n)) hr (by rcases hs with h | h <;> simp [h]) (by simp)
    (by simp only [alignment, Scalar.bytes]; exact Nat.mod_eq_zero_of_dvd ha)
    (by simp only [Int.toNat_natCast, hlo, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, hlo, Ty.bytes, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, hlo, hm]; rfl)
  simpa only [Int.toNat_natCast, hlo, Ty.bytes, Scalar.bytes, logged] using this

/-- A binary32 store to a device buffer. -/
theorem store_f32 (ctx : Ctx) (sh : Shared) (region n : Nat) (r : Region) (v : Float32)
    (hr : sh.regions region = some r) (hs : r.space = .device) (ha : 4 ∣ r.align) (hb : 4 * n + 4 ≤ r.size) :
    (storeAt ctx (.scalar .f32) ⟨region, ((4 * n : Nat) : Int), .scalar .f32⟩ (.f32 v)).run sh =
      some ((), tput (logged ctx sh region 4 n true) region (4 * n) (wordBytes 4 (Val.f32Bits v))) :=
  storeAt_run ctx (.scalar .f32) ⟨region, ((4 * n : Nat) : Int), .scalar .f32⟩ r sh (.f32 v)
    (wordBytes 4 (Val.f32Bits v)) hr (by simp [hs]) (by simp [hs]) (by simp)
    (by simp only [alignment, Scalar.bytes]; exact Nat.mod_eq_zero_of_dvd ha)
    (by simp only [Int.toNat_natCast, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, Ty.bytes, Scalar.bytes]; omega) rfl

theorem load_f32_group (ctx : Ctx) (sh : Shared) (region size e : Nat)
    (hr : sh.regions region = some ⟨.threadgroup, size, 4⟩) (hb : 4 * e + 4 ≤ size) :
    (loadAt ctx (.scalar .f32) ⟨region, ((4 * e : Nat) : Int), .scalar .f32⟩).run sh =
      some (.f32 (f32At (sh.bytes region) e), rd4 ctx sh region (4 * e)) := by
  have ho : loadOffset (.scalar .f32) ⟨.threadgroup, size, 4⟩ (((4 * e : Nat) : Int)).toNat = 4 * e := by
    simp only [loadOffset, Int.toNat_natCast]; simp [Ty.bytes, Scalar.bytes]
  have h := loadAt_run ctx (.scalar .f32) ⟨region, ((4 * e : Nat) : Int), .scalar .f32⟩ ⟨.threadgroup, size, 4⟩ sh
    (.f32 (f32At (sh.bytes region) e)) hr (by simp) (Int.natCast_nonneg _) (by simp [alignment, Scalar.bytes])
    (by rw [ho]; simp [alignment, Scalar.bytes]) (by rw [ho]; simp [Ty.bytes, Scalar.bytes]; omega) (by rw [ho]; rfl)
  rw [h, ho]
  rfl

theorem store_f32_group (ctx : Ctx) (sh : Shared) (region size e : Nat) (y : Float32)
    (hr : sh.regions region = some ⟨.threadgroup, size, 4⟩) (hb : 4 * e + 4 ≤ size) :
    (storeAt ctx (.scalar .f32) ⟨region, ((4 * e : Nat) : Int), .scalar .f32⟩ (.f32 y)).run sh =
      some ((), wr4 ctx sh region (4 * e) y) := by
  rw [storeAt_run ctx (.scalar .f32) _ ⟨.threadgroup, size, 4⟩ sh (.f32 y) (wordBytes 4 (Val.f32Bits y)) hr
    (by simp) (by simp) (Int.natCast_nonneg _) (by simp [alignment, Scalar.bytes])
    (by simp only [Int.toNat_natCast]; simp [alignment, Scalar.bytes]) (by simp [Ty.bytes, Scalar.bytes]; omega)
    (by simp [encode, Val.word, Scalar.bytes])]
  rfl

/-- A `vec<bfloat, 4>` load from device memory at an 8-aligned offset: four bf16 elements from `e`. -/
theorem load_vec4_bf16 (ctx : Ctx) (sh : Shared) (region size align e : Nat)
    (hr : sh.regions region = some ⟨.device, size, align⟩) (ha : align % 8 = 0) (he : e % 4 = 0) (hb : 2 * e + 8 ≤ size) :
    (loadAt ctx (.vec .bf16 4) ⟨region, ((2 * e : Nat) : Int), .vec .bf16 4⟩).run sh =
      some (.vec .bf16 [.bf16 (bfAt (sh.bytes region) e), .bf16 (bfAt (sh.bytes region) (e + 1)),
        .bf16 (bfAt (sh.bytes region) (e + 2)), .bf16 (bfAt (sh.bytes region) (e + 3))], rdn ctx sh region (2 * e) 8) := by
  have hlo : loadOffset (.vec .bf16 4) ⟨.device, size, align⟩ ((2 * e : Nat) : Int).toNat = 2 * e := by
    simp only [loadOffset, Int.toNat_natCast]; simp
  have h := loadAt_run ctx (.vec .bf16 4) ⟨region, ((2 * e : Nat) : Int), .vec .bf16 4⟩ ⟨.device, size, align⟩ sh
    (.vec .bf16 [.bf16 (bfAt (sh.bytes region) e), .bf16 (bfAt (sh.bytes region) (e + 1)),
        .bf16 (bfAt (sh.bytes region) (e + 2)), .bf16 (bfAt (sh.bytes region) (e + 3))]) hr (by simp)
    (Int.natCast_nonneg _) (by simpa [alignment, Ty.bytes, Scalar.bytes] using ha)
    (by rw [hlo]; simp [alignment, Ty.bytes, Scalar.bytes]; omega) (by rw [hlo]; simp [Ty.bytes, Scalar.bytes]; omega)
    (by
      rw [hlo]
      simp [decode, bfAt, Ty.bytes, Scalar.bytes, List.range_succ, Val.ofWord, bytesWord]
      refine ⟨?_, ?_, ?_⟩ <;> ring_nf)
  rw [h, hlo]
  rfl

/-- A `uint4` as its four words. -/
def vec4 (bs : List (BitVec 8)) : Val :=
  .vec .u32 ((List.range 4).map fun i => Val.ofWord .u32 (bytesWord ((bs.drop (Scalar.u32.bytes * i)).take Scalar.u32.bytes)))

/-- A `uint4` load from device or threadgroup memory at a 16-aligned offset. -/
theorem load_vec4 (ctx : Ctx) (sh : Shared) (reg o : Nat) (r : Region) (hr : sh.regions reg = some r)
    (hs : r.space ≠ .thread) (ha : r.align % 16 = 0) (hoa : o % 16 = 0) (hb : o + 16 ≤ r.size) :
    (loadAt ctx (.vec .u32 4) ⟨reg, (o : Int), .vec .u32 4⟩).run sh =
      some (vec4 (cells (sh.bytes reg) o 16), rdn ctx sh reg o 16) := by
  have hlo : loadOffset (.vec .u32 4) r (o : Int).toNat = o := by simp [loadOffset, Ty.bytes, Scalar.bytes]
  have h := loadAt_run ctx (.vec .u32 4) ⟨reg, (o : Int), .vec .u32 4⟩ r sh (vec4 (cells (sh.bytes reg) o 16)) hr hs
    (Int.natCast_nonneg _) (by simpa [alignment, Ty.bytes, Scalar.bytes] using ha)
    (by rw [hlo]; simpa [alignment, Ty.bytes, Scalar.bytes] using hoa) (by rw [hlo]; simpa [Ty.bytes, Scalar.bytes] using hb)
    (by rw [hlo]; rfl)
  rw [h, hlo]
  rfl

/-- A `uint4` copied word by word stores back the bytes it was loaded from. -/
theorem encode_vec4 (B : ByteMemory.Bytes) (o : Nat) : encode (.vec .u32 4) (vec4 (cells B o 16)) = some (cells B o 16) := by
  have hc : cells B o 16 = [B (o + 0), B (o + 1), B (o + 2), B (o + 3), B (o + 4), B (o + 5), B (o + 6), B (o + 7),
      B (o + 8), B (o + 9), B (o + 10), B (o + 11), B (o + 12), B (o + 13), B (o + 14), B (o + 15)] := rfl
  rw [hc]
  generalize B (o + 0) = b0, B (o + 1) = b1, B (o + 2) = b2, B (o + 3) = b3, B (o + 4) = b4, B (o + 5) = b5,
    B (o + 6) = b6, B (o + 7) = b7, B (o + 8) = b8, B (o + 9) = b9, B (o + 10) = b10, B (o + 11) = b11,
    B (o + 12) = b12, B (o + 13) = b13, B (o + 14) = b14, B (o + 15) = b15
  have hw : ∀ a b c d : BitVec 8, (Val.ofWord .u32 (bytesWord [a, b, c, d])).word = some (.u32, bytesWord [a, b, c, d]) := by
    intro a b c d
    have := bytesWord_lt [a, b, c, d]
    simp only [Val.ofWord, Val.word, Scalar.width, Scalar.bytes, List.length_cons, List.length_nil] at this ⊢
    rw [Nat.mod_eq_of_lt (by simpa using this)]
  show encode (.vec .u32 4) (.vec .u32 [Val.ofWord .u32 (bytesWord [b0, b1, b2, b3]), Val.ofWord .u32 (bytesWord [b4, b5, b6, b7]),
    Val.ofWord .u32 (bytesWord [b8, b9, b10, b11]), Val.ofWord .u32 (bytesWord [b12, b13, b14, b15])]) = _
  simp only [encode, List.length_cons, List.length_nil, and_self, ite_true, List.mapM_cons, List.mapM_nil, hw,
    Option.bind_eq_bind, Option.bind_some, ite_true, Option.pure_def, Option.map_some]
  simp only [Scalar.bytes, wordBytes4_bytesWord]
  rfl

/-- A `uint4` store to device or threadgroup memory at a 16-aligned offset, of bytes loaded from `B`. -/
theorem store_vec4 (ctx : Ctx) (sh : Shared) (reg o : Nat) (r : Region) (B : ByteMemory.Bytes) (o' : Nat)
    (hr : sh.regions reg = some r) (hs : r.space ≠ .thread) (hc : r.space ≠ .constant) (ha : r.align % 16 = 0)
    (hoa : o % 16 = 0) (hb : o + 16 ≤ r.size) :
    (storeAt ctx (.vec .u32 4) ⟨reg, (o : Int), .vec .u32 4⟩ (vec4 (cells B o' 16))).run sh =
      some ((), wrn ctx sh reg o 16 (cells B o' 16)) := by
  have h := storeAt_run ctx (.vec .u32 4) ⟨reg, (o : Int), .vec .u32 4⟩ r sh _ _ hr hs hc (Int.natCast_nonneg _)
    (by simpa [alignment, Ty.bytes, Scalar.bytes] using ha) (by simpa [alignment, Ty.bytes, Scalar.bytes] using hoa)
    (by simpa [Ty.bytes, Scalar.bytes] using hb) (encode_vec4 B o')
  rw [h]
  rfl

section Device
variable (C : M1Max.Contract)

/-- A `vec<bfloat, 4>` load from device memory at an 8-aligned offset. -/
theorem load_bf16x4 (ctx : Ctx) (sh : Shared) (reg o : Nat) (r : Region) (hr : sh.regions reg = some r)
    (hs : r.space ≠ .thread) (ha : r.align % 8 = 0) (hoa : o % 8 = 0) (hb : o + 8 ≤ r.size) :
    (loadAt ctx (.vec .bf16 4) ⟨reg, (o : Int), .vec .bf16 4⟩).run sh =
      some (.vec .bf16 [bfVal (sh.bytes reg) o, bfVal (sh.bytes reg) (o + 2), bfVal (sh.bytes reg) (o + 4),
        bfVal (sh.bytes reg) (o + 6)], rdn ctx sh reg o 8) := by
  have hlo : loadOffset (.vec .bf16 4) r (o : Int).toNat = o := by simp [loadOffset, Ty.bytes, Scalar.bytes]
  have hd : decode (.vec .bf16 4) ((List.range (Ty.vec .bf16 4).bytes).map fun i =>
      sh.bytes reg (loadOffset (.vec .bf16 4) r (o : Int).toNat + i)) =
      some (.vec .bf16 [bfVal (sh.bytes reg) o, bfVal (sh.bytes reg) (o + 2), bfVal (sh.bytes reg) (o + 4),
        bfVal (sh.bytes reg) (o + 6)]) := by
    rw [hlo]
    show some (Val.vec .bf16 [Val.ofWord .bf16 (bytesWord (((cells (sh.bytes reg) o 8).drop (2 * 0)).take 2)),
      Val.ofWord .bf16 (bytesWord (((cells (sh.bytes reg) o 8).drop (2 * 1)).take 2)),
      Val.ofWord .bf16 (bytesWord (((cells (sh.bytes reg) o 8).drop (2 * 2)).take 2)),
      Val.ofWord .bf16 (bytesWord (((cells (sh.bytes reg) o 8).drop (2 * 3)).take 2))]) = _
    rw [cells_drop_take _ _ _ _ _ (by omega), cells_drop_take _ _ _ _ _ (by omega),
      cells_drop_take _ _ _ _ _ (by omega), cells_drop_take _ _ _ _ _ (by omega)]
    rfl
  have h := loadAt_run ctx (.vec .bf16 4) ⟨reg, (o : Int), .vec .bf16 4⟩ r sh _ hr hs (Int.natCast_nonneg _)
    (by simpa [alignment, Ty.bytes, Scalar.bytes] using ha)
    (by rw [hlo]; simpa [alignment, Ty.bytes, Scalar.bytes] using hoa)
    (by rw [hlo]; simpa [Ty.bytes, Scalar.bytes] using hb) hd
  rw [h, hlo]
  rfl

end Device

/-- A `half4` store to device memory at an 8-aligned offset. -/
theorem store_half4 (ctx : Ctx) (sh : Shared) (reg o : Nat) (r : Region) (h0 h1 h2 h3 : Float16.Value)
    (hr : sh.regions reg = some r) (hs : r.space ≠ .thread) (hc : r.space ≠ .constant) (ha : r.align % 8 = 0)
    (hoa : o % 8 = 0) (hb : o + 8 ≤ r.size) :
    (storeAt ctx (.vec .f16 4) ⟨reg, (o : Int), .vec .f16 4⟩ (.vec .f16 [.f16 h0, .f16 h1, .f16 h2, .f16 h3])).run sh =
      some ((), wrn ctx sh reg o 8 (wordBytes 2 (Val.f16Bits h0) ++ wordBytes 2 (Val.f16Bits h1) ++
        wordBytes 2 (Val.f16Bits h2) ++ wordBytes 2 (Val.f16Bits h3))) := by
  have h := storeAt_run ctx (.vec .f16 4) ⟨reg, (o : Int), .vec .f16 4⟩ r sh _ _ hr hs hc (Int.natCast_nonneg _)
    (by simpa [alignment, Ty.bytes, Scalar.bytes] using ha) (by simpa [alignment, Ty.bytes, Scalar.bytes] using hoa)
    (by simpa [Ty.bytes, Scalar.bytes] using hb) (encode_half4 h0 h1 h2 h3)
  rw [h]
  rfl

/-! ## Thread memory -/

/-- A scalar load from thread memory (not logged). -/
theorem load_thread (ctx : Ctx) (s : Scalar) (sh : Shared) (reg o size al : Nat)
    (hr : sh.regions reg = some ⟨.thread, size, al⟩) (ha : al % s.bytes = 0) (hoa : o % s.bytes = 0)
    (hb : o + s.bytes ≤ size) :
    (loadAt ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩).run sh =
      some (Val.ofWord s (bytesWord (cells (sh.bytes reg) o s.bytes)), sh) :=
  loadAt_run_thread ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩ ⟨.thread, size, al⟩ sh
    (Val.ofWord s (bytesWord (cells (sh.bytes reg) o s.bytes))) hr rfl (Int.natCast_nonneg _)
    (by simpa [alignment] using ha) (by simpa [alignment] using hoa) (by simpa [Ty.bytes] using hb)
    (by rw [Int.toNat_natCast]; exact decode_cells s (sh.bytes reg) o)

/-- A scalar store to thread memory (not logged). -/
theorem store_thread (ctx : Ctx) (s : Scalar) (sh : Shared) (reg o size al : Nat) (v : Val) (bs : List (BitVec 8))
    (hr : sh.regions reg = some ⟨.thread, size, al⟩) (ha : al % s.bytes = 0) (hoa : o % s.bytes = 0)
    (hb : o + s.bytes ≤ size) (he : encode (.scalar s) v = some bs) :
    (storeAt ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩ v).run sh = some ((), tput sh reg o bs) := by
  have h := storeAt_run_thread ctx (.scalar s) ⟨reg, (o : Int), .scalar s⟩ ⟨.thread, size, al⟩ sh v bs hr rfl
    (Int.natCast_nonneg _) (by simpa [alignment] using ha) (by simpa [alignment] using hoa)
    (by simpa [Ty.bytes] using hb) he
  simpa [tput] using h

/-- A load from thread memory. -/
theorem load_t (ctx : Ctx) (ty e : Ty) (sh : Shared) (reg o size al : Nat) (v : Val)
    (hr : sh.regions reg = some ⟨.thread, size, al⟩) (ha : al % alignment ty = 0) (hoa : o % alignment ty = 0)
    (hb : o + ty.bytes ≤ size) (hd : decode ty (cells (sh.bytes reg) o ty.bytes) = some v) :
    (loadAt ctx ty ⟨reg, (o : Int), e⟩).run sh = some (v, sh) :=
  loadAt_run_thread ctx ty ⟨reg, (o : Int), e⟩ ⟨.thread, size, al⟩ sh v hr rfl (Int.natCast_nonneg _) ha
    (by simpa using hoa) (by simpa using hb) (by simpa [cells] using hd)

/-- A store to thread memory. -/
theorem store_t (ctx : Ctx) (ty e : Ty) (sh : Shared) (reg o size al : Nat) (v : Val) (bs : List (BitVec 8))
    (hr : sh.regions reg = some ⟨.thread, size, al⟩) (ha : al % alignment ty = 0) (hoa : o % alignment ty = 0)
    (hb : o + ty.bytes ≤ size) (he : encode ty v = some bs) :
    (storeAt ctx ty ⟨reg, (o : Int), e⟩ v).run sh = some ((), tput sh reg o bs) := by
  have h := storeAt_run_thread ctx ty ⟨reg, (o : Int), e⟩ ⟨.thread, size, al⟩ sh v bs hr rfl (Int.natCast_nonneg _) ha
    (by simpa using hoa) (by simpa using hb) he
  simpa [tput] using h

theorem load_f32_thread (ctx : Ctx) (sh : Shared) (region size e : Nat)
    (hr : sh.regions region = some ⟨.thread, size, 4⟩) (hb : 4 * e + 4 ≤ size) :
    (loadAt ctx (.scalar .f32) ⟨region, ((4 * e : Nat) : Int), .scalar .f32⟩).run sh =
      some (.f32 (f32At (sh.bytes region) e), sh) :=
  loadAt_run_thread ctx (.scalar .f32) _ ⟨.thread, size, 4⟩ sh _ hr rfl (Int.natCast_nonneg _)
    (by simp [alignment, Scalar.bytes]) (by simp only [Int.toNat_natCast]; simp [alignment, Scalar.bytes])
    (by simp [Ty.bytes, Scalar.bytes]; omega) rfl

theorem store_f32_thread (ctx : Ctx) (sh : Shared) (region size e : Nat) (y : Float32)
    (hr : sh.regions region = some ⟨.thread, size, 4⟩) (hb : 4 * e + 4 ≤ size) :
    (storeAt ctx (.scalar .f32) ⟨region, ((4 * e : Nat) : Int), .scalar .f32⟩ (.f32 y)).run sh =
      some ((), wrT sh region (4 * e) y) := by
  rw [storeAt_run_thread ctx (.scalar .f32) _ ⟨.thread, size, 4⟩ sh (.f32 y) (wordBytes 4 (Val.f32Bits y)) hr rfl
    (Int.natCast_nonneg _) (by simp [alignment, Scalar.bytes]) (by simp only [Int.toNat_natCast]; simp [alignment, Scalar.bytes])
    (by simp [Ty.bytes, Scalar.bytes]; omega) (by simp [encode, Val.word, Scalar.bytes])]
  rfl

/-- A binary32 load from the thread's own array. -/
theorem load_f32_thread_of (ctx : Ctx) (sh : Shared) (region n size : Nat) (x : Float32)
    (hr : sh.regions region = some ⟨.thread, size, 4⟩) (hb : 4 * n + 4 ≤ size)
    (hm : ∀ i < 4, sh.bytes region (4 * n + i) = (wordBytes 4 (Val.f32Bits x)).getD i 0) :
    (loadAt ctx (.scalar .f32) ⟨region, ((4 * n : Nat) : Int), .scalar .f32⟩).run sh = some (.f32 x, sh) :=
  loadAt_run_thread ctx (.scalar .f32) ⟨region, ((4 * n : Nat) : Int), .scalar .f32⟩ ⟨.thread, size, 4⟩ sh
    (.f32 x) hr rfl (by simp) (by simp [alignment, Scalar.bytes])
    (by simp only [Int.toNat_natCast, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, Ty.bytes, Scalar.bytes]; omega) (decode_f32 _ _ x hm)

/-- A binary32 store to the thread's own array. -/
theorem store_f32_thread_tput (ctx : Ctx) (sh : Shared) (region n size : Nat) (v : Float32)
    (hr : sh.regions region = some ⟨.thread, size, 4⟩) (hb : 4 * n + 4 ≤ size) :
    (storeAt ctx (.scalar .f32) ⟨region, ((4 * n : Nat) : Int), .scalar .f32⟩ (.f32 v)).run sh =
      some ((), tput sh region (4 * n) (wordBytes 4 (Val.f32Bits v))) :=
  storeAt_run_thread ctx (.scalar .f32) ⟨region, ((4 * n : Nat) : Int), .scalar .f32⟩ ⟨.thread, size, 4⟩ sh
    (.f32 v) (wordBytes 4 (Val.f32Bits v)) hr rfl (by simp) (by simp [alignment, Scalar.bytes])
    (by simp only [Int.toNat_natCast, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, Ty.bytes, Scalar.bytes]; omega) rfl

/-- A bf16 load from the thread's own array. -/
theorem load_bf16_thread (ctx : Ctx) (sh : Shared) (region n size : Nat) (x : BF)
    (hr : sh.regions region = some ⟨.thread, size, 2⟩) (hb : 2 * n + 2 ≤ size)
    (hm : ∀ i < 2, sh.bytes region (2 * n + i) = (wordBytes 2 (Val.bf16Bits x)).getD i 0) :
    (loadAt ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩).run sh = some (.bf16 x, sh) :=
  loadAt_run_thread ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩ ⟨.thread, size, 2⟩ sh
    (.bf16 x) hr rfl (by simp) (by simp [alignment, Scalar.bytes]) (by simp only [Int.toNat_natCast, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, Ty.bytes, Scalar.bytes]; omega) (decode_bf16 _ _ x hm)

/-- A bf16 store to the thread's own array. -/
theorem store_bf16_thread (ctx : Ctx) (sh : Shared) (region n size : Nat) (v : BF)
    (hr : sh.regions region = some ⟨.thread, size, 2⟩) (hb : 2 * n + 2 ≤ size) :
    (storeAt ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩ (.bf16 v)).run sh =
      some ((), written2 sh region n v) :=
  storeAt_run_thread ctx (.scalar .bf16) ⟨region, ((2 * n : Nat) : Int), .scalar .bf16⟩ ⟨.thread, size, 2⟩ sh
    (.bf16 v) (wordBytes 2 (Val.bf16Bits v)) hr rfl (by simp) (by simp [alignment, Scalar.bytes])
    (by simp only [Int.toNat_natCast, alignment, Scalar.bytes]; omega)
    (by simp only [Int.toNat_natCast, Ty.bytes, Scalar.bytes]; omega) rfl

/-- A `half2`-sized thread array holding two halves loads as their vector (not logged). -/
theorem load_vec_f16 (ctx : Ctx) (sh : Shared) (reg : Nat) (hr : sh.regions reg = some ⟨.thread, 4, 4⟩)
    (a0 a1 : Float16.Value) (h0 : cells (sh.bytes reg) 0 2 = wordBytes 2 (Val.f16Bits a0))
    (h1 : cells (sh.bytes reg) 2 2 = wordBytes 2 (Val.f16Bits a1)) :
    (loadAt ctx (.vec .f16 2) ⟨reg, 0, .vec .f16 2⟩).run sh = some (.vec .f16 [.f16 a0, .f16 a1], sh) := by
  refine loadAt_run_thread ctx (.vec .f16 2) ⟨reg, 0, .vec .f16 2⟩ ⟨.thread, 4, 4⟩ sh _ hr rfl (le_refl _)
    (by decide) (by simp [Ty.bytes, Scalar.bytes, alignment]) (by simp [Ty.bytes, Scalar.bytes]) ?_
  show decode (.vec .f16 2) (cells (sh.bytes reg) 0 4) = _
  rw [decode_vec_f16, h0, h1, ofWord_f16, ofWord_f16]

/-- A `float2`-sized thread array holding two floats loads as their vector (not logged). -/
theorem load_vec_f32 (ctx : Ctx) (sh : Shared) (reg : Nat) (hr : sh.regions reg = some ⟨.thread, 8, 8⟩)
    (b0 b1 : Float32) (h0 : cells (sh.bytes reg) 0 4 = wordBytes 4 (Val.f32Bits b0))
    (h1 : cells (sh.bytes reg) 4 4 = wordBytes 4 (Val.f32Bits b1)) :
    (loadAt ctx (.vec .f32 2) ⟨reg, 0, .vec .f32 2⟩).run sh = some (.vec .f32 [.f32 b0, .f32 b1], sh) := by
  refine loadAt_run_thread ctx (.vec .f32 2) ⟨reg, 0, .vec .f32 2⟩ ⟨.thread, 8, 8⟩ sh _ hr rfl (le_refl _)
    (by decide) (by simp [Ty.bytes, Scalar.bytes, alignment]) (by simp [Ty.bytes, Scalar.bytes]) ?_
  show decode (.vec .f32 2) (cells (sh.bytes reg) 0 8) = _
  rw [decode_vec_f32, h0, h1, ofWord_f32, ofWord_f32]

section Thread
variable (C : M1Max.Contract)

/-- A `float2` (two f32 words) in thread memory. -/
theorem load_thread_f32x2 (ctx : Ctx) (sh : Shared) (reg o size al : Nat)
    (hr : sh.regions reg = some ⟨.thread, size, al⟩) (ha : al % 8 = 0) (hoa : o % 8 = 0) (hb : o + 8 ≤ size)
    {x y : Float32} (hx : cells (sh.bytes reg) o 4 = wordBytes 4 (Val.f32Bits x))
    (hy : cells (sh.bytes reg) (o + 4) 4 = wordBytes 4 (Val.f32Bits y)) :
    (loadAt ctx (.vec .f32 2) ⟨reg, (o : Int), .vec .f32 2⟩).run sh = some (.vec .f32 [.f32 x, .f32 y], sh) := by
  refine loadAt_run_thread ctx (.vec .f32 2) ⟨reg, (o : Int), .vec .f32 2⟩ ⟨.thread, size, al⟩ sh _ hr rfl
    (Int.natCast_nonneg _) (by simpa [alignment, Ty.bytes, Scalar.bytes] using ha)
    (by simpa [alignment, Ty.bytes, Scalar.bytes] using hoa) (by simpa [Ty.bytes, Scalar.bytes] using hb) ?_
  rw [Int.toNat_natCast]
  have e0 : ((cells (sh.bytes reg) o 8).drop (4 * 0)).take 4 = cells (sh.bytes reg) o 4 := by
    rw [cells_drop_take _ _ _ _ _ (by omega)]; rfl
  have e1 : ((cells (sh.bytes reg) o 8).drop (4 * 1)).take 4 = cells (sh.bytes reg) (o + 4) 4 :=
    cells_drop_take _ _ _ _ _ (by omega)
  show some (Val.vec .f32 [Val.ofWord .f32 (bytesWord (((cells (sh.bytes reg) o 8).drop (4 * 0)).take 4)),
    Val.ofWord .f32 (bytesWord (((cells (sh.bytes reg) o 8).drop (4 * 1)).take 4))]) = _
  rw [e0, e1, hx, hy, ofWord_f32, ofWord_f32]

/-- A `float2` store to thread memory. -/
theorem store_thread_f32x2 (ctx : Ctx) (sh : Shared) (reg o size al : Nat)
    (hr : sh.regions reg = some ⟨.thread, size, al⟩) (ha : al % 8 = 0) (hoa : o % 8 = 0) (hb : o + 8 ≤ size)
    (x y : Float32) :
    (storeAt ctx (.vec .f32 2) ⟨reg, (o : Int), .vec .f32 2⟩ (.vec .f32 [.f32 x, .f32 y])).run sh =
      some ((), tput sh reg o (wordBytes 4 (Val.f32Bits x) ++ wordBytes 4 (Val.f32Bits y))) := by
  have h := storeAt_run_thread ctx (.vec .f32 2) ⟨reg, (o : Int), .vec .f32 2⟩ ⟨.thread, size, al⟩ sh _ _ hr rfl
    (Int.natCast_nonneg _) (by simpa [alignment, Ty.bytes, Scalar.bytes] using ha)
    (by simpa [alignment, Ty.bytes, Scalar.bytes] using hoa) (by simpa [Ty.bytes, Scalar.bytes] using hb)
    (encode_f32x2 x y)
  simpa [tput] using h

end Thread

section Thread
variable (C : M1Max.Contract) {ctx : Ctx}

/-- A thread-array `f32` element. -/
theorem load_f32_thread_cells {sh : Shared} {reg size o : Nat} {x : Float32} (hr : sh.regions reg = some ⟨.thread, size, 4⟩)
    (hb : 4 * o + 4 ≤ size) (hc : cells (sh.bytes reg) (4 * o) 4 = wordBytes 4 (Val.f32Bits x)) :
    (loadAt ctx (.scalar .f32) ⟨reg, ((4 * o : Nat) : Int), .scalar .f32⟩).run sh = some (.f32 x, sh) := by
  rw [load_thread ctx .f32 sh reg (4 * o) size 4 hr (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega)]
  simp only [Scalar.bytes]
  rw [hc, ofWord_f32]

/-- A lane's two binary32 `thread_elements()` in thread memory. -/
theorem load_pair_f32 {sh : Shared} {reg size o : Nat} {x y : Float32}
    (hr : sh.regions reg = some ⟨.thread, size, 8⟩) (ho : o % 8 = 0) (hb : o + 8 ≤ size)
    (hx : cells (sh.bytes reg) o 4 = wordBytes 4 (Val.f32Bits x))
    (hy : cells (sh.bytes reg) (o + 4) 4 = wordBytes 4 (Val.f32Bits y)) :
    (loadAt ctx (.vec .f32 2) ⟨reg, (o : Int), .vec .f32 2⟩).run sh = some (.vec .f32 [.f32 x, .f32 y], sh) := by
  refine loadAt_run_thread ctx (.vec .f32 2) ⟨reg, (o : Int), .vec .f32 2⟩ ⟨.thread, size, 8⟩ sh _ hr rfl (Int.natCast_nonneg _) (by simp [alignment, Ty.bytes, Scalar.bytes])
    (by simp [alignment, Ty.bytes, Scalar.bytes]; omega) (by simp [Ty.bytes, Scalar.bytes]; omega) ?_
  have e : ((List.range (Ty.vec .f32 2).bytes).map fun i => sh.bytes reg ((o : Int).toNat + i)) =
      cells (sh.bytes reg) o 8 := by rw [Int.toNat_natCast]; rfl
  rw [e]
  have h0 : ((cells (sh.bytes reg) o 8).drop (Scalar.f32.bytes * 0)).take Scalar.f32.bytes = cells (sh.bytes reg) o 4 :=
    cells_drop_take _ _ _ _ _ (by decide)
  have h1 : ((cells (sh.bytes reg) o 8).drop (Scalar.f32.bytes * 1)).take Scalar.f32.bytes =
      cells (sh.bytes reg) (o + 4) 4 := cells_drop_take _ _ _ _ _ (by decide)
  show some (Val.vec .f32 [Val.ofWord .f32 (bytesWord (((cells (sh.bytes reg) o 8).drop (Scalar.f32.bytes * 0)).take
      Scalar.f32.bytes)), Val.ofWord .f32 (bytesWord (((cells (sh.bytes reg) o 8).drop (Scalar.f32.bytes * 1)).take
      Scalar.f32.bytes))]) = _
  rw [h0, h1, hx, hy, ofWord_f32, ofWord_f32]

/-- A lane's two binary16 `thread_elements()` in thread memory. -/
theorem load_pair_f16 {sh : Shared} {reg size al o : Nat} {x y : Float16.Value}
    (hr : sh.regions reg = some ⟨.thread, size, al⟩) (hal : al % 4 = 0) (ho : o % 4 = 0) (hb : o + 4 ≤ size)
    (hx : cells (sh.bytes reg) o 2 = wordBytes 2 (Val.f16Bits x))
    (hy : cells (sh.bytes reg) (o + 2) 2 = wordBytes 2 (Val.f16Bits y)) :
    (loadAt ctx (.vec .f16 2) ⟨reg, (o : Int), .vec .f16 2⟩).run sh = some (.vec .f16 [.f16 x, .f16 y], sh) := by
  refine loadAt_run_thread ctx (.vec .f16 2) ⟨reg, (o : Int), .vec .f16 2⟩ ⟨.thread, size, al⟩ sh _ hr rfl (Int.natCast_nonneg _)
    (by simp [alignment, Ty.bytes, Scalar.bytes]; omega)
    (by simp [alignment, Ty.bytes, Scalar.bytes]; omega) (by simp [Ty.bytes, Scalar.bytes]; omega) ?_
  have e : ((List.range (Ty.vec .f16 2).bytes).map fun i => sh.bytes reg ((o : Int).toNat + i)) =
      cells (sh.bytes reg) o 4 := by rw [Int.toNat_natCast]; rfl
  rw [e]
  have h0 : ((cells (sh.bytes reg) o 4).drop (Scalar.f16.bytes * 0)).take Scalar.f16.bytes = cells (sh.bytes reg) o 2 :=
    cells_drop_take _ _ _ _ _ (by decide)
  have h1 : ((cells (sh.bytes reg) o 4).drop (Scalar.f16.bytes * 1)).take Scalar.f16.bytes =
      cells (sh.bytes reg) (o + 2) 2 := cells_drop_take _ _ _ _ _ (by decide)
  show some (Val.vec .f16 [Val.ofWord .f16 (bytesWord (((cells (sh.bytes reg) o 4).drop (Scalar.f16.bytes * 0)).take
      Scalar.f16.bytes)), Val.ofWord .f16 (bytesWord (((cells (sh.bytes reg) o 4).drop (Scalar.f16.bytes * 1)).take
      Scalar.f16.bytes))]) = _
  rw [h0, h1, hx, hy, ofWord_f16, ofWord_f16]

/-- A store of a lane's two binary32 `thread_elements()` to thread memory. -/
theorem store_pair_f32 {sh : Shared} {reg size o : Nat} (x y : Float32)
    (hr : sh.regions reg = some ⟨.thread, size, 8⟩) (ho : o % 8 = 0) (hb : o + 8 ≤ size) :
    (storeAt ctx (.vec .f32 2) ⟨reg, (o : Int), .vec .f32 2⟩ (.vec .f32 [.f32 x, .f32 y])).run sh =
      some ((), tput sh reg o (pairBytes x y)) := by
  have h := storeAt_run_thread ctx (.vec .f32 2) ⟨reg, (o : Int), .vec .f32 2⟩ ⟨.thread, size, 8⟩ sh _ _ hr rfl
    (Int.natCast_nonneg _) (by simp [alignment, Ty.bytes, Scalar.bytes]) (by simp [alignment, Ty.bytes, Scalar.bytes]; omega)
    (by simp [Ty.bytes, Scalar.bytes]; omega) (encode_pair x y)
  simpa [tput] using h

/-- A device pointer to bfloat at byte `off` of region 0, as thread memory holds it. -/
theorem encode_ptr_x (off : Nat) (h : off < 2 ^ 40) :
    encode (.ptr .device (.scalar .bf16)) (.ptr ⟨0, (off : Int), .scalar .bf16⟩) = some (wordBytes 8 off) := by
  simp [encode, ptrWord]; omega

theorem load_ptr_x {sh : Shared} {reg size o off : Nat} (hr : sh.regions reg = some ⟨.thread, size, 8⟩)
    (ho : o % 8 = 0) (hb : o + 8 ≤ size) (hoff : off < 2 ^ 40) (hc : cells (sh.bytes reg) o 8 = wordBytes 8 off) :
    (loadAt ctx (.ptr .device (.scalar .bf16)) ⟨reg, (o : Int), .ptr .device (.scalar .bf16)⟩).run sh =
      some (.ptr ⟨0, (off : Int), .scalar .bf16⟩, sh) := by
  refine loadAt_run_thread ctx (.ptr .device (.scalar .bf16)) ⟨reg, (o : Int), .ptr .device (.scalar .bf16)⟩ ⟨.thread, size, 8⟩ sh _ hr rfl (Int.natCast_nonneg _) (by simp [alignment, Ty.bytes])
    (by simp [alignment, Ty.bytes]; omega) (by simp [Ty.bytes]; omega) ?_
  have e : ((List.range (Ty.ptr .device (.scalar .bf16)).bytes).map fun i => sh.bytes reg ((o : Int).toNat + i)) =
      cells (sh.bytes reg) o 8 := by rw [Int.toNat_natCast]; rfl
  rw [e, hc]
  have hw : bytesWord (wordBytes 8 off) = off := by
    rw [bytesWord_wordBytes, Nat.mod_eq_of_lt (by have : (2 : Nat) ^ 40 ≤ 256 ^ 8 := by norm_num
                                                  omega)]
  simp only [decode, List.take_of_length_le (by rw [wordBytes_length] : (wordBytes 8 off).length ≤ 8), hw]
  rw [Nat.div_eq_of_lt hoff, Nat.mod_eq_of_lt hoff]

theorem store_ptr_x {sh : Shared} {reg size o off : Nat} (hr : sh.regions reg = some ⟨.thread, size, 8⟩)
    (ho : o % 8 = 0) (hb : o + 8 ≤ size) (hoff : off < 2 ^ 40) :
    (storeAt ctx (.ptr .device (.scalar .bf16)) ⟨reg, (o : Int), .ptr .device (.scalar .bf16)⟩
      (.ptr ⟨0, (off : Int), .scalar .bf16⟩)).run sh = some ((), tput sh reg o (wordBytes 8 off)) := by
  have h := storeAt_run_thread ctx (.ptr .device (.scalar .bf16)) ⟨reg, (o : Int), .ptr .device (.scalar .bf16)⟩
    ⟨.thread, size, 8⟩ sh _ _ hr rfl (Int.natCast_nonneg _) (by simp [alignment, Ty.bytes]) (by simp [alignment, Ty.bytes]; omega)
    (by simp [Ty.bytes]; omega) (encode_ptr_x off hoff)
  simpa [tput] using h

/-! ## Counted fills of thread arrays -/

/-- A counted loop from `a` to `N` (condition `cnd`, counter slot `c`) storing the word `F m` at element `m` of
thread array `reg` (slot `ptr`); the stored expression may read memory, leaving its bytes. -/
theorem exec_fill32 {Inv : Shared → Prop} {reg : Nat} {l : Locals} {sh : Shared} {size : Nat}
    (hput : ∀ sh o bs, Inv sh → Inv (tput sh reg o bs)) (N c ptr a : Nat) (cnd e : CExpr) (F : Nat → Nat)
    (hcnd : ∀ (l' : Locals) (sh' : Shared) (m : Nat), a ≤ m → m ≤ N → l' c = some (u32 m) →
      (∀ j, j ≠ c → l' j = l j) → Inv sh' → (eval C ctx l' cnd).run sh' = some (.bool (decide (m < N)), sh'))
    (he : ∀ (l' : Locals) (sh' : Shared) (m : Nat), a ≤ m → m < N → l' c = some (u32 m) →
      (∀ j, j ≠ c → l' j = l j) → Inv sh' →
      ∃ sh'', (eval C ctx l' e).run sh' = some (u32 (F m), sh'') ∧ Inv sh'' ∧ sh''.bytes = sh'.bytes)
    (hF : ∀ m, F m < 2 ^ 32) (hp : l ptr = some (.ptr ⟨reg, 0, .scalar .u32⟩)) (hcp : c ≠ ptr)
    (hr : ∀ sh', Inv sh' → sh'.regions reg = some ⟨.thread, size, 4⟩) (hsize : 4 * N ≤ size) (hN : N < 2 ^ 30)
    (haN : a ≤ N) (h0 : Inv sh) :
    ∃ l' sh', Exec C ctx [.set c (.lit (.int .u32 a)), .loop cnd [.set c (.bin .add .u32 0 (.local c) (.lit (.int .u32 1)))]
        [.store (.scalar .u32) (.offset (.local ptr) (.local c)) e]] l sh .normal l' sh' ∧ Inv sh' ∧
      (∀ j, j ≠ c → l' j = l j) ∧ (∀ r, r ≠ reg → sh'.bytes r = sh.bytes r) ∧
      (∀ o, o + 4 ≤ 4 * a ∨ 4 * N ≤ o → cells (sh'.bytes reg) o 4 = cells (sh.bytes reg) o 4) ∧
      ∀ m, a ≤ m → m < N → cells (sh'.bytes reg) (4 * m) 4 = wordBytes 4 (F m) := by
  let J : Nat → Locals → Shared → Prop := fun k l' sh' => Inv sh' ∧ (∀ j, j ≠ c → l' j = l j) ∧
    l' c = some (u32 (a + k)) ∧ (∀ r, r ≠ reg → sh'.bytes r = sh.bytes r) ∧
    (∀ o, o + 4 ≤ 4 * a ∨ 4 * N ≤ o → cells (sh'.bytes reg) o 4 = cells (sh.bytes reg) o 4) ∧
    ∀ m, a ≤ m → m < a + k → cells (sh'.bytes reg) (4 * m) 4 = wordBytes 4 (F m)
  obtain ⟨l', sh', hex, hJ⟩ := Exec.loop_count (c := cnd) (st := [.set c (.bin .add .u32 0 (.local c) (.lit (.int .u32 1)))])
    (ctx := ctx) (C := C) (N - a) J J
    (fun k hk l' sh' hJ => ⟨sh', by
      have := hcnd l' sh' (a + k) (by omega) (by omega) hJ.2.2.1 hJ.2.1 hJ.1
      rwa [show decide (a + k < N) = decide (k < N - a) from decide_eq_decide.mpr (by omega)] at this, hJ⟩)
    (fun k hk l' sh' hJ => by
      obtain ⟨hinv, hag, hc, hoth, hkeep, hw⟩ := hJ
      have hptr : (eval C ctx l' (.offset (.local ptr) (.local c))).run sh' =
          some (.ptr ⟨reg, ((4 * (a + k) : Nat) : Int), .scalar .u32⟩, sh') := by
        have := eval_ptr_u32 C (ctx := ctx) (eval_local' C (by rw [hag ptr hcp.symm]; exact hp) sh')
          (eval_local' C hc sh') (by omega)
        rwa [show (a + k) * (Ty.scalar .u32).bytes = 4 * (a + k) by simp [Ty.bytes, Scalar.bytes]; ring] at this
      obtain ⟨sh'', hev, hinv'', hb''⟩ := he l' sh' (a + k) (by omega) (by omega) hc hag hinv
      have hst := store_thread ctx .u32 sh'' reg (4 * (a + k)) size 4 (u32 (F (a + k))) (wordBytes 4 (F (a + k)))
        (hr sh'' hinv'') (by decide) (by simp [Scalar.bytes]) (by simp [Scalar.bytes]; omega) (encode_u32 _ (hF _))
      refine ⟨.normal, l', _, setLocal l' c (u32 (a + k + 1)), _, .inl rfl, .store hptr hev hst (.nil _ _),
        .set (eval_bin_u32 C (eval_local' C hc _) (eval_u32lit C _ _ 1 (by decide)) (binary_add_u32 C _ 1)) (.nil _ _),
        hput _ _ _ hinv'', fun j hj => by rw [setLocal_other _ _ hj]; exact hag j hj, by rw [setLocal_same]; rfl,
        fun r hr' => by rw [tput_other _ _ _ hr', hb'', hoth r hr'], fun o ho => ?_, fun m hm1 hm2 => ?_⟩
      · rw [tput_same, hb'', cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega), hkeep o ho]
      rw [tput_same, hb'']
      by_cases hmk : m = a + k
      · subst hmk
        have := cells_writeBytes_same (sh'.bytes reg) (4 * (a + k)) (wordBytes 4 (F (a + k)))
        rwa [wordBytes_length] at this
      · rw [cells_writeBytes_other _ _ _ _ _ (by rw [wordBytes_length]; omega)]
        exact hw m hm1 (by omega))
    (l := setLocal l c (u32 a)) (sh := sh)
    ⟨h0, fun j hj => setLocal_other _ _ hj, by rw [setLocal_same, Nat.add_zero], fun _ _ => rfl, fun _ _ => rfl,
      fun m h1 h2 => absurd h2 (by omega)⟩
  refine ⟨l', sh', .set (eval_u32lit C _ _ a (by omega)) hex, hJ.1, hJ.2.1, hJ.2.2.2.1, hJ.2.2.2.2.1, fun m h1 h2 => ?_⟩
  exact hJ.2.2.2.2.2 m h1 (by omega)

end Thread

end Metal
