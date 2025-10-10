defmodule KddNotionEx.Types.DateRange do
  @type t() :: {DateTime.t(), DateTime.t()}
  use KddNotionEx.NotionType, ecto_type: {:array, :utc_datetime}

  def load({start_time, end_time}), do: {:ok, [start_time, end_time]}

  def dump([start_time, end_time]), do: {:ok, {start_time, end_time}}

  def includes?({st, et}, {q_st, q_et}) do
    if DateTime.compare(st, q_et) == :eq do
      false
    else
      includes?({st, et}, q_st) or includes?({st, et}, q_et)
    end
  end

  def includes?({st, et}, q) do
    (DateTime.compare(q, st) in [:eq, :gt]) and (DateTime.compare(q, et) in [:lt])
  end

  @spec make_windows(list(t()), Duration.t(), Duration.t(), list(t())) :: list(t())
  def make_windows(available, duration, gap, exclude) do
    Enum.flat_map(available, fn {start_time, end_time} ->
      windows(start_time, duration, end_time, gap)
    end)
    |> Enum.reject(fn w ->
      Enum.any?(exclude, fn a ->
        includes?(a, w) or includes?(w, a)
      end)
    end)
  end

  def windows(start_time, duration, end_time, size) when is_struct(start_time) do
    window_end = DateTime.shift(start_time, duration)
    if DateTime.compare(window_end, end_time) in [:eq, :lt] do
      windows([{start_time, window_end}], duration, end_time, size)
    else
      []
    end
  end

  def windows(acc, duration, end_time, size) when is_list(acc) do
    {prev, _} = hd(acc)
    start_time = DateTime.shift(prev, size)
    window_end = DateTime.shift(start_time, duration)
    if DateTime.compare(window_end, end_time) in [:eq, :lt] do
      windows([{start_time, window_end} | acc], duration, end_time, size)
    else
      Enum.reverse(acc)
    end
  end


end
