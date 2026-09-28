import type { PlainKvReads } from "../contracts/mlx/cache";

/** Plain storage: every append is read plain. */
export const plainKvStorage: PlainKvReads = Object.freeze({ appendable: () => true });
