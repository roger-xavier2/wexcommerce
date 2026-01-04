/**
 * Build a product "slug" for URLs.
 *
 * Notes:
 * - We MUST always return a non-empty segment to guarantee a 2-segment route: /product/:id/:name
 * - We keep unicode (e.g. Chinese) and only sanitize characters that would break a path segment.
 */
export const getProductSlug = (name: string | undefined, fallback: string) => {
  const raw = (name ?? '').trim()
  if (!raw) return fallback

  // Remove path separators and query/hash delimiters; normalize whitespace to dashes
  const slug = raw
    .replace(/[/?#]+/g, ' ')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')

  return slug || fallback
}

/**
 * Build the frontend route path for a product page.
 */
export const getProductPath = (id: string, name?: string) => {
  const slug = getProductSlug(name, id)
  return `/product/${id}/${slug}`
}

/**
 * Some records may contain a legacy/invalid product.url like "/product/<id>" (missing slug segment).
 * We only accept URLs that contain "/product/<id>/" (two-segment route).
 */
export const isValidProductUrl = (url: string | undefined, id: string) => {
  if (!url) return false
  return url.includes(`/product/${id}/`)
}


