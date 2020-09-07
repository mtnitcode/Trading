using System;
using System.Data;
using System.Data.SqlClient;

namespace TradingData
{
	public class AdoHandler
	{
		public string _connectionString;

		public AdoHandler(string connectionString)
		{
			if (string.IsNullOrEmpty(connectionString))
				throw new Exception("ConnectionString is Invalid.");

			_connectionString = connectionString;
		}

        public SqlTransaction _SqlTransaction;
        public SqlConnection _SQLConnection;
		#region Private Methods

		private SqlCommand CommandFactory(SqlConnection SqlConnection , CommandType commandType, string commandText, SqlParameter[] commandParameters)
		{
			SqlCommand command = new SqlCommand();

			try
			{
				//if the provided connection is not open, we will open it

                if (SqlConnection.State == ConnectionState.Closed && SqlConnection.State != ConnectionState.Broken)
                    SqlConnection.Open();

				//associate the connection with the command
				command.Connection = SqlConnection;

				//set the command text (stored procedure name or SQL statement)
				command.CommandText = commandText;
                command.CommandTimeout = 0;
                if(_SqlTransaction != null)
                {
                    command.Transaction = _SqlTransaction;
                }

				//set the command type
				command.CommandType = commandType;

				//attach the command parameters if they are provided
				if (commandParameters != null)
					foreach (SqlParameter parameter in commandParameters)
					{
						//check for derived output value with no value assigned
						if ((parameter.Direction == ParameterDirection.InputOutput) && (parameter.Value == null))
							parameter.Value = DBNull.Value;

						command.Parameters.Add(parameter);
					}

				return command;
			}
			catch (SqlException sqlex)
			{
				throw sqlex;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		#endregion Private Methods

		#region AddParameters

		public object CheckForNullString(string text)
		{
			if (string.IsNullOrEmpty(text) || text.Trim().Length == 0)
				return DBNull.Value;
			else
				return text;
		}

		public SqlParameter MakeInParam(string ParamName, object Value)
		{
			return new SqlParameter(ParamName, Value);
		}

		public SqlParameter MakeInParam(string ParamName, SqlDbType DbType, object Value)
		{
			return MakeParam(ParamName, DbType, -1, ParameterDirection.Input, Value);
		}

		public SqlParameter MakeInParam(string ParamName, SqlDbType DbType, int Size, object Value)
		{
			return MakeParam(ParamName, DbType, Size, ParameterDirection.Input, Value);
		}

		public SqlParameter MakeOutParam(string ParamName, SqlDbType DbType)
		{
			return MakeParam(ParamName, DbType, -1, ParameterDirection.Output, null);
		}

		public SqlParameter MakeOutParam(string ParamName, SqlDbType DbType, int Size)
		{
			return MakeParam(ParamName, DbType, Size, ParameterDirection.Output, null);
		}

		public SqlParameter MakeParam(string ParamName, SqlDbType DbType, Int32 Size, ParameterDirection Direction, object Value)
		{
			SqlParameter param;

			if (Size > 0)
				param = new SqlParameter(ParamName, DbType, Size);
			else
				param = new SqlParameter(ParamName, DbType);

			param.Direction = Direction;
			param.Value = "";
			if (!(Direction == ParameterDirection.Output && Value == null))
				param.Value = Value;

			return param;
		}

		#endregion AddParameters

		#region ExecuteNonQuery

		public int ExecuteNonQuery(CommandType commandType, string commandText)
		{
			return ExecuteNonQuery(commandType, commandText, (SqlParameter[])null);
		}

		public int ExecuteNonQuery(CommandType commandType, string commandText, params SqlParameter[] commandParameters)
		{
			int retval = -1;

			try
			{
				//create a command and prepare it for execution

				using (SqlCommand command = CommandFactory(new SqlConnection(_connectionString), commandType, commandText, commandParameters))
				{
					//finally, execute the command.
					retval = command.ExecuteNonQuery();


				}

				return retval;
			}
			catch (SqlException sqlex)
			{
				throw sqlex;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

        public int ExecuteNonQuery(SqlConnection connection, CommandType commandType, string commandText)
		{
            return ExecuteNonQuery(connection, commandType, commandText, (SqlParameter[])null);
		}


		public int ExecuteNonQuery(SqlConnection connection, CommandType commandType, string commandText, params SqlParameter[] commandParameters)
		{
			int retval = -1;

			try
			{

                using (SqlCommand command = CommandFactory(connection, commandType, commandText, commandParameters))
                {
                    //finally, execute the command.
                    retval = command.ExecuteNonQuery();
                }

				return retval;
			}
			catch (SqlException sqlex)
			{
				throw sqlex;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		#endregion ExecuteNonQuery

		#region ExecuteDataSet

		public DataSet ExecuteDataset(CommandType commandType, string commandText)
		{
			return ExecuteDataset(commandType, commandText, (SqlParameter[])null);
		}

		public DataSet ExecuteDataset(CommandType commandType, string commandText, params SqlParameter[] commandParameters)
		{
			DataSet oDataSet = new DataSet();

			try
			{
				using (SqlCommand command = CommandFactory(new SqlConnection(_connectionString), commandType, commandText, commandParameters))
				{
					//create the DataAdapter & DataSet
					SqlDataAdapter oDataAdapter = new SqlDataAdapter(command);

					//fill the DataSet using default values for DataTable names, etc.
					oDataAdapter.Fill(oDataSet);
				}

				return oDataSet;
			}
			catch (SqlException sqlex)
			{
				throw sqlex;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public DataSet ExecuteDataset(SqlConnection sqlConnection, CommandType commandType, string commandText)
		{
			return ExecuteDataset(sqlConnection, commandType, commandText, (SqlParameter[])null);
		}

		public DataSet ExecuteDataset(SqlConnection sqlConnection, CommandType commandType, string commandText, params SqlParameter[] commandParameters)
		{
			DataSet oDataSet = new DataSet();

			try
			{
				using (SqlCommand command = CommandFactory(sqlConnection, commandType, commandText, commandParameters))
				{
					//create the DataAdapter & DataSet
					SqlDataAdapter oDataAdapter = new SqlDataAdapter(command);

					//fill the DataSet using default values for DataTable names, etc.
					oDataAdapter.Fill(oDataSet);


				}

				// detach the SqlParameters from the command object, so they can be used again.
				return oDataSet;
			}
			catch (SqlException sqlex)
			{
				throw sqlex;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		#endregion ExecuteDataSet

		#region ExecuteDataTable

		public DataTable ExecuteDataTable(CommandType commandType, string commandText)
		{
			return ExecuteDataTable(commandType, commandText, (SqlParameter[])null);
		}

		public DataTable ExecuteDataTable(CommandType commandType, string commandText, params SqlParameter[] commandParameters)
		{
			DataTable oDataTable = new DataTable();

			try
			{
                using (SqlCommand command = CommandFactory(new SqlConnection(_connectionString), commandType, commandText, commandParameters))
				{
					//create the DataAdapter & DataTable
					SqlDataAdapter oDataAdapter = new SqlDataAdapter(command);

					//fill the DataTable using default values for DataTable names, etc.
					oDataAdapter.Fill(oDataTable);

				}

				return oDataTable;
			}
			catch (SqlException sqlex)
			{
				throw sqlex;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public DataTable ExecuteDataTable(SqlConnection sqlConnection, CommandType commandType, string commandText)
		{
            return ExecuteDataTable(sqlConnection, commandType, commandText, (SqlParameter[])null);
		}

		public DataTable ExecuteDataTable(SqlConnection sqlConnection, CommandType commandType, string commandText, params SqlParameter[] commandParameters)
		{
			DataTable oDataTable = new DataTable();

			try
			{
				using (SqlCommand command = CommandFactory(sqlConnection, commandType, commandText, commandParameters))
				{
					//create the DataAdapter & DataTable
					SqlDataAdapter oDataAdapter = new SqlDataAdapter(command);

					//fill the DataTable using default values for DataTable names, etc.
					oDataAdapter.Fill(oDataTable);


				}

				return oDataTable;
			}
			catch (System.Data.SqlClient.SqlException sqlex)
			{
				throw sqlex;
			}
			catch (System.Exception ex)
			{
				throw ex;
			}
		}

		#endregion ExecuteDataTable

		#region ExecuteScalar

		public object ExecuteScalar(CommandType commandType, string commandText)
		{
			return ExecuteScalar(commandType, commandText, (SqlParameter[])null);
		}

		public object ExecuteScalar(CommandType commandType, string commandText, params SqlParameter[] commandParameters)
		{
			//create a command and prepare it for execution
			object retval = null;

			try
			{
				using (SqlCommand command = CommandFactory(new SqlConnection(_connectionString), commandType, commandText, commandParameters))
				{
					retval = command.ExecuteScalar();
				}

				return retval;
			}
			catch (SqlException sqlex)
			{
				throw sqlex;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public object ExecuteScalar(SqlConnection sqlConnection, CommandType commandType, string commandText)
		{
            return ExecuteScalar(sqlConnection, commandType, commandText, (SqlParameter[])null);
		}

        public object ExecuteScalar(SqlConnection sqlConnection, CommandType commandType, string commandText, params SqlParameter[] commandParameters)
		{
			//create a command and prepare it for execution
			object retval = null;// new SqlCommand();
			try
			{
                using (SqlCommand command = CommandFactory(sqlConnection, commandType, commandText, commandParameters))
				{
					//execute the command & return the results
					retval = command.ExecuteScalar();

				}

				return retval;
			}
			catch (SqlException sqlex)
			{
				throw sqlex;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		#endregion ExecuteScalar

    }
}