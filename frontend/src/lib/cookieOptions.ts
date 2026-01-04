'use server'

import { headers } from 'next/headers'
import { CookieOptions as BaseCookieOptions } from '@/config/env.config'

/**
 * For IP-based HTTP testing (e.g. http://<ip>:8080), cookies with `secure: true`
 * are rejected by browsers. Here we derive the scheme from reverse-proxy headers
 * and only set `secure` when the request is actually HTTPS.
 */
export const getCookieOptions = async () => {
  const h = await headers()
  const proto = h.get('x-forwarded-proto')?.split(',')[0]?.trim().toLowerCase()
  const isHttps = proto === 'https'

  return {
    ...BaseCookieOptions,
    secure: isHttps,
  }
}


