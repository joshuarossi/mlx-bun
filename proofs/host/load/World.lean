import host.mlx.Ffi
namespace Host.Load
open Host.Ts

/-! # The host world of a model load

The interpreter's `Ffi` for a whole process: the mlx-c model
(`Host.Mlx.Ffi`) for `mlx_*` symbols, and for everything else a model of
the host the TypeScript reaches through `bun:ffi` and the runtime:

* the environment (`getenv`, `setenv`, `process.env`): an explicit list;
* the file system: paths to contents (text files the run reads, and
  binary files as their size and the prefix of bytes the run reads); a
  directory exists when a file lies below it;
* file descriptors and `mmap`: a mapping is native memory whose bytes are
  the file's modelled prefix (reading past it makes the run stuck);
* Metal device discovery through the Objective-C runtime
  (`MTLCreateSystemDefaultDevice`, `sel_registerName`, `objc_msgSend`):
  the device's architecture name is a platform fact (`arch`);
* the Neural Engine bridge (`libmlx_bun_ane.dylib`, `mbane_*`): calls return
  fresh opaque handles and touch no MLX state;
* host calls of the JavaScript host library (`%…` names): files, the
  environment block, the working directory and the machine's memory size.

Every call is an `Event` of the trace. Host objects are native memory
regions `4h + 3` (`h ≥ 512`); mappings are `h = k < 512` at the numeric
addresses `hostAddr` decodes (`HostBuiltins`). -/

/-- A file: text contents, or a binary file of `size` bytes whose first bytes are `pre`. -/
inductive FileC where
  | text (cs : List Char)
  | blob (size : Nat) (pre : List Nat)

inductive HObj where
  | mapping (path : List Char)
  | cstr (cs : List Char)
  | device
  | archObj
  | nsString (cs : List Char)
  | sel (name : List Char)
  /-- A Neural Engine program the bridge returned, with its call number. -/
  | ane (n : Nat)

structure HostSt where
  env : List (List Char × List Char)
  files : List (List Char × FileC)
  fds : List (Nat × List Char)
  nextFd : Nat
  objs : Trie HObj
  /-- Next mapping id (below 512) and next other host object id. -/
  nextMap : Nat
  next : Nat
  /-- Platform facts: the Metal device's architecture name, physical memory bytes. -/
  arch : List Char
  memsize : Nat
  cwd : List Char
  /-- Neural Engine programs created. -/
  ane : Nat
  /-- The runtime's transcendental functions at the arguments the run evaluates
  (`Math.log` …): function name, argument, result. A platform fact table;
  an argument not in it makes the run stuck. -/
  math : List (List Char × F64 × F64)

structure LSt where
  mlx : Host.Mlx.Ffi.St
  host : HostSt

def HostSt.init (env : List (List Char × List Char)) (files : List (List Char × FileC)) (arch : List Char)
    (memsize : Nat) (cwd : List Char) (math : List (List Char × F64 × F64)) : HostSt :=
  ⟨env, files, [], 3, .nil, 1, 512, arch, memsize, cwd, 0, math⟩

def HostSt.newObj (s : HostSt) (o : HObj) : Nat × HostSt := (s.next, { s with next := s.next + 1, objs := s.objs.set s.next o })

def region (h : Nat) : Nat := 4 * h + 3

/-! ## Lookups -/

def lookupS (k : List Char) : List (List Char × List Char) → Option (List Char)
  | [] => none
  | (a, v) :: r => bif nameEq a k then some v else lookupS k r

def setS (k v : List Char) : List (List Char × List Char) → List (List Char × List Char)
  | [] => [(k, v)]
  | (a, w) :: r => bif nameEq a k then (a, v) :: r else (a, w) :: setS k v r

def fileOf (s : HostSt) (p : List Char) : Option FileC :=
  (s.files.find? fun (q, _) => nameEq q p).map Prod.snd

/-- A directory: some file lies below `p/`. -/
def isDir (s : HostSt) (p : List Char) : Bool :=
  let d := bif (p.getLast? == some '/') then p else p ++ ['/']
  s.files.any fun (q, _) => isPrefixC d q

def fileSize : FileC → Nat
  | .text cs => len (utf8 cs)
  | .blob n _ => n

/-! ## Calls -/

abbrev R := M (Option (LSt × Ret × List (Nat × Nat × List Byte)))

def okH (s : LSt) (h : HostSt) (r : Ret) : R := .pure (some ({ s with host := h }, r, []))
def stuckH : R := .pure none

def strArgH : Arg → Option (List Char)
  | .other (.str cs) => some cs
  | a => Host.Mlx.Ffi.cstrArg a

def numArgH : Arg → Option Nat
  | .num (.lit x) => F64.toIndex? x
  | .big i => bif decide (0 ≤ i) then some i.toNat else none
  | _ => none

def objArgH (h : HostSt) : Arg → Option HObj
  | .extPtr r 0 => bif Nat.beq (r % 4) 3 then h.objs.get (r / 4) else none
  | _ => none

def envBlock : List (List Char × List Char) → List Char
  | [] => []
  | [(k, v)] => k ++ '=' :: v
  | (k, v) :: r => k ++ '=' :: v ++ '\n' :: envBlock r

def newPtr (s : LSt) (h : HostSt) (o : HObj) : R :=
  let (i, h) := h.newObj o
  okH s h (.ptr (region i) 0)

/-- `objc_msgSend(receiver, selector)` for the selectors device discovery sends. -/
def msgSend (s : LSt) (h : HostSt) (recv sel : HObj) : R :=
  match recv, sel with
  | .device, .sel n => bif nameEq n chars!"architecture" then newPtr s h .archObj
      else bif nameEq n chars!"release" then okH s h .null else stuckH
  | .archObj, .sel n => bif nameEq n chars!"name" then newPtr s h (.nsString h.arch) else stuckH
  | .nsString cs, .sel n => bif nameEq n chars!"UTF8String" then newPtr s h (.cstr cs) else stuckH
  | _, _ => stuckH

/-- The JavaScript host library's calls (`%` names). -/
def pseudoCall (s : LSt) (h : HostSt) (name : Name) (args : List Arg) : R :=
  match name, args with
  | ['%', 'e', 'n', 'v'], [] => okH s h (.cstr (envBlock h.env))
  | ['%', 'c', 'w', 'd'], [] => okH s h (.cstr h.cwd)
  | ['%', 'm', 'e', 'm'], [] => okH s h (.num (.lit (F64.ofNat h.memsize)))
  | ['%', 'm', 'a', 't', 'h'], [f, .num (.lit x)] => match strArgH f with
    | some fn => match h.math.find? fun (g, y, _) => nameEq g fn && decide (y = x) with
      | some (_, _, r) => okH s h (.num (.lit r))
      | none => stuckH
    | none => stuckH
  | ['%', 'e', 'x', 'i', 's', 't', 's'], [p] => match strArgH p with
    | some p => okH s h (.bool ((fileOf h p).isSome || isDir h p))
    | none => stuckH
  | ['%', 'i', 's', 'd', 'i', 'r'], [p] => match strArgH p with
    | some p => okH s h (.bool (isDir h p))
    | none => stuckH
  | ['%', 't', 'e', 'x', 't'], [p] => match strArgH p with
    | some p => match fileOf h p with
      | some (.text cs) => okH s h (.cstr cs)
      | _ => stuckH
    | none => stuckH
  | ['%', 's', 'i', 'z', 'e'], [p] => match strArgH p with
    | some p => match fileOf h p with
      | some f => okH s h (.num (.lit (F64.ofNat (fileSize f))))
      | none => okH s h (.num (.lit (F64.ofInt (-1))))
    | none => stuckH
  | ['%', 'o', 'p', 'e', 'n'], [p] => match strArgH p with
    | some p => match fileOf h p with
      | some _ => okH s { h with fds := (h.nextFd, p) :: h.fds, nextFd := h.nextFd + 1 } (.num (.lit (F64.ofNat h.nextFd)))
      | none => okH s h (.num (.lit (F64.ofInt (-1))))
    | none => stuckH
  | ['%', 'f', 's', 'i', 'z', 'e'], [fd] => match (numArgH fd).bind fun d => (h.fds.find? fun (e, _) => Nat.beq e d) with
    | some (_, p) => match fileOf h p with
      | some f => okH s h (.num (.lit (F64.ofNat (fileSize f))))
      | none => stuckH
    | none => stuckH
  | ['%', 'c', 'l', 'o', 's', 'e'], [fd] => match numArgH fd with
    | some d => okH s { h with fds := h.fds.filter fun (e, _) => !Nat.beq e d } .void
    | none => stuckH
  | _, _ => stuckH

def isMlx : Name → Bool
  | 'm' :: 'l' :: 'x' :: '_' :: 'b' :: 'u' :: 'n' :: '_' :: _ => false
  | 'm' :: 'l' :: 'x' :: '_' :: _ => true
  | _ => false

def isMbane : Name → Bool
  | 'm' :: 'b' :: 'a' :: 'n' :: 'e' :: '_' :: _ => true
  | _ => false

def hostCall (s : LSt) (name : Name) (args : List Arg) : R :=
  let h := s.host
  match name with
  | '%' :: _ => pseudoCall s h name args
  | _ =>
  bif nameEq name chars!"getenv" then match args with
    | [n] => match strArgH n with
      | some k => match lookupS k h.env with
        | some v => newPtr s h (.cstr v)
        | none => okH s h .null
      | none => stuckH
    | _ => stuckH
  else bif nameEq name chars!"setenv" then match args with
    | [n, v, o] => match strArgH n, strArgH v, numArgH o with
      | some k, some v, some o => bif Nat.beq o 0 && (lookupS k h.env).isSome then okH s h (.num zeroN)
        else okH s { h with env := setS k v h.env } (.num zeroN)
      | _, _, _ => stuckH
    | _ => stuckH
  else bif nameEq name chars!"MTLCreateSystemDefaultDevice" then match args with
    | [] => newPtr s h .device
    | _ => stuckH
  else bif nameEq name chars!"sel_registerName" then match args with
    | [n] => match strArgH n with
      | some k => newPtr s h (.sel k)
      | none => stuckH
    | _ => stuckH
  else bif nameEq name chars!"objc_msgSend" then match args with
    | [r, sel] => match objArgH h r, objArgH h sel with
      | some ro, some so => msgSend s h ro so
      | _, _ => stuckH
    | _ => stuckH
  else bif nameEq name chars!"mmap" then match args with
    | [_, _, _, _, fd, _] => match (numArgH fd).bind fun d => (h.fds.find? fun (e, _) => Nat.beq e d) with
      | some (_, p) => bif Nat.blt h.nextMap 512 then
          let k := h.nextMap
          okH s { h with objs := h.objs.set k (.mapping p), nextMap := k + 1 } (.big ((hostAddrBase + k * hostAddrSpan : Nat) : Int))
        else stuckH
      | none => stuckH
    | _ => stuckH
  else bif nameEq name chars!"munmap" then okH s h (.num zeroN)
  else bif nameEq name chars!"mbane_program_create" then
    let (i, h) := h.newObj (.ane h.ane)
    okH s { h with ane := h.ane + 1 } (.ptr (region i) 0)
  else stuckH

def call (s : LSt) (name : Name) (args : List Arg) : R :=
  bif isMlx name then .bind (Host.Mlx.Ffi.call s.mlx name args) fun
    | some (m, r, ws) => .pure (some ({ s with mlx := m }, r, ws))
    | none => .pure none
  else hostCall s name args

/-- Native memory: host regions (`4h + 3`), else the mlx model's. -/
def read (s : LSt) (r off n : Nat) : Option (List Byte) :=
  bif Nat.beq (r % 4) 3 then match s.host.objs.get (r / 4) with
    | some (.mapping p) => match fileOf s.host p with
      | some (.blob _ pre) => bif Nat.ble (off + n) (len pre) then some (((pre.drop off).take n).map Byte.lit) else none
      | _ => none
    | some (.cstr cs) => some ((((utf8 cs).map Byte.lit) ++ [Byte.lit 0]).drop off |>.take n)
    | _ => none
  else Host.Mlx.Ffi.read s.mlx r off n

def back (s : LSt) (a : Arg) : R := .bind (Host.Mlx.Ffi.back s.mlx a) fun
  | some (m, r, ws) => .pure (some ({ s with mlx := m }, r, ws))
  | none => .pure none

def ffi : Ffi := ⟨LSt, call, read, fun _ => 4096, back⟩

end Host.Load
