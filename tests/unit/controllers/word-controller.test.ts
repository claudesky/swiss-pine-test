const dotenv = require('dotenv')
dotenv.config({path: '.env.test.local'})

import { describe, expect, it, jest } from '@jest/globals'
import { createRequest, createResponse } from 'node-mocks-http'
import { ready, sequelize } from '../sequelize-service-mock'
import { WordController } from '../../../src/controllers/word-controller'

jest.mock('../../../src/services/sequelize-service', () => {
  return {
    sequelize,
    ready
  }
})

const wordController = new WordController()

describe('happy path', () => {
  it('can do its job', async () => {
    await ready

    const req = createRequest({
      query: {
        word: "fOoBar25"
      }
    })

    const res = createResponse()

    await wordController.word(req, res)

    expect(res.statusCode).toBe(200)

    expect(res._getData()).toMatchObject({
      transformed: '52RAbOoF'
    })
  })
})

describe('unhappy path', () => {
  it('is not happy without input', async () => {
    await ready

    const req = createRequest()

    const res = createResponse()

    await wordController.word(req, res)

    expect(res.statusCode).toBe(422)

    expect(res._getData()).toMatchObject({
      error: 'Invalid Input'
    })
  }),
  it('is not happy without enough input', async () => {
    await ready

    const req = createRequest({
      query: {
        word: ""
      }
    })

    const res = createResponse()

    await wordController.word(req, res)

    expect(res.statusCode).toBe(422)

    expect(res._getData()).toMatchObject({
      error: 'Invalid Input'
    })
  }),
  it('is not happy with weird input', async () => {
    await ready

    const req = createRequest({
      query: {
        word: ['test', 'test2']
      }
    })

    const res = createResponse()

    await wordController.word(req, res)

    expect(res.statusCode).toBe(422)

    expect(res._getData()).toMatchObject({
      error: 'Invalid Input'
    })
  })
})
