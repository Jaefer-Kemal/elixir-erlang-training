
defmodule Geometry do
    @moduledoc """
        Computer all the possible Geometry
    """
    @doc """
    Calculate the area of a rectangle standard notation
 """
    def rectangle_area(a, b) do

        (a * b)
    end

    @doc """
    Calculate the perimeter of a rectangle using infix notation
   """
    def rectangle_perimeter(a, b ), do: 2 * (a + b)
end

defmodule MyMath do
    def add(a, b \\ 0), do: sum(a, b)
    defp sum(a, b), do: a + b
end

defmodule ListModule do
         def list_len(list) do
         list_len(0, list)
         end
         defp list_len(len, []) do
         len
         end

         defp list_len(len, [head | tail]) do
         list_len(len + 1, tail)
         end
         end
