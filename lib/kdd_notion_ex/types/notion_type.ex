defmodule KddNotionEx.NotionType do
  defmacro __using__(ecto_type: ecto_type) do
    quote do
      @behaviour Ecto.Type
      def embed_as(_), do: :self
      def equal?(term1, term2), do: term1 == term2
      def type(), do: unquote(ecto_type)

      def cast(%{"type" => _} = value) do
        {:ok, KddNotionEx.Transform.parse_property(value)}
      end

      def cast(value), do: {:ok, value}

      def load(value), do: {:ok, value}

      def dump(value), do: {:ok, value}

      defoverridable(cast: 1, load: 1, dump: 1)
    end
  end
end
