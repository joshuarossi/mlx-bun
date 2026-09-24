export interface TrellisGeometry {
  k: number;
  L: number;
  T: number;
  axis: 0 | 1;
  /** Stored-matrix rows / coded columns. */
  rows: number;
  cols: number;
  inFeatures: number;
  outFeatures: number;
  /** Two coded blocks interleaved across rows; absent for row-major codes. */
  blockInterleave?: 2;
}
