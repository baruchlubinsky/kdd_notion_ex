defmodule KddNotionEx.Types.DateRangeTest do
  use ExUnit.Case, async: true

  alias KddNotionEx.Types.DateRange

  setup do
    st = DateTime.from_naive!(~N[2023-01-01 00:00:00], "Etc/UTC")
    et = DateTime.from_naive!(~N[2023-01-10 00:00:00], "Etc/UTC")
    q_st = DateTime.from_naive!(~N[2023-01-03 00:00:00], "Etc/UTC")
    q_et = DateTime.from_naive!(~N[2023-01-05 00:00:00], "Etc/UTC")
    q_out = DateTime.from_naive!(~N[2023-01-15 00:00:00], "Etc/UTC")
    {:ok, st: st, et: et, q_st: q_st, q_et: q_et, q_out: q_out}
  end

  test "includes? returns true when both query times are inside", %{st: st, et: et, q_st: q_st, q_et: q_et} do
    assert DateRange.includes?({st, et}, {q_st, q_et}) == true
  end

  test "includes? returns true when only start query is inside", %{st: st, et: et, q_st: q_st, q_out: q_out} do
    assert DateRange.includes?({st, et}, {q_st, q_out}) == true
  end

  test "includes? returns false when both query times are outside", %{st: st, et: et, q_out: q_out} do
    before = DateTime.from_naive!(~N[2022-12-31 00:00:00], "Etc/UTC")
    assert DateRange.includes?({st, et}, {before, q_out}) == false
  end

  test "includes? returns true when single query is inside", %{st: st, et: et, q_st: q_st} do
    assert DateRange.includes?({st, et}, q_st) == true
  end

  test "includes? returns false when single query is outside", %{st: st, et: et, q_out: q_out} do
    assert DateRange.includes?({st, et}, q_out) == false
  end

  test "includes? returns false when single query is equal to end time", %{st: st, et: et} do
    assert DateRange.includes?({st, et}, et) == false
  end

  test "includes? returns false for consecutive time spans", %{st: st, et: et, q_out: q_out} do
    assert DateRange.includes?({st, et}, {et, q_out}) == false
  end

end
