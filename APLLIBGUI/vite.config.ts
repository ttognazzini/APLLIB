import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    // Dev-only: forward API calls to the APLLIBGUI web server on the
    // IBM i (in production Apache serves both, same origin, no proxy).
    proxy: {
      '/api': { target: 'http://WINCH400:8500', changeOrigin: true },
    },
  },
})
