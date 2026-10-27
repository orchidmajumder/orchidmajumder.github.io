# Builds resume/resume.tex straight into Hugo's static/, so the site serves the latest PDF.
# Run from the repo root:  latexmk    (or latexmk -pvc to rebuild on save)
@default_files = ('resume/resume.tex');
$pdf_mode = 1;
$out_dir = 'static';
$aux_dir = 'resume/build';
