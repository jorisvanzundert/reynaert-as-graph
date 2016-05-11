# Reynaert as Graph

This is the code base that was used in an experiment in slow coding and computer literacy. The [docs](doc/index.html) contain technical documentation primarily. A more scholarly oriented introduction and discussion on this project you will find in the accompanying Jupyter Notebook ["Slow Programming & Close Reading"](notebook/Slow%20Programming%20%26%20Close%20Reading.ipynb).

The code was developed specifically to parse the OCRed text of the scholarly edition of "Of Reynaert the Fox" by André Bouwman and Bart Besamusca, and to represent the text of the Dutch Medieval novel as an OO model.

In [lib/ocr_parser](lib/ocr_parser.rb) you will find the {OCRParser} class, which is probably a good place to start exploring this package. The OCRParser is setup according to a visitor pattern which should allow—with some limited coding—for reuse and adaption for other projects.
