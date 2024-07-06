import express from 'express'

import { config } from './config'
import { ready } from './services/sequelize-service'
import { WordController } from './controllers/word-controller'

const wordController = new WordController()

const app = express()

app.get('/api/health', (_, res) => {
  res.send({status: 'ok'})
})

app.get('/api/mirror', wordController.word)

exports.app = Promise.all([ready]).then(() => {

  const server = app.listen(config.app.port, () => {
    console.log(
      `[server]: Server is running at http://localhost:${config.app.port}`
    )
  })

  process.on('SIGINT', function() {
    // cleanup or logs
    server.close();
  });

  return server
})
