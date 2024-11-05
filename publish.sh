#!/usr/bin/env bash
git checkout gh-pages
rm -r ENM_tutorial_files
rm -r assets
mv docs/* .
rm -r docs
git add .
git commit -m "Last version of book"
