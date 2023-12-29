import glob

from tree_sitter import Language

languages = [
    './src/vendor/tree-sitter-java',
]

Language.build_library(
    # Store the library in the directory
    './src/build/py-tree-sitter-languages.so',
    # Include one or more languages
    languages
)
