defmodule Phoenix.LiveView.AsyncResult do
  @moduledoc ~S'''
  Provides a data structure for tracking the state of an async assign.

  See the `Async Operations` section of the `Phoenix.LiveView` docs for more information.

  ## Fields

    * `:ok?` - When true, indicates the `:result` has been set successfully at least once.
    * `:loading` - The current loading state
    * `:failed` - The current failed state
    * `:result` - The successful result of the async task
    * `:idle?` - When true, indicates the async assign has not been initiated yet.
  '''

  defstruct ok?: false,
            loading: nil,
            failed: nil,
            result: nil,
            idle?: true

  alias Phoenix.LiveView.AsyncResult

  @doc """
  Creates an async result in loading state.

  ## Examples

      iex> result = AsyncResult.loading()
      iex> result.loading
      true
      iex> result.ok?
      false
      iex> result.idle?
      false

  """
  def loading do
    %AsyncResult{loading: true, idle?: false}
  end

  @doc """
  Updates the loading state.

  When loading, the failed state will be reset to `nil`, and `idle?` will be set to `false`.

  ## Examples

      iex> result = AsyncResult.loading(%{my: :loading_state})
      iex> result.loading
      %{my: :loading_state}
      iex> result.idle?
      false
      iex> result = AsyncResult.loading(result)
      iex> result.loading
      true

  """
  def loading(%AsyncResult{} = result) do
    %AsyncResult{result | loading: true, failed: nil, idle?: false}
  end

  def loading(loading_state) do
    %AsyncResult{loading: loading_state, failed: nil, idle?: false}
  end

  @doc """
  Updates the loading state of an existing `async_result`.

  When loading, the failed state will be reset to `nil`, and `idle?` will be set to `false`.
  If the result was previously `ok?`, both `result` and `loading` will be set.

  ## Examples

      iex> result = AsyncResult.loading()
      iex> result = AsyncResult.loading(result, %{my: :other_state})
      iex> result.loading
      %{my: :other_state}
      iex> result.idle?
      false

  """
  def loading(%AsyncResult{} = result, loading_state) do
    %AsyncResult{result | loading: loading_state, failed: nil, idle?: false}
  end

  @doc """
  Updates the failed state.

  When failed, the loading state will be reset to `nil`, and `idle?` will be set to `false`.
  If the result was previously `ok?`, both `result` and `failed` will be set.

  ## Examples

      iex> result = AsyncResult.loading()
      iex> result = AsyncResult.failed(result, {:exit, :boom})
      iex> result.failed
      {:exit, :boom}
      iex> result.loading
      nil
      iex> result.idle?
      false

  """
  def failed(%AsyncResult{} = result, reason) do
    %AsyncResult{result | failed: reason, loading: nil, idle?: false}
  end

  @doc """
  Creates a successful result.

  The `:ok?` field will also be set to `true` to indicate this result has
  completed successfully at least once, regardless of future state changes.
  The `:idle?` field will be set to `false`.

  ## Examples

      iex> result = AsyncResult.ok("initial result")
      iex> result.ok?
      true
      iex> result.result
      "initial result"
      iex> result.idle?
      false

  """
  def ok(value) do
    %AsyncResult{
      failed: nil,
      loading: nil,
      ok?: true,
      result: value,
      idle?: false
    }
  end

  @doc """
  Updates the successful result.

  The `:ok?` field will also be set to `true` to indicate this result has
  completed successfully at least once, regardless of future state changes.
  When ok'd, the loading and failed state will be reset to `nil`, and `idle?` will be set to `false`.

  ## Examples

      iex> result = AsyncResult.loading()
      iex> result = AsyncResult.ok(result, "completed")
      iex> result.ok?
      true
      iex> result.result
      "completed"
      iex> result.loading
      nil
      iex> result.idle?
      false

  """
  def ok(%AsyncResult{} = result, value) do
    %AsyncResult{
      result
      | failed: nil,
        loading: nil,
        ok?: true,
        result: value,
        idle?: false
    }
  end

  @doc """
  Creates an async result in the `idle?` state.

  This can be useful to explicitly represent that the async assign has not been initiated yet.

  ## Examples

      iex> result = AsyncResult.idle()
      iex> result.idle?
      true
      iex> result.ok?
      false
      iex> result.loading
      nil
      iex> result.failed
      nil

  """
  def idle do
    %AsyncResult{idle?: true, ok?: false, loading: nil, failed: nil, result: nil}
  end
end
