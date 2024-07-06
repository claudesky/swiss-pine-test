// .env files only loaded in dev

import { Dialect } from "sequelize"

// DEV label dropped by esbuild
DEV: {
  const dotenv = require('dotenv') as any
  dotenv.config()
}

export const config = {
  app: {
    port: process.env.APP_PORT ?? 4004
  },
  sequelize: {
    dialect: (process.env.DB_TYPE ?? 'postgres') as Dialect,
    name: process.env.DB_NAME ?? 'swiss_pine',
    user: process.env.DB_USER ?? 'postgres',
    password: process.env.DB_PASS,
    host: process.env.DB_HOST ?? 'localhost',
    port: parseInt(process.env.DB_PORT ?? '5432')
  }
}
