#!/usr/bin/env julia
# Convert a jldoctest .md file to a Jupyter notebook (.ipynb)
# Usage: julia md_to_notebook.jl path/to/file.md [path/to/file.ipynb]

using JSON3

function md_to_notebook(md_file, out_file = joinpath(dirname(md_file), "..", "..", "notebooks", replace(basename(md_file), r"\.md$" => ".ipynb")))
    src = read(md_file, String)

    # Extract the jldoctest block
    m = match(r"```jldoctest[^\n]*\n(.*?)```"s, src)
    if m === nothing
        error("No jldoctest block found in $md_file")
    end
    block = m.captures[1]

    lines = split(block, '\n')

    cells = []

    i = 1
    while i <= length(lines)
        line = lines[i]

        if startswith(line, "julia> ")
            # Collect this input block (may span multiple lines)
            code = line[8:end]  # strip "julia> "
            i += 1
            # Continuation lines have no prefix
            while i <= length(lines) && !startswith(lines[i], "julia> ") && !isempty(lines[i]) && !startswith(lines[i], "```")
                next = lines[i]
                # If it looks like output (no indent, not empty), stop
                if !startswith(next, " ") && !startswith(next, "\t") && i > 1
                    # Check if previous line ended with something that allows continuation
                    # Simple heuristic: if code ends with operator or open bracket, continue
                    stripped = rstrip(code)
                    if !endswith(stripped, r"[,\(\[\{\\]") && !endswith(stripped, "=")
                        break
                    end
                end
                code *= "\n" * next
                i += 1
            end
            # Skip output lines until next julia> or end
            while i <= length(lines) && !startswith(lines[i], "julia> ")
                i += 1
            end
            push!(cells, (type="code", source=code))
        else
            i += 1
        end
    end

    # Build notebook JSON
    nb_cells = map(cells) do cell
        Dict(
            "cell_type" => "code",
            "execution_count" => nothing,
            "metadata" => Dict("language" => "julia"),
            "outputs" => [],
            "source" => [cell.source]
        )
    end

    nb = Dict(
        "cells" => nb_cells,
        "metadata" => Dict(
            "kernelspec" => Dict(
                "display_name" => "Julia",
                "language" => "julia",
                "name" => "julia"
            ),
            "language_info" => Dict("name" => "julia")
        ),
        "nbformat" => 4,
        "nbformat_minor" => 5
    )

    if isfile(out_file)
        print("\"$out_file\" already exists. Overwrite? [y/N] ")
        answer = readline()
        if !occursin(r"^[yY]", answer)
            println("Aborted.")
            return nothing
        end
    end

    open(out_file, "w") do f
        JSON3.pretty(f, nb)
    end

    println("Written: $out_file  ($(length(cells)) cells)")
    return out_file
end

if abspath(PROGRAM_FILE) == @__FILE__
    isempty(ARGS) && error("Usage: julia md_to_notebook.jl file.md [output.ipynb]")
    md_to_notebook(ARGS[1], length(ARGS) >= 2 ? ARGS[2] : joinpath(dirname(ARGS[1]), "..", "..", "notebooks", replace(basename(ARGS[1]), r"\.md$" => ".ipynb")))
end
