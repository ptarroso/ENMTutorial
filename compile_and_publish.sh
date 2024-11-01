#!/usr/bin/env bash
Rscript compile.R
git checkout gh-pages
mv docs/* .
rm -r docs
git add .
git commit -m "Last version of book"

