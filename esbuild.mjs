import * as esbuild from 'esbuild'
import esbuildPluginTsc from 'esbuild-plugin-tsc'

await esbuild.build({
  entryPoints: ['./src/index.ts'],
  bundle: true,
  packages: 'external',
  sourcemap: true,
  outfile: 'dist/app.js',
  platform: 'node',
  target: 'node22',
  dropLabels: ['DEV'],
  logLevel: 'info',
  plugins: [esbuildPluginTsc()]
})
