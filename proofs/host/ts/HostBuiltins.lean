import host.ts.Builtins
namespace Host.Ts

/-! # Host builtins: JSON, UTF-8, SHA-256, regular expressions, C strings

Builtins the load phase of a model run calls, as Lean functions on the
machine state (`HostN`; the realm installs them, `host/ts/Link`).

* `JSON.parse` is resumable: one machine step consumes at most
  `jsonBudget` tokens and leaves a builtin frame with the parser state (the
  remaining input, a mode, and the containers being filled), so a large
  document is many small steps, not one large reduction.
* `JSON.stringify` (no replacer, no indentation) over data properties.
* UTF-8 (`TextDecoder.decode`, `TextEncoder.encode`): replacement character
  for malformed input.
* SHA-256 (FIPS 180-4) over the UTF-8 bytes of strings and the bytes of
  typed arrays (`Bun.CryptoHasher("sha256")`).
* Regular expressions: a backtracking matcher for the subset the route's
  patterns use (literals, `.`, classes with ranges and `\d\w\s`, anchors,
  `\b`, groups, alternation, greedy and lazy quantifiers, flag `i`), with
  fuel; a pattern outside the subset makes the run stuck, never a silent
  mismatch. `regexExecAt(re, s, i)` returns match and group bounds; the
  `RegExp` and `String` methods are JavaScript over it (`HostLib`).
* C strings read from native memory (`new CString(ptr)`). -/

deriving instance Lean.ToExpr for Host.Ts.HostN

/-! ## UTF-8 -/

def replacementChar : Char := Char.ofNat 0xFFFD

def cont (b : Nat) : Bool := Nat.ble 0x80 b && Nat.blt b 0xC0

/-- UTF-8 decoding with one replacement character per malformed byte. -/
def utf8Dec : Nat → List Nat → List Char
  | 0, _ => []
  | _, [] => []
  | f + 1, b :: bs =>
    bif Nat.blt b 0x80 then Char.ofNat b :: utf8Dec f bs
    else bif Nat.ble 0xC2 b && Nat.blt b 0xE0 then
      match bs with
      | c :: r => bif cont c then Char.ofNat ((b - 0xC0) * 64 + (c - 0x80)) :: utf8Dec f r else replacementChar :: utf8Dec f bs
      | [] => [replacementChar]
    else bif Nat.ble 0xE0 b && Nat.blt b 0xF0 then
      match bs with
      | c :: d :: r => bif cont c && cont d then
          Char.ofNat ((b - 0xE0) * 4096 + (c - 0x80) * 64 + (d - 0x80)) :: utf8Dec f r
        else replacementChar :: utf8Dec f bs
      | _ => replacementChar :: utf8Dec f bs
    else bif Nat.ble 0xF0 b && Nat.blt b 0xF5 then
      match bs with
      | c :: d :: e :: r => bif cont c && cont d && cont e then
          Char.ofNat ((b - 0xF0) * 262144 + (c - 0x80) * 4096 + (d - 0x80) * 64 + (e - 0x80)) :: utf8Dec f r
        else replacementChar :: utf8Dec f bs
      | _ => replacementChar :: utf8Dec f bs
    else replacementChar :: utf8Dec f bs

/-! ## SHA-256 -/

def w32 : Nat := 4294967296

def rotr (x n : Nat) : Nat := Nat.lor (Nat.shiftRight x n) (Nat.shiftLeft x (32 - n) % w32)

def shaK : List Nat :=
  [0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2]

def shaH0 : List Nat :=
  [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19]

def beWord : List Nat → Nat
  | [a, b, c, d] => ((a * 256 + b) * 256 + c) * 256 + d
  | _ => 0

def words16 : Nat → List Nat → List Nat
  | 0, _ => []
  | n + 1, bs => beWord (bs.take 4) :: words16 n (bs.drop 4)

/-- The message schedule `W₀ … W₆₃`, newest last. -/
def schedule (w : List Nat) : Nat → List Nat
  | 0 => w
  | n + 1 =>
    let k := w.length
    let w2 := nthD 0 w (k - 2)
    let w7 := nthD 0 w (k - 7)
    let w15 := nthD 0 w (k - 15)
    let w16 := nthD 0 w (k - 16)
    let s0 := Nat.xor (Nat.xor (rotr w15 7) (rotr w15 18)) (Nat.shiftRight w15 3)
    let s1 := Nat.xor (Nat.xor (rotr w2 17) (rotr w2 19)) (Nat.shiftRight w2 10)
    schedule (w ++ [(w16 + s0 + w7 + s1) % w32]) n

def shaRound (h : List Nat) (kw : Nat × Nat) : List Nat :=
  match h with
  | [a, b, c, d, e, f, g, hh] =>
    let (k, w) := kw
    let s1 := Nat.xor (Nat.xor (rotr e 6) (rotr e 11)) (rotr e 25)
    let ch := Nat.xor (Nat.land e f) (Nat.land (Nat.xor e (w32 - 1)) g)
    let t1 := (hh + s1 + ch + k + w) % w32
    let s0 := Nat.xor (Nat.xor (rotr a 2) (rotr a 13)) (rotr a 22)
    let maj := Nat.xor (Nat.xor (Nat.land a b) (Nat.land a c)) (Nat.land b c)
    let t2 := (s0 + maj) % w32
    [(t1 + t2) % w32, a, b, c, (d + t1) % w32, e, f, g]
  | h => h

def shaBlock (h : List Nat) (block : List Nat) : List Nat :=
  let w := schedule (words16 16 block) 48
  let h' := (shaK.zip w).foldl shaRound h
  (h.zip h').map fun (x, y) => (x + y) % w32

def shaBlocks : Nat → List Nat → List Nat → List Nat
  | 0, h, _ => h
  | _, h, [] => h
  | f + 1, h, bs => shaBlocks f (shaBlock h (bs.take 64)) (bs.drop 64)

def beBytes (n v : Nat) : List Nat := (leBytes n v).reverse

def sha256 (msg : List Nat) : List Nat :=
  let l := len msg
  let padLen := (119 - l % 64) % 64
  let padded := msg ++ [0x80] ++ List.replicate padLen 0 ++ beBytes 8 (l * 8)
  (shaBlocks (len padded / 64 + 1) shaH0 padded).flatMap (beBytes 4)

def hexDigit (d : Nat) : Char := Char.ofNat (bif Nat.blt d 10 then 48 + d else 87 + d)

def hexBytes (bs : List Nat) : List Char := bs.flatMap fun b => [hexDigit (b / 16), hexDigit (b % 16)]

/-! ## JSON -/

def isJsonWs (c : Char) : Bool := c == ' ' || c == '\n' || c == '\t' || c == '\r'

def jsonWs : List Char → List Char
  | c :: cs => bif isJsonWs c then jsonWs cs else c :: cs
  | [] => []

/-- A JSON string body after its opening quote: characters and the rest after the closing quote. -/
def jsonStr : Nat → List Char → List Char → Option (List Char × List Char)
  | 0, _, _ => none
  | _ + 1, acc, '"' :: cs => some (acc.reverse, cs)
  | f + 1, acc, '\\' :: c :: cs =>
    match c with
    | '"' => jsonStr f ('"' :: acc) cs | '\\' => jsonStr f ('\\' :: acc) cs | '/' => jsonStr f ('/' :: acc) cs
    | 'b' => jsonStr f (Char.ofNat 8 :: acc) cs | 'f' => jsonStr f (Char.ofNat 12 :: acc) cs
    | 'n' => jsonStr f ('\n' :: acc) cs | 'r' => jsonStr f ('\r' :: acc) cs | 't' => jsonStr f ('\t' :: acc) cs
    | 'u' => (hexN 4 cs 0).bind fun (v, cs) => jsonStr f (Char.ofNat v :: acc) cs
    | _ => none
  | f + 1, acc, c :: cs => bif Nat.blt c.toNat 32 then none else jsonStr f (c :: acc) cs
  | _, _, [] => none

def isNumC (c : Char) : Bool := (Nat.ble 48 c.toNat && Nat.ble c.toNat 57) || c == '-' || c == '+' || c == '.' || c == 'e' || c == 'E'

def jsonNum (cs : List Char) : Option (F64 × List Char) :=
  let t := cs.takeWhile isNumC
  let r := cs.dropWhile isNumC
  match t with
  | '-' :: d => (F64.parseDecimal d).map fun x => (F64.neg x, r)
  | d => (F64.parseDecimal d).map fun x => (x, r)

def isPrefixL : List Char → List Char → Bool
  | [], _ => true
  | _, [] => false
  | a :: as, b :: bs => a == b && isPrefixL as bs

/-- Tokens one machine step of `JSON.parse` consumes at most. -/
def jsonBudget : Nat := 256

section
variable (F : Ffi)

/-- Outcome of a bounded parse: more input, a value, or a syntax error. -/
inductive JRes where
  | more (rest : List Char) (mode : Nat) (stack : List Val)
  | done (v : Val)
  | err

def isArrayAt (s : St F.S) (a : Nat) : Bool :=
  match s.obj? a with
  | some ⟨.array _, _, _, _, _⟩ => true
  | _ => false

/-- Parser modes: 0 a value; 1 after a value; 2 a key or `}` (after `{`); 3 a
value or `]` (after `[`); 4 a key. The stack holds the open containers,
innermost first: an array (elements newest first), an object, or a key
string above its object. -/
def jsonLoop : Nat → St F.S → List Char → Nat → List Val → St F.S × JRes
  | 0, s, rest, mode, st => (s, .more rest mode st)
  | f + 1, s, rest, mode, st =>
    let cs := jsonWs rest
    -- a completed value `v` with input `r` after it
    let produce (s : St F.S) (v : Val) (r : List Char) : St F.S × Option (List Char × Nat × List Val) × Option Val :=
      match st with
      | [] => (s, none, bif (jsonWs r).isEmpty then some v else none)
      | .str k :: .obj o :: st' => (defineData F s o (.str k) v, some (r, 1, .obj o :: st'), none)
      | .obj a :: st' => match s.obj? a with
        | some ⟨.array es, p, ps, pr, ex⟩ => (s.setObj a ⟨.array (v :: es), p, ps, pr, ex⟩, some (r, 1, .obj a :: st'), none)
        | _ => (s, none, none)
      | _ => (s, none, none)
    let next (r : St F.S × Option (List Char × Nat × List Val) × Option Val) : St F.S × JRes :=
      match r with
      | (s, some (r, m, st), _) => jsonLoop f s r m st
      | (s, none, some v) => (s, .done v)
      | (s, none, none) => (s, .err)
    let value (s : St F.S) (cs : List Char) : St F.S × JRes :=
      match cs with
      | '{' :: r => let (o, s) := s.allocObj .ordinary (.obj aObjectProto) []; jsonLoop f s r 2 (.obj o :: st)
      | '[' :: r => let (a, s) := newArray s []; jsonLoop f s r 3 (.obj a :: st)
      | '"' :: r => match jsonStr 1000000 [] r with
        | some (str, r) => next (produce s (.str str) r)
        | none => (s, .err)
      | 't' :: 'r' :: 'u' :: 'e' :: r => next (produce s (.bool true) r)
      | 'f' :: 'a' :: 'l' :: 's' :: 'e' :: r => next (produce s (.bool false) r)
      | 'n' :: 'u' :: 'l' :: 'l' :: r => next (produce s .null r)
      | cs => match jsonNum cs with
        | some (x, r) => next (produce s (.num (.lit x)) r)
        | none => (s, .err)
    let close (s : St F.S) (r : List Char) : St F.S × JRes :=
      match st with
      | .obj a :: st' =>
        let s := match s.obj? a with
          | some ⟨.array es, p, ps, pr, ex⟩ => s.setObj a ⟨.array es.reverse, p, ps, pr, ex⟩
          | _ => s
        let r' := (s, r)
        match st' with
        | [] => bif (jsonWs r).isEmpty then (r'.1, .done (.obj a)) else (s, .err)
        | .str k :: .obj o :: st'' => jsonLoop f (defineData F r'.1 o (.str k) (.obj a)) r 1 (.obj o :: st'')
        | .obj b :: st'' => match r'.1.obj? b with
          | some ⟨.array es, p, ps, pr, ex⟩ => jsonLoop f (r'.1.setObj b ⟨.array (.obj a :: es), p, ps, pr, ex⟩) r 1 (.obj b :: st'')
          | _ => (s, .err)
        | _ => (s, .err)
      | _ => (s, .err)
    let key (s : St F.S) (cs : List Char) : St F.S × JRes :=
      match cs with
      | '"' :: r => match jsonStr 1000000 [] r with
        | some (k, r) => match jsonWs r with
          | ':' :: r => jsonLoop f s r 0 (.str k :: st)
          | _ => (s, .err)
        | none => (s, .err)
      | _ => (s, .err)
    match mode with
    | 0 => value s cs
    | 1 => match cs, st with
      | ',' :: r, .obj a :: _ => jsonLoop f s r (bif isArrayAt F s a then 0 else 4) st
      | ']' :: r, .obj a :: _ => bif isArrayAt F s a then close s r else (s, .err)
      | '}' :: r, .obj a :: _ => bif isArrayAt F s a then (s, .err) else close s r
      | _, _ => (s, .err)
    | 2 => match cs with
      | '}' :: r => close s r
      | cs => key s cs
    | 3 => match cs with
      | ']' :: r => close s r
      | cs => value s cs
    | _ => key s cs

/-- `SyntaxError` (an `Error` with that `name`). -/
def syntaxErr (s : St F.S) (msg : List Char) : RS F :=
  let (a, s) := s.allocObj .ordinary (.obj aErrorProto)
    [(kMessage, .data (.str msg) true false), (.str chars!"name", .data (.str chars!"SyntaxError") true false)]
  .pure (s.go (.abr (.throw (.obj a))))

/-- Run the parser for one step's budget: a value, or the builtin frame to continue. -/
def jsonStep (s : St F.S) (rest : List Char) (mode : Nat) (st : List Val) : RS F :=
  match jsonLoop F jsonBudget s rest mode st with
  | (s, .done v) => retS F s v
  | (s, .more rest mode st) => .pure ((s.push (.k (.native (.host .jsonParse) (.str rest :: natV mode :: st)))).ret .undef)
  | (s, .err) => syntaxErr F s chars!"JSON Parse error"

/-- The `JSON.parse` frame resumed (its data: input, mode, stack). -/
def jsonResume (s : St F.S) (data : List Val) : RS F :=
  match data with
  | .str rest :: .num (.lit m) :: st => match F64.toIndex? m with
    | some mode => jsonStep F s rest mode st
    | none => .fail "JSON.parse frame"
  | _ => .fail "JSON.parse frame"

/-! ### `JSON.stringify` -/

def jsonEsc (c : Char) : List Char :=
  let n := c.toNat
  bif c == '"' then ['\\', '"'] else bif c == '\\' then ['\\', '\\']
  else bif Nat.beq n 10 then ['\\', 'n'] else bif Nat.beq n 13 then ['\\', 'r'] else bif Nat.beq n 9 then ['\\', 't']
  else bif Nat.beq n 8 then ['\\', 'b'] else bif Nat.beq n 12 then ['\\', 'f']
  else bif Nat.blt n 32 then ['\\', 'u', '0', '0', hexDigit (n / 16), hexDigit (n % 16)]
  else [c]

def jsonQuote (cs : List Char) : List Char := '"' :: (cs.flatMap jsonEsc ++ ['"'])

/-- Serialization of `v`; `none` for `undefined` and functions (omitted in objects). -/
def jsonSer (s : St F.S) : Nat → Val → M (Option (Option (List Char)))
  | 0, _ => .pure none
  | f + 1, v => match v with
    | .null => .pure (some (some chars!"null"))
    | .undef => .pure (some none)
    | .bool b => .pure (some (some (bif b then chars!"true" else chars!"false")))
    | .str cs => .pure (some (some (jsonQuote cs)))
    | .num x => .bind (numConc x) fun x => match x with
      | .nan | .inf _ => .pure (some (some chars!"null"))
      | x => .pure (some ((F64.toStr x).map id))
    | .obj a => match s.obj? a with
      | some o => match o.kind with
        | .fn _ => .pure (some none)
        | .array es =>
          let rec items : List Val → M (Option (List (List Char)))
            | [] => .pure (some [])
            | e :: r => .bind (jsonSer s f e) fun
              | some x => .bind (items r) fun rs => .pure (rs.map ((x.getD chars!"null") :: ·))
              | none => .pure none
          .bind (items es) fun r => .pure (r.map fun xs => some ('[' :: (List.intercalate [','] xs ++ [']'])))
        | _ => .bind (dataProps F s o) fun
          | some kvs =>
            let rec props : List (PKey × Val) → M (Option (List (List Char)))
              | [] => .pure (some [])
              | (.str k, e) :: r => .bind (jsonSer s f e) fun
                | some (some x) => .bind (props r) fun rs => .pure (rs.map ((jsonQuote k ++ ':' :: x) :: ·))
                | some none => props r
                | none => .pure none
              | _ :: r => props r
            .bind (props kvs) fun r => .pure (r.map fun xs => some ('{' :: (List.intercalate [','] xs ++ ['}'])))
          | none => .pure none
      | none => .pure none
    | _ => .pure none

end

/-! ## Regular expressions -/

inductive Re where
  | empty
  | chr (c : Nat)
  | any
  /-- A class: negated, ranges (inclusive code points). -/
  | cls (neg : Bool) (rs : List (Nat × Nat))
  | seq (a b : Re)
  | alt (a b : Re)
  /-- `r{min,max}` (`max = none`: unbounded), greedy or lazy. -/
  | rep (r : Re) (min : Nat) (max : Option Nat) (greedy : Bool)
  | group (i : Nat) (r : Re)
  | bol | eol
  | wordB (neg : Bool)

def digitR : List (Nat × Nat) := [(48, 57)]
def wordR : List (Nat × Nat) := [(48, 57), (65, 90), (95, 95), (97, 122)]
def spaceR : List (Nat × Nat) := [(9, 13), (32, 32), (160, 160), (0x2028, 0x2029), (0xFEFF, 0xFEFF)]

/-- A class escape (`\d` …) as ranges and negation. -/
def classEsc : Char → Option (Bool × List (Nat × Nat))
  | 'd' => some (false, digitR) | 'D' => some (true, digitR)
  | 'w' => some (false, wordR) | 'W' => some (true, wordR)
  | 's' => some (false, spaceR) | 'S' => some (true, spaceR)
  | _ => none

/-- A character escape's code point and the rest. -/
def charEsc : List Char → Option (Nat × List Char)
  | 'n' :: r => some (10, r) | 't' :: r => some (9, r) | 'r' :: r => some (13, r)
  | 'f' :: r => some (12, r) | 'v' :: r => some (11, r) | '0' :: r => some (0, r)
  | 'x' :: r => hexN 2 r 0
  | 'u' :: r => hexN 4 r 0
  | c :: r => bif (Nat.ble 48 c.toNat && Nat.ble c.toNat 57) || (Nat.ble 65 c.toNat && Nat.ble c.toNat 90)
      || (Nat.ble 97 c.toNat && Nat.ble c.toNat 122) then none else some (c.toNat, r)
  | [] => none

/-- Class body after `[` (and `^`): ranges and the rest after `]`. -/
def classBody : Nat → List (Nat × Nat) → List Char → Option (List (Nat × Nat) × List Char)
  | 0, _, _ => none
  | _ + 1, acc, ']' :: r => some (acc, r)
  | f + 1, acc, '\\' :: c :: r => match classEsc c with
    | some (false, rs) => classBody f (acc ++ rs) r
    | some (true, _) => none
    | none => (charEsc (c :: r)).bind fun (x, r) => classRange f acc x r
  | f + 1, acc, c :: r => classRange f acc c.toNat r
  | _, _, [] => none
where
  classRange (f : Nat) (acc : List (Nat × Nat)) (lo : Nat) : List Char → Option (List (Nat × Nat) × List Char)
    | '-' :: ']' :: r => some (acc ++ [(lo, lo), (45, 45)], r)
    | '-' :: '\\' :: c :: r => (charEsc (c :: r)).bind fun (hi, r) => classBody f (acc ++ [(lo, hi)]) r
    | '-' :: c :: r => classBody f (acc ++ [(lo, c.toNat)]) r
    | r => classBody f (acc ++ [(lo, lo)]) r

def natLit (cs : List Char) : Option (Nat × List Char) :=
  let ds := cs.takeWhile fun c => Nat.ble 48 c.toNat && Nat.ble c.toNat 57
  bif ds.isEmpty then none else some (ds.foldl (fun n c => n * 10 + (c.toNat - 48)) 0, cs.drop ds.length)

/-- A quantifier after an atom: bounds, greediness, rest. -/
def quant (cs : List Char) : Option ((Nat × Option Nat × Bool) × List Char) :=
  let lazy (b : Nat × Option Nat) (r : List Char) : (Nat × Option Nat × Bool) × List Char :=
    match r with
    | '?' :: r => ((b.1, b.2, false), r)
    | r => ((b.1, b.2, true), r)
  match cs with
  | '*' :: r => some (lazy (0, none) r)
  | '+' :: r => some (lazy (1, none) r)
  | '?' :: r => some (lazy (0, some 1) r)
  | '{' :: r => (natLit r).bind fun (lo, r) => match r with
    | '}' :: r => some (lazy (lo, some lo) r)
    | ',' :: '}' :: r => some (lazy (lo, none) r)
    | ',' :: r => (natLit r).bind fun (hi, r) => match r with
      | '}' :: r => some (lazy (lo, some hi) r)
      | _ => none
    | _ => none
  | _ => none

/-- Pattern parser: alternation, sequence, atom. `g` counts capturing groups. -/
def reAlt : Nat → Nat → List Char → Option (Re × Nat × List Char)
  | 0, _, _ => none
  | f + 1, g, cs => (reSeq f g Re.empty cs).bind fun (a, g, r) => match r with
    | '|' :: r => (reAlt f g r).map fun (b, g, r) => (.alt a b, g, r)
    | r => some (a, g, r)
where
  reSeq : Nat → Nat → Re → List Char → Option (Re × Nat × List Char)
    | 0, _, _, _ => none
    | _ + 1, g, acc, [] => some (acc, g, [])
    | _ + 1, g, acc, '|' :: r => some (acc, g, '|' :: r)
    | _ + 1, g, acc, ')' :: r => some (acc, g, ')' :: r)
    | f + 1, g, acc, cs => (reAtom f g cs).bind fun (a, g, r) =>
      let a' : Option (Re × List Char) := match quant r with
        | some ((lo, hi, gr), r) => some (.rep a lo hi gr, r)
        | none => match r with
          | '*' :: _ | '+' :: _ | '?' :: _ => none
          | r => some (a, r)
      a'.bind fun (a, r) => reSeq f g (match acc with | .empty => a | _ => .seq acc a) r
  reAtom : Nat → Nat → List Char → Option (Re × Nat × List Char)
    | 0, _, _ => none
    | _ + 1, g, '^' :: r => some (.bol, g, r)
    | _ + 1, g, '$' :: r => some (.eol, g, r)
    | _ + 1, g, '.' :: r => some (.any, g, r)
    | f + 1, g, '(' :: '?' :: ':' :: r => (reAlt f g r).bind fun (a, g, r) => match r with
      | ')' :: r => some (a, g, r)
      | _ => none
    | _ + 1, _, '(' :: '?' :: _ => none
    | f + 1, g, '(' :: r => (reAlt f (g + 1) r).bind fun (a, g', r) => match r with
      | ')' :: r => some (.group (g + 1) a, g', r)
      | _ => none
    | _ + 1, g, '[' :: '^' :: r => (classBody 4096 [] r).map fun (rs, r) => (.cls true rs, g, r)
    | _ + 1, g, '[' :: r => (classBody 4096 [] r).map fun (rs, r) => (.cls false rs, g, r)
    | _ + 1, g, '\\' :: 'b' :: r => some (.wordB false, g, r)
    | _ + 1, g, '\\' :: 'B' :: r => some (.wordB true, g, r)
    | _ + 1, g, '\\' :: c :: r => match classEsc c with
      | some (n, rs) => some (.cls n rs, g, r)
      | none => (charEsc (c :: r)).map fun (x, r) => (.chr x, g, r)
    | _ + 1, _, ']' :: _ => none
    | _ + 1, _, '{' :: _ => none
    | _ + 1, _, '}' :: _ => none
    | _ + 1, g, c :: r => some (.chr c.toNat, g, r)
    | _ + 1, _, [] => none

/-- A whole pattern and its group count. -/
def reParse (p : List Char) : Option (Re × Nat) :=
  match reAlt (4 * p.length + 8) 0 p with
  | some (r, g, []) => some (r, g)
  | _ => none

def lowerN (n : Nat) : Nat := bif Nat.ble 65 n && Nat.ble n 90 then n + 32 else n

def inRanges (c : Nat) : List (Nat × Nat) → Bool
  | [] => false
  | (lo, hi) :: rs => (Nat.ble lo c && Nat.ble c hi) || inRanges c rs

def clsHas (ic : Bool) (rs : List (Nat × Nat)) (c : Nat) : Bool :=
  inRanges c rs || (ic && (inRanges (lowerN c) rs || rs.any fun (lo, hi) =>
    Nat.ble 97 c && Nat.ble c 122 && Nat.ble lo (c - 32) && Nat.ble (c - 32) hi))

def isWordC (c : Char) : Bool := inRanges c.toNat wordR

/-- Input position: index, the characters before (reversed, for `\b`), the rest. -/
structure RPos where
  i : Nat
  prev : Option Char
  rest : List Char

abbrev Caps := List (Nat × Option (Nat × Nat))

def capSet (cs : Caps) (g : Nat) (v : Nat × Nat) : Caps := (g, some v) :: cs

/-- Backtracking matcher in continuation-passing style; fuel bounds the work. -/
def reM (ic : Bool) : Nat → Re → RPos → Caps → (RPos → Caps → Option (RPos × Caps)) → Option (RPos × Caps)
  | 0, _, _, _, _ => none
  | f + 1, r, p, cs, k => match r with
    | .empty => k p cs
    | .chr c => match p.rest with
      | d :: rest => bif Nat.beq c d.toNat || (ic && Nat.beq (lowerN c) (lowerN d.toNat)) then k ⟨p.i + 1, some d, rest⟩ cs else none
      | [] => none
    | .any => match p.rest with
      | d :: rest => bif Nat.beq d.toNat 10 || Nat.beq d.toNat 13 then none else k ⟨p.i + 1, some d, rest⟩ cs
      | [] => none
    | .cls neg rs => match p.rest with
      | d :: rest => bif clsHas ic rs d.toNat != neg then k ⟨p.i + 1, some d, rest⟩ cs else none
      | [] => none
    | .seq a b => reM ic f a p cs fun p cs => reM ic f b p cs k
    | .alt a b => match reM ic f a p cs k with
      | some r => some r
      | none => reM ic f b p cs k
    | .group g a => reM ic f a p cs fun q cs => k q (capSet cs g (p.i, q.i))
    | .bol => match p.prev with
      | none => k p cs
      | some _ => none
    | .eol => match p.rest with
      | [] => k p cs
      | _ => none
    | .wordB neg =>
      let a := (p.prev.map isWordC).getD false
      let b := match p.rest with | d :: _ => isWordC d | [] => false
      bif (a != b) != neg then k p cs else none
    | .rep a lo hi gr =>
      let more : Option (RPos × Caps) := match hi with
        | some 0 => none
        | _ => reM ic f a p cs fun q cs =>
          -- an empty iteration past the minimum ends the loop
          bif Nat.beq q.i p.i && Nat.beq lo 0 then none
          else reM ic f (.rep a (lo - 1) (hi.map (· - 1)) gr) q cs k
      bif Nat.blt 0 lo then more
      else bif gr then (match more with | some r => some r | none => k p cs)
      else (match k p cs with | some r => some r | none => more)

def capLookup (cs : Caps) (g : Nat) : Option (Nat × Nat) :=
  ((cs.find? fun (h, _) => Nat.beq h g).bind Prod.snd)

/-- First match at or after `start` (only at `start` when sticky): bounds and group bounds. -/
def reSearch (re : Re) (ng : Nat) (ic sticky : Bool) (s : List Char) (start : Nat) : Option (Nat × Nat × List (Option (Nat × Nat))) :=
  let fuel := 64 * (s.length + 4) * (s.length + 4)
  let rec go : Nat → Nat → Option Char → List Char → Option (Nat × Nat × List (Option (Nat × Nat)))
    | 0, _, _, _ => none
    | n + 1, i, prev, rest =>
      match reM ic fuel re ⟨i, prev, rest⟩ [] fun q cs => some (q, cs) with
      | some (q, cs) => some (i, q.i, (List.range ng).map fun g => capLookup cs (g + 1))
      | none => bif sticky then none else match rest with
        | c :: r => go n (i + 1) (some c) r
        | [] => none
  go (s.length + 2 - start) start ((s.take start).getLast?) (s.drop start)

/-! ## Dispatch -/

/-- Native memory of the host world model at numeric addresses (`mmap`
results are integers in JavaScript): region `4k + 3` spans `2^33` bytes
from `2^44 + k·2^33`, below `2^53` so the address is an exact number. -/
def hostAddrBase : Nat := 2 ^ 44
def hostAddrSpan : Nat := 2 ^ 33

/-- A native address as a JavaScript number: a host mapping (above), or a
`BigInt(ptr)` value of native memory (`ptrInt`: `2^62 + r·2^24 + off`). -/
def hostAddr (x : F64) : Option (Nat × Nat) :=
  match F64.toInt? x with
  | some (.ofNat a) =>
    bif Nat.ble (2 ^ 62) a then some ((a - 2 ^ 62) / 2 ^ 24, (a - 2 ^ 62) % 2 ^ 24)
    else bif Nat.ble hostAddrBase a && Nat.blt a (hostAddrBase + 512 * hostAddrSpan) then
      some (4 * ((a - hostAddrBase) / hostAddrSpan) + 3, (a - hostAddrBase) % hostAddrSpan) else none
  | _ => none

section
variable (F : Ffi)

/-- Bytes of a typed array, `ArrayBuffer` or `DataView` argument. -/
def viewBytes (s : St F.S) (v : Val) : Option (List Nat) :=
  match v with
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .typed k b off n => (bufBytes F s b).bind fun bs => concBytes ((bs.drop off).take (n * k.size))
      | .view b off n => (bufBytes F s b).bind fun bs => concBytes ((bs.drop off).take n)
      | .buf bs => concBytes bs
      | .extBuf r off n => (F.read s.ffi r off n).bind concBytes
      | _ => none
    | none => none
  | _ => none

/-- Bytes of a hasher part: a string's UTF-8 bytes or a view's bytes. -/
def partBytes (s : St F.S) : Val → Option (List Nat)
  | .str cs => some (utf8 cs)
  | v => viewBytes F s v

/-- A NUL-terminated string in native memory, read in 64-byte pieces. -/
def readCStr (s : St F.S) (r off : Nat) : Nat → Option (List Char)
  | 0 => none
  | f + 1 => (F.read s.ffi r off 64).bind fun bs => (concBytes bs).bind fun ns =>
    match ns.findIdx? (Nat.beq 0) with
    | some i => some (utf8Dec (i + 1) (ns.take i))
    | none => bif Nat.blt (len ns) 64 then none else (readCStr s r (off + 64) f).map (utf8Dec 64 ns ++ ·)

def hostN (s : St F.S) (this : Val) (args : List Val) (data : List Val) : HostN → RS F
  | .jsonParse => match arg args 0 with
    | .str cs => jsonStep F s cs 0 []
    | v => .bind (primStr v) fun
      | some cs => jsonStep F s cs 0 []
      | none => .fail "JSON.parse of an object"
  | .jsonStringify => match arg args 1, arg args 2 with
    | .undef, .undef => .bind (jsonSer F s 64 (arg args 0)) fun
      | some (some cs) => retS F s (.str cs)
      | some none => retS F s .undef
      | none => .fail "JSON.stringify of an unsupported value"
    | _, _ => .fail "JSON.stringify with a replacer or indentation"
  | .utf8Decode => match arg args 0 with
    | .undef => retS F s (.str [])
    | v => match viewBytes F s v with
      | some bs => retS F s (.str (utf8Dec (len bs) bs))
      | none => .fail "TextDecoder.decode of an unsupported buffer"
  | .utf8Encode => .bind (match arg args 0 with | .undef => .pure (some []) | v => primStr v) fun
    | some cs => let bytes := utf8 cs
      let (r, s) := newTyped F s .u8 (aTypedProtoOf .u8) (bytes.map Byte.lit) (len bytes)
      retS F s (.obj r)
    | none => .fail "TextEncoder.encode of an object"
  | .sha256 => .bind (elemsOf F s (arg args 0)) fun
    | some parts => match parts.mapM (partBytes F s) with
      | some bss => retS F s (.str (hexBytes (sha256 bss.flatten)))
      | none => .fail "sha256 of an unsupported part"
    | none => .fail "sha256 parts"
  | .regexNew => match data, arg args 0, arg args 1 with
    | [proto], .str p, fl => .bind (match fl with | .undef => .pure (some []) | v => primStr v) fun
      | some fl => match reParse p with
        | some _ =>
          let has (c : Char) : Val := .bool (fl.contains c)
          let (a, s) := s.allocObj .ordinary proto
            [(.str chars!"source", .data (.str p) false false), (.str chars!"flags", .data (.str fl) false false),
             (.str chars!"global", .data (has 'g') false false), (.str chars!"ignoreCase", .data (has 'i') false false),
             (.str chars!"sticky", .data (has 'y') false false), (.str chars!"lastIndex", .data (natV 0) true false)]
          retS F s (.obj a)
        | none => .fail ("regular expression outside the modelled subset: " ++ String.ofList p)
      | none => .fail "RegExp flags"
    | _, _, _ => .fail "RegExp pattern"
  | .regexExecAt => match arg args 0, arg args 1, arg args 2 with
    | .obj a, .str str, .num (.lit x) => match s.obj? a, F64.toIndex? x with
      | some o, some start => match findProp (.str chars!"source") o.props, findProp (.str chars!"flags") o.props with
        | some (.data (.str p) _ _), some (.data (.str fl) _ _) => match reParse p with
          | some (re, ng) => match reSearch re ng (fl.contains 'i') (fl.contains 'y') str start with
            | some (i, j, gs) =>
              let (r, s) := newArray s (natV i :: natV j :: gs.flatMap fun
                | some (a, b) => [natV a, natV b]
                | none => [intV (-1), intV (-1)])
              retS F s (.obj r)
            | none => retS F s .null
          | none => .fail "regular expression outside the modelled subset"
        | _, _ => .fail "regexExecAt of a non-RegExp"
      | _, _ => .fail "regexExecAt"
    | _, _, _ => .fail "regexExecAt arguments"
  | .cstring => match arg args 0 with
    | .ptr (.ext r) off => match readCStr F s r off 4096 with
      | some cs => retS F s (.str cs)
      | none => .fail "CString of unreadable memory"
    | .num (.lit x) => match hostAddr x with
      | some (r, off) => match readCStr F s r off 4096 with
        | some cs => retS F s (.str cs)
        | none => .fail "CString of unreadable memory"
      | none => .fail "CString of a number that names no native memory"
    | .null => retS F s (.str [])
    | _ => .fail "CString of a non-native pointer"
  | .call => let _ := this; .fail "host call outside Control"

end

end Host.Ts
