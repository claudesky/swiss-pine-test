import { Sequelize } from "sequelize-typescript";
import { Word } from "../../src/models/word";

export const sequelize = new Sequelize(
  {
    dialect: 'sqlite',
    storage: ':memory:',
    models: [Word],
    logging: false,
  }
)

export const ready = sequelize
  .authenticate()
  .then(() => sequelize.sync())
  .then(() => true)
