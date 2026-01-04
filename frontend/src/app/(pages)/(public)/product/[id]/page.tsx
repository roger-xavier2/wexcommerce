import { redirect } from 'next/navigation'
import { getProductPath } from '@/utils/productUrl'

/**
 * Compatibility route:
 * Some environments/data may generate legacy links like /product/:id (missing slug segment).
 * Our actual product page route is /product/:id/:name.
 *
 * We redirect to a safe two-segment path, using id as slug fallback.
 */
const ProductById = async (props: { params: Promise<{ id: string }> }) => {
  const params = await props.params
  redirect(getProductPath(params.id))
}

export default ProductById


