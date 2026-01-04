import cors from 'cors'
import * as helper from '../utils/helper'
import * as env from '../config/env.config'
import * as logger from '../utils/logger'

const whitelist = [
  helper.trimEnd(env.ADMIN_HOST, '/'),
  helper.trimEnd(env.FRONTEND_HOST, '/'),
]

const originMatchesHostOrSamePort = (origin: string, hostUrl: string): boolean => {
  const normalizedOrigin = helper.trimEnd(origin, '/')
  const normalizedHost = helper.trimEnd(hostUrl, '/')

  if (normalizedOrigin === normalizedHost) {
    return true
  }

  try {
    const o = new URL(normalizedOrigin)
    const h = new URL(normalizedHost)

    // Allow IP-based testing without changing env: if protocol + port match,
    // we consider the origin trusted (e.g. env.FRONTEND_HOST=http://localhost:8080
    // but request comes from http://192.168.1.10:8080).
    return o.protocol === h.protocol && o.port === h.port
  } catch {
    return false
  }
}

const isAllowedOrigin = (origin?: string | null): boolean => {
  if (!origin) {
    return true
  }

  const normalized = helper.trimEnd(origin, '/')

  if (whitelist.indexOf(normalized) !== -1) {
    return true
  }

  return originMatchesHostOrSamePort(origin, env.ADMIN_HOST)
    || originMatchesHostOrSamePort(origin, env.FRONTEND_HOST)
}

/**
 * CORS configuration.
 *
 * @type {cors.CorsOptions}
 */
const CORS_CONFIG: cors.CorsOptions = {
  origin(origin, callback) {
    if (isAllowedOrigin(origin)) {
      callback(null, true)
    } else {
      const message = `Not allowed by CORS: ${origin}`
      logger.error(message)
      callback(new Error(message))
    }
  },
  credentials: true,
  optionsSuccessStatus: 200, // some legacy browsers (IE11, various SmartTVs) choke on 204
}

/**
 * CORS middleware.
 *
 * @export
 * @returns {*}
 */
export default () => cors(CORS_CONFIG)
