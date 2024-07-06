import {
  DataTypes
} from 'sequelize'
import { Model, Table, Column } from 'sequelize-typescript'

@Table({ timestamps: false })
export class Word extends Model {
  @Column({
    type: DataTypes.STRING,
    allowNull: false,
  })
  declare word: string

  @Column({
    type: DataTypes.STRING,
    allowNull: false,
  })
  declare mirroredWord: string
}
