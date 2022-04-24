defmodule Koios.DomainGraph do

  defp retrieve_loop(file) do
    receive do
      {:found, domain, context} ->
        IO.write(file, "\"#{context[:source_domain]}\" -- \"#{domain}\"\n")
        retrieve_loop(file)
      _ -> retrieve_loop(file) # ignore anything else
    end
  end

  def generate_dot_file(url, depth, out_file_name) do
    task = Task.async(fn ->
      Koios.Finder.find_on_page(url, depth, self())
      {:ok, file} = File.open(out_file_name, [:write])
      IO.write(file, "strict graph {\n")
      IO.write(file, "node[shape=point]\n")
      retrieve_loop(file)
    end)
    task
  end
end
