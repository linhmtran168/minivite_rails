import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  base: '/vite',
  plugins: [vue()],
  resolve: {
    alias: {
      '@': './src' // This is required
    }
  },
  build: {
    manifest: true, // This is required
    rollupOptions: {
      input: fileURLToPath(new URL('./src/main.ts', import.meta.url)) // The entry file of your application, it will depends on your project structure
    },
    // For this example, the frontend code and vite configuration file are directly in a child folder from the root of the Rails project.
    outDir: fileURLToPath(new URL('../public/vite', import.meta.url)),
    emptyOutDir: true,
  },
  server: {
    origin: 'http://localhost:5173' // For referencing assets from vite dev server
  }
})
