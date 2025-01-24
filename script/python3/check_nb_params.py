#!/usr/bin/env python
import os
import nbformat
import typer
from pathlib import Path
from tabulate import tabulate

app = typer.Typer()

def count_parameters_tags(notebook_path: Path) -> int:
    """
    Count the number of cells with the 'parameters' tag in a Jupyter notebook.
    """
    with notebook_path.open() as f:
        nb = nbformat.read(f, as_version=4)

    count = 0
    for cell in nb.cells:
        if cell.cell_type == 'code':
            if 'parameters' in cell.metadata.get('tags', []):
                count += 1
    return count

@app.command()
def check_directory(directory: Path):
    """
    Check all Jupyter notebooks in the specified directory for the 'parameters' tag
    and output a table with the results.
    """
    if not directory.is_dir():
        typer.echo(f"Error: {directory} is not a valid directory.")
        raise typer.Exit(code=1)

    notebooks = list(directory.glob('*.ipynb'))

    if not notebooks:
        typer.echo(f"No Jupyter notebooks found in the directory {directory}.")
        raise typer.Exit(code=0)

    # Prepare the table data
    table_data = []
    for notebook in notebooks:
        count = count_parameters_tags(notebook)
        table_data.append([notebook.name, count])

    # Output the table
    table_headers = ["Notebook", "Number of 'parameters' Tags"]
    typer.echo(tabulate(table_data, headers=table_headers, tablefmt="grid"))

if __name__ == "__main__":
    app()
