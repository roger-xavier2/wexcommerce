import type { NextConfig } from 'next'
import dns from 'node:dns'
import path from 'node:path'

dns.setDefaultResultOrder('ipv4first')

const isProduction = process.env.NODE_ENV === 'production'

const nextConfig: NextConfig = {
  reactStrictMode: false,
  poweredByHeader: false,
  images: {
    //
    // Add your frontend domain here
    //
    remotePatterns: [
      {
        protocol: 'http',
        hostname: 'localhost',
        pathname: '**',
      },
      {
        protocol: 'https',
        hostname: 'wexcommerce.dynv6.net',
        pathname: '**',
      },
    ],
    unoptimized: true,
  },
  turbopack: {
    root: path.resolve(__dirname, '..'), // makes it absolute
    resolveAlias: {
      ':wexcommerce-types': '../packages/wexcommerce-types',
      ':wexcommerce-helper': '../packages/wexcommerce-helper',
      ':reactjs-social-login': '../packages/reactjs-social-login',
    },
  },
  //
  // Nginx will do gzip compression. We disable
  // compression here so we can prevent buffering
  // streaming responses
  //
  compress: false,
  //
  // Add your frontend domain here
  //
  experimental: {
    serverActions: {
      allowedOrigins: ['localhost', 'wexcommerce.dynv6.net:8002'],
    },
    // workerThreads: false,
  },
  reactCompiler: true,
  logging: {
    fetches: {
      fullUrl: !isProduction,
    },
  },
  async redirects() {
    return [
      //
      // Compatibility: some links/data may still point to /product/:id (missing slug segment).
      // Our actual route is /product/:id/:name, so we redirect to a safe 2-segment URL.
      //
      {
        source: '/product/:id',
        destination: '/product/:id/p',
        permanent: false,
      },
    ]
  },
}

export default nextConfig
