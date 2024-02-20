import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { fileURLToPath, URL } from 'node:url'

// https://vitejs.dev/config/
export default defineConfig({
  base: '/vite_admin/',
  plugins: [react()],
  build: {
    manifest: true, // This is required
    rollupOptions: {
      input: fileURLToPath(new URL('./src/main.tsx', import.meta.url))
    },
    outDir: fileURLToPath(new URL('../public/vite_admin', import.meta.url)),
    emptyOutDir: true,
  },
  server: {
    port: 5174,
    origin: 'http://localhost:5174'
  }
})
