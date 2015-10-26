defmodule Database.Worker do
  use GenServer
  @timeout 6000

  @moduledoc """
  Contains a connection to the database and handles running queries.
  Each of these servers is managed by the Pool in supervisor
  """

  def start_link(args\\[]) do
    arguments = args |> Enum.into %{}
    GenServer.start_link(__MODULE__, arguments)
  end

  def query(pid, query, args \\ []) do
    GenServer.call(pid, {:query, query, args}, @timeout)
  end


  ######################################################################
  # Genserver callbacks ..
  ######################################################################
  def init(arguments) do
    Process.flag(:trap_exit, true)
    # Create a connection to the database ...
    {:ok, pid} = Postgrex.Connection.start_link(hostname: arguments.host,
                                                                 username: arguments.dbuser,
                                                                 password: arguments.dbpass,
                                                                 database: arguments.database,
                                                                 port: arguments.port,
                                                                 extensions: [{Postgrex.Extensions.JSON, library: Poison},
                                                                                     {Geo.PostGIS.Extension, library: Geo}])

    Postgrex.Connection.query!(pid, "set statement_timeout to 5000;", [])
    {:ok, pid}
  end

  def terminate(_reason, connection) do
    Postgrex.Connection.stop(connection)
    :ok
  end

  def handle_call({:query, query, arguments}, _from, connection) do
    results = Postgrex.Connection.query(connection, query, arguments, [timeout: @timeout])
    {:reply, results, connection}
  end

  def handle_info({:EXIT, _conn, _reason}, connection) do
    disconnect(connection)
    {:noreply, connection}
  end

 defp disconnect(connection) do
    _ = connection && Connection.shutdown(connection)
    nil
  end

end
