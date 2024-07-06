import { Sequelize } from "sequelize-typescript";
import { Word } from "../models/word";
import { config } from "../config";

export const sequelize = new Sequelize(
  config.sequelize.name,
  config.sequelize.user,
  config.sequelize.password,
  {
    dialect: config.sequelize.dialect,
    host: config.sequelize.host,
    port: config.sequelize.port,
    models: [Word],
    logging: false,
  }
)

export const ready = sequelize
  .authenticate()
  .then(() => sequelize.sync())
  .then(() => true)
