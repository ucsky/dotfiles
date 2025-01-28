#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import unittest
from pathlib import Path

import nbformat
from nbformat.v4 import new_code_cell, new_notebook

# Add the script directory to the sys.path to import the function
script_dir = Path(__file__).resolve().parent.parent / "script" / "python3"
sys.path.insert(0, str(script_dir))

from CheckNotebookParams import count_parameters_tags


class TestCheckNbParams(unittest.TestCase):
    def setUp(self):
        """
        Create sample notebooks for testing.
        """
        self.notebook_with_one_tag = new_notebook(
            cells=[
                new_code_cell(
                    source="print('Hello World')", metadata={"tags": ["parameters"]}
                ),
                new_code_cell(source="print('Another cell')"),
            ]
        )
        self.notebook_with_multiple_tags = new_notebook(
            cells=[
                new_code_cell(
                    source="print('Cell 1')", metadata={"tags": ["parameters"]}
                ),
                new_code_cell(
                    source="print('Cell 2')", metadata={"tags": ["parameters"]}
                ),
                new_code_cell(
                    source="print('Cell 3')", metadata={"tags": ["parameters"]}
                ),
            ]
        )
        self.notebook_without_tag = new_notebook(
            cells=[
                new_code_cell(source="print('Hello World')"),
                new_code_cell(source="print('Another cell')"),
            ]
        )

        # Paths for the temporary test notebooks
        self.path_with_one_tag = Path("test_with_one_tag.ipynb")
        self.path_with_multiple_tags = Path("test_with_multiple_tags.ipynb")
        self.path_without_tag = Path("test_without_tag.ipynb")

        # Write these notebooks to temporary files
        with self.path_with_one_tag.open("w") as f:
            nbformat.write(self.notebook_with_one_tag, f)
        with self.path_with_multiple_tags.open("w") as f:
            nbformat.write(self.notebook_with_multiple_tags, f)
        with self.path_without_tag.open("w") as f:
            nbformat.write(self.notebook_without_tag, f)

    def tearDown(self):
        """
        Clean up any files created during the tests.
        """
        self.path_with_one_tag.unlink(missing_ok=True)
        self.path_with_multiple_tags.unlink(missing_ok=True)
        self.path_without_tag.unlink(missing_ok=True)

    def test_notebook_with_one_parameters_tag(self):
        """
        Test that the function correctly counts one 'parameters' tag.
        """
        result = count_parameters_tags(self.path_with_one_tag)
        self.assertEqual(result, 1)

    def test_notebook_with_multiple_parameters_tags(self):
        """
        Test that the function correctly counts multiple 'parameters' tags.
        """
        result = count_parameters_tags(self.path_with_multiple_tags)
        self.assertEqual(result, 3)

    def test_notebook_without_parameters_tag(self):
        """
        Test that the function returns 0 when no 'parameters' tag is present.
        """
        result = count_parameters_tags(self.path_without_tag)
        self.assertEqual(result, 0)


if __name__ == "__main__":
    unittest.main()
