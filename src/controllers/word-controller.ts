import { Request, Response } from 'express'
import { Word } from '../models/word'

export class WordController {
  public async word(req: Request, res: Response) {
    let word = req.query['word']

    if (typeof word !== 'string' || word.length < 1){
      return res.status(422).send({error: 'Invalid Input'})
    }

    word = word as string

    let transformed = Array.from(word).reverse().map(char => {
      const isUpper = char.match(/[A-Z]/) !== null

      if (isUpper) {
        return char.toLowerCase()
      } else {
        return char.toUpperCase() // ignores non-alphabetic
      }
    }).join('')

    await Word.create({
      word,
      mirroredWord: transformed
    })

    return res.send({transformed})
  }
}
