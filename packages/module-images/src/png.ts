// RGB pixels to a PNG file's bytes. The module's only image encoding: the
// route returns them as base64 and the verb writes them to disk.
import { encode } from "fast-png";

/** An 8-bit RGB PNG of `pixels` (row-major, three bytes per pixel). */
export function encodePng(image: { readonly width: number; readonly height: number; readonly pixels: Uint8Array }): Uint8Array {
  const { width, height, pixels } = image;
  if (!Number.isInteger(width) || !Number.isInteger(height) || width <= 0 || height <= 0)
    throw new RangeError(`image dimensions must be positive integers, got ${width}x${height}`);
  if (pixels.length !== width * height * 3)
    throw new RangeError(`expected ${width * height * 3} RGB bytes for ${width}x${height}, got ${pixels.length}`);
  return encode({ width, height, data: pixels, depth: 8, channels: 3 });
}
