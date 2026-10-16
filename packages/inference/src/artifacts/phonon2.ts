import { createHash } from "node:crypto";
import { basename, join } from "node:path";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import {
  fermionRecords,
  readPhononArchive,
  unpackDense,
  unpackFiveValue,
  type FermionRecord,
} from "./phonon2-format";

/** Owns arrays copied from the container. Returned tensors are borrowed until dispose(). */
export class Phonon2Weights {
  readonly #arrays: MlxArray[] = [];
  readonly #used = new Set<string>();
  private constructor(
    readonly config: Record<string, any>,
    readonly records: Map<string, FermionRecord>,
    readonly bytes: number,
  ) {}
  static async open(directory: string): Promise<Phonon2Weights> {
    const config = await Bun.file(join(directory, "config.json")).json();
    let modelConfig = config,
      bytes: Uint8Array;
    if (config.artifact?.filename) {
      const name = config.artifact.filename;
      if (name !== basename(name))
        throw new Error("Phonon-2: invalid artifact filename");
      const archive = new Uint8Array(
        await Bun.file(join(directory, name)).arrayBuffer(),
      );
      if (
        archive.length !== config.artifact.download_bytes ||
        createHash("sha256").update(archive).digest("hex") !==
          config.artifact.sha256
      )
        throw new Error("Phonon-2: archive checksum mismatch");
      const files = readPhononArchive(await Bun.zstdDecompress(archive));
      bytes = files.get("model.fermion")!;
      modelConfig = JSON.parse(
        new TextDecoder().decode(files.get("config.json")),
      );
      if (
        !bytes ||
        createHash("sha256").update(bytes).digest("hex") !==
          config.artifact.container_sha256
      )
        throw new Error("Phonon-2: container checksum mismatch");
    } else {
      bytes = new Uint8Array(
        await Bun.file(join(directory, "model.fermion")).arrayBuffer(),
      );
      if (
        config.fermion?.container_sha256 &&
        createHash("sha256").update(bytes).digest("hex") !==
          config.fermion.container_sha256
      )
        throw new Error("Phonon-2: container checksum mismatch");
    }
    return new Phonon2Weights(modelConfig, fermionRecords(bytes), bytes.length);
  }
  #record(name: string): FermionRecord {
    const record = this.records.get(name);
    if (!record) throw new Error(`Phonon-2: missing ${name}`);
    this.#used.add(name);
    return record;
  }
  #own(array: MlxArray): MlxArray {
    this.#arrays.push(array);
    return array;
  }
  tensor(name: string, axes?: number[], dtype = Dtype.bfloat16): MlxArray {
    const r = this.#record(name);
    using raw = MlxArray.fromFloat32(unpackDense(r), r.shape);
    using cast = raw.astype(dtype);
    return this.#own(axes ? ops.transposeAxes(cast, axes) : ops.copyOf(cast));
  }
  /** Transfers temporary packed arrays to the caller. */
  fiveValue(name: string): {
    base: MlxArray;
    residual: MlxArray;
    lo: MlxArray;
    delta: MlxArray;
  } {
    const r = this.#record(name),
      data = unpackFiveValue(r),
      shape = [r.shape[0]!, r.shape[1]! / 16];
    const temporaries: MlxArray[] = [];
    const own = (a: MlxArray) => {
      temporaries.push(a);
      return a;
    };
    const packed = (v: Uint32Array) =>
      own(
        MlxArray.fromBytesCopy(new Uint8Array(v.buffer), shape, Dtype.uint32),
      );
    try {
      return {
        base: packed(data.base),
        residual: packed(data.residual),
        lo: own(MlxArray.fromFloat32(data.lo, [data.lo.length])),
        delta: own(MlxArray.fromFloat32(data.delta, [data.delta.length])),
      };
    } catch (error) {
      for (const a of temporaries) a.dispose();
      throw error;
    }
  }
  /** Audit the complete key set and release the source container after native copies exist. */
  finish(): void {
    const unused = [...this.records.keys()].filter(
      (k) => !this.#used.has(k) && !k.endsWith("num_batches_tracked"),
    );
    if (unused.length)
      throw new Error(`Phonon-2: unused weights: ${unused.join(", ")}`);
    ops.evalAll(this.#arrays);
    this.records.clear();
  }
  get residentBytes(): number {
    return this.#arrays.reduce((sum, a) => sum + a.nbytes, 0);
  }
  dispose(): void {
    for (const a of this.#arrays.splice(0)) a.dispose();
    this.records.clear();
  }
}
